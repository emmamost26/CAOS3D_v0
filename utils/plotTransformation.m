function plotTransformation(T, texte, arrow_size)
% Purpose: plotTransformation creates a 3D visualization of a pose given by a 4 by 4
% euclidean transformation T

% Input: 
% - T: 4 by 4 euclidean transformation matrix
% - texte: text to be written next to the coordinate system corresponding
% to the pose
% - arrow_size: optional argument to change the size of the arrows.

if nargin < 3
    arrow_size = 0.2; % Default length of the coordinate axes
end
    translation = T(1:3,4);
    

    x_w = [arrow_size; 0; 0; 1];
    y_w = [0; arrow_size; 0; 1];
    z_w = [0; 0; arrow_size; 1];
    
    O = [0 0 0 1]';
    O = T * O; % Transform origin from camera to world frame
    O = O(1:3);
    
    % Plot arrows for camera reference frame 
    x_c = T*x_w;
    y_c = T*y_w;
    z_c = T*z_w;
    
    plot3(O(1), O(2), O(3), '*', 'Color', 'r', 'MarkerSize', 10);
    
    quiver3(O(1), O(2), O(3),  x_c(1) - O(1), x_c(2) - O(2), x_c(3) - O(3), 'Color', 'r', 'LineWidth', 1, 'MaxHeadSize', 0.5);
    hold on
    quiver3(O(1), O(2), O(3),  y_c(1) - O(1), y_c(2) - O(2), y_c(3) - O(3), 'Color', 'g', 'LineWidth', 1, 'MaxHeadSize', 0.5);
    quiver3(O(1), O(2), O(3),  z_c(1) - O(1), z_c(2) - O(2), z_c(3) - O(3), 'Color', 'b', 'LineWidth', 1, 'MaxHeadSize', 0.5);

    text(translation(1)-0.04, translation(2)-0.04, translation(3), texte, 'FontSize', 15, 'Color', 'r');

end

