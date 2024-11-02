function plotCameras(transformations_cell, color)
% Purpose: plots camera poses using matlab plotCamera function in 3D frame for visualization
% Input:
% - transformations_cell: cell of N 4 by 4 camera poses
% - color: color for the camera plots

if nargin <2
    color = 'r';
end
N = numel(transformations_cell);
    for i = 1:N
        % Extract translation and quaternion from the data
        T = transformations_cell{i};
        translation = T(1:3,4);
        R = T(1:3,1:3);
    
        % Plot the translation as a point
        plotCamera('Location', translation', 'Orientation', R', 'Size',0.02, 'Color', color )
    end
end