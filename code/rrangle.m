function r = rrangle ...
    (RI, RJ, angles, resampfact, resampinterp, optimmode, costmode)
%
% RRANGLE Radon transform image registration; rotation angle parameter
% estimation.
%
% SYNTAX
%
%   R = RRANGLE (RI, RJ)
%   R = RRANGLE (RI, RJ, ANGLES)
%   R = RRANGLE (..., RESAMPFACT)
%   R = RRANGLE (..., RESAMPINTERP)
%   R = RRANGLE (..., OPTIMMODE)
%   R = RRANGLE (..., COSTMODE)
%
% DESCRIPTION
%
%   R = RRANGLE(RI,RJ) estimates the rotation angle R from the Radon
%   transforms, RI and RJ, of two images, which are related to each other
%   through an affine transformation that does not include scaling.
%
%   R = RRANGLES(RI,RJ,ANGLES) specifies the degrees of the projection
%   angles which correspond to the columns of RI and RJ sa being equal to
%   the corresponding elements of the vector ANGLES. By default, ANGLES is
%   assumed to be equal to linspace(0,180,size(RI,2)+1), sans the first
%   element.
%
%   R = RRANGLE(...,RESAMPFACT) resamples the DRTs, RI and RJ, by factor of
%   RESAMPFACT, which must be a positive integer number (if it is not, it
%   is rounded down). The resampling is done via linear interpolation by
%   default.
%
%   R = RRANGLE(...,RESAMPINTERP) resamples the DRTs using the specified
%   interpolation method. RESAMPINTERP may take the following values:
%   'linear', 'sinc', 'cubic', 'spline'.
%
%   R = RRANGLE(...,OPTIMMODE) performs the rotation angle estimate
%   optimization using the specified method. By default, this is done with
%   a brute-force, iterative approach, i.e. by checking all integer angles.
%
%   R = RRANGLE(...,COSTMODE) optimizes the specified cost measure.
%   COSTMODE can take the following values:
%       - 'sse' | 'l2-norm'
%           The cost measure is the sum of squared differences between
%           corresponding elements in the DRTs.
%       - 'sae' | 'l1-norm'
%           The cost measure is the sum of absolute difference between
%           corresponding elements in the DRTs.
%   If no COSTMODE is specified, it is set to 'sse'.
%
% ALGORITHM
%
%   The computations follow the model in [1]. The images are translated so
%   that their respective centers of mass are at the origin, in order for
%   the rotation angle to be found. It is important that the images be in
%   the same scale.
%
%   Sinc interpolation, by using INTERPFT, is performed in order to
%   estimate missing columns (i.e. projection angles) in the DRTs. Hence,
%   the angular difference between successive columns of the DRTs must be
%   constant; in other words, the sampled projection angles must be
%   equidistant. This restriction could be removed in the future by making
%   use of the generalised expansion theorem [2] or by implementing the
%   algorithm in [3].
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
%   [2] Athanasios Papoulis, "Generalized Sampling Expansion." IEEE
%   Transaction on Circuits and Systems, 24(11):652-654, November 1977.
%
%   [3] Leonid P. Yaroslavsky, "Efficient Algorithm for Discrete Sinc
%   Interpolation." Applied Optics, 36(2):460-463, January 1997.
%
% AUTHOR
%
%   Alexandros-Stavros Iliopoulos <ailiop@cs.duke.edu>
%
%
% See also  affinemtx2.m, imrotatecrop.m, rrscale.m, radonreg.m, interpft.
%


%% DEFAULTS

if ~exist( 'angles', 'var' ) || isempty( angles )
    angles = linspace( 0, 180, size(RI,2) + 1 );
    angles(1) = [];
end

if ~exist( 'resampfact', 'var' ) || isempty( resampfact )
    resampfact = 1;
end

if ~exist( 'resampinterp', 'var' ) || isempty( resampinterp )
    resampinterp = 'linear';
end

if ~exist( 'costmode', 'var' ) || isempty( costmode )
    costmode = 'sse';
end

if ~exist( 'optimmode', 'var' ) || isempty( optimmode )
    optimmode = 'iterative';
