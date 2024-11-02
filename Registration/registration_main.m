clear; close all; clc
addpath("..\utils\")
addpath("registration_functions\")

% Define paths
path_to_ellipse_estimates = 'registration_data\ellipse_params.mat';
images_path = 'registration_data\images'; 
path_to_sfm_poses = 'registration_data\sfm_poses.csv'; % raw sfm poses, not in metric scale
path_to_robot_poses = 'registration_data\robot_poses.csv'; % robot end effector poses, in metric scale
% convention for poses rows is: [x, y, z, qx, qy, qz, qw]

% Paths to camera calibration variables computed in calibration_main
path_to_T_EE_C = '..\Calibration\calibration_output\T_EE_C.mat'; % end effector to camera calibration
cameraParams = load('..\Calibration\calibration_output\cameraParams').cameraParams; % cameraParams determined in camera calibration

sam_ellipses = load(path_to_ellipse_estimates).ellipse_params;
K = cameraParams.K;
nb_pts_per_ellipse = 200; %number of points on the ellipse outline used in the minimization for the scene registration
plot_el_extract_ = 1; % choose 0 to avoid plotting the ellipse extraction steps, otherwise 1

% Extract camera poses in world reference frame
camera_pose_type = "SFM"; % Choose to use SFM poses or ROBOT poses

if camera_pose_type == "SFM"
    % Determine initial sfm scale estimate by finding the similarity
    % transformation between the sfm poses and the robot poses
    [~, ~, scale_sfm, ~] = estimate_similarity_transform(path_to_sfm_poses, path_to_robot_poses, path_to_T_EE_C, 0);
    poseData = table2array(readtable(path_to_sfm_poses));
    nb_frames = size(poseData, 1);

    % Extract T_W_C_cell, the cell of camera poses expressed in the world
    % reference frame W
    T_W_C_cell = cell(nb_frames,1);
    for i = 1:nb_frames
        translation = scale_sfm*poseData(i, 1:3); %scale the translations
        quaternion = [poseData(i, end), poseData(i, 4:6)];    
        rotCam = quat2rotm(quaternion);
        centerCam = -rotCam'*translation';
        T = [rotCam' centerCam;0 0 0 1];
        T_W_C_cell{i} = T;
    end
    
elseif camera_pose_type == "ROBOT"
    poseData = readtable(path_to_robot_poses);
    poseData = table2array(poseData);
    nb_frames = size(poseData, 1);
    T_W_C_cell = cell(nb_frames,1);
    T_EE_C = load(path_to_T_EE_C).T_EE_C_opti;
    
    T_W_EE_cell = cell(nb_frames, 1);
    for i = 1:nb_frames
        translation = 0.001* poseData(i, 1:3);
        quaternion = [poseData(i, end), poseData(i, 4:6)];    
        T_W_EE = [quat2rotm(quaternion) translation';0 0 0 1];
        T_W_EE_cell{i} = T_W_EE;
        T_W_C_cell{i} = T_W_EE*T_EE_C;
    end
else
    error('Poses have to be either SFM or ROBOT')
end

% 3D centers extracted from the scanned model (CT or optical scan)
centers = 1e-3*[188.20 46.82 32.37;
    130.73 116.26 -0.88;
    26.34 184.60 7.01;
    -46.32 221.15 -21.30;
    -175.93 197.90 -1.42;
    -219.37 130.27 6.24;
    -199.62 -28.53 16.50;
    -134.86 -113.67 45.84;
    -7.93 -174.71 95.31;
    167.08 -109.63 91.82;
    -113.53 82.18 15.40;
    -48.14 75.04 5.98;
    -71.22 10.71 20.81;
    -21.11 -5.14 26.86;
    -57.58 -73.97 20.24;
    49.20 44.48 17.65;
    77.11 -10.77 48.90;
    28.83 -60.29 65.06];

radii = 1e-3*15; % in meters, radii are assumed the same for all spheres
nb_markers = size(centers, 1);

% colors for plotting results
colors =[
    0, 0, 1;   % Blue
    0, 1, 0;   % Green
    1, 0, 0;   % Red
    0, 1, 1;   % Cyan
    1, 0, 1;   % Magenta
    1, 1, 0;   % Yellow
    0, 0.5, 0; % Dark Green
    0, 0, 0.5; % Dark Blue
    0.5, 0, 0.5; % Dark Purple
    0, 0.5, 0.5; % Teal
    0.5, 0.5, 0; % Olive
    1, 0, 1;   % Magenta
    1, 1, 0;   % Yellow
    0, 0.5, 0; % Dark Green
    0, 0, 0.5; % Dark Blue
    0.5, 0, 0.5; % Dark Purple
    0, 0.5, 0.5; % Teal
    0.5, 0.5, 0; % Olive
];


%% Order the centers and radii
%!!!! This part is still a draft, does not work but shows the idea !!!!
% 
% centers_undist = zeros(size(sam_ellipses, 1), size(sam_ellipses, 2));
% for i = 1:nb_frames
%     for j = 1:nb_markers
%         centers_undist(i, j, :) = undistortPoints([sam_ellipses(i, j, 1), sam_ellipses(i,j,2)], cameraParams);
%     end
% end
% combinations = get_all_combinations(nb_markers,4);
% sam_ellipses_ordered = zeros(size(sam_ellipses));
% for i = 1:nb_frames
%     order = match_centers(squeeze(centers_undist(1,:,:)), centers, cameraParams, combinations);
%     sam_ellipses_ordered(i, :, :) = sam_ellipses(i, order);
% end
% 
% for i = 1:nb_frames
% 
% end
% % Plot centers on top of images for checking of coordinate frames etc
% for i = 1:nb_frames
%     figure;
%     axis_handle = axes;
%     imshow(imread(fullfile(images_path, [num2str(i) '.jpg'])));
%     hold on
%     for j = 1:nb_markers
%         plot(sam_ellipses(i,j,1), sam_ellipses(i,j,2), 'r*');
%         hold on
%         el = struct( ...
%             'a',sam_ellipses(i,j,3),...
%             'b',sam_ellipses(i,j,4),...
%             'phi',sam_ellipses(i,j,5),...
%             'X0_in',sam_ellipses(i,j,1),...
%             'Y0_in',sam_ellipses(i,j,2));
%         plotEllipse(inv(param2ellipse(el)), colors(j, :), [cameraParams.ImageSize(2), cameraParams.ImageSize(1)])
%     end
% end

%% Get ellipse sample points
% close all % close figures before this, so that the following figure numbers work
% disp('Computing edge detection, ellipse fitting and sampling points on ellipse outlines...')
% E_samples_full = cell(nb_frames, nb_markers); % all edge points inside envelope
% E_samples_ransac = cell(nb_frames, nb_markers); % all ransac inlier edge points
% E_samples_even = cell(nb_frames, nb_markers); % evenly spread points sampled on the ransac fitted ellipse
% E_samples_subset = cell(nb_frames, nb_markers); % subset of nb_pts_per_ellipse ransac inlier edge points for each ellipse
% 
% el_fit_error = ones(nb_frames, nb_markers);%keeps track of the ellipse fitting error
% 
% for i = 1:nb_frames
%     i % to keep track of the advancement
%     img = imread(fullfile(images_path, [num2str(i) '.jpg'])); 
%     gray_img = rgb2gray(img);
%     edges_outside = edge(gray_img, 'canny', [0.1 0.2]); % canny thresholds need to be tuned for different exposures, outside is darker
%     edges_inside = edge(gray_img, 'canny', [0.05 0.1]); % inside is more exposed
% 
%     [rows_out, cols_out] = find(edges_outside);
%     edges_coords_out = [cols_out, rows_out];
%     [rows_in, cols_in] = find(edges_inside);
%     edges_coords_in = [cols_in, rows_in];
% 
%     if plot_el_extract_ == 1
%         % Plots for edges
%         figure(3*i-2);
%         imshow(img); hold on;
%         plot(cols_out, rows_out, 'r*', MarkerSize=1)
%         plot(cols_in, rows_in, 'bo', MarkerSize=1)
%         axis equal; grid on;
% 
%         % Plots for envelopes
%         figure(3*i-1); axis_handle = axes;
%         imshow(img); hold on;
% 
%         % Plots for ransac inliers
%         figure(3*i); 
%         imshow(img);
%         hold on;
%     end
% 
%     for j = 1:size(centers, 1)
%         % ellipse structure from the initial approximation (from Nino)
%         el = struct( ...
%             'a',sam_ellipses(i,j,3),...
%             'b',sam_ellipses(i,j,4),...
%             'phi',sam_ellipses(i,j,5),...
%             'X0_in',sam_ellipses(i,j,1),...
%             'Y0_in',sam_ellipses(i,j,2));
% 
%         % First, for a given point that corresponds to the center of an arbitrarily
%         % chosen ellipse
%         env_size_o = 1.1; %define the ratio size of the envelope
%         env_size_i = 1.1;
% 
%         % Create structures for inner and outer ellipses
%         el_o = struct( ...
%                 'a',el.a*env_size_o,...
%                 'b',el.b*env_size_o,...
%                 'phi',el.phi,...
%                 'X0_in',el.X0_in,...
%                 'Y0_in',el.Y0_in );%outer ellipse
% 
%         el_i = struct( ...
%                 'a',el.a/env_size_i,...
%                 'b',el.b/env_size_i,...
%                 'phi',el.phi,...
%                 'X0_in',el.X0_in,...
%                 'Y0_in',el.Y0_in );%inner ellipse
% 
%         % Conic matrices for inner and outer ellipses
%         E_o = param2ellipse(el_o);
%         E_i = param2ellipse(el_i);
% 
%         % Get edge points inside envelope
%         %pt'*E_o*pt>0 & pt'*E_i*pt<0 % condition for a
%         %point pt to be outside of E_i and inside of E_o.
%         if j < 11 %for the registration spheres, in the dark outer part of the image
%             edges_aug = [edges_coords_out, ones(size(edges_coords_out ,1),1)]; % augmented coordinates for edges
%             in_env = (sum((edges_aug*E_o).*edges_aug, 2)) > 0 & (sum((edges_aug*E_i).*edges_aug, 2)) < 0;
%             el_edges_coords = edges_coords_out(in_env == 1, :);
%         else % for the evaluation sheres, in the center part of the image
%             edges_aug = [edges_coords_in, ones(size(edges_coords_in ,1),1)]; % augmented coordinates for edges
%             in_env = (sum((edges_aug*E_o).*edges_aug, 2)) > 0 & (sum((edges_aug*E_i).*edges_aug, 2)) < 0;
%             el_edges_coords = edges_coords_in(in_env == 1, :);
%         end
% 
%         if plot_el_extract_ == 1
%             figure(3*i-1);
%             h = ellipse(el.a, el.b, el.phi, el.X0_in, el.Y0_in,'m'); % approximate ellipse from SAM
%             h_o = ellipse(el_o.a, el_o.b, el_o.phi, el_o.X0_in, el_o.Y0_in,'y'); % outer envelope boundary ellipse
%             h_i = ellipse(el_i.a, el_i.b, el_i.phi, el_i.X0_in, el_i.Y0_in,'c'); % inner envelope boundary ellipse
%             plot(el_edges_coords(:,1),el_edges_coords(:,2), 'r*', MarkerSize=3);
%         end
% 
%         E_samples_full{i,j} = el_edges_coords;
%         % Robust ellipse fitting to edge points contained in envelope
%         [e, el_edges_coords_inliers, el_error] = ransac_ellipse_fitting(el_edges_coords, cameraParams);
% 
%         % in case robust ellipse fitting failed the first time
%         while strcmp(e.status, 'Hyperbola found') || strcmp(e.status, 'Parabola found')
%             [e, el_edges_coords_inliers, el_error] = ransac_ellipse_fitting(el_edges_coords, cameraParams, 'min_sample_size', 5);
%         end % usually ends after the first try
%         el_fit_error(i,j) = el_error;
% 
%         E_samples_ransac{i, j} = el_edges_coords_inliers;
%         E_samples_even{i, j} = undistortPoints(sample_on_ellipse(e, nb_pts_per_ellipse), cameraParams); % the points are angulary equally spaced
%         E_samples_subset{i,j} = undistortPoints(el_edges_coords_inliers(randperm(size(el_edges_coords_inliers, 1), nb_pts_per_ellipse), :), cameraParams);
% 
%         % Show final ellipse coordinates
%         if plot_el_extract_ == 1
%             figure(3*i);
%             plotEllipse(inv(param2ellipse(e)), 'r', [cameraParams.ImageSize(2), cameraParams.ImageSize(1)]);
%             plot(el_edges_coords_inliers(:,1), el_edges_coords_inliers(:,2), 'g*', MarkerSize=3);
%         end 
%     end 
% end
% mean_el_fit_error = mean(el_fit_error(:)) % mean ellipse fitting error


%%  Scene registration
disp('Performing nonlinear refinement to optimize over all sampled points...')
%Using only a subset of the markers
train_markers = 1:10; %using the outer markers for registration
eval_markers = [11, 12, 13]; %inner markers for evaluation (only 11, 12, 13 because the others might have moved)
init_image = 1; %the image in which all centers are visible - used to solve pnp for initialization of the scene registration
rand_init = 0; %random initialization (not random when set to 0, random when set to 1)

%E_samples = E_samples_even; 
E_samples = load('registration_output\E_samples_even_saved').E_samples_even;% if
%samples have been previously comupted and saved

T_C_W_cell = cell(nb_frames, 1);                               
for i = 1:nb_frames
    T_C_W_cell{i} = inv(T_W_C_cell{i});
end 

%initialization
marker_centers2d = get_ellipse_centers(E_samples(init_image, :), 1, [cameraParams.ImageSize(2), cameraParams.ImageSize(1)]);
order2DCentersInitImg = 1:nb_markers; %order (in case the marker centers were not in the right order)

T_W_C_init = T_W_C_cell{init_image};
T_W_S_init = pnp_initialization(T_W_C_init, marker_centers2d, order2DCentersInitImg, centers, K, [cameraParams.ImageSize(2), cameraParams.ImageSize(1)]); 

% Show errors after initialization
%[errors, mean_error_init] = show_scene_registration_results(T_W_S_init, images_path, T_C_W_cell, E_samples(:,eval_markers), radii, centers(eval_markers,:), colors(eval_markers, :), cameraParams);
%mean_error_init

% Nonlinear refinement
scale_init = 1; %the initial estimate of the scale is 1 and gets refined for sfm poses
[x, ~, residual, ~, ~] = estimate_scene_registration(K, rand_init, T_W_S_init, T_C_W_cell, centers(train_markers, :), E_samples(:,train_markers), radii, camera_pose_type, scale_init);
T_W_S_opti = [eul2rotm(deg2rad([x(1), x(2), x(3)]))' [x(4); x(5); x(6)]; 0 0 0 1];
[errors, mean_error] = show_scene_registration_results(T_W_S_opti, images_path, T_C_W_cell, E_samples(:,eval_markers), radii, centers(eval_markers,:), colors(eval_markers, :), cameraParams);
mean_error

%% Plot resulting transformations
figure
hold on
view(3)
plotTransformation(eye(4), 'World')
plotTransformations(T_W_C_cell, 0, 0.04)
%plotTransformations(T_W_EE, 1, 0.04)
plotCameras(T_W_C_cell)
plotTransformation(T_W_S_opti, 'opti scene')
show_spheres = true;
Q_cell = generateSpheres(T_W_S_opti, centers, radii, show_spheres, colors, 0);
xlabel('x'); ylabel('y'); zlabel('z'); grid on; axis equal;

%% Radial error
centers_K = T_W_S_opti*[centers';ones(1, nb_markers)];
centers_K = centers_K(1:3,:)';
mean_dists = zeros(nb_frames, numel(eval_markers));
all_dists = [];
for i = 1:nb_frames
    for j = 1:numel(eval_markers)
        % radii = r*ones(11,1);
        [mean_dists(i,j), dists] = distFromSphere(E_samples{i,eval_markers(j)}', K, T_W_C_cell{i}, centers_K(eval_markers(j),:)',radii);
        all_dists = [all_dists; dists];
    end
end
mean_radial_error_mm = 1000*mean(mean_dists(:))
figure
boxplot(1000*all_dists); ylabel('radial error in mm'); grid on;
title('radial error statistics')