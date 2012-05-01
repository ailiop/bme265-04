function t = rrtranslation (scale, rot, tcomI, tcomJ)
%
% RRTRANSLATION Radon transform image registration; total translation
% vector estimation.
%
% SYNTAX
%
%   T = RRTRANSLATION (SCALE, ROT, TCOMI, TCOMJ)
%
% DESCRIPTION
%
%   T = RRTRANSLATION(SCALE,ROT,TCOMI,TCOMJ) computes the translation
%   estimate for the affine transform that links two images. SCALE is the
%   relative scaling factor between the two images, TCOMI and TCOMJ are
%   translation vectors that register the images' centers of mass with the
%   axes' origin, and ROT is their relative rotation angle (assuming they
%   are algined). The translation estimate T is the translation vector that
%   transforms the anchor frame (I) to the other one (J).
%
% ALGORITHM
%
%   The computation follows the model in [1]. This function is intended to
%   be used in conjuction with the other functions that implement this
%   model, which would return the appropriate input arguments.
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
% See also rrscale.m, rrangle.m, rrshiftcom.m, radonreg.m.
%


%% COMPUTATION

% this computational step simply combines previous computations to get the
% total translational motion
t = [(tcomJ(1) * cosd(rot) - tcomJ(2) * sind(rot) - tcomI(1)) / scale;
     (tcomJ(2) * cosd(rot) + tcomJ(1) * sind(rot) - tcomI(2)) / scale];

% % negate the computed translation vector
% t = -t;


end
