function [optimized_vars, resnorm, residual, exitflag, output] = estimate_robot_camera_calibration( ...
    T_EE_C_est, T_W_CH_est, T_W_EE_cell, corners, pts3D, K, rand_init)

% Purpose: solve nonlinear least squares problem to estimate the end
% effector to camera pose

% Input:
% - T_EE_C_est: initial estimate for the camera to end effector pose (4x4
% euclidean matrix)
% - T_W_CH_est: initial estimate for the checkerboard to world pose (4x4
% euclidean matrix)
% - T_W_EE_cell: cell of 4x4 euclidean matrices giving the robot end
% effector poses expressed in world (= robot base) reference frame
% - corners: array containing all the stacked checkerboard corner coordinates for all
% images
% - pts3D: 3D coordinates of the checkerboard corners
% - K: camera calibration matrix
% - rand_init: boolean (=0 if you want to use initial estimates, 1 for
% random initialization)

% Output:
% [optimized_vars, resnorm, residual, exitflag, output] from lsqnonlin

    if size(corners, 1)~= size(pts3D, 2)
        error('There must be as many 3dpoints as 2d corners')
    end
    % pts are the list of 2D reprojected corners
    if rand_init ~= 0 && rand_init ~= 1
        error('rand_init must be 0 or 1 ');
    end
    
    if rand_init == 0
        vec1 = rad2deg(rotm2eul(T_EE_C_est(1:3,1:3)'));
        vec2 = rad2deg(rotm2eul(T_W_CH_est(1:3,1:3)'));
        phi1 = vec1(1);
        theta1 = vec1(2);
        psi1 = vec1(3);
        phi2 = vec2(1);
        theta2 = vec2(2);
        psi2 = vec2(3);
        initial_guess = [phi1; theta1; psi1; T_EE_C_est(1:3,4); phi2; theta2; psi2; T_W_CH_est(1:3,4)]; 
    else
        initial_guess = [360*rand(3,1)-180;rand(3,1);360*rand(3,1)-180;rand(3,1)];
    end

    
    % Define the lower and upper bounds
    lb = -Inf(size(initial_guess));
    ub = Inf(size(initial_guess));
    
    % Define the optimization options 
    options = optimoptions('lsqnonlin','Display', 'iter'); % choose 'off' or 'iter' 
    % Set the maximum number of iterations
    % options.OptimalityTolerance = 1e-10;  % Termination tolerance for optimality
    % options.StepTolerance = 1e-10;  % Termination tolerance for step size
    % options.FunctionTolerance = 1e-10;

    iter = 0; % for debug 
    % Call lsqnonlin to perform the optimization
    [optimized_vars, resnorm, residual, exitflag, output] = lsqnonlin(@(x) costFunction ...
        (x, T_W_EE_cell,corners, pts3D, K, iter), initial_guess, lb, ub, options);
end

% Define the objective function
function residuals = costFunction(x, T_W_EE_cell, corners, pts3D, K, iter)
    iter = iter + 1;
    N = numel(T_W_EE_cell); % number of frames we are optimizing on
    M = size(corners, 1);
    % Extract transformation matrix X from the decision variables in x
    T_EE_C_est = [eul2rotm(deg2rad([x(1), x(2), x(3)]))' [x(4); x(5); x(6)];0 0 0 1];
    T_W_CH_est = [eul2rotm(deg2rad([x(7), x(8), x(9)]))' [x(10); x(11); x(12)];0 0 0 1];
    residuals = zeros(N*M*2,1);
    for i = 1:N
        for j = 1:M
            T_C_W = inv(T_W_EE_cell{i}*T_EE_C_est);
            P = T_C_W(1:3,:); % the world-to-camera projection matrix
            reproj_corner = K*P*T_W_CH_est*pts3D(:,j);
            reproj_corner = reproj_corner/reproj_corner(end); % normalize
            reproj_corner = reproj_corner(1:2); % get 2d coordinate from the homogeneous point 
            residuals(M*2*(i-1) + 2*(j-1) + 1 : M*2*(i-1) + 2*(j-1) + 2) = corners(j,:,i)' - reproj_corner;
        end
    end
end