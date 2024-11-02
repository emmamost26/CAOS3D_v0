function [R_pr, t_pr, s_pr, procrustes_error] = estimate_similarity_transform(path_to_colmap_poses, path_to_end_effector_poses, path_to_T_EE_C, plot_)
%Purpose: This function estimates the similarity matrix to be applied to the colmap
% poses so that they are closest to the poses estimated by the robot (given
% by T_EE_C = T_W_EE*T_EE_C)

%Input:
% - path_to_colmap_poses: path to colmap poses, each row should be [x, y, z,
% qx, qy, qz, qw]
% - path_to_end_effector_poses: path to robot end effector poses, each row
% should be [x, y, z, qx, qy, qz, qw] (this is default given by the robot)
% - path_to_T_EE_C: path to the end effector to camera pose
% - plot_: 1 if you want to plot, 0 otherwise

%Output:
% output of procrustes
% - R_pr: rotation
% - t_pr: translation
% - s_pr: scale
% - procrustes_error: residual error   

poseDataColmap = readtable(path_to_colmap_poses);
poseDataColmap = table2array(poseDataColmap);
nb_frames = size(poseDataColmap, 1);
T_W_C_colmap_cell = cell(nb_frames,1);

for i = 1:nb_frames
    translation = poseDataColmap(i, 1:3);
    quaternion = [poseDataColmap(i, end), poseDataColmap(i, 4:6)]; 
    rotCam =  quat2rotm(quaternion);
    centerCam = -rotCam'*translation';
    T = [rotCam' centerCam;0 0 0 1];
    T_W_C_colmap.t = T(1:3, 4);
    T_W_C_colmap.R = T(1:3, 1:3);
    T_W_C_colmap.T = T;
    T_W_C_colmap_cell{i} = T_W_C_colmap;
end

poseDataRobot = readtable(path_to_end_effector_poses);
poseDataRobot = table2array(poseDataRobot);
T_EE_C = load(path_to_T_EE_C).T_EE_C_opti;
T_W_C_robot_cell = cell(nb_frames,1);

for i = 1:nb_frames
    translation = 0.001* poseDataRobot(i, 1:3);
    quaternion = [poseDataRobot(i, end), poseDataRobot(i, 4:6)];    
    T_W_EE = [quat2rotm(quaternion) translation';0 0 0 1];
    T = T_W_EE*T_EE_C;
    T_W_C_robot.t = T(1:3, 4);
    T_W_C_robot.R = T(1:3, 1:3);
    T_W_C_robot.T = T;
    T_W_C_robot_cell{i} = T_W_C_robot;
end

Q = zeros(nb_frames, 3);
P = zeros(nb_frames, 3);
for i = 1:nb_frames
    Q(i, :) = T_W_C_robot_cell{i}.t';
    P(i, :) = T_W_C_colmap_cell{i}.t';
end

[T_pr, R_pr, t_pr, s_pr, dist] = procrustes(P, Q(:,1:3));
procrustes_error = mean(dist);

Pt = (T_pr*[P ones(size(P, 1),1)]')';

if plot_ == 1
    figure; view(3); 
    plot3(Q(:,1), Q(:,2), Q(:,3), 'g*');
    hold on; grid on; axis equal
    plot3(Pt(:,1), Pt(:,2), Pt(:,3), 'ro');
    for i = 1:nb_frames
        text(Q(i, 1), Q(i, 2), Q(i, 3), sprintf('%d', i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'g');
        text(Pt(i, 1), Pt(i, 2), Pt(i, 3), sprintf('%d', i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'r');
    end
    title('COLMAP translations aligned to robot after Procrustes')
end

T_W_C_cell_colmap_transformed = cell(nb_frames, 1);
T_W_C_cell_robot = cell(nb_frames, 1);
for i = 1:nb_frames
    T_W_C_cell_colmap_transformed{i} = [R_pr*T_W_C_colmap_cell{i}.R s_pr*R_pr*T_W_C_colmap_cell{i}.t + t_pr; 0 0 0 1];
    T_W_C_cell_robot{i} = T_W_C_robot_cell{i}.T;
end

if plot_ == 1
    figure; hold on; view(3)
    
    plotCameras(T_W_C_cell_colmap_transformed, 'r')
    plotCameras(T_W_C_cell_robot, 'g')
    for i = 1:nb_frames
        text(Q(i, 1), Q(i, 2), Q(i, 3), sprintf('%d', i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'black');
        text(Pt(i, 1), Pt(i, 2), Pt(i, 3), sprintf('%d', i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'r');
    end
    grid on; axis equal
    title('COLMAP camera poses aligned to robot cameras after procrustes')
end