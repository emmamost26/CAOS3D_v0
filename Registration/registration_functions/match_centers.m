function trueIndices = match_centers(unorderedCenters2D, centers3D, camParams, combinations)
% Purpose: match the unordered 2d centers corresponding to the centers3D by
% testing the PnP for all combinations corresponding to the minimal solutions (i.e. 4
% out of all the 2d points) and keeping the solution with minimal residual
% error

% Input:
% unordered_centers2D, size (m, 2)
% centers3D, size (M, 3)
% combinations: precomputed list of combinations to test

% Output:
% trueIndices: order of the unorderedCenters2D

% IT MIGHT BE NECESSARY TO TUNE THE MAX REPROJECTION ERROR FOR THE P3P 
thresh = 150; % outlier threshold in pixels. When the distance between the 2D center and the projected 3D center is bigger than thresh, they are not considered a match.
M = size(centers3D, 1);
m = size(unorderedCenters2D, 1);
k = size(combinations, 2);
subsetCenters2D = unorderedCenters2D(randperm(m, k), :); % pick 4 of the unordered 2D centers at random
trueIndices = zeros(M,1);

min_dist = Inf;
for i = 1:size(combinations, 1)
    % solve pnp for that combination
    try % try to solve pnp
        T_S_C_est = estworldpose(subsetCenters2D, centers3D(combinations(i,:), :), camParams.Intrinsics, MaxReprojectionError=50).A;
        disp(['pnp succeeeded for combination ', num2str(i), ' out of ', num2str(size(combinations, 1))]);

    catch ME 
        %disp(['Skipping iteration ', num2str(i), ' out of ', num2str(size(combinations,1)),' due to error: ', getReport(ME)]);
        %disp(['Skipping iteration ', num2str(i), ' out of ', num2str(size(combinations,1)),' due to error']);
     
        continue; 
    end

    totalDist = 0;
    indicesClosestSpheres = -1*ones(m,1);
    minDists = Inf*ones(M,1);

    for k = 1:m
        [dist, idx] = get_closest_center(T_S_C_est, unorderedCenters2D(k, :), centers3D, camParams.K);
        totalDist = totalDist + dist;
        
        if (dist > thresh) || (dist > minDists(idx)) % to make it robust to having less 2D centers than 3D centers or some other reason for outliers.
            continue;
        else
            minDists(idx) = dist;
            indicesClosestSpheres(k) = idx;
        end
    end

    if totalDist < min_dist
        min_dist = totalDist;
        trueIndices = indicesClosestSpheres;
    end
end
end
