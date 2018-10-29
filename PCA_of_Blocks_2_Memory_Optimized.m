% 2016 Written by Soham Saha
% 2017-01-17 Kurt went through and cleaned-up code
% 2017-07-06 Kurt optimized memory by clearing unused or duplicate
% variables
% Rootdir - Animal
% --Subdir - Dates

clear all
components = 50; %Number of principal components
Rootdir = 'I:\Soham Experiments\2017 Mitral cell recording photostim\Shutter control\Animal 3'; %3d TIFFs to be registered
ImgNameFormat = 'Reg_*.tif';
StartAtTiffNumber = 1; %Input the first tiff from FilenamesALL to start at if computer crashes
ZDownscaleFactor = 3; %Fold-factor to reduce time dimension

cd(Rootdir);
List = dir;
FilenamesALL = [];
for h = 3:length(List)
    if List(h).isdir == 1;
        cd([Rootdir '\' List(h).name]);
        Filenames = dir(ImgNameFormat);
        for k = 1:length(Filenames)
            [Path,Name,Type] = fileparts([Rootdir '\' List(h).name '\' Filenames(k).name]);
            FilenamesTemp{k,1} = [Path '\' Name Type];
            FilenamesTemp{k,2} = Path;
            FilenamesTemp{k,3} = [Name Type];
        end
        FilenamesALL = [FilenamesALL; FilenamesTemp];
        clear FilenamesTemp Filenames Path Name Type;
    end
end

for k = StartAtTiffNumber:size(FilenamesALL,1)
    cd(FilenamesALL{k,2});
    stack = loadtif(FilenamesALL{k,3}, FilenamesALL{k,2});
    [pixw,pixh,dim] = size(stack);
    stack = im2double(stack);
    stack=  reshape(stack, (pixw*pixh), dim, []);
    stack = imresize(stack, [(pixw*pixh), dim/ZDownscaleFactor]);
    %% PCA algorithm
    [coeff, score] = pca(stack);
    clear stack
    %% Reconstruction
    project = (coeff(:,1:components)*(score(:,1:components)'));
    clear coeff score
    project = project';
    project = project .* (double(project > 0));%Make values =< 0 == 0
    project = project * (2^16)/(max(max(project)));%Make max value 16-bit
    project = reshape(project, pixw, pixh, []);
    project = uint16(project);
    outputFileName = ['PCA_' FilenamesALL{k,3}];
    saveastiff(project, outputFileName);
    clearvars -except FilenamesALL components k StartAtTiffNumber outputFileName ZDownscaleFactor
    disp([num2str(k) 'done']);
end
