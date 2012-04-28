function J = imrotatecrop (I, angle, direction)
%
% IMROTATECROP Rotate an image and crop the output to the initial size.
%
% SYNTAX
%
%   J = IMROTATECROP (I, ANGLE)
%   J = IMROTATECROP (I, ANGLE, DIRECTION)
%
% DESCRIPTION
%
%   J = IMROTATECROP(I,ANGLE) applies a rotation transformation of ANGLE
%   degrees to image I and crops the output, J, so that its size is equal
%   to that of I. If the input image, I, is not zero-padded, this will
%   result in loss of image pixels (unless the rotation angle is a multiple
%   of 90).
%
%   J = IMROTATECROP(...,DIRECTION) specifies whether the transformation is
%   a "forward" or an "inverse" one, conceptually speaking. This is useful
%   when one wants to transform a rotated and cropped image back to the
%   original one, because the cropping rectangle alignment must be shifted
%   by 1 pixel in order for the images to be properly aligned. DIRECTION
%   can be {'forward'|'fwd'} or {'inverse'|'inv'}. The default behaviour is
%   that of a 'forward' direction transformation.
%
% ALGORITHM
%
%   While performing the "forward" direction rotation-and-crop, the NW
%   pixel index of the cropping rectangle is at 
%       floor( (size(I) + 1) ./ 2 ) + 1,
%   whereas the "inverse" direction cropping rectangle's NW corner is at
%       floor( (size(I) + 1) ./ 2 )
%
% AUTHOR
%
%   Alexandros-Stavros Iliopoulos <ailiop@cs.duke.edu>
%
%
% See also imtransform, imcrop.
%


%% DEFAULTS

% default transformation direction is 'forward'
if ~exist( 'direction', 'var' ) || isempty( direction )
    direction = 'forward';
end


%% ROTATION

% create the rotation transformation, depending on the transformation
% direction
switch direction
    case {'forward', 'fwd'}
        t = affinemtx2( 'rotation', angle );
    case {'inverse', 'inv'}
        t = affinemtx2( 'rotation', -angle );
end
T = maketform( 'affine', t );

% apply the rotation transformation
I_rot = imtransform( I, T );


%% CROP

% calculate the input (and output) image size
imsize = size( I );

% calculate the difference in the two images' sizes
sizediff = size( I_rot ) - size( I );

% calculate the NW corner of the cropping rectangle, depending on the
% transformation direction
switch direction
    case {'forward', 'fwd'}
        cropNW = floor( ([sizediff(1) sizediff(2)] + 1) ./ 2 ) + 1;
    case {'inverse', 'inv'}
        cropNW = floor( ([sizediff(1) sizediff(2)] + 1) ./ 2 );
end

% set the cropping rectangle's parameters for use within imcrop
croprect = [cropNW(2) cropNW(1) (imsize(2)-1) (imsize(1)-1)];

% crop the rotated image
J = imcrop( I_rot, croprect );


end
