function centers = get_ellipse_centers(points_cell, plot_, imageSize)
% Purpose: fits an ellipse to a set of input points and returns their centers

% Input:
% - points_cell: cell of m elements (i=1 to m) where each element contains
% a certain amount of points taken on the outline of an ellipse
% - plot_: option for plotting (0 or 1)
% - imageSize

% Output: 
% centers (shape m*2)
m = numel(points_cell);
centers = zeros(m,2);

if plot_ == 1
    figure; % Creates a new figure
    axis_handle = axes; % Creates new axes in the current figure and returns the handle
    axis equal; grid on;
    xlim([0 imageSize(1)]);
    ylim([0 imageSize(2)]);
end

for i = 1:m
    pts = points_cell{i};
    [x, y] = deal(pts(:,1), pts(:,2));

    if plot_ == 1
        ellipse = fit_ellipse(x, y, axis_handle);
        hold on; grid on;
        centers(i, :) = [ellipse.X0_in, ellipse.Y0_in];
        plot(x, y, 'b*');
        plot(ellipse.X0_in, ellipse.Y0_in, 'rx')
    else
        ellipse = fit_ellipse(x, y);
        centers(i, :) = [ellipse.X0_in, ellipse.Y0_in];
    end
    
end

title('Ellipse centers used for scene registration initialization')
end
