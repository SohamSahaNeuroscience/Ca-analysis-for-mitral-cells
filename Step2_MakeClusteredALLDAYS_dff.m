%PART 2 For splitting Clustered_pixels_var.mat and copying the clustered waves
%into individual ALLBLOCKS. Then each individaul ALLBLOCKS is renamed with
%the experimental date included and all placed into a folder

clear all

Animaldir = 'E:\MC\odor+light\2017-08-22_400time';
cd(Animaldir)
dates = dir;
odorpres = 1;

for k = 3:length(dates)
    if dates(k).isdir == 1
        cd([Animaldir '\' dates(k).name]);
        load('ALLBLOCKS.mat')
        for i = 1:length(ALLBLOCKS)
            ALLBLOCKS(i).NaNwaves = zeros(size(ALLBLOCKS(i).data,1),size(ALLBLOCKS(i).include,1));
            for ROInum = 1:size(ALLBLOCKS(i).data,1)%For each ROI
                indx = 1;
                inc = 1;
                for Trialnum = 1:length(ALLBLOCKS(i).include)%Counter for all frames
                    if ALLBLOCKS(i).include(indx) == 1
                        ALLBLOCKS(i).NaNwaves(ROInum,indx,:) = ALLBLOCKS(i).data(ROInum,inc);
                        inc = inc + 1;
                        indx = indx + 1;
                    else
                        ALLBLOCKS(i).NaNwaves(ROInum,indx,:) = NaN;
                        indx = indx + 1;
                    end
                end
            end
            
            
        end
    end
    save('ALLBLOCKS.mat','ALLBLOCKS','-v7.3');
    
end
clear ALLBLOCKS

cd(Animaldir);
for k = 3:length(dates)
    if dates(k).isdir == 1
        cd([Animaldir '\' dates(k).name]);
        %loads indexed clusters and the variable is named "clust"
        load('Indexedclusters.mat');
        load('ALLBLOCKS.mat');
        for i = 1:length(ALLBLOCKS)
            for k = 1:max(clust)
                x = find(clust == k);
                if length(x) == 1
                    temp(k,:) = ALLBLOCKS(i).NaNwaves(x,:);
                else
                    if length(x) > 1
                        temp(k,:) = nanmean(ALLBLOCKS(i).NaNwaves(x,:));
                    end
                end
            end
            ALLBLOCKS(i).ClustNaN = temp;
            clear temp;
        end
        clear clust
        save('ALLBLOCKS.mat','ALLBLOCKS','-v7.3');
    end
end
clear k i;

%make ALLDAYS of all ALLBLOCKS with each block annotated with date
%Will add experimental date to ALLDAYS from directory names
ALLDAYS = [];
counter = 1;
for k = 3:length(dates)
    if dates(k).isdir == 1
        cd([Animaldir '\' dates(k).name]);
        load('ALLBLOCKS.mat')
        for i = 1:length(ALLBLOCKS)
            ALLDAYS = [ALLDAYS; ALLBLOCKS(i)];
        end
        clear ALLBLOCKS
    end
end
clear k i;

counter = 1;
for k = 3:length(dates)
    if dates(k).isdir == 1
        cd([Animaldir '\' dates(k).name]);
        load('ALLBLOCKS.mat');
        for i = 1:length(ALLBLOCKS)
            ALLDAYS(counter).ExpID = dates(k).name;
            counter = 1 + counter;
        end
    end
end

for l = 1:length(ALLDAYS)
    if length(ALLDAYS(l).ClustNaN) <= 4000
        ALLDAYS(l).Code = 1;%spontaneous
    else
        ALLDAYS(l).Code = 2;%odor evoked
    end
    
end

%To remove extra data that isn't needed and otherwise makes files huge
cd(Animaldir);
dropfields = {'triallist','imgindx','corrs','include'};
ALLDAYS = rmfield(ALLDAYS,dropfields);


%% part 2

for j = 1:size(ALLDAYS,1)
    if (ALLDAYS(j).Code == 1 && size(ALLDAYS(j).ClustNaN,2) == 4000) == 1
        blocksize = 2;
        length = 2000;
        for rois = 1:size(ALLDAYS(j).ClustNaN,1)
            for k = 1:blocksize
                ALLDAYS(j).MCNaN(k,:,rois) = ALLDAYS(j).ClustNaN(rois,((k-1)*length)+1:(k*length));
            end
        end
    end
end

for j = 1:size(ALLDAYS,1)
    if (ALLDAYS(j).Code == 1 && size(ALLDAYS(j).ClustNaN,2) <4000) == 1
        blocksize = 1;
        length = 2000;
        
        for rois = 1:size(ALLDAYS(j).ClustNaN,1)
            for k = 1:blocksize
                ALLDAYS(j).MCNaN(k,:,rois) = ALLDAYS(j).ClustNaN(rois,((k-1)*length)+1:(k*length));
            end
        end
    end
end

for j = 1:size(ALLDAYS,1)
    if ALLDAYS(j).Code == 2
        blocksize = 20;
        length = size(ALLDAYS(j).ClustNaN, 2)/blocksize;
        
        for rois = 1:size(ALLDAYS(j).ClustNaN,1)
            for k = 1:blocksize
                ALLDAYS(j).MCNaN(k,:,rois) = ALLDAYS(j).ClustNaN(rois,((k-1)*length)+1:(k*length));
            end
        end
    end
end

save('ALLDAYS.mat','ALLDAYS','-v7.3');

%% odorA odorB

if odorpres == 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SEGREGATE BETWEEN ODORA AND ODORB%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for k = 1:size(ALLDAYS,1)
        BlockSize = 20;
        TrialSize = size(ALLDAYS(k).ClustNaN, 2)/BlockSize;% #frames per trial
        % BlockSize = 20;% SET TO 20 FOR 10 ODORA AND 10 ODOR B
        O1 = 'VALDEHYDE';% Put exact name as appears in ALLBLOCKS.OdorsBeh
        O2 = 'CINEOLE';
        O3 = 'HEXANONE';
        O4 = 'ETHYL TIGLATE';
        O5 = '60EB 40AA';
        O6 = '40EB 60AA';
        O7 = '55EB 45AA';
        O8 = '45EB 55AA';
        O9 = 'Min-Limonen';
        O10 = 'BUTYRIC ACID';
        O11 = 'VALVE 1';
        O12 = 'VALVE 2';
        
        
        O1reg = strcmp(O1,ALLDAYS(k).OdorsBeh(:,1));
        O2reg = strcmp(O2,ALLDAYS(k).OdorsBeh(:,1));
        O3reg = strcmp(O3,ALLDAYS(k).OdorsBeh(:,1));
        O4reg = strcmp(O4,ALLDAYS(k).OdorsBeh(:,1));
        O5reg = strcmp(O5,ALLDAYS(k).OdorsBeh(:,1));
        O6reg = strcmp(O6,ALLDAYS(k).OdorsBeh(:,1));
        O7reg = strcmp(O7,ALLDAYS(k).OdorsBeh(:,1));
        O8reg = strcmp(O8,ALLDAYS(k).OdorsBeh(:,1));
        O9reg = strcmp(O9,ALLDAYS(k).OdorsBeh(:,1));
        O10reg = strcmp(O10,ALLDAYS(k).OdorsBeh(:,1));
        O11reg = strcmp(O11,ALLDAYS(k).OdorsBeh(:,1));
        O12reg = strcmp(O12,ALLDAYS(k).OdorsBeh(:,1));
        ALLOdors = [O1reg O2reg O3reg O4reg O5reg O6reg O7reg O8reg O9reg O10reg O11reg O12reg];
        Odorsets = iszero(sum(ALLOdors,1));
        InxOdors = find(Odorsets == 0);
        OdorA = ALLOdors(:,InxOdors(1));
        OdorB = ALLOdors(:,InxOdors(2));
        
        for roi = 1:size(ALLDAYS(k).ClustNaN,1)
            counterA = 1;
            counterB = 1;
            for h = 1:BlockSize
                first = ((h-1)*TrialSize)+1;
                last = h*TrialSize;
                if OdorA(h) == 1
                    OdorAdat(counterA,:) = ALLDAYS(k).ClustNaN(roi,first:last);
                    counterA = counterA + 1;
                elseif OdorB(h) == 1
                    OdorBdat(counterB,:) = ALLDAYS(k).ClustNaN(roi,first:last);
                    counterB = counterB + 1;
                end
            end
            OdorAROI(:,:,roi) = OdorAdat;
            OdorBROI(:,:,roi) = OdorBdat;
        end
        ALLDAYS(k).OdorA = OdorAROI;
        ALLDAYS(k).OdorB = OdorBROI;
        clear OdorAROI OdorBROI
    end
end

cd(Animaldir);
save('ALLDAYS.mat', 'ALLDAYS', '-v7.3');
