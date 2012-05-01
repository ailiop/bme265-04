%
% SCRIPT: testrr.m
%
% A simple testing script for the Radon domain registration suite.
%
% Author: Alexandros-Stavros Iliopoulos <ailiop@cs.duke.edu>
%


%% EVERYTHING CLEAN!

clear all
close all


%% PARAMETERS

imagename = 'cameraman.tif';
noise     = 'gaussian';
scale     = 1.284;
rot       = 41.713;
trans     = [23.402 -8.91];


%% REGISTRATION TEST

% load testing image
I = im2double( imread( imagename ) );

% pad testing image
Ipad = padarray( I + eps, floor(size(I)/2) );
sizeIpad = size( Ipad );

% transform testing image
Jpad = imaffinetransform( Ipad, scale, trans, rot, 'forward' );
sizeJpad = size(Jpad);

% add noise to the images
switch noise
    case 'none'
        Ipad(Ipad>0) = Ipad(Ipad>0) - eps;
        Ipad = reshape( Ipad, sizeIpad );
        JPad(Jpad>0) = Jpad(Jpad>0) - eps;
        Jpad = reshape( Jpad, sizeJpad );
    otherwise
        Ipad(Ipad>0) = imnoise( Ipad(Ipad>0), noise ) - eps;
        Ipad(Ipad<0) = 0;
        Ipad = reshape( Ipad, sizeIpad );
        Jpad(Jpad>0) = imnoise( Jpad(Jpad>0), noise ) - eps;
        Jpad(Jpad<0) = 0;
        Jpad = reshape( Jpad, sizeJpad );
end

% estimate the transformation parameters
[est.scale, est.rot, est.trans] = radonreg( Ipad, Jpad );


%% DISPLAY ESTIMATES

estimates = sprintf(['scale       = %.3f\n' ...
    'rotation    = %.3f\n' ...
    'translation = [%.3f %.3f]'], ...
    est.scale, est.rot, est.trans(1), est.trans(2));
display( estimates )

