function T = matFromVec(vector)
    R = eul2rotm(deg2rad(vector(1:3))')';
    T = [R [vector(4); vector(5); vector(6)]; 0 0 0 1];
end