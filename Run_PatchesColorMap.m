% Test script that loads intrinsic imaging matrix and blood vessel image
% and then creates the colored patches maps

% Settings
numYpatches = 4;
numXpatches = 6;

% File locations
BVfile = dir('BloodVessel*.tiff');
PatchesFiles = dir('.\PatchesImages\Patch*.tif');

% Load one image to get the image dimensions
Im = imread([PatchesFiles(1).folder filesep PatchesFiles(1).name]);
ySize = size(Im,1);
xSize = size(Im,2);
nPatches = length(PatchesFiles);

% Load all files and display which patch they are assigne to
AverageResponseMatrix = zeros( ySize, xSize, nPatches );
for p = 1:nPatches
    Im = im2double(imread([PatchesFiles(p).folder filesep PatchesFiles(p).name]));
    if length(size(Im)) == 3
        Im = mean(Im,3);
    end
    yPos = ceil(p/numXpatches);
    xPos = mod(p-1,numXpatches)+1;
    fprintf('%2.0f: %s (Patch Y=%1.0f, X=%1.0f)\n', ...
        p, [PatchesFiles(p).folder filesep PatchesFiles(p).name], yPos, xPos );
    AverageResponseMatrix(:,:,p) = Im;
end

% Load bloodvessel image if present
if ~isempty(BVfile)
    BloodVesselImage = imread(BVfile(1).name);
    fprintf('Bloodvessel file: %s \n', [BVfile(1).folder filesep BVfile(1).name]);
else
    BloodVesselImage = ones( ySize, xSize );
    fprintf('Bloodvessel file: None \n');
end

% Make maps
SaveDirectory = pwd;
PatchesColorMap( numYpatches, numXpatches, ...
    AverageResponseMatrix, SaveDirectory, BloodVesselImage);

