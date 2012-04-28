function r = rrangle (RI, RJ, optimmode, costmode)
%
% RRANGLE Radon transform image registration; rotation angle parameter
% estimation.
%
% SYNTAX
%
%   R = RRANGLE (RI, RJ)
%   R = RRANGLE (..., OPTIMMODE)
%   R = RRANGLE (..., COSTMODE)
%
% DESCRIPTION
%
%   R = RRANGLE(RI,RJ) estimates the rotation angle R from the Radon
%   transforms, RI and RJ, of two images, which are related to each other
%   through an affine transformation that does not include scaling.
%
%   R = RRANGLE(...,OPTIMMODE) performs the rotation angle estimate
%   optimization using the specified method. By default, this is done with
%   a brute-force, iterative approach, i.e. by checking all integer angles.
%
%   R = RRANGLE(...,COSTMODE) optimizes the specified cost measure. By
%   default, this is the sum of squared errors between the two images'
%   Radon transforms.
%
% ALGORITHM
%
%   The computations follow the model in [1]. The images are translated so
%   that their respective centers of mass are at the origin, in order for
%   the rotation angle to be found. It is important that the images be in
%   the same scale.
%
% EXAMPLE
%
%   r_true = 60;    % angle given in degrees
%   I = imread('cameraman.tif');
%   J = imrotatecrop( I, r_true );
%   RI = radon(I);
%   RJ = radon(J);
%   r_estim = rrangle(RI,RJ);
%   r_true - r_estim
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
% See also affinemtx2.m, imrotatecrop.m, rrscale.m, radonreg.m.
%


%% DEFAULTS

if ~exist( 'costmode', 'var' ) || isempty( costmode )
    costmode = 'sse';
end

if ~exist( 'optimmode', 'var' ) || isempty( optimmode )
    optimmode = 'iterative';
end


%% INITIALISATION

% get the size of the DRTs (both DRTs have the same size)
[rowN, colN] = size( RI );


%% COMPUTATION

% set the cost function
switch costmode
    case {'sse', 'l2-norm'}
        costfun = @(phi) sum( (RI(:) - radonrotate(RJ,phi)) .^ 2 );
%         costfun = @(phi) sum( (RI(:) - circshift(RJ(:), rowN*phi)) .^ 2 );
end

% solve the optimization problem in the specified manner
switch optimmode
    
    % iterative optimization
    case {'iterative', 'iter'}
        
        % prepare the iterative process
        mincost = Inf;
        
        % iteratively minimize the cost function
        for angle = 0 : (colN - 1)
            cost = costfun( angle );
            if cost < mincost
                mincost = cost;
                r = angle;
            end
        end
        
end


end


%% PRIVATE FUNCTIONS

%
% This "helper" function rotates an image in the Radon domain. RI is the
% DRT of the image and phi is the rotation angle in degrees. Essentially,
% this function shifts the DRT's columns circularly, flipping the columns
% that "wrap around" the DRT. The latter is done because a column that has
% wrapped around the DRT is a column that corresponds to a projection angle
% that is greater than 180 degrees, and MATLAB computes DRTs using angles
% 1:180.
%
% This functionality will need to become "smarter," should the Radon
% Registration suite support DRTs that are not defined over the angle set
% {1,...,180}.
%
function RJ = radonrotate (RI, phi)

% get the size of the DRT
num_projections = size( RI, 1 );

% flip the columns that "wrap around" the DRT of the rotated image
RI(:, end-(phi-1) : end) = flipud( RI(:, end-(phi-1) : end) );

% circularly shift the columns of the image and return as a column vector
RJ = circshift( RI(:), num_projections * phi );

end
