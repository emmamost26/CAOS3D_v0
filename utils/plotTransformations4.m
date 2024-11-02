function plotTransformations4(cell, numbers, arrow_size)
if nargin < 3
    arrow_size = 0.2; % Default length of the coordinate axes
end

N = numel(cell);

for i = 1:N
    % Extract translation and quaternion from the data
    T = cell{i};
    %T = T.A;
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


    if numbers == 1
        text(translation(1), translation(2), translation(3), num2str(i), 'FontSize', 15, 'Color', 'r');
    end 
end
    xlabel('X in m');
    ylabel('Y in m');
    zlabel('Z in m');
    axis equal
end

