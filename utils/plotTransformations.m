function plotTransformations(T_cell, numbers, axisLength)
% Purpose: creates a 3D plot to visualize multiple transformations
% Input:
% - T_cell: cell of transformation matrices to plot
% - numbers: boolean (takes value 1 if you want the transformations to be
% numbered in the plot, 0 otherwise)
% - axisLength: optional parameter to tune the length of the arrows in the
% plot

if nargin < 4
    axisLength = 0.04; % Default length of the coordinate axes
end

N = numel(T_cell);

for i = 1:N
    % Extract translation and quaternion from the data
    T = T_cell{i};
    translation = T(1:3,4);
    R = T(1:3,1:3);

    % Plot the translation as a point
    plot3(translation(1), translation(2), translation(3), ['r' '*'], 'MarkerSize', 10);

    % Create coordinate axes for the rotation

    % Plot the coordinate axes
    % X-axis
    quiver3(translation(1), translation(2), translation(3), R(1, 1), R(2, 1), R(3, 1), axisLength, 'Color', 'r', 'LineWidth', 2);

    % Y-axis
    quiver3(translation(1), translation(2), translation(3), R(1, 2), R(2, 2), R(3, 2), axisLength, 'Color', 'g', 'LineWidth', 2);

    % Z-axis
    quiver3(translation(1), translation(2), translation(3), R(1, 3), R(2, 3), R(3, 3), axisLength, 'Color', 'b', 'LineWidth', 2);

    % Write down the index next to the point
    if numbers == 1
        text(translation(1), translation(2), translation(3), num2str(i), 'FontSize', 15, 'Color', 'b');
    end 
end

end

