function points = sample_on_ellipse(e, nb_points)
% Samples n evenly spaced points along ellise of structure e
alpha = linspace(0, 2*pi, nb_points);
transformation = [cos(e.phi) -sin(e.phi) e.X0_in; 
    sin(e.phi) cos(e.phi) e.Y0_in;
    0 0 1];
points = [e.a*cos(alpha); e.b*sin(alpha); ones(1,nb_points)];
points = transformation * points;
points = points(1:2, :)';
end
