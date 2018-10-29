% 2017-01-12 created by Kurt Sailor and PCA by Soham Saha
% Extract behaviors 2016-07-11 written by Kurt Sailor
% 2017-07-07 Changed dff calculation based on code from John Meng and
% Hermann Riecke from Northwestern University to take iterated clipping of
% peaks outside SD and take mean of values for baseline.
% This Script does the following:
% 1) Automatically extracts elipse(only) ROIs drawn in ImageJ(FIJI) saved
% as .zip.
% 2) Take the first principal component of each ROI.
% 3) Calculated mean fluorescence over time of each PCA ROI.
% 4) Fills dropped frames with NaN and calculated dff.
% 5) Saves meanwaves, NaNmean and dff in ALLBLOCKS.
% 6) Outputs 3D tiff of all ROIs for each block.
% 7) Inputs behavior data from rtf files into ALLBLOCKS.OdorsBeh
% files and creating structure with all pixel values
% Dependency 'ReadImageJROI.m'
% code will go through individual animal directory, extract roi locations
% and save in 'waves' folder within individual directories
% Need to do each animal separately because each has different ROI file...
% FOR EXTRACT BEHAVIORS
% This code requires ALLBLOCKS to be in root directories segregated by date
% and to have a subfolder in this directory named 'behaviors' that contains
% the behavioral files (multiple files) from each respective day.
% File structure:
% AnimalID directory
% --Date of experiment directory

