function p = plot_mesh(handle, faces, vertices, opacity, tissue)
    
axes(handle);
if any(any(faces == 0)) %FIX: useful?
    faces = faces+1;
end
if strcmp(tissue,'scalp')
    color = [1,.75,.65];
elseif strcmp(tissue,'brain')
    color = [.93,.93,.93];
end
p = patch('vertices', vertices, 'faces', faces, 'facecolor', color); 
set(p,'EdgeColor','none')
set(p,'FaceAlpha',opacity)
set(p, 'specularcolorreflectance', 0, 'specularexponent',50);
set(p,'DiffuseStrength',.6,'SpecularStrength',0,'AmbientStrength',.4,'SpecularExponent',5);
axis equal
axis off;
axis vis3d
view(18,8);
set(gca, 'CameraViewAngle', 6)
lighting phong;

end
