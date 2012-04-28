function R_trans = rrimtranslate (R, v)
%
% RRIMTRANSLATE Radon transform image registration; translate an image in
% the Radon transform domain.
%
% SYNTAX
%
%   R_TRANS = RRIMTRANSLATE (R, V)
%
% DESCRIPTION
%
%   R_TRANS = RRIMTRANSLATE(R,V) returns the Radon transform of the image
%   whose Radon transform is R, if the image is translated according to the
%   2-element vector V. V(1) contains the translation shift in the x-axis
%   and V(2) contains the translation shift in the (-y)-axis.
%
% ALGORITHM
%
%   Spatial translation of an image in the Radon domain corresponds to
%   shifting every column of the image's DRT depending on the angle it
%   corresponds to.
%
%   The translation model is as in [1].
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
% See also rrshiftcom.m, rrscale.m, radonreg.m, affinemtx2.m, maketform,
% imtransform.
%


%% INITIALISATION

% pre-allocate space for the translated Radon transform
R_trans = zeros( size(R) );


%% TRANSLATION

% translate each column of the DRT (column correspond to projection angles)
for phi = 1 : size(R, 2)
    
    % create the 1D affine transform for each projection line slope
    % ** the y-translation coefficient is negated because the MATLAB y-axis
    % ** corresponds to the (-y)-axis in the typical Cartesian plane
    t = affinemtx2( 'translation', ...
                    [0, sum( v .* [cosd(phi); -sind(phi)] )] );
    T = maketform( 'affine', t );
    
    % apply it
    R_trans(:,phi) = imtransform( R(:,phi), T, ...
                        'XData', [1 1], 'YData', [1 size(R,1)] );
end


end
