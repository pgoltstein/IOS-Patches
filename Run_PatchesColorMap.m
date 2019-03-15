% Test script that loads intrinsic imaging matrix and blood vessel image
% and then creates the colored patches maps

% Settings & File locations
numYpatches = 4;
numXpatches = 6;
BVfile = dir('BloodVesselPattern.tiff');
PatchesFiles = dir('.\PatchesImages\Patch*.tif');
GaussFilterSigma = 0; % Sigma of Gaussian smooth
ScaleRange = [0.4 0.9];
NormalizeImages = true;
ClipAtLowerPercentile = 0.25; % set to e.g. 0.25 for 25%
InvertResponse = true;

% % Settings & File locations
% numYpatches = 3;
% numXpatches = 5;
% BVfile = dir('BloodVessel*.tiff');
% PatchesFiles = dir('*map*.bmp');
% GaussFilterSigma = 11; % Sigma of Gaussian smooth
% ScaleRange = [0 1];
% NormalizeImages = false;
% ClipAtLowerPercentile = 0.5;
% InvertResponse = true;

% Load one image to get the image dimensions
Im = imread([PatchesFiles(1).folder filesep PatchesFiles(1).name]);
ySize = size(Im,1);
xSize = size(Im,2);
nPatches = length(PatchesFiles);

% Load all files and display which patch they are assigne to
AverageResponseMatrix = zeros( ySize, xSize, nPatches );
for p = 1:nPatches
    
    % Load image
    Im = im2double(imread([PatchesFiles(p).folder filesep PatchesFiles(p).name]));
    if length(size(Im)) == 3
        Im = mean(Im,3);
    end
    
    % Smooth image if sigma is > 0
    if GaussFilterSigma > 0
        Im = imgaussfilt(Im,GaussFilterSigma);
    end
    
    % Gollect image in matrix
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
    AverageResponseMatrix, SaveDirectory, BloodVesselImage, ...
    ScaleRange, NormalizeImages, ClipAtLowerPercentile, InvertResponse);

