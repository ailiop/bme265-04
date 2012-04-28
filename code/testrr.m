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
scale     = 1.56;
trans     = [40 -20];
rot       = 72;


%% TEST

% load testing image
I = im2double( imread( imagename ) );

% pad testing image
Ipad = padarray( I, floor(size(I)/2) );

% transform testing image
Jpad = imaffinetransform( Ipad, scale, trans, rot, 'forward' );

% estimate the transformation parameters
[est.scale, est.rot, est.trans] = radonreg( Ipad, Jpad );
