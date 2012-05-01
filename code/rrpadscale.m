function [R1ss, R2ss] = rrpadscale (R1, R2)
%
% RRPADSCALE Radon transform image registration; pad scaled Radon
% transforms
%
% SYNTAX
%
%   [R1ss, R2ss] = RRPADSCALE (R1, R2)
%
% DESCRIPTION
%
%   [R1ss,R2ss] = RRPADSCALE(R1,R2) pads the matrix, R1 or R2, that is
%   smaller in size with rows of zeroes and returns the two same-sized
%   matrices R1ss and R2ss (one of which is identical to the corresponding
%   input).
%
% ALGORITHM
%
%   If the difference, D, in the sizes of R1 and R2 is an odd number of
%   rows, then floor(D/2) rows are inserted in the top (lower-index) of the
%   appropriate matrix and ceil(D/2) rows are inserted in the bottom
%   (higher-index).
%
%   This arbitrary padding scheme was empeirically found to be the one that
%   minimises the MSE between two DRTs, when one is a estimated scaled-back
%   version of the other. (That is, if only paddings of an integral number
%   of zero-rows are considered.)
%
% AUTHOR
%
%   Alexandros-Stavros Iliopoulos <ailiop@cs.duke.edu>
%
%
% See also  rrscale.m, radonreg.m.
%


%% INITIALISATION

% get number of columns (assumed equal for both input matrices)
cols = size( R1, 2 );

% calculate the disparity in number of rows
rowsdiff = size( R1, 1 ) - size( R2, 1 );

% calculate the paddings' sizes
padtop = floor( abs(rowsdiff) / 2 );
padbtm = ceil(  abs(rowsdiff) / 2 );


%% PAD

% zero-pad the appropriate matrix and leave the other one as is
if rowsdiff > 0
    R2ss = [zeros( padtop, cols );
            R2;
            zeros( padbtm, cols )];
    R1ss = R1;
else
    R1ss = [zeros( padtop, cols );
            R1;
            zeros( padbtm, cols )];
    R2ss = R2;
end


end