clear all; close all; clc
%%
RunExtractROIs = 1;
RunExtractBehaviors = 0;
BehaviorFolderName = 'behaviors';
AnimalIDdir = 'I:\Soham Experiments\2017 Mitral cell recording photostim\GL cells';
ROIfile = 'I:\Soham Experiments\2017 Mitral cell recording photostim\GL cells\ROIs\Animal 3\RoiSet2.zip';
PCAFileID = 'PCA_block*';%Unique name of PCA-proccessed stacks to search
OrigFileID = 'Reg_*';%Unique name of unproccessed stacks to search
PrincCompMask = 1;%Number of PCs to take for ROI masks
PreEvokedPeriod = 11:100;%Period before odor to take baseline
ExcludePreEP = .6;%Percentage of NaN allowed
TrialSize = 300;%Number of frames for each trial
BlockSize = 20;%Number of trails for each block
StartDir = 6;%Default to 3, use after a crash...
%%
if RunExtractROIs == 1;
    %Get elipse binary map of ROIs
    [sROI] = ReadImageJROI(ROIfile);
    for i = 1:length(sROI)
        ROICoor{i}.Xval = sROI{1,i}.mnCoordinates(:,1);
        ROICoor{i}.Yval = sROI{1,i}.mnCoordinates(:,2);
        ROIBinmaps(:,:,i) = poly2mask(ROICoor{i}.Xval,ROICoor{i}.Yval,512,512);
        [ROIs(i).rows ROIs(i).cols] = find(ROIBinmaps(:,:,i));
    end
    
    cd(AnimalIDdir);
    ExpDateDir = dir;
    counter = 1;
    for f = StartDir%:length(ExpDateDir)
        if ExpDateDir(f).isdir == 1
            cd([AnimalIDdir '\' ExpDateDir(f).name]);
            load('ALLBLOCKS.mat');
            Stackdir = dir(PCAFileID);
            ExtractWavesTIFFs = dir(OrigFileID);
            for s = 1:length(Stackdir)
                stack = loadtif(Stackdir(s).name, [AnimalIDdir '\' ExpDateDir(f).name]);
                for t = 1:length(ROIs)
                    Xval = ROIs(t).rows;
                    Yval = ROIs(t).cols;
                    for y = 1:length(Xval)
                        for u = 1:size(stack,3)
                            ROIs(t).pixels(:,y,u) = double(stack(Xval(y),Yval(y),u));
                        end
                    end
                end
                
                m=1;
                for k = 1:length(ROIs)
                    ROIsPixtemp = squeeze(ROIs(k).pixels);
                    preprocess_ROI = ROIsPixtemp;
                    [l b w] = size(preprocess_ROI);
                    [pca(m).COEFF,pca(m).SCORE,pca(m).latent,pca(m).tsquare] = princomp(preprocess_ROI,'econ');
                    pca(m).latent = pca(m).latent/sum(pca(m).latent);
                    m=m+1;
                    clear ROIsPixtemp;
                end
                n=1;
                for j = 1:length(pca)
                    v = 1;%Take first principal component
                    coeff1 = pca(j).COEFF;
                    score1 = pca(j).SCORE;
                    projection = coeff1(:,v)*score1(:,v)'*50;%increasing contrast by 100
                    project = projection';
                    mu_pro = mean(project);
                    deducted = bsxfun(@minus,project,mu_pro);%CHANGED THE MEAN originally my_pro
                    [A B C] = size(ROIs(j).pixels);
                    final = reshape(deducted, A, B, []);
                    Projection = max(final,[],3);
                    F=Projection;
                    F(F<=0)=0;
                    F = uint16(F);
                    [ROIs(n).x3, ROIs(n).y3] = find(F);
                    n=n+1;
                end
                PCAROIs = zeros(512,512,length(ROIs));
                for r = 1:length(ROIs);
                    for d = 1:length(ROIs(r).y3)
                        if isempty(ROIs(r).y3) == 1
                            ROIs(r).xcor = [];
                            ROIs(r).ycor = [];
                        else
                            Xvalues = ROIs(r).rows(ROIs(r).y3);%Take indexed in y3 of 512x512 coor in rows-cols
                            yvalues = ROIs(r).cols(ROIs(r).y3);
                            ROIs(r).xcor = Xvalues;
                            ROIs(r).ycor = yvalues;
                            ROIs(r).XY =[ROIs(r).xcor, ROIs(r).ycor];
                        end
                    end
                end
                for r = 1:length(ROIs);
                    if isempty(ROIs(r).XY) == 1
                        ROIs(r).XY = [ROIs(r).rows ROIs(r).cols];
                    end
                    if length(ROIs(r).XY) == 2 || length(ROIs(r).XY) == 1
                        ROIs(r).XY = [ROIs(r).rows ROIs(r).cols];
                    end
                end
                for r = 1:length(ROIs)
                    for d = 1:length(ROIs(r).XY)
                        X = ROIs(r).XY(:,1);
                        Y = ROIs(r).XY(:,2);
                        PCAROIs(X(d),Y(d),r) = 1;
                    end
                end
                OrigDataStack = loadtif(ExtractWavesTIFFs(s).name, [AnimalIDdir '\' ExpDateDir(f).name]);
                for k = 1:length(ROIs)
                    for ii = 1:length(ROIs(k).XY)
                        tempOrigDataStack(ii,:) = OrigDataStack(ROIs(k).XY(ii,1), ROIs(k).XY(ii,end),:);
                    end
                    allmean(k,:) = mean(tempOrigDataStack,1);
                    clear tempOrigDataStack;
                end
                ALLBLOCKS(s).meanwaves = allmean;
                %Insert NaN for dropped frames and calculate dff
                ALLBLOCKS(s).NaNwaves = zeros(size(ALLBLOCKS(s).meanwaves,1),size(ALLBLOCKS(s).include,1));
                ALLBLOCKS(s).dffNaN = zeros(size(ALLBLOCKS(s).meanwaves,1),size(ALLBLOCKS(s).include,1));
                for ROInum = 1:size(ALLBLOCKS(s).meanwaves,1)%For each ROI
                    indx = 1;
                    inc = 1;
                    for Trialnum = 1:length(ALLBLOCKS(s).include)%Counter for all frames
                        if ALLBLOCKS(s).include(indx) == 1
                            ALLBLOCKS(s).NaNwaves(ROInum,indx,:) = ALLBLOCKS(s).meanwaves(ROInum,inc);
                            inc = inc + 1;
                            indx = indx + 1;
                        else
                            ALLBLOCKS(s).NaNwaves(ROInum,indx,:) = NaN;
                            indx = indx + 1;
                        end
                    end
                end
                %Calculate F0 in the pre-evoked period and perform dff
                for dffnum = 1:size(ALLBLOCKS(s).NaNwaves,1)
                    for i = 1:BlockSize
                        tempALLBLOCKS = ALLBLOCKS(s).NaNwaves(dffnum,(((i-1)*TrialSize)+1):(i*TrialSize));
                        ED = tempALLBLOCKS(PreEvokedPeriod);
                        if sum(isnan(ED)) < ExcludePreEP*length(PreEvokedPeriod);
                            
                            IndED = 1:length(ED);
                            IndED(isnan(ED))=[];
                            ED(isnan(ED))=[];
                            
                            Trace0 = ED;
                            ind0 = IndED;
                            LD = length(ED);
                            LDB = 0;
                            
                            while abs(LDB-LD)~=0
                                
                                mED=nanmean(ED);
                                sED=nanstd(ED);
                                IndED(abs(ED-mED)>3*sED)=[];
                                ED(abs(ED-mED)>3*sED)=[];
                                LDB=LD;
                                LD=length(ED);
                            end
                            f0 = mED;
                            FminF0 = tempALLBLOCKS - f0;
                            ALLBLOCKS(s).dffNaN(dffnum,(((i-1)*TrialSize)+1):(i*TrialSize)) = FminF0 ./ f0;
                        else ALLBLOCKS(s).dffNaN(dffnum,(((i-1)*TrialSize)+1):(i*TrialSize)) = NaN;
                        end
                        clear tempALLBLOCKS
                    end
                    
                end
                PCAMax = uint8(sum(PCAROIs,3));
                PCAROImap = 255./(max(max(PCAMax))) * PCAMax;
                imwrite(PCAROImap, ['PCA_ROIBinMap_' Stackdir(s).name(1:end-4) '.tif']);
                PCAROImapStack(:,:,counter) = PCAROImap;
                counter = counter+1;
                clear PCAROIs PCAROImap allmean;
            end
            cd([AnimalIDdir '\' ExpDateDir(f).name]);
            save('ALLBLOCKS.mat','ALLBLOCKS');
            clear ALLBLOCKS
        end
        clear tempALLBLOCKS
    end
    cd(AnimalIDdir);
    saveastiff(PCAROImapStack, 'AllPCAROIMaps.tif');
end

if RunExtractBehaviors == 1;
    
    o1 = 'VALVE 1';
    o2 = 'VALVE 2';
    o3 = 'Ethyl buyterate';
    o4 = 'Amyl acetate';
    o5 = '60EB40AA';
    o6 = '40EB60AA';
    o7 = '55EB 45AA';
    o8 = '45EB 55AA';
    o9 = 'Min-L*';
    o10 = 'Butyric*';
    o11 = 'ETHYL BUTYRATE';
    o12 = 'Air2';
    o13 = '6EB 4AA';
    o14 = '4EB 6AA';
    o15 = 'ISOAMYL ACETATE';
    
    b1 = 'MISS';
    b2 = 'CR';
    b3 = 'HIT';
    b4 = 'FA';
    
    Rew1 = '+';
    Rew2 = '-';
    Directory = AnimalIDdir;
    cd(Directory);
    dates = dir;
    for g = 3:length(dates)
        if dates(g).isdir == 1
            cd([Directory '\' dates(g).name]);
            load('ALLBLOCKS.mat');
            %ALLBLOCKS = rmfield(ALLBLOCKS,'OdorsBeh');
            cd([Directory '\' dates(g).name '\' BehaviorFolderName]);
            files = dir('*.csv');
            countero = 1;
            counterb = 1;
            counterc = 1;
            for f = 1:length(files)
                delimiter = ',';
                startRow = 48;
                formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';
                fileID = fopen([Directory '\' dates(g).name '\' BehaviorFolderName '\' files(f).name],'r');
                textscan(fileID, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
                dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);
                fclose(fileID);
                raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
                for col=1:length(dataArray)-1
                    raw(1:length(dataArray{col}),col) = dataArray{col};
                end
                numericData = NaN(size(dataArray{1},1),size(dataArray,2));
                rawData = dataArray{2};
                for row=1:size(rawData, 1);
                    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                    try
                        result = regexp(rawData{row}, regexstr, 'names');
                        numbers = result.numbers;
                        invalidThousandsSeparator = false;
                        if any(numbers==',');
                            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                            if isempty(regexp(thousandsRegExp, ',', 'once'));
                                numbers = NaN;
                                invalidThousandsSeparator = true;
                            end
                        end
                        if ~invalidThousandsSeparator;
                            numbers = textscan(strrep(numbers, ',', ''), '%f');
                            numericData(row, 2) = numbers{1};
                            raw{row, 2} = numbers{1};
                        end
                    catch me
                    end
                end
                rawNumericColumns = raw(:, 2);
                rawCellColumns = raw(:, [1,3,4,5,6,7]);
                R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
                rawNumericColumns(R) = {NaN};
                OdorsBeh = raw;
                clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;
                odors = OdorsBeh(:,3);
                behaviors = OdorsBeh(:,7);
                Rewards = OdorsBeh(:,5);
                o1Ind = regexp(odors,o1);
                o2Ind = regexp(odors,o2);
                o3Ind = regexp(odors,o3);
                o4Ind = regexp(odors,o4);
                o5Ind = regexp(odors,o5);
                o6Ind = regexp(odors,o6);
                o7Ind = regexp(odors,o7);
                o8Ind = regexp(odors,o8);
                o9Ind = regexp(odors,o9);
                o10Ind = regexp(odors,o10);
                o11Ind = regexp(odors,o11);
                o12Ind = regexp(odors,o12);
                o13Ind = regexp(odors,o13);
                o14Ind = regexp(odors,o14);
                o15Ind = regexp(odors,o15);
                b1Ind = regexp(behaviors,b1);
                b2Ind = regexp(behaviors,b2);
                b3Ind = regexp(behaviors,b3);
                b4Ind = regexp(behaviors,b4);
                Rew1Ind = regexp(Rewards,Rew1);
                Rew2Ind = regexp(Rewards,Rew2);
                for h = 1:length(o1Ind)
                    if o1Ind{h} == 1
                        FinalOdors{countero,1} = 'VALVE 1';
                        countero = countero + 1;
                    elseif o2Ind{h} == 1
                        FinalOdors{countero,1} = 'VALVE 2';
                        countero = countero + 1;
                    elseif o3Ind{h} == 1
                        FinalOdors{countero,1} = 'Ethyl buyterate';
                        countero = countero + 1;
                    elseif o4Ind{h} == 1
                        FinalOdors{countero,1} = 'Amyl acetate';
                        countero = countero + 1;
                    elseif o5Ind{h} == 1
                        FinalOdors{countero,1} = '60EB 40AA';
                        countero = countero + 1;
                    elseif o6Ind{h} == 1
                        FinalOdors{countero,1} = '40EB 60AA';
                        countero = countero + 1;
                    elseif o7Ind{h} == 1
                        FinalOdors{countero,1} = '55EB 45AA';
                        countero = countero + 1;
                    elseif o8Ind{h} == 1
                        FinalOdors{countero,1} = '45EB 55AA';
                        countero = countero + 1;
                    elseif o9Ind{h} == 1
                        FinalOdors{countero,1} = 'Min-Limonen';
                        countero = countero + 1;
                    elseif o10Ind{h} == 1
                        FinalOdors{countero,1} = 'BUTYRIC ACID';
                        countero = countero + 1;
                    elseif o11Ind{h} == 1
                        FinalOdors{countero,1} = 'Air1';
                        countero = countero + 1;
                    elseif o12Ind{h} == 1
                        FinalOdors{countero,1} = 'Air2';
                        countero = countero + 1;
                    elseif o13Ind{h} == 1
                        FinalOdors{countero,1} = '60EB 40AA';
                        countero = countero + 1;
                    elseif o14Ind{h} == 1
                        FinalOdors{countero,1} = '40EB 60AA';
                        countero = countero + 1;
                    elseif o15Ind{h} == 1
                        FinalOdors{countero,1} = 'ISOAMYL ACETATE';
                        countero = countero + 1;
                    end
                end
                for j = 1:length(b1Ind)
                    if b1Ind{j} == 1
                        FinalBeh{counterb,1} = 'MISS';
                        counterb = counterb + 1;
                    elseif b2Ind{j} == 1
                        FinalBeh{counterb,1} = 'CR';
                        counterb = counterb + 1;
                    elseif b3Ind{j} == 1
                        FinalBeh{counterb,1} = 'HIT';
                        counterb = counterb + 1;
                    elseif b4Ind{j} == 1
                        FinalBeh{counterb,1} = 'FA';
                        counterb = counterb + 1;
                    end
                end
                for k = 1:length(Rew1Ind)
                    if Rew1Ind{k} == 1
                        FinalRew{counterc,1} = '+';
                        counterc = counterc + 1;
                    elseif Rew2Ind{k} == 1
                        FinalRew{counterc,1} = '-';
                        counterc = counterc + 1;
                    end
                end
                Merged = [FinalOdors FinalBeh FinalRew];
            end
            
            for a = 1:length(ALLBLOCKS)
                c(a) = ALLBLOCKS(a).Olf_data;
                [~,index1] = find(c==1);
            end
            clear a
            
            for q = 1:length(index1)
                b = ((q-1)*20) + 1;
                ALLBLOCKS(index1(q)).OdorsBeh = Merged(b:(q*20),:);
            end

            cd([Directory '\' dates(g).name]);
            save('ALLBLOCKS.mat','ALLBLOCKS');
            %clear Merged FinalOdors FinalBeh;
        end
        clear c index1 q
    end
end
