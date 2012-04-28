function J = imaffinetransform (I, scale, trans, rot, direction)
%
% IMAFFINETRANSFORM Apply a scaling, translation and rotation
% transformation to image.
%
% SYNTAX
%
%   J = IMAFFINETRANSFORM (I, SCALE, TRANS, ROT)
%   J = IMAFFINETRANSFORM (..., DIRECTION)
%
% DESCRIPTION
%
%   J = IMAFFINETRANSFORM(I,SCALE,TRANS,ROT) scales, translates and rotates
%   image I to produce image J. The respective transformation parameters
%   are SCALE, TRANS and ROT (as expected by AFFINEMTX2). The size of the
%   resulting image might be different from that of the input one's, due to
%   the scaling transformation, but the image is cropped after the rotation
%   (so that it has the same size as before the rotation).
%
%   Any transformation parameter may be [], which means that no such
%   transformation will be applied.
%
%   J = IMAFFINETRANSFORM(...,DIRECTION) specifies whether the
%   transformation is a "forward" or "inverse" one (DIRECTION is a string
%   that takes one of these values). If it is specified as 'inverse', then,
%   the negative (or inverted, for scaling) values of the parameters are
%   used, and the transformation sequence is reversed. By default, this is
%   set to 'forward'.
%
% AUTHOR
%
%   Alexandros-Stavros Iliopoulos <ailiop@cs.duke.edu>
%
%
% See also affinemtx2.m, maketform, imtransform, imrotatecrop.m.
%


%% DEFAULTS

% if a transformation parameter is [], then set it so that no
% transformation will take place
if ~exist( 'scale', 'var' ) || isempty( scale )
    scale = 1;
end
if ~exist( 'trans', 'var' ) || isempty( trans )
    trans = [0 0];
end
if ~exist( 'rot', 'var' ) || isempty( rot )
    rot = 0;
end
if ~exist( 'direction', 'var' ) || isempty( direction )
    direction = 'forward';
end


%% TRANSFORMATION OBJECTS

% create the scaling transformation
tscale = affinemtx2( 'scale', scale );
Tscale = maketform( 'affine', tscale );
if strcmp( direction, 'inverse' ) || strcmp( direction, 'inv' )
    Tscale = fliptform( Tscale );
end

% create the translation transformation
ttrans = affinemtx2( 'translation', trans );
Ttrans = maketform( 'affine', ttrans );
if strcmp( direction, 'inverse' ) || strcmp( direction, 'inv' )
    Ttrans = fliptform( Ttrans );
end

% rotation is applied through IMROTATECROP, hence we needn't create a
% transformation object
if strcmp( direction, 'inverse' ) || strcmp( direction, 'inv' )
    rot = -rot;
end


%% APPLY TRANSFORMATIONS

% scale, translate and rotate the image (reverse the order for 'inverse'
% transformation)
switch direction
    
    case {'forward', 'fwd'}
        I2 = imtransform( I,  Tscale, 'XYScale', 1 );
        I3 = imtransform( I2, Ttrans, ...
            'XData', [1 size(I2,2)], 'YData', [1 size(I2,1)] );
        I4 = imrotatecrop( I3, rot );
        
    case {'inverse', 'inv'}
        I2 = imrotatecrop( I, rot );
        I3 = imtransform( I2, Ttrans, ...
            'XData', [1 size(I2,2)], 'YData', [1 size(I2,1)] );
        I4 = imtransform( I3, Tscale, 'XYScale', 1 );
        
end

% output transformed image
J = I4;


end
