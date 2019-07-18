function [idx, dist] = sd_rangesearch(det_pts,src_pts,radius)
%SD_RANGESEARCH Equivalent of MATLAB function "rangesearch" included in
%Statistics and Machine Learning Toolbox

idx = cell(size(src_pts,1),1);
dist = cell(size(src_pts,1),1);
for i = 1:size(src_pts,1)
    idx{i}=[];
    dist{i}=[];
    for j = 1:size(det_pts,1)
        euclid_dist = sqrt( (det_pts(j,1)-src_pts(i,1))^2 + (det_pts(j,2)-src_pts(i,2))^2 + (det_pts(j,3)-src_pts(i,3))^2);
        if euclid_dist<radius
            idx{i} = [idx{i} j];
            dist{i} = [dist{i} euclid_dist];
        end
    end
    [dist{i},order] = sort(dist{i});
    temp = idx{i};
    idx{i} = temp(order);
end
end

