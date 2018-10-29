% Script for automatically extracting ROIs drawn in ImageJ(FIJI) as .zip
% files and creating structure with all pixel values
% Dependency 'ReadImageJROI.m'
% code will go through individual animal directory, extract roi locations
% and save in 'waves' folder within individual directories
% File structure:
% AnimalID directory
% --Date of experiment directory

clear all


AnimalIDdir = 'Y:\Soham Experiments\2017 Mitral cell recording photostim\GL cells';
ROIfile = 'Y:\Soham Experiments\2017 Mitral cell recording photostim\GL cells\ROIs\Animal 1 side 1\RoiSet1-7.zip';
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
for f = 3%:length(ExpDateDir)
    if ExpDateDir(f).isdir == 1
        cd([AnimalIDdir '\' ExpDateDir(f).name]);
        load('ALLBLOCKS.mat');
        Stackdir = dir('PCA_block*');
        Stackdir1 = dir('Reg_*');
        mkdir('waves');
        for s = 1:length(Stackdir)
            stack = loadtif(Stackdir(s).name, [AnimalIDdir '\' ExpDateDir(f).name]);
            stack1 = loadtif(Stackdir1(s).name, [AnimalIDdir '\' ExpDateDir(f).name]);
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
            for k = 1:length(ROIs)
                for ii = 1:length(ROIs(k).XY)
                    temp(ii,:) = stack1(ROIs(k).XY(ii,1), ROIs(k).XY(ii,end),:);
                end
                allmean(k,:) = mean(temp,1);
                clear temp;
            end
            %cd([Rootdir '\' Animals(qw).name '\' Dates(we).name '\maps']);
            %savefile = ['waves_' Images(s).name(1:end-3) 'mat'];
            %save(savefile,'allmean');
            ALLBLOCKS(s).meanwaves = allmean;
            cd([AnimalIDdir '\' ExpDateDir(f).name '\waves'])
            savefile = [Stackdir(s).name(1:end-4) '.mat'];
            save(savefile, 'ROIs');
            savePCARois = ['PCA_ROIs_' Stackdir(s).name(1:end-4) '.mat'];
            save(savePCARois, 'PCAROIs');
            PCAMax = uint8(sum(PCAROIs,3));
            PCAROImap = 255./(max(max(PCAMax))) * PCAMax;
            imwrite(PCAROImap, ['PCA_ROIBinMap_' Stackdir(s).name(1:end-4) '.tif']);
            PCAROImapStack(:,:,counter) = PCAROImap;
            counter = counter+1;
            
            clear PCAROIs PCAROImap allmean stack stack1;
        end
    end
end
cd(AnimalIDdir);
% saveastiff(PCAROImapStack, 'AllPCAROIMaps.tif');




