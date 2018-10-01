function p = plot_mesh(handle, faces, vertices, opacity)
    
axes(handle);
if any(any(faces == 0)) %FIX: useful?
    faces = faces+1;
end
p = patch('vertices', vertices, 'faces', faces, 'facecolor', [1,.75,.65]);
set(p,'EdgeColor','none')
set(p,'FaceAlpha',opacity)
set(p, 'specularcolorreflectance', 0, 'specularexponent',50);
set(p,'DiffuseStrength',.6,'SpecularStrength',0,'AmbientStrength',.4,'SpecularExponent',5);
axis equal
axis off;
axis vis3d
view(18,8);
set(gca, 'CameraViewAngle', 6)
lightangle(225,30)
lighting phong;

end
