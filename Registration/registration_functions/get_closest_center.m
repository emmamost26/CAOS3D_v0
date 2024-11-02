function [minDist, idx] = get_closest_center(T_S_C, P, points3D, K)
% Purpose: get the closest 3D point corresponding to a 2D point in the image

% Input:
% - T_S_C: camera-to-scene transformation (i.e. camera pose)
% - P: 2D image pixel location
% - points3D: points expressed in reference frame S (scene)
% - K: camera calibration matrix

% Output:
% - minDist: distance to the closest projected point (in pixels)
% - idx: idx to the closest 3D point


m = size(points3D, 1);
points = project_world_points_to_image(K, inv(T_S_C), points3D);
differences = points - P;
distances = sqrt(sum(differences.^2, 2)); 
[minDist, idx] = min(distances);

debug = 0;
if debug  == 1
    figure;
    plot(points(:,1), points(:,2), 'r*');
    hold on
    plot(P(1,1), P(1,2), 'b*');
    plot(points(idx, 1), points(idx, 2), 'ro');
    title("reprojected 3D points and 2D point. Closest point is circled");
    axis equal; grid on;
    xlim([0 1616])
    ylim([0 1080])
    hold off
end
end