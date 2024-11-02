function [mean_dist, dists] = distFromSphere(px, K, T_W_C, C, r)
% This function computes the radial distance between a ray thatis
% backprojected from a pixel px on the image, and the surface of a sphere of
% center C and radius r, given the relative camera pose and calibration
% matrix

% INPUT
% - px: the image coordinates in pixels that we want to backproject, shape 2 by N
% - K: the calibration matrix K
% - T_W_C: the camera pose expressed as the transformation that transforms
% a point expressed in the camera frame into a point expressed in the world
% reference frame
% - C: the center of the sphere, shape 3 by 1, expressed in the world
% reference frame
% - radius: the radius of the sphere

% OUTPUT
% - dist: the distance between the backprojected ray and the sphere
% (computed by taking the distance between the ray and the center of the
% sphere minus the radius)

plot_ = 0;
R_W_C = T_W_C(1:3, 1:3); %camera rotation
O = T_W_C(1:3, 4); %camera origin
dists = zeros(size(px, 2), 1);
for i = 1:size(px, 2)
    d = R_W_C / K * [px(:,i);1]; % ray direction
    
    % Take the triangle OCI where O in the camera center, C is the sphere center
    % and I is the closest point to C on the backprojected ray from px. 
    OC = C - O; % vector OC points from the camera center O to the center of the sphere C
    OI = dot(OC, d)/dot(d,d)*d; % projection of OC onto d to find OI
    CI = -OC + OI;
    D = norm(CI);
    dists(i) = abs(r - D);
    
    if plot_ == 1
        figure;
        plot_line(O, d, 0.4); % plot the backprojected ray
        hold on; grid on; axis equal
        [X, Y, Z] = sphere;
        surf(r*X+C(1),r*Y+C(2),r*Z+C(3),'FaceColor', 'r', 'FaceAlpha', 0.5)
        I = OI + O;
        plot3(I(1), I(2), I(3), 'r*', MarkerSize=12);
        plot3(O(1), O(2), O(3), 'ro', MarkerSize=12);
    end
end
mean_dist = mean(dists);
end