function permArray = get_all_combinations(n, k)
% permArray contains all unique permutations of choosing k out of n

% Generate all combinations (choose k out of n)
comb = nchoosek(1:n, k);

% Initialize an array to hold the permutations of combinations
permArray = zeros(factorial(n) / factorial(n-k), k);

% Loop over each combination to generate permutations
for i = 1:size(comb, 1)
    % Generate all permutations of the current combination
    permsOfComb = perms(comb(i, :));
    
    % Append these permutations to the permArray
    permArray((i-1)*size(permsOfComb, 1)+1: i*size(permsOfComb, 1), :) = permsOfComb;
end

% Remove duplicate rows, if any (can occur depending on n and k)
n_before = size(permArray);
permArray = unique(permArray, 'rows');
n_after = size(permArray);
if(n_before ~= n_after)
    disp("Some duplicate rows were removed from the combinations");
end

end