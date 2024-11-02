function [errors, mean_error] = show_scene_registration_results(T_W_S_est, images_path, T_C_W_cell, E_samples, radius, centers, colors, cameraParams)
% Purpose: plot the images with detected ellipses and reprojected ellipses
% after scene registration and compute the reprojection errors

% Input: 
% - T_W_S_est: estimated scene-to-world pose (i.e. the 
% - images_path: path to the images where ellipses have been detected (not
% undistorted)
% - T_C_W_cell: cell of world-to-camera poses for each image
% - E_samples: (N*M)-sized cell where each input contains a K*2 array of
% points on the outline of an ellipse in the i-th image corresponding to the
% j-th sphere

% - radius: radius of the spherical markers
% - centers: M*3 array of the 3D spherical marker centers
% - colors: M*3 array of M different colors for visualization
% - cameraParams

% Output:
% - errors: N*M array of the mean reprojection error for each image i = 1:N and
% ellipse j=1:M
% - mean_error: average of all errors = final mean reprojection error

Q_cell_opti = generateSpheres(T_W_S_est, centers, radius, false, colors);% get sphere quadrics in kuka reference frame
visualize_proj_ = 1;
K = cameraParams.K;
imageSize = cameraParams.ImageSize;
nb_frames = size(E_samples, 1);
nb_markers = size(E_samples, 2);
errors = zeros(nb_frames, nb_markers);

for i = 1:nb_frames
    T_C_K = T_C_W_cell{i};
    T = T_C_K(1:3,:); %[R|t]
    P = K*T; %K [R|t], from world to camera

    for j = 1:size(E_samples, 2)

        E_inv_opti = P/Q_cell_opti{j}*P';
        if visualize_proj_
            if j == 1
                figure;
                axis_handle = axes;
                imshow(undistortImage(imread(fullfile(images_path, [num2str(i) '.jpg'])), cameraParams));
                hold on
            end
            plotEllipse(E_inv_opti, colors(j,:), [imageSize(2), imageSize(1)]) %plots the outline of the ellipse obtained with optimized scene registrations
            %plotEllipse(E_inv_opti, 'red', [imageSize(2), imageSize(1)]) %plots the outline of the ellipse obtained with optimized scene registrations
            sampled_points = E_samples{i,j}; %gives the original samples ellipse points to plot 

            % Distance between the sampled points and the ellipses
            dist = 0;
            for k = 1:size(sampled_points, 1)
                dist = dist + rosin_dist(ellipse2param(inv(E_inv_opti)), sampled_points(k, :)', imageSize);
            end 
            errors(i,j) = dist/size(sampled_points, 1);

            if isempty(sampled_points)
                continue
            else
                % Plot the ellipse fit to the sampled points
                fit_ellipse(sampled_points(:,1), sampled_points(:,2), axis_handle);
                plot(sampled_points(:,1), sampled_points(:,2), LineStyle='none', Marker='*', Color=colors(j,:))
            end
        end
    end
end
mean_error = mean(errors(:));
end