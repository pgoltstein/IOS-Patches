function PatchesColorMap( numYpatches, numXpatches, ...
    AverageResponseMatrix, SaveDirectory, BloodVesselImage)
% function PatchesColorMap( numYpatches, numXpatches, ...
%     AverageResponseMatrix, SaveDirectory, BloodVesselImage)
% 
% This function plots the individual response maps (scaled to respective maxima
% and then assigns a color to each pixel based on which stimulus patch gave
% the largest response
%
% Inputs:
%  - numYpatches:   Number of patches along vertical axis of monitor
%  - numXpatches:   Number of patches along horizontal axis of monitor
%  - AverageResponseMatrix: Matrix that contains an image of the average
%                           intrisic response per patch 
%                           [npixelsY, npixelsX, nStimuli]
%                           Stimuli are patches organized in a row like this:
%                           [ X1Y1, X2Y1, X3Y1, X1Y2, X2Y2, X3Y2, etc..]
%  - BloodVesselImage:  (optional) Matrix containing a bloodvessel image [Y,X]
%  - SaveDirectory:     Any directory, e.g. 'C:\Users\goltstein\Pictures'
%
    
    % Local settings
    UseColorMap = 'hsv'; % Use this map, unless n-ptaches is 4 or 9, 
                         %   then it uses manually defined, see below

    % Get size and number of stimuli
    [ySize,xSize,nStim] = size(AverageResponseMatrix);
    
    % Make sure bloodvessel image is there, a double and scaled nicely
    if nargin > 3
        BloodVesselImage = im2double(BloodVesselImage);
        BloodVesselImage = imadjust(BloodVesselImage);
    else
        BloodVesselImage = zeros(ySize,xSize);
    end
    
    % get colormap for patches
    if nStim == 4
        Cmap = {[0 0 1],[0 1 0],[1 1 0],[1 0 0]};
    elseif nStim == 9
        Cmap = {[0 0.5 0.5],[0 0.5 1],[0 0 1],[0.5 0.5 0],[0.5 1 0],[0 1 0],[0.5 0 0.5],[1 0 0.5],[1 0 0]};
    else
        Cmap = LOCAL_ColorMap( nStim, UseColorMap );
        for s = 1:length(Cmap)
            Cmap{s}(Cmap{s}==max(Cmap{s})) = 1;
        end
    end
        
    % Normalize and invert each patch separately
    ScaledResponseMatrix = zeros(ySize,xSize,nStim);
    for c = 1:nStim
        I = AverageResponseMatrix(:,:,c) * -1; % Here we switch from negative to positive responses
        SortedInt = sort(I(:),'ascend');
        IntThreshold = SortedInt( round(length(SortedInt)*0.25) );
        I(I<IntThreshold) = IntThreshold;
        ScaledResponseMatrix(:,:,c) = (I-min(I(:))) ./ (max(I(:))-min(I(:)));
    end
    
    % Display scaled individual maps
    figure; colormap('gray');
    for s = 1:nStim
        subplot(numYpatches,numXpatches,s);
        imagesc( ScaledResponseMatrix(:,:,s) );
        colorbar;
    end

    % get largests negative response
    ScaleRange = [0.3 0.9];
    for s = 1:nStim
        MaxR(s) = max(max(ScaledResponseMatrix(:,:,s)));
    end
    MaxR = max(MaxR)*ScaleRange(2);

    % Make colored response map
    PatchesColormap = zeros(ySize,xSize,3);
    PatchesBVoverlay = zeros(ySize,xSize,3);
    for y = 1:ySize
        for x = 1:xSize
            
            % get responses from all patches for this pixel
            Responsevec = squeeze(ScaledResponseMatrix(y,x,:));
            
            % Get the patch that gives the largest negative response
            Winner = find( Responsevec == max(Responsevec) );
            if length(Winner) > 1
                [~,ix] = sort(rand(1,length(Winner)));
                Winner = Winner(ix(1));
            end
            
            % get relative amplitude of the response in this patch
            ResponseAmp = min([ Responsevec(Winner)./MaxR 1]);
            ResponseAmp = (ResponseAmp-ScaleRange(1)) ./ (1-ScaleRange(1));
            ResponseAmp(ResponseAmp<0) = 0;
            
            % get a scaled color in the patch
            PatchesColormap(y,x,:) = Cmap{Winner} .* ResponseAmp;
            PatchesBVoverlay(y,x,:) = (Cmap{Winner} .* ResponseAmp) + ...
                ((1-ResponseAmp)*BloodVesselImage(y,x));
        end
    end
    
    % Make patches index map to show which color belongs to which patch
    ColorPatchesIndex = zeros(numYpatches+10,numXpatches+10,3);
    six = 0;
    for y = 1:numYpatches
        for x = 1:numXpatches
            six = six + 1;
            xIx = (((x-1)*10)+1):(x*10);
            yIx = (((y-1)*10)+1):(y*10);
            for c = 1:3
                ColorPatchesIndex(yIx,xIx,c) = Cmap{six}(c);
            end
        end
    end
    
    % show figure
    figure;
    subplot(2,2,1);
    imshow(ColorPatchesIndex);
    title('Legend');
    subplot(2,2,2);
    imshow(PatchesColormap);
    title('Colormap');
    subplot(2,2,3);
    imshow(BloodVesselImage);
    title('Bloodvessel pattern');
    subplot(2,2,4);
    imshow(PatchesBVoverlay);
    title('Bloodvessel patches overlay');
    
    % Save data
    save([ SaveDirectory filesep 'PatchesMapData.mat']',...
        'ScaledResponseMatrix','ColorPatchesIndex',...
        'PatchesColormap','PatchesBVoverlay', ...
        'numYpatches', 'numYpatches', 'BloodVesselImage' );
    
    % Export images
    imwrite( ColorPatchesIndex, [SaveDirectory filesep 'ColorPatchesIndex.tiff'] );
    imwrite( PatchesColormap, [SaveDirectory filesep 'PatchesColormap.tiff'] );
    imwrite( BloodVesselImage, [SaveDirectory filesep 'BloodVesselImage.tiff'] );
    imwrite( PatchesBVoverlay, [SaveDirectory filesep 'PatchesBVoverlay.tiff'] );
    
end

function C = LOCAL_ColorMap( N, Name )
    figure;
    CM = colormap( Name );
    close;
    IX = round(linspace(1,64,N));
    for i = 1:length(IX)
        C{i} = CM(IX(i),:);
    end
end
