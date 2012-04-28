function e = immae (I, J)
%
% IMMAE Maximum absolute error between images.
%
% SYNTAX
%
%   E = IMMAE (I, J)
%
% DESCRIPTION
%
%   E = IMMAE(I,J) calculates the maximum absolute error (MAE) between
%   images I and J.
%
% ALGORITHM
%
%   This function calls IM2DOUBLE as a pre-processing step, hence if the
%   images are of an integer class, they will be converted to doubles in
%   the range [0,1].
%
% AUTHOR
%
%   Alexandros-Stavros Iliopoulos <ailiop@cs.duke.edu>
%
%
% See also im2double.
%


%% PRE-PROCESSING

% make sure the images are of class 'double'
I = im2double( I );
J = im2double( J );


%% COMPUTATION

% compute the MAE
e = max( abs( I(:) - J(:) ) );


end
