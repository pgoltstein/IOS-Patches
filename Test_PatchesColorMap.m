% Test script that loads intrinsic imaging matrix and blood vessel image
% and then creates the colored patches maps

% Load intrinsic image matrix
load('AverageResponseMatrix.mat');

% Load bloodvessel image
BloodVesselImage = imread('BloodVesselPattern.tiff');

% Make maps
SaveDirectory = pwd;
numYpatches = 4;
numXpatches = 6;
PatchesColorMap( numYpatches, numXpatches, ...
    AverageResponseMatrix, SaveDirectory, BloodVesselImage);

