function t = rrshiftcom (R, xp, angles, outmode)
%
% RRSHIFTCOM Radon transform image registration; translation of center of
% mass to origin.
%
% SYNTAX
%
%   T = RRSHIFTCOM (R)
%   T = RRSHIFTCOM (R,XP)
%   T = RRSHIFTCOM (...,ANGLES)
%   T = RRSHIFTCOM (...,OUTMODE)
%
% DESCRIPTION
%
%   T = RRSHIFTCOM(R) returns a 2-by-1 translation vector that defines the
%   2D shift that must be applied to the image whose Radon transform is R
%   in order for its center of mass to be at the origin. T(1) contains the
%   translation offset along the x-axis and T(2) contains the translation
%   offset along the (-y)-axis.
%
%   T = RRSHIFTCOM(R,XP) provides the function with the radial coordinates
%   of the Radon projection lines. These are assumed to range in [-P,+P],
%   where P = floor((M-1)/2) and M is the number of rows in R, i.e. the
%   number of projections for a given angle.
%
%   T = RRSHIFTCOM(...,ANGLES) estimates the translation vector using the
%   Radon projections for each angle in the specified vector ANGLES. By
%   default, the output vector results from averaging all such estimates.
%
%   T = RRSHIFTCOM(...,OUTMODE) combines the translation vectors that
%   estimated for different projection angles using the specified method.
%
%   This function is useful as part of estimating the angle between two
%   rotated images, as it allows them to have a common point of
%   translational reference.
%
% ALGORITHM
%
%   The computations follow the model in [1]. This is a sub-step of finding
%   the rotation angle between two images.
%
%   The columns in the left half of the Radon transform R must correspond
%   to angles that are perpendicular to the angles that correspond to the
%   columns in the right half. (I.e. R(:, a + floor((size(R,2)+1)/2))
%   contains the projections on the line at angle (a+90) degrees.)
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
% See also rrangle.m, radonreg.m.
%


%% DEFAULTS

if ~exist( 'xp', 'var' ) || isempty( xp )
    maxoffset = (size(R,1) - 1) / 2;
    xp = (-maxoffset : 1 : maxoffset).';
end

if ~exist( 'angles', 'var' ) || isempty( angles )
    angles  = 1 : floor( size(R,2) / 2 );
end

if ~exist( 'outmode', 'var' ) || isempty( outmode )
	outmode = 'mean';
end


%% INITIALISATION

% calculate the column index offset that corresponds to a 90-degree
% difference between two Radon projection lines
plus90deg = floor( (size(R,2) + 1) / 2 );

% get the shifted angle indices
angles_plus90 = angles + plus90deg;
% wrapIdx = find( angles_plus90 > 180 );
% angles_plus90(wrapIdx) = mod( angles_plus90(wrapIdx), 180 );

% expand the radial coordinate vectors to matrices
xp_mat = repmat( xp, 1, length(angles) );


%% SHIFT ESTIMATIONS

% compute the fractions of Radon transform integrals (see [1])
rsums_angles = sum( R(:,angles), 1 );
wrsums_angles   = sum( xp_mat .* R(:,angles), 1 );
wrsums_angles90 = sum( xp_mat .* R(:,angles_plus90), 1 );
rfracs    = wrsums_angles ./ rsums_angles;
rfracs_90 = wrsums_angles90 ./ rsums_angles;

% compute the translation vector elements that register the image's center
% of mass with the origin
tx = cosd(angles) .* rfracs - sind(angles) .* rfracs_90;
ty = sind(angles) .* rfracs + cosd(angles) .* rfracs_90;


%% COMBINATION OF ESTIMATES

% compute a single estimate for the translation vector
switch outmode
    case {'mean', 'average'}
        t = [mean(tx); mean(ty)];
end

% map the estimated translation vector to the MATLAB-image space (1st
% dimension is y-axis and 2nd dimension is (-x)-axis)
t(1) = -t(1);
% t = flipud( t );


end
