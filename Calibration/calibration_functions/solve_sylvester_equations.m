function T = solve_sylvester_equations(L, R, relevantUnknown)
    % Input :
    % - L and R : Cells of left and right matrices 
    % in the equations Li X0 = X1 Ri
    % where X0 and X1 are the two unknown transformation matrices

    % - relevantUnknown : Takes value 0 if the function should return X0, 1
    % if the function should return X1 
    % If relevantUnknown = 0, function couples all Li X0 Ri^-1 = X1

    % Output :
    % Euclidean transformation X0 or X1 

    % Check if the two input cell arrays contain the same number of matrices
    if numel(R) ~= numel(L)
        error('Both input cell arrays must contain the same number of matrices.');
    end

    % Get measurement matrix and solve for the rotation part
    N = numel(R);
    M_R = zeros(9*nchoosek(N,2), 9);
    for i = 1:N
        for j = i+1:N 

            % General furmula : A * X = X * B
            % where A, B are euclidean transformations
            if relevantUnknown == 0
                % L1 * X0 * R1^-1 = L2 * X0 * R2^-1 ==> L2\L1 * X0 = X0 * R2\R1
                A = L{j}\L{i};
                B = R{j}\R{i};
            end
            if relevantUnknown == 1
                % L1^-1 * X1 * R1 = L2^-1 * X1 * R2 ==> L2/L1 * X1 = X1 * R2/R1
                A = L{i}/L{j};
                B = R{i}/R{j};
            end

            % Select the rotation matrices A and B
            R_A = A(1:3, 1:3);
            R_B = B(1:3, 1:3);

            % Update the measurement matrix M
            % Solution to the sylvester equation A * X + X * B = C is given by the
            % solution to [kron(I, A) + kron(B', I)] * X(:) = C(:)
            % where [kron(I, A) + kron(B', I)] = M 
            % In our case, C(:) = 0
            M_R((i-1)*9+1 : i*9, :) =  kron(eye(3), R_A) - kron(R_B', eye(3));
        end
    end

    % Solve for rotation part R
    % Solve argmin(M*X(:))
    [~, ~, V] = svd(M_R);
    Rot = V(:,end);
    Rot = Rot/norm(Rot); % making sure x has norm 1
    Rot = reshape(Rot, 3,3);
    
    % Recover the rotation matrix in SO(3)
    [U, ~, V] = svd(Rot);
    Rot = U*V';

    % When det(R_X), multiply matrix by -1
    Rot = Rot * det(Rot);

    % Solve for translation part t
    % (R_A - eye(3)) * t_X = (R_X * t_B - t_A)
    % Can write this as a least squares problem :
    % t_x = argmin ||A t_x - b || 
    % where A = stacked(R_A - eye(3))  
    % and b = stacked(R_X * t_B - t_A)
    % We construct an augmented linear system of equations :
    % [A -b] * [x 1]' = 0 and solve for x
    % The measurement matrix is M_t = [A -b]
    M_t = zeros(3*nchoosek(N,2), 4);
    for i = 1:N
        for j = i+1:N
            if relevantUnknown == 0
                % L1 * X0 * R1^-1 = L2 * X0 * R2^-1 ==> L2\L1 * X0 = X0 * R2\R1
                A = L{j}\L{i};
                B = R{j}\R{i};
            end
            if relevantUnknown == 1
                % L1^-1 * X1 * R1 = L2^-1 * X1 * R2 ==> L2/L1 * X1 = X1 * R2/R1
                A = L{i}/L{j};
                B = R{i}/R{j};
            end

            % Select the rotation matrix A
            R_A = A(1:3, 1:3);

            % Select the translation part
            t_A = A(1:3, 4);
            t_B = B(1:3, 4);

            % Update the measurement matrix M_t
            M_t((i-1)*3+1 : i*3, 1:3) = R_A - eye(3) ;
            M_t((i-1)*3+1 : i*3, 4) = -(Rot*t_B - t_A);
        end
    end
    % Recover t_X
    [~, ~, V] = svd(M_t);
    t = V(:,end);
    t = t/t(4); % enforce last element to be 1
    t = t(1:3); 

    % Build the whole 4 by 4 transformation matrix
    T = [Rot t;0 0 0 1];
end