function [optimized_vars, resnorm, residual, exitflag, output] = estimate_scene_registration( ...
    K, rand_init, T_W_S_init, T_C_W_cell, centers, ellipse_pts, radii, pose_origin, colmap_scale_estimate)
% Purpose: solves the nonlinear least squares problem, minimizing the
% algebraic error to estimate the scene registration, as explained in the master
% thesis and semester project reports.

% Input:
% - K: calibration matrix
% - rand_init: 0 for using initial estimates, 1 for random initialization
% - T_W_S_init: initial estimate for scene-to-world transformation (scene
% registration)
% - T_C_W_cell: cell of world-to-camera transformations, i.e. camera poses
% coming from ROBOT or from SFM
% - centers: 3D centers of the spheres, expressed in local scene reference
% frame S
% - ellipse_pts: sample 2D points on ellipse outlines, in a cell of shape
% (N*M) where N is the number of frames and M the number of spherical
% markers in the scene
% - radii: radii of the M spheres
% - pose_origin: "SFM" or "ROBOT", depending on where the camera poses come
% from
% - colmap_scale_estimate: initial estimate for the colmap scale

% Output:
% optimized_vars: [eul1 eul2 eul3 x y z scale] if poses come from SFM (pose_origin = "SFM") and
% [eul1 eul2 eul3 x y z] if poses come from robot (pose_origin = "ROBOT").
% resnorm, from lsqnonlin
% residual, from lsqnonlin
% exitflag, from lsqnonlin
% output, from lsqnonlin

nb_frames = numel(T_C_W_cell);
nb_spheres = size(centers, 1);

% Get nb of sampled points for each sphere and each frame 
nb_points = zeros(nb_frames, nb_spheres); 
if size(radii, 1) == 1 & size(radii, 2) == 1
    radii = ones(size(centers, 1), 1)*radii;
end

% Get the projection matrices
P_cell = cell(nb_frames, 1);
for i = 1:nb_frames
    T = T_C_W_cell{i};
    T = T(1:3,:); %[R|t]
    P_cell{i} = K*T; %K[R|t]
    for j = 1:nb_spheres
        nb_points(i,j) = size(ellipse_pts{i,j}, 1);
    end
end

% Define the optimization options 
options = optimoptions('lsqnonlin', ...
               'Algorithm', 'levenberg-marquardt', ...
               'Display', 'final', ...
               'MaxIterations', 400, ...
               'FunctionTolerance', 1e-6, ...
               'SpecifyObjectiveGradient', false, ...
               'StepTolerance', 1e-6, ...
               'OptimalityTolerance', 1e-6, ...
               'MaxFunctionEvaluations', 400, ...
               'Jacobian', 'off', ...
               'CheckGradients', false, ...
               'DiffMinChange', 1e-8, ...
               'DiffMaxChange', 0.1, ...
               'FiniteDifferenceType', 'forward', ...
               'ScaleProblem', 'none', ...
               'UseParallel', false);

if rand_init == 1
    %initial_guess = [360*rand(3,1)-180;rand(3,1);360*rand(3,1)-180;rand(3,1)];
    if pose_origin == "ROBOT"
        initial_guess = [0,0,0,0,0,0];
    elseif pose_origin == "SFM"
        initial_guess = [0,0,0,0,0,0,1];
    else 
        error('Pose origin has to be either SFM or COLMAP')
    end
elseif rand_init == 0
    if pose_origin == "ROBOT"
        initial_guess = vecFromMat(T_W_S_init);
    elseif pose_origin == "SFM"
        initial_guess = [vecFromMat(T_W_S_init); colmap_scale_estimate];
    else 
        error('Pose origin has to be either ROBOT or SFM')
    end
else 
    error('rand_init has to be either 0 or 1')
end

% Define the lower and upper bounds
lb = -Inf(size(initial_guess));
ub = Inf(size(initial_guess));

