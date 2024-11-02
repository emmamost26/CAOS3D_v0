function [T, R, t, s, dist] = procrustes(P, Q)
%This function implements the procrustes algorithm. T is the
% transformation that, applied to the reference points P (shape N by 3), obtains the
% transformed points Q (shape N by 3).
% Q' = T*P'

% T = [s*R t;0 0 0 1] but careful, (s*R) is not a valid rotation and T in
% this form is not a valid euclidean transformation

% Step 1: Compute centroids and center the point cloud
P_c = P - mean(P);
Q_c = Q - mean(Q);

% Compute norms
norm_P = norm(P_c, 'fro');
norm_Q = norm(Q_c, 'fro');

% Scaling factor
s = norm_Q / norm_P;

% Scale P
P_scaled = s * P_c;

% Compute the rotation using SVD
H = P_scaled'*Q_c;
[U, ~, V] = svd(H);
R = V*U';

% Ensure a proper rotation (det(R) should be +1)
if det(R) < 0
    V(:,end) = -V(:,end);
    R = V * U';
end

% Step 2: translation
t = mean(Q)' - R * s * mean(P)';
T = [s*R t;0 0 0 1]; % this can be used to transform the centers but not the rotation matrices. 
% The rotation does not get scaled (otherwise its determinant is not 1 anymore) 

P_transformed = (s*R * P' + t)';
error = norm(P_transformed - Q);

dist = zeros(size(Q,1), 1);
for i = 1: size(P_transformed, 1)
    dist(i) = norm(P_transformed(i, :) - Q(i,:));
end
end