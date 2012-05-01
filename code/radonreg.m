function [scale, rot, trans] = radonreg (I, J, angles)
%
% RADONREG Radon transform image registration.
%
% SYNTAX
%
%   [SCALE, ROT, TRANS] = RADONREG (I, J)
%
% DESCRIPTION
%
%   [SCALE,ROT,TRANS] = RADONREG(I,J) estimates the affine transformation
%   parameters that register the two specified images, I and J. The
%   estimation procedure takes place in the Discrete Radon domain. The
%   returned values are estimates of the parameters of the affine
%   transformation that was applied to I in order to obtain J.
%
%   [SCALE,ROT,TRANS] = RADONREG(...,ANGLES) performs the estimation in the
%   Discrete Radon domain where the Radon projections occur along the set
%   of lines whose angles (in degrees) with the x-axis are specified in the
%   vector ANGLES. By default, ANGLES is set to (1:180).
%
%   For every angle in ANGLES, the counter-clockwise orthogonal angle must
%   also be present. That is, the length of ANGLES must be an even number
%   and
%           ANGLES(A+H) = ANGLES(A) + 90
%   where H = (length(ANGLES) / 2) and A is an index in {1,...,H}.
%
% ALGORITHM
%
%   The model for estimation of the affine geometric transformation's
%   parameteters is the one presented in [1].
%
%   This algorithm assumes that the image matrices have been appropriately
%   padded and that they were of the same size before any scaling took
%   place.
%
% EXAMPLE
%
%   scale = 1.32;
%   rot   = 23.1;
%   trans = [-8.3 2.0];
%   I = imread('cameraman.tif');
%   I = padarray(I,floor(size(I)/2));
%   J = imaffinetransform(I,scale,trans,rot);
%   [est.scale, est.rot, est.trans] = radonreg(I,J);
%   estimates = sprintf(['scale       = %.3f\n' ...
%       'rotation    = %.3f\n' ...
%       'translation = [%.3f %.3f]'], ...
%       est.scale, est.rot, est.trans(1), est.trans(2))
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
% See also  rrscale.m, rrangle.m, rrshiftcom.m, rrtranslation.m,
%           rrpadscale.m, rrimtranslate.m, affinemtx2.m, radon.
%


%% PARAMETERS

SCALEMODE    = 'median';      % mode of scaling estimation
SHIFTCOMMODE = 'median';      % mode of center-of-mass shifting estimation
ANGLERESAMP  = 4;           % angle resampling factor
ANGLEINTERP  = 'linear';    % angle resampling interpolation method
ANGLEOPTIM   = 'iterative'; % angle estimation optimisation method
ANGLECOST    = 'sae';       % angle estimateion optimisation cost method


%% DEFAULTS

% project among lines at angles (1:180) by default
if ~exist( 'angles', 'var' ) || isempty( angles )
    angles = 1:1:180;
end


%% INITIALISATION

% make sure the images are in 'double' format
I = im2double( I );
J = im2double( J );

% compute the Radon transforms of the images
RI = radon( I, angles );
RJ = radon( J, angles );


%% REGISTRATION: SCALE

% estimate the scaling factor
scale = rrscale( RI, RJ, [], SCALEMODE );

% scale the non-anchor frame, in the Radon domain
t_sc = affinemtx2( 'scale', [1, (1/scale)] );
T_sc = maketform( 'affine', t_sc );
RJ_sc = (1/scale) * imtransform( RJ, T_sc );

% make sure that the Radon transforms of the two frames have the same size
[RI, RJ_sc] = rrpadscale( RI, RJ_sc );


%% REGISTRATION: ROTATION

% estimate the translation vectors that place the frames' centers of mass
% to the axes' origin
vI_org = rrshiftcom( RI   , [], angles, SHIFTCOMMODE );
vJ_org = rrshiftcom( RJ_sc, [], angles, SHIFTCOMMODE );

% translate the frames accordingly, in the Radon domain
RI_org = rrimtranslate( RI,    vI_org );
RJ_org = rrimtranslate( RJ_sc, vJ_org );


% figure; subplot(1,2,1); imshow(RI_org,[]); subplot(1,2,2); imshow(RJ_org,[]); colormap hot


% estimate the rotation angle
rot = rrangle( RI_org, RJ_org, angles, ...
    ANGLERESAMP, ANGLEINTERP, ANGLEOPTIM, ANGLECOST );


%% REGISTRATION: TRANSLATION

% compute the total translation vector
trans = rrtranslation( 1/scale, -rot, -vI_org, -vJ_org );


end
