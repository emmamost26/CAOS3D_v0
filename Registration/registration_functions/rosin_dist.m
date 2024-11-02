function dist = rosin_dist(el, P, imageSize)
% Purpose: Let P the point in the image, E be the ellipse and H be the hyperbola confocal to E
% and passing through P. Rosin approximates dist(P,E) by dist(P,I) where I
% is the intersection between H and E.

% Input:
% - el: ellipse struture (with attributes xc, yc, ae, be, phi)
% - P: 2D point coordinates (2 by 1) 

% Output:
% - dist: distance in pixels, approximated using confocal hyperbola method

plot_ = 0;
xc = el.X0_in; % ellipse center (xc, yc)
yc = el.Y0_in;
ae = el.a; % semi axis in x direction
be = el.b; % semi axis in y direction
phi = el.phi; % angular tilt w.r.t. horizontal

E_tilt = param2ellipse(el);

if plot_ == 1
    figure;
    plotEllipse(inv(E_tilt), 'r', imageSize); hold on;
    plot(P(1), P(2), 'r*');
end


% Transform P into canonical coordinate frame, i.e. reference frame in
% which ellipse is centered in (0,0) and phi = 0, P_canon = inv(T)*P
T = [cos(phi) -sin(phi) xc;
    sin(phi) cos(phi) yc;
    0 0 1];

P = T\[P;1];

% Treat edge cases
% P lies on E
%P = [ae;0]; %--> ERROR
x = P(1); y = P(2);
f = sqrt(abs(ae^2 - be^2));
if x^2/ae^2 + y^2/be^2 == 1 % P lies on E
    dist = 0;
    return;
elseif x == 0 && y == 0 % P lies on center of E
    dist = min(ae, be);
    return;
elseif y == 0 && x < -f
    dist = abs(ae+y);
    return;
elseif y == 0 && x > f
    dist = abs(ae-y);
    return;
elseif abs(x) < 1e-3 
    dist = abs(abs(x) - be); % assuming that the points are always relatively close to the outline and that the ellipse is relatively circular
    return;
elseif abs(y) < 1e-3
    dist = abs(abs(x) - ae); % assuming that the points are always relatively close to the outline and that the ellipse is relatively circular
    return;
end

% Canonical ellipse equation
% E := x^2/ae^2 + y^2/be^2 = 1   fe = sqrt(ae^2 - be^2)

% Hyperbola equation
% H := x^2/ah^2 - y^2/bh^2 = 1   fh = sqrt(ah^2 + bh^2)

% For confocal conics: fe = fh

% Plot ellipse in canonical reference frame
el.phi = 0; el.X0_in = 0; el.Y0_in = 0;
E = param2ellipse(el);

if plot_ == 1
    figure;
    plotEllipseGeneral(inv(E), 'r', imageSize);
    hold on;
    plot(P(1), P(2), 'b*');
    plot([-f f], [0 0], 'y*')
end

% Solve for ah and bh
% Let A := ah^2, X := x^2, Y := y^2, F = fe^2 = fh^2
F = f^2; 
X = x^2; Y = y^2;
if (X+Y+F)^2 - 4*X*F < 0
    error('negative delta in solving hyperbola equation')
end
% 2 solutions for A = ah^2. Only one solution satisfies A>0 and B=F-A>0
% (this is the case because of the uniqueness of the parabola passing
% through the focus and the point
A1 = 0.5*(X+Y+F+sqrt((X+Y+F)^2 - 4*X*F));
A2 = 0.5*(X+Y+F-sqrt((X+Y+F)^2 - 4*X*F));
if A1>0 && F-A1>0
    ah = sqrt(A1);
    bh = sqrt(F-A1);
    if plot_ == 1
        draw_hyperbola(ah, bh, imageSize,'g')   
    end

elseif A2>0 && F-A2>0
    ah = sqrt(A2);
    bh = sqrt(F-A2);
    if plot_ == 1
        draw_hyperbola(ah, bh, imageSize, 'b')
    end
else
    P
    E
    figure;
    plotEllipseGeneral(inv(E), 'r', imageSize);
    hold on;
    plot(P(1), P(2), 'b*');
    plot([-f f], [0 0], 'y*')
    error('Confocal hyperbola could not be found')

end

% Get I, the intersections between the hyperbola and the ellipse
% There are 4 solutions for I
xi1 = ah*sqrt((ae^2*(be^2+bh^2))/(ah^2*be^2+ae^2*bh^2));
xi2 = - ah*sqrt((ae^2*(be^2+bh^2))/(ah^2*be^2+ae^2*bh^2));
yi1 = be*bh*sqrt(ae^2-ah^2)/sqrt(ah^2*be^2+ae^2*bh^2);
yi2 = -be*bh*sqrt(ae^2-ah^2)/sqrt(ah^2*be^2+ae^2*bh^2);

if plot_ == 1
    plot([xi1 xi2 xi1 xi2], [yi1 yi1 yi2 yi2], 'r*')
end

% Calculate the distance between P and the 4 possible I. Keep the minimal
% one.
I = [xi1 xi1 xi2 xi2;
    yi1 yi2 yi1 yi2];

dists = (I - P(1:2)).^2;
dists = sqrt(dists(1,:) + dists(2,:));
[dist, idx] = min(dists);
I_opti = I(:, idx);
if plot_ == 1
    plot(I_opti(1), I_opti(2), 'ro');
end
end