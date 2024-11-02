function Q_cell = generateSpheres(T_W_S, centers, r,show, colors, newFig)
% Purpose: generates spheres expressed in the world reference frame W, given
% centers expressed in locale scene reference frame S

% Input: 
% - T_W_S: scene-to-world pose (4*4)
% - centers: 3D centers expressed in scene reference frame (M*3)
% - r: radius of the spheres
% - show: boolean to choose if visualization is desired
% - colors: colors for all the centers (M*3)
% - newFig: boolean to choose if a new figure is required (irrelevant if
% show is set to 0)

% Output:
% - Q_cell: cell of 4*4 quadric matrices representing the spheres expressed in
% world reference frame

if nargin < 6
    newFig =1;
end

M = size(centers, 1);
% Get the quadric form and store them in a cell
Q_cell = cell(M, 1);
C = zeros(4,M);

if size(r, 1) == 1 & size(r, 2) == 1
    r = ones(size(centers, 1), 1)*r;
end

for j = 1:M
    %express center in Kuka frame
    C(:,j) = T_W_S * [centers(j,:) 1]';
    %define quadric
    Q_cell{j} = [1 0 0 -C(1, j);
        0 1 0 -C(2, j);
        0 0 1 -C(3, j);
        -C(1, j) -C(2, j) -C(3, j) C(1, j)^2+C(2, j)^2+C(3, j)^2-r(j)^2];
end

if show == true
    if newFig == 1
        figure;
    end
    for j = 1:size(centers, 1)
        [X, Y, Z] = sphere;
        surf(r(j)*X+C(1, j),r(j)*Y+C(2, j),r(j)*Z+C(3, j),'FaceColor', colors(j, :), 'FaceAlpha', 0.5)
        hold on
        axis equal
    end
    xlabel('X [m]');
    ylabel('Y [m]');
    zlabel('Z [m]');
    grid on; axis equal;
end
end