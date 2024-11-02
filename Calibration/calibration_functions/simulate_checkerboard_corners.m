function objp = simulate_checkerboard_corners(chessboard_size, square_size)
%This function takes as input an origin vector [X,Y,Z] as well as the
%number of chessboard size [nb_horizontal, nb_vertical] and the checkersize in meters.

%It outputs a flat (constant z) grid of 3D corners (only the inner corners, just like
%cv2.findChessboardCorners would give it)


% Prepare 3D points
objp = zeros(prod(chessboard_size), 3);
[X, Y] = meshgrid(0:chessboard_size(2)-1, 0:chessboard_size(1)-1);
objp(:, 2) = Y(:) * square_size;
objp(:, 1) = X(:) * square_size;

end