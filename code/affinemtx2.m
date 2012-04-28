function T = affinemtx2 (trans, param)
%
% AFFINEMTX2 Affine transformation matrix for 2D images.
%
% SYNTAX
%
%   T = AFFINEMTX2 (TRANS, PARAM)
%
% DESCRIPTION
%
%   T = AFFINEMTX2(TRANS,PARAM) returns the 3-by-3 matrix of the 2D affine
%   transformation of type TRANS whose values are determined by PARAM. The
%   input TRANS can have the following values:
%   - 'rotation' | 'rot'
%       defines a rotation matrix for a rotation angle of PARAM degrees
%   - 'translation' | 'trans' | 'tx'
%       defines a translation matrix; PARAM can either be scalar (equal
%       translation for both axes) or a 2-element vector (the 1st element
%       corresponds to the y-axis translation and the 2nd one to the
%       x-axis)
%   - 'scale' | 'sc'
%       defines a scaling matrix; PARAM can either be scalar (equal scaling
%       for both axes) or a 2-element vector (the 1st element corresponds
%       to the y-axis scaling and the 2nd one to the x-axis).
%
%   The returned matrix T can be applied to a homogeneous coordinate vector
%   X as Y = X * T.
%
% EXAMPLE
%
%   I = imread( 'cameraman.tif' );
%   t1 = affinemtx2( 'scale', [2.0 0.5] );
%   t2 = affinemtx2( 'rotation', 30 );
%   t = t1 * t2;
%   T = maketform( 'affine', t );
%   J = imtransform( I, T );
%   figure; imshow(I); title( 'original image' )
%   figure; imshow(J); title( 'transformed image' )
%
% AUTHOR
%
%   Alexandros-Stavros Iliopoulos <ailiop@cs.duke.edu>
%
%
% See also maketform, imtransform.
%


%% INITIALISATION

% initiliase the transformation matrix
T = eye(3);

% force the 'param' input into a row vector
param = param(:).';


%% TRANSFORMATION MATRIX

% construct the transformation matrix according to the specified type
switch trans
    
    case {'rot', 'rotation'}
        T(1:2,1:2) = [cosd(param) sind(param); -sind(param) cosd(param)];
        
    case {'tx','translation', 'trans'}
        T(3,1:2) = param;
        
    case {'sc', 'scale'}
        if length(param) == 1
            scales = [param param 1];
        else  % length(param) == 2
            scales = [param 1];
        end
        T = T .* diag(scales);
        
end


end
