function [cameraParams, undistCorners, bad_images, worldPoints] = calibrate_camera(imageNumbers, image_path)

% Purpose: calibrate the camera (intrinsics and extrinsics) and return the
% undistorted corners

% Input:
% - imageNumbers: number of images (1.jpg, ...) used for the camera
% calibration
% - image_path: path to the image folder

% Output:
% cameraParams, undistCorners, bad_images, worldPoints

    % Construct the cell array of image file names
    imageFileNames = cell(1, numel(imageNumbers));
    for i = 1:numel(imageNumbers)
        imageFileNames{i} = fullfile(image_path, [num2str(imageNumbers(i)) '.jpg']);
    end

    % Detect calibration pattern in images
    N = numel(imageFileNames);
    detector = vision.calibration.monocular.CheckerboardDetector();
    [imagePoints, imagesUsed] = detectPatternPoints(detector, imageFileNames);
    imageFileNames = imageFileNames(imagesUsed);

    if N ~= numel(imageFileNames)
        error("Not all images were usable for calibration")
    end
    
    % Read the first image to obtain image size
    originalImage = imread(imageFileNames{1});
    [mrows, ncols, ~] = size(originalImage);
    
    % Generate world coordinates for the planar pattern keypoints
    squareSize = 15;  % in units of 'millimeters'
    worldPoints = generateWorldPoints(detector, 'SquareSize', squareSize);
    
    % Calibrate the camera
    [cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
        'EstimateSkew', false, 'EstimateTangentialDistortion', true, ...
        'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
        'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
        'ImageSize', [mrows, ncols]);

    % with default parameters
    % [cameraParams, ~, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    % 'ImageSize', [mrows, ncols]);
    
    % Undistort points
    undistCorners = zeros(size(imagePoints));

    bad_images = [];
    idx = 1;
    
    for i = 1:size(imagePoints, 3)
        try 
            undistCorners(:,:,idx) = undistortPoints(imagePoints(:,:,i), cameraParams);
            idx = idx + 1;
        catch undistortError
            fprintf('Error undistorting points in image %d: %s\n', i, undistortError.message);
            bad_images = [bad_images, i];
        end 
    end 
    
    % View reprojection errors
    h1=figure; showReprojectionErrors(cameraParams);
    
    % Visualize pattern locations
    h2=figure; showExtrinsics(cameraParams, 'CameraCentric');
    
    h3=figure; showExtrinsics(cameraParams, "PatternCentric");
    % Display parameter estimation errors
    displayErrors(estimationErrors, cameraParams);
end

