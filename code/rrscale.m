function s = rrscale (RI, RJ, angles, outmode)
%
% RRSCALE Radon transform image registration; scaling parameter estimation.
%
% SYNTAX
%
%   S = RRSCALE (RI, RJ)
%   S = RRSCALE (..., ANGLES)
%   S = RRSCALE (..., OUTMODE)
%
% DESCRIPTION
%
%   S = RRSCALE(RI,R2) estimates the scaling parameter S from the Radon
%   transforms, RI and RJ, of two images, which are related to each other
%   through an affine transformation.
%
%   S = RRSCALE(...,ANGLES) estimates the scaling parameter for each of the
%   specified projection line slopes and then combines the estimates into a
%   single one. By default, the scaling parameter is estimated for all
%   corresponding (in the images' current alignment) slopes.
%
%   S RRSCALE(...,OUTMODE) uses the specified method to combine the
%   estimated scaling parameters. By default, this is 'mean', which simply
%   averages the estimates.
%
% ALGORITHM
%
%   The computation is done according to the model in [1].
%
% EXAMPLE
%
%   s_true = 2;
%   t = affinemtx2('scale',s_true);
%   T = maketform('affine',t);
%   I = imread('cameraman.tif');
%   J = imtransform(I,T);
%   RI = radon(I);
%   RJ = radon(J);
%   s_estim = rrscale(RI,RJ);
%   s_true - s_estim
%
% REFERENCES
%
%   [1] Fawaz Hjouj, David W. Kammler, "Identification of Reflected,
%   Scaled, Translated, and Rotated Objects from their Radon Transforms."
%   IEEE Transaction on Image Processing, 17(3):301-310, March 2008.
%
% AUTHOR
%
%   Alexandros-Stavros Iliopoulos <ailiop@cs.duke.edu>
%
%
% See also affinemtx2.m, rrangle.m.
%


%% DEFAULTS

% if no options are specified, estimate scale using all projection angles
% and average
if nargin == 2
    angles  = 1 : size(RI,2);
    outmode = 'mean';
end


%% SCALE ESTIMATION

% estimate the scaling parameter using each specified projection angle
estimates = sqrt( sum( RJ(:,angles), 1 ) ./ sum( RI(:,angles), 1 ) );

% combine the possibly multiple estimates into one
switch outmode
    case {'mean', 'average'}
        s = mean(estimates);
end


end
