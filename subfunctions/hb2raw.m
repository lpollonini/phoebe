function [Y1,Y2] = hb2raw(hb1,hb2, ext)
%HB2RAW Converts Hb data to raw intensity measurements (Hb->OD->Intensities)
% Arguments
% Input
%
% hb1 : matrix with Hb data [#samples x (#channels)] from WL1
% hb2 : matrix with Hb data [#samples x (#channels)] from WL2
% ext: exctintion coefficients
%
% Output
% Y1 : Intensity values for first wavelength 1
% Y2 : Intensity values for first wavelength 2
%
% Notes:
% 1. The chosen DPF value MUST match the value used in raw -> Hb
% conversion by the software streaming the Hb data.
% 2. File spectra.mat containing the extinction coefficients is required.
% Version 0.1 Initial state
% Version 0.2 Changes in input arguments (two hb matrices, no SD order
% information)
% Version 0.3 Changes in input arguments (two hb matrices, extintion coeffs)

Y1 = zeros(size(hb1));
Y2 = zeros(size(hb2));
for j = 1:size(hb1,2)
    Y = [hb1(:,j),hb2(:,j)]./1e6 * ext';
    Y1(:,j) = Y(:,1); 
    Y2(:,j) = Y(:,2);
end

% Convert OD to intensity
% Y1 = exp( -bsxfun(@minus, Y1, 3) );
% Y2 = exp( -bsxfun(@minus, Y2, 3) );
Y1 = exp(-Y1);
Y2 = exp(-Y2);
if ~isreal(Y1)||~isreal(Y2)
    warning('OD contains complex numbers');
end