end


%% INITIALISATION

% get the size of the DRTs (both DRTs have the same size)
[rowN, colN] = size( RI );


%% RESAMPLING

% make sure the resampling factor is an integer
resampfact = floor( resampfact );


% % perform trigonometric interpolation for each row of the DRTs
% RI_rs = horzcat( interpft( RI(:,1:colN/2),       resampfact * (colN/2) - 1, 2 ), ...
%                  interpft( RI(:,(colN/2+1):end), resampfact * (colN/2) - 1, 2 ) );
% RJ_rs = horzcat( interpft( RJ(:,1:colN/2),       resampfact * (colN/2) - 1, 2 ), ...
%                  interpft( RJ(:,(colN/2+1):end), resampfact * (colN/2) - 1, 2 ) );

% compute the resampled projection angles
resampangles = linspace( 0, 180, resampfact * colN + 1 );
resampangles(1) = [];

% perform linear interpolation for each row of the DRTs
% (linear interpolation returns NaN for samples that are outside the range
% of the original signal; to counter that, use the flipped value of the
% projection at 180 degrees as the projection at 0 degrees)
RI_rs = zeros( rowN, resampfact * colN );
RJ_rs = zeros( rowN, resampfact * colN );
for p = 1 : rowN
    RI_rs(p,:) = interp1( [0 angles], [RI(rowN-p+1,colN) RI(p,:)], ...
                          resampangles, resampinterp );
    RJ_rs(p,:) = interp1( [0 angles], [RJ(rowN-p+1,colN) RJ(p,:)], ...
                          resampangles, resampinterp );
end

% overwrite RI & RJ to keep from modifying the rest of the M-file for now
RI = RI_rs;
RJ = RJ_rs;
[rowN, colN] = size( RI );
angles = resampangles;


%% COMPUTATION

% set the cost function
switch costmode
    case {'sse', 'l2-norm'}
        costfun = @(phi) sum( (RI(:) - radonrotate(RJ,phi)) .^ 2 );
%         costfun = @(phi) sum( (RI(:) - circshift(RJ(:), rowN*phi)) .^ 2 );
    case {'sae', 'l1-norm'}
        costfun = @(phi) sum( abs( RI(:) - radonrotate(RJ,phi) ) );
end

% solve the optimization problem in the specified manner
switch optimmode
    
    % iterative optimization
    case {'iterative', 'iter'}
        
        % prepare the iterative process
        mincost = Inf;
        
        % iteratively minimize the cost function
        for angle = 0 : colN
            cost = costfun( angle );
            if cost < mincost
                mincost = cost;
                angleidx = angle;
            end
        end
        
        % map the optimal oclumn index to an actual angle value
        if angleidx == 0
            r = 0;
        else
            r = angles(angleidx);
        end
        
end

% % map the optimal column index to an actual angle value (in degrees)
% angles_lt90 = linspace( 1, 90, colN/2);
% if angleidx <= colN/2
%     r = angles_lt90(angleidx);
% else
%     r = angles_lt90(angleidx-90);
% end


end


%% PRIVATE FUNCTIONS

%
% This helper function rotates an image in the Radon domain. RI is the DRT
% of the image and phi is the rotation angle in degrees. Essentially, this
% function shifts the DRT's columns circularly, flipping the columns that
% "wrap around" the DRT. The latter is done because a column that has
% wrapped around the DRT is a column that corresponds to a projection angle
% that is greater than 180 degrees, and MATLAB computes DRTs using angles
% 1:180.
%
% This functionality will need to become "smarter," should the Radon
% Registration suite support DRTs that are not defined over the angle set
% {1,...,180}.
%
function R2 = radonrotate (R1, phi)

% get the size of the DRT
num_projections = size( R1, 1 );

% flip the columns that "wrap around" the DRT of the rotated image
R1(:, end-(phi-1) : end) = flipud( R1(:, end-(phi-1) : end) );

% circularly shift the columns of the image and return as a column vector
R2 = circshift( R1(:), num_projections * phi );

end

