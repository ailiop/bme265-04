function e = immse (I, J)
%
% IMMSE Mean square error between images.
%
% SYNTAX
%
%   E = IMMSE (I, J)
%
% DESCRIPTION
%
%   E = IMMSE(I,J) calculates the mean square error (MSE) between images I
%   and J.
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

% compute the MSE
e = mean( (I(:) - J(:)) .^ 2 );


end
