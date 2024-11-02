function C = param2ellipse(el)
% Purpose: converts ellipse parameters stucture into 3 by 3 conic matrix
% form

% Input:
% el = struct( ...
%         'a',el.a/env_size_i,...
%         'b',el.b/env_size_i,...
%         'phi',el.phi,...
%         'X0_in',el.X0_in,...
%         'Y0_in',el.Y0_in );%inner ellipse

% Output:
% - C: 3 by 3 ellipse conic matrix

if isempty(el)
    error('Ellipse is empty')
end

T     = [ cos(el.phi),-sin(el.phi),el.X0_in; sin(el.phi),cos(el.phi),el.Y0_in; 0,0,1 ];
C     = transpose(inv(T))*diag([1/el.a^2;1/el.b^2;-1])*inv(T);

% Get signed conic (so that o*C*o' > 0  when o is inside ellipse C)
o = [el.X0_in el.Y0_in 1]; % ellipse center, homogeneous 
C = C*sign(o*C*o');

% Normalize the top left 2 by 2 block of the ellipse matrix
if (det(C(1:2,1:2)) < 0)
    disp('Warning!!! Ellipse determinant is negative');
end
C = C* sqrt(1/det(C(1:2,1:2)));
