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
%   specified projection line slopes (provided as a vector of indices that
%   specify columns of RI and RJ) and then combines the estimates into a
%   single one. By default, the scaling parameter is estimated for all
%   corresponding (in the images' current alignment) slopes.
%
%   S RRSCALE(...,OUTMODE) uses the specified method to combine the
%   estimated scaling parameters. OUTMODE can take the following values:
%       - 'mean' | 'average'
%           returns the mean value of all computed estimates.
%       - 'median'
%           returns the median value of all computed estimates.
%   If no OUTMODE is specified, it is set to 'mean'.
%
% ALGORITHM
%
%   The computation is done according to the model in [1].
%
% EXAMPLE
%
%   s_true = 2;
%   I = imread('cameraman.tif');
%   J = imaffinetransform(I,s_true,[],[])
%   RI = radon(I);
%   RJ = radon(J);
%   s_estim = rrscale(RI,RJ);
%   error = s_true - s_estim
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
% See also  imaffinetransform.m, rrangle.m, rrtranslation.m, radonreg.m,
%           rrpadscale.m.
%


%% DEFAULTS

% estimate the scale using all available projection angles
if ~exist( 'angles', 'var' ) || isempty( angles )
    angles = 1 : size(RI,2);
end

% return the average of all estimates
if ~exist( 'outmode', 'var' ) || isempty( outmode )
    outmode = 'mean';
end


%% SCALE ESTIMATION

% estimate the scaling parameter using each specified projection angle
estimates = sqrt( sum( RI(:,angles), 1 ) ./ sum( RJ(:,angles), 1 ) );
estimates = 1 ./ estimates;

% combine the possibly multiple estimates into one
switch outmode
    case {'mean', 'average'}
        s = mean( estimates );
    case {'median'}
        s = median( estimates );
end


end
