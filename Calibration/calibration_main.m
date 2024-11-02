close all; clear; clc
addpath("..\utils\")
addpath("calibration_functions\")

% Define paths to images and robot end effector poses
image_path = 'calibration_data\images';
poses_path = 'calibration_data\robot_poses.csv';

% Choose desired visualizations
visualize_initial_corners_ = 0;
visualize_reprojected_corners_ = 1;

% Define chessboard size
chessboard_size = [17, 24]; % numbers of checkers in y, x
square_size = 0.015; % in meters 

%% Camera intrinsics and extrinsics calibration
imageNumbers = 1:86; %image indices used for estimating K and distortion
ee_c_calib_ids = 47:86; %image indices used to find T_EE_C (only those for fixed checkerboard position)
valid_pose_ids = 1:40; %pose indices (with fixed checkerboard) 

already_calibrated = 1;
if already_calibrated == 0
    % Calibrate the camera
    [cameraParams, corners, bad_images, worldPoints] = calibrate_camera(imageNumbers, image_path);
    
    if size(bad_images, 2) > 0 % stop script if some corners were not undistorted properly
        error('Please remove bad images, i.e. images where corners could not be undistorted')
    end
    save('calibration_output\cameraParams.mat','cameraParams');
    save('calibration_output\corners.mat','corners');
    save('calibration_output\worldPoints.mat','worldPoints');
else
    cameraParams = load('calibration_output\cameraParams.mat').cameraParams;
    corners = load('calibration_output\corners.mat').corners;
    worldPoints = load('calibration_output\worldPoints.mat').worldPoints;
end

% Extract parameters
N = size(valid_pose_ids, 2);
K = cameraParams.K;
image_width = cameraParams.ImageSize(2); %px
image_height = cameraParams.ImageSize(1); %px

%% Robot-camera calibration
% Load T_W_EE,i given by kuka robot and T_C_CH,i given by PnP
poseData = readtable(poses_path);
poseData = table2array(poseData);

T_W_EE_cell = cell(N,1);
T_CH_C_cell = cell(N,1);

i = 1;
for idx = valid_pose_ids
    % Extract translation and quaternion from the data
    translation = 0.001* poseData(idx, 1:3);
    quaternion = [poseData(idx, end), poseData(idx, 4:6)];
    
    % Create a rotation matrix from the quaternion
    R = quat2rotm(quaternion);
    T_W_EE_cell{i} = [R translation';0 0 0 1];
    i = i + 1;
end

i = 1;
for idx = ee_c_calib_ids
    T_C_CH = cameraParams.PatternExtrinsics(idx).A;
    T_CH_C_cell{i} = inv([T_C_CH(1:3,1:3) 0.001*T_C_CH(1:3,4);0 0 0 1]);
    i = i + 1;
end

% Plot the end effector poses 
figure
view(3)
plotTransformations4(T_W_EE_cell, 1, 0.02)
title('T^{EE}_C')
plotTransformation(eye(4), 'Origin')

% Generate simulated checkerboard corners in 3D
pts3D = simulate_checkerboard_corners(chessboard_size, square_size); % 126*3
pts3D = pts3D'; % 3*126
pts3D = [pts3D; ones(1,chessboard_size(1)*chessboard_size(2))]; % 4*126

% Initial estimate for T_EE_C
T_EE_C_est = solve_sylvester_equations(T_W_EE_cell, T_CH_C_cell, 0);
T_W_CH_est = solve_sylvester_equations(T_W_EE_cell, T_CH_C_cell, 1);

% Nonlinear calibration refinement minimizing the reprojection error
% X_opti has the form [z_rot, y_rot, x_rot, x_trans, y_trans, z_trans];
corners = corners(:,:,ee_c_calib_ids); 
rand_init_ = 0;
[X_opti, resnorm, res,~,~] = estimate_robot_camera_calibration( ...
    T_EE_C_est, T_W_CH_est, T_W_EE_cell, corners, pts3D, K, rand_init_);

disp('resnorm:')
disp(resnorm)
mean_reprojection_error = sqrt(resnorm / (N*chessboard_size(1)*chessboard_size(2)));
disp('mean_reprojection_error:')
disp(mean_reprojection_error)
disp("For noisy corners, the resnorm remains " + ...
    "quite high but this is normal since the total" + ...
    " reprojection error is the sum of the error for all corners. " + ...
    "It does not mean lsqnonlin has not converged")
T_EE_C_opti = matFromVec(X_opti(1:6));
T_W_CH_opti = matFromVec(X_opti(7:12));

% Save T_EE_C_opti for the scene registration
save("calibration_output\T_EE_C.mat", 'T_EE_C_opti');

% Show images and reprojected corners
reproj_corners = zeros(2, chessboard_size(1)*chessboard_size(2), N);

for i = 1:10 % show only 10 first images
    T_C_W = inv(T_W_EE_cell{valid_pose_ids(i)}*T_EE_C_opti); % world-to-camera
    P = T_C_W(1:3,:); % the world-to-camera projection matrix
    reproj_corner = K*P*T_W_CH_opti*pts3D;
    reproj_corner = reproj_corner ./ reproj_corner(end, :);
    reproj_corner = reproj_corner(1:2, :); 
    reproj_corners(:,:,i) = reproj_corner;

    if visualize_reprojected_corners_
        % Visual representation
        figure;
        imshow(undistortImage(imread(fullfile(image_path, [num2str(ee_c_calib_ids(i)) '.jpg'])), cameraParams));
        hold on
        grid on; axis equal;
        xlim([0 image_width]);ylim([0 image_height]);
        plot(corners(:,1,i), corners(:,2,i), LineStyle="none", Marker="*", Color="green" , MarkerSize=10, LineWidth =1)
        plot(reproj_corner(1,:), reproj_corner(2,:), LineStyle="none", Marker="+", Color="red", MarkerSize=10, LineWidth =1)

    end
end