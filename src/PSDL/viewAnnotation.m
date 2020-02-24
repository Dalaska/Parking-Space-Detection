%this script is used to view the annotation of negative samples
%before running it, make sure that the folder 'parkingslot1.0\negView'
%exists
allFiles = dir('parkingslot1.0\training\negative samples\images\*.bmp');

for index = 1:length(allFiles)
    currentFileName = allFiles(index).name;
    oriImage = imread(['parkingslot1.0\training\negative samples\images\' currentFileName]);
    figure;
    oriImage = rgb2gray(oriImage);
    imshow(oriImage)
    hold on;
        
    nameLength = length(currentFileName);
    currentExpectedMatName = ['parkingslot1.0\training\negative samples\annotations\' currentFileName(1:nameLength-4) '.txt'];
    
    fid=fopen(currentExpectedMatName,'r');
    while ~feof(fid)
        tl = fgetl(fid);
        id = strfind(tl,'person');
        if ~isempty(id)
            for objectIndex = 1:length(id)
                currentStr = tl(id(objectIndex):end);
                spacePos = strfind(currentStr,' ');
                x = str2num(currentStr(spacePos(1)+1:spacePos(2)-1));
                y = str2num(currentStr(spacePos(2)+1:spacePos(3)-1));
                w = str2num(currentStr(spacePos(3)+1:spacePos(4)-1));
                h = str2num(currentStr(spacePos(4)+1:spacePos(5)-1));

                xs = [x x+w x+w x x];
                ys = [y y y+h y+h y];

                plot(xs,ys,'g');
            end
        end
    end
    fclose(fid);
    
    print(['parkingslot1.0\negView\' currentFileName], '-dbmp');
    close all;
end
