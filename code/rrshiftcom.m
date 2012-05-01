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
%   default, the output vector results from combining estimates obtained by
%   all available angles.
%
%   In order for the estimate to be computed correctly, the elements in the
%   second half of the ANGLES vector must be indices of columns of R that
%   correspond to projection angles that are counter-clockwise orthogonal
%   to the angles that correspond to the indices in the first half of
%   ANGLES.
%
%   T = RRSHIFTCOM(...,OUTMODE) combines the translation vectors that
%   estimated for different projection angles using the specified method.
%   OUTMODE can take the following values:
%       - 'mean' | 'average'
%           returns the mean value of all computed estimates.
%       - 'median'
%           returns the median value of all computed estimates.
%   If no OUTMODE is specified, it is set to 'mean'.
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
% See also  rrangle.m, radonreg.m.
%


%% DEFAULTS

% work with all projection displacements
if ~exist( 'xp', 'var' ) || isempty( xp )
    maxoffset = (size(R,1) - 1) / 2;
    xp = (-maxoffset : 1 : maxoffset).';
end

% the set of "lower" angles is the first half of columns in R
if ~exist( 'angles', 'var' ) || isempty( angles )
%     angles  = 1 : floor( size(R,2) / 2 );
    angles = 1 : size(R,2);
end

% average all estimates
if ~exist( 'outmode', 'var' ) || isempty( outmode )
	outmode = 'mean';
end


%% INITIALISATION

% get the indices of the columns that correspond to angles that are lower
% (or greater, respectively) than 90 degrees
angleidx_lt90 = 1 : floor( length(angles) / 2 );
angleidx_gt90 = (ceil( length(angles) / 2 ) + 1) : length(angles);

% get the corresponding angle sets
angles_lt90 = angles(angleidx_lt90);
angles_gt90 = angles(angleidx_gt90);

% % calculate the column index offset that corresponds to a 90-degree
% % difference between two Radon projection lines
% plus90deg = ceil( size(R,2) / 2 );
% 
% % get the shifted angle indices
% angles_gt90 = angles_lt90 + plus90deg;

% form two sets of angles whose corresponding elements point to
% perpendicular projections
angles_1 = [angles_lt90, angles_gt90];  % phi
angles_2 = [angles_gt90, angles_lt90];  % phi + (pi/2)

% form the corresponding column index sets
angleidx_1 = [angleidx_lt90, angleidx_gt90];
angleidx_2 = [angleidx_gt90, angleidx_lt90];

% the second half of angles in angles_2 correspond to flipped columns of
% the DRT (as the angles are now in the range (90,270]).
% form two copies of the radial coordinate vector, expanded to matrices,
% that would facilitate the operations under this consideration
xp_mat_1 = repmat( xp, 1, length(angles_1) );
xp_mat_2 = horzcat(  repmat( xp, 1, length(angles_gt90) ), ...
                    -repmat( xp, 1, length(angles_lt90) ) );


%% SHIFT ESTIMATIONS

% compute the fractions of Radon transform integrals (see [1])
psums_angles_1  = sum( R(:,angleidx_1), 1 );
psums_angles_2  = sum( R(:,angleidx_2), 1 );
wpsums_angles_1 = sum( xp_mat_1 .* R(:,angleidx_1), 1 );
wpsums_angles_2 = sum( xp_mat_2 .* R(:,angleidx_2), 1 );
fracs_11        = wpsums_angles_1 ./ psums_angles_1;
fracs_21        = wpsums_angles_2 ./ psums_angles_1;
fracs_22        = wpsums_angles_2 ./ psums_angles_2;

% compute the translation vector elements that register the image's center
% of mass with the origin
tx = cosd(angles_1) .* fracs_11 - sind(angles_1) .* fracs_21;
ty = sind(angles_1) .* fracs_11 + cosd(angles_1) .* fracs_22;


%% COMBINATION OF ESTIMATES

% compute a single estimate for the translation vector
switch outmode
    case {'mean', 'average'}
        t = [mean(tx); mean(ty)];
    case {'median'}
        t = [median(tx); median(ty)];
end

% map the estimated translation vector to the MATLAB-image space (1st
% dimension is x-axis and 2nd dimension is (-y)-axis)
t(1) = -t(1);
% t = flipud( t );


end
