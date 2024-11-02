function T_W_S_init = pnp_initialization(T_W_C, centers2D, center2DOrder, centers3D, K, imageSize)
% Purpose: estimate the scene to world transformation (i.e. the scene
% registration) by solving the PnP on one image using the centers of ellipses in the
% image and corresponding 3D centers of the spherical markers as 2D-3D
% correspondences 

% Input:
% - T_W_C: camera pose for the image used for initialization
% - centers2D: M*2 shaped ellipse centers in the image
% - center2DOrder: order of the centers2D so that they correspond to the
% order of the sphere centers given in centers3D (can be [1:M] if they are
% already in the same order. I just prepared this for later to have it more automized)
% - centers3D: M*3 shaped 3D marker centers in scene reference frame
% - K: camera calibration matrix
% - imageSize

% Output:
% - T_W_S_init: solution to the pnp, giving an initial solution to the
% registration problem

focalLength = [K(1,1), K(2,2)]; % fx and fy
principalPoint = [K(1,3), K(2,3)]; % cx and cy

M = size(centers2D, 1);
centers2DO = [];
centers3DO = [];

% Order the 2D centers to match the 3D centers. The size of centers2DO and
% centers3DO should be the same and equal to the amount of non (-1) entries
% in center2DOrder.
for i = 1:M
    if center2DOrder(i) == -1
        continue;
    else
        centers2DO = [centers2DO; centers2D(i, :)];
        centers3DO = [centers3DO; centers3D(center2DOrder(i), :)];
    end
end 
% Create the cameraIntrinsics object
camIntrinsics = cameraIntrinsics(focalLength, principalPoint, imageSize);
T_S_C = estworldpose(centers2DO, centers3DO, camIntrinsics, 'MaxReprojectionError', 15, 'Confidence', 95, 'MaxNumTrials', 5000).A;
T_W_S_init = T_W_C/T_S_C;

end