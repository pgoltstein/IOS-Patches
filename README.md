# IOS-Patches

The function PatchesColorMap is contained in PatchesColorMap.m. 
This function creates the colormap and overlay image and saves images and data to disk

The file Test_PatchesColorMap.m loads the demo data and runs the function.

The file AverageResponseMatrix.mat contains a 3d Matlab matrix with average 
intrinsic response images for each patch (see function description in PatchesColorMap.m)

The file BloodVesselImage.tiff is an image of the bloodvessel pattern. It is 
important that this image has the same dimensions as the intrinsic response 
maps in the AverageResponseMatrix.


