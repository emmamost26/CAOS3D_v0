function plotEllipse(E_inv, color, imageSize)
% Purpose: plot ellipse on the image
% Input: 
% - E_inv: inverse of the conic 3 by 3 matrix describing the ellipse
% - color
% - imageSize

    %imageSize = height, width = 1080*1616 or 6336*9504 for example
    image_width = imageSize(1); %px
    image_height = imageSize(2); %px

    hold on;
    syms x y
    
    % Plot ellipse
    fimplicit([x; y; 1]'/E_inv*[x; y; 1] == 0, [0 image_width 0 image_height], Color=color, LineWidth=1.5)
    
    % Restrict plot to image resolution
    axis equal
    axis([0, image_width, 0, image_height]); 
    grid on;
    title('Projected ellipse');
end