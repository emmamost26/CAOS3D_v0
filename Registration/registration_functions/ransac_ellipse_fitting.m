function [e_opti, best_inlier_set, mean_fit_error] = ransac_ellipse_fitting(samples, cameraParams, varargin)
% Purpose: This functions fits an ellipse to a set of points and returns
% the parameters of the optimal ellipse

% Input: 
% - samples: points (Nx2) to fit the ellipse on 
% - cameraParams: matlab cameraParams structure
% - varargin: optional arguments, see below

% Output: 
% - e_opti: structure that defines the best fit to the ellipse
%                       a           - sub axis (radius) of the X axis of the non-tilt ellipse
%                       b           - sub axis (radius) of the Y axis of the non-tilt ellipse
%                       phi         - orientation in radians of the ellipse (tilt)
%                       X0          - center at the X axis of the non-tilt ellipse
%                       Y0          - center at the Y axis of the non-tilt ellipse
%                       X0_in       - center at the X axis of the tilted ellipse
%                       Y0_in       - center at the Y axis of the tilted ellipse
%                       long_axis   - size of the long axis of the ellipse
%                       short_axis  - size of the short axis of the ellipse
%                       status      - status of detection of an ellipse
% - best_inlier_set: set of inlier points that were kept to estimate e_opti
% - mean_fit_error: mean distance from inliers to output ellipse

% Default assumptions: 
% fraction of inliers w = 50%
% probability of success p = 99%
% definition of p: the probability to have selected at least s points that
% are all inliers after k iterations

% Default optional parameters
options.min_sample_size = 5; % min amount of points to fit an ellipse
options.inlier_ratio = 0.5;
options.prob_success = 0.99;
options.threshold = 1.5; %px, inlier distance from the fit ellipse threshold 
options.plot_ellipses = 0;
options.plot_final_ellipse = 0;

% Overwrite defaults with user-provided values
options = parseArgs(options, varargin{:});

s = options.min_sample_size;
w = options.inlier_ratio;
p = options.prob_success;
thresh = options.threshold;
plot_ = options.plot_ellipses;
plot_final_ = options.plot_final_ellipse;

k = log(1-p)/log(1-w^s); 
n = size(samples, 1);

max_nb_inliers = 0;
for i=1:round(k)

    if plot_ == 1
        figure;
        axis_handle = axes;
        plot(samples(:,1), samples(:,2), 'g*');
        hold on; grid on; axis equal;
    end
    
    % Sample minimal subset
    sample = samples(randperm(n, s), :);
    if plot_ == 1
        plot(sample(:,1), sample(:,2), 'bo');
        e = fit_ellipse(sample(:,1), sample(:,2), axis_handle); e.phi = -e.phi;
    else 
        e = fit_ellipse(sample(:,1), sample(:,2));
        s2 = s;
        while isempty(e)
            s2 = s2+1;
            sample = samples(randperm(n, s2), :);
            e = fit_ellipse(sample(:,1), sample(:,2));
        end
        while strcmp(e.status, 'Hyperbola found') || strcmp(e.status, 'Parabola found')
            s2 = s2+1;
            sample = samples(randperm(n, s2), :);
            e = fit_ellipse(sample(:,1), sample(:,2));
        end
        e.phi = -e.phi;
    end

    % Fit ellipse to minimal subset
    
    if strcmp(e.status, 'Hyperbola found') || strcmp(e.status, 'Parabola found')
        %close;
        continue;
    end
    distances = 0;
    nb_inliers = 0;
    
    inlier_set = [];
    dist_inliers = 0;
    for j = 1:n
        dist = rosin_dist(e, samples(j,:)', cameraParams.ImageSize);
        distances = distances + dist;
        if dist < thresh
            dist_inliers = dist_inliers + dist;
            nb_inliers = nb_inliers + 1;
            inlier_set = [inlier_set; samples(j,:)];
        end
    end

    if nb_inliers > max_nb_inliers
        best_inlier_set = inlier_set;
        max_nb_inliers = nb_inliers;
        best_dist_inliers = dist_inliers;
    end
    %close;
end

if plot_final_ == 1
    figure;
    axis_handle = axes;
    plot(samples(:,1), samples(:,2), 'b*');
    hold on; grid on; axis equal;
    e_opti = fit_ellipse(best_inlier_set(:,1), best_inlier_set(:,2), axis_handle); e_opti.phi = -e_opti.phi; % so that the angle is positively defined, trigonometrically
    plot(best_inlier_set(:,1), best_inlier_set(:,2), 'go');
else
    e_opti = fit_ellipse(best_inlier_set(:,1), best_inlier_set(:,2)); e_opti.phi = -e_opti.phi; % so that the angle is positively defined, trigonometrically
end

    mean_fit_error = best_dist_inliers/size(best_inlier_set, 1);
end

% Function that deals with optional parameters
function options = parseArgs(options, varargin)
    % Parse the varargin cell array and update the options struct
    for i = 1:2:length(varargin)
        if isfield(options, varargin{i})
            options.(varargin{i}) = varargin{i+1};
        else
            error('Invalid parameter name: %s', varargin{i});
        end
    end
end