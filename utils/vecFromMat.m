function vector = vecFromMat(T)
% vecFromMat converts a 4 by 4 euclidean transformation matrix into a 6 by
% 1 vector [eul1 eul2 eul3 x y z]
    rotation_matrix = T(1:3,1:3)';
    vec = rad2deg(rotm2eul(rotation_matrix));
    vector = [vec(1); vec(2); vec(3) ;T(1:3,4)];
end