% Call lsqnonlin to perform the optimization
if pose_origin == "ROBOT"
    [optimized_vars, resnorm, residual, exitflag, output] = lsqnonlin(@(x) costFunction ...
        (x, P_cell,centers, ellipse_pts, nb_points, nb_spheres, nb_frames, radii), initial_guess, lb, ub, options);
elseif pose_origin == "SFM"
    [optimized_vars, resnorm, residual, exitflag, output] = lsqnonlin(@(x) costFunction2 ...
        (x, K, T_C_W_cell, centers, ellipse_pts, nb_points, nb_spheres, nb_frames, radii), initial_guess, lb, ub, options);
end


% Define the objective function
function residual = costFunction(x, P_cell, centers, clicked_pts, nb_points, nb_spheres, nb_frames, radii)
current_idx = 1;
residual = zeros(sum(nb_points(:)), 1);
T_K_S = [eul2rotm(deg2rad([x(1), x(2), x(3)]))' [x(4); x(5); x(6)]; 0 0 0 1];

for j = 1:nb_spheres
    %express center in Kuka frame
    C = T_K_S * [centers(j,:) 1]';
    
    %define quadric
    Q = [1 0 0 -C(1);
    0 1 0 -C(2);
    0 0 1 -C(3);
    -C(1) -C(2) -C(3) C(1)^2+C(2)^2+C(3)^2-radii(j)^2];

    for i = 1:nb_frames
        if nb_points(i,j) == 0
            continue
        else
            E_inv = P_cell{i}/Q*P_cell{i}';
            E = inv(E_inv);
            E = E*sqrt(1/det(E(1:2,1:2))); %normalize E
            dist = 0;
            for k = 1:nb_points(i,j)
                %obtain conic matrix E of ellipse 
                pts = clicked_pts{i,j}';
                residual(current_idx) = [pts(:,k)' 1]*E*[pts(:,k);1]; % pt'*E*pt = 0
                current_idx = current_idx + 1;
                
                dist = dist + rosin_dist(ellipse2param(E), pts(:,k), [6336, 9504]);
                
            end
            errors(i,j) = dist/size(pts, 2);
        end
    end
end
mean_err = mean(errors(:)) % just indicative
end

function residual = costFunction2(x, K, T_C_K_cell, centers, clicked_pts, nb_points, nb_spheres, nb_frames, radii)
current_idx = 1;
residual = zeros(sum(nb_points(:)), 1);
T_K_S = [eul2rotm(deg2rad([x(1), x(2), x(3)]))' [x(4); x(5); x(6)]; 0 0 0 1];
scale = x(7);

for j = 1:nb_spheres
    %express center in Kuka frame
    C = T_K_S * [centers(j,:) 1]';
    
    %define quadric
    Q = [1 0 0 -C(1);
    0 1 0 -C(2);
    0 0 1 -C(3);
    -C(1) -C(2) -C(3) C(1)^2+C(2)^2+C(3)^2-radii(j)^2];

    for i = 1:nb_frames
        if nb_points(i,j) == 0
            continue
        else
            T_K_C = inv(T_C_K_cell{i});
            T_K_C(1:3, 4) = scale*T_K_C(1:3, 4);
            T = inv(T_K_C);
            T = T(1:3,:); %[R|t]
            P = K*T;
            dist = 0;
            for k = 1:nb_points(i,j)
                %obtain conic matrix E of ellipse 
                E_inv = P/Q*P';
                pts = clicked_pts{i,j}';
                residual(current_idx) = [pts(:,k)' 1] /E_inv*[pts(:,k);1]; % pt'*E*pt = 0
                current_idx = current_idx + 1;
                E = inv(E_inv);
                dist = dist + rosin_dist(ellipse2param(E), pts(:,k), [6336, 9504]);
                
            end
            errors(i,j) = dist/size(pts, 2);
        end
    end
end
mean_err = mean(errors(:)) % just indicative
end
end