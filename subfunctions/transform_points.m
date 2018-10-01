function p_out = transform_points(p,R,t)

p_out = R*p' + repmat(t,[1 size(p,1)]);
p_out = p_out';
