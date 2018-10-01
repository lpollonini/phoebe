function [R,t] = rigid_transform_3D(A,B)
% rigid_transform_3D(A,B) computes the rotation matrix R and the
% translation array t to bring the triangle with vertices A (3x3) onto
% triangle B (3x3)

if nargin ~= 2
    error('Missing parameters');
end

centroid_A = mean(A,1);
centroid_B = mean(B,1);

N = size(A,1);
H = (A - repmat(centroid_A, N, 1))' * (B - repmat(centroid_B, N, 1));
[U,~,V] = svd(H);

R = V*U';
if det(R) < 0
%         printf('Reflection detected\n');
    V(:,3) = V(:,3)* -1;
    R = V*U';
end

t = -R*centroid_A' + centroid_B';

end


