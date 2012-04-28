function [scale, rot, trans] = radonreg (I, J)
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
%   parameters that register the two spcified images, I and J.
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
% See also rrscale.m, rrangle.m, rrshiftcom.m, rrtranslation.m,
% rrpadscale.m, affinemtx2.m.
%


%% DEFAULTS

angles = 1:180;



%% INITIALISATION

% make sure the images are in 'double' format
I = im2double( I );
J = im2double( J );

% compute the Radon transforms of the images
RI = radon( I );
RJ = radon( J );


%% REGISTRATION

% estimate the scaling factor
scale = rrscale( RI, RJ, angles, 'mean' );

% scale the non-anchor frame, in the Radon domain
t_sc = affinemtx2( 'scale', [1, (1/scale)] );
T_sc = maketform( 'affine', t_sc );
RJ_sc = (1/scale) * imtransform( RJ, T_sc );

% make sure that the Radon transforms of the two frames have the same size
[RI, RJ_sc] = rrpadscale( RI, RJ_sc );

% estimate the translation vectors that place the frames' centers of mass
% to the axes' origin
vI_org = rrshiftcom( RI    );%, [], 1:90, 'mean' );
vJ_org = rrshiftcom( RJ_sc );%, [], 1:90, 'mean' );

% translate the frames accordingly, in the Radon domain
RI_org = rrimtranslate( RI,    vI_org );
RJ_org = rrimtranslate( RJ_sc, vJ_org );

% estimate the rotation angle
rot = rrangle( RI_org, RJ_org, 'iterative', 'sse' );

% compute the total translation vector
trans = rrtranslation( 1/scale, -rot, vI_org, vJ_org );


end
