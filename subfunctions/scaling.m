function [A,s,d] = scaling(A,s,d,B,factor)
    
    centroid_A = mean(A,1);
    centroid_s = mean(s,1);
    centroid_d = mean(d,1);
    centroid_B = mean(B,1);
    
    N = size(A,1);
    
    Acen = A - repmat(centroid_A, N, 1);
    scen = s - repmat(centroid_s, size(s,1), 1);
    dcen = d - repmat(centroid_d, size(d,1), 1);
    Bcen = B - repmat(centroid_B, N, 1);
    
    scale = factor * mean(sqrt(sum(Bcen.^2,2))./sqrt(sum(Acen.^2,2)));
    
    Acen = Acen*scale;
    scen = scen*scale;
    dcen = dcen*scale;
    
    A = Acen + repmat(centroid_A, N, 1);
    s = scen + repmat(centroid_s, size(s,1), 1);
    d = dcen + repmat(centroid_d, size(d,1), 1);
    
end