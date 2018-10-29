%%  Code to prepare large two-photon calcium imaging datasets for analysis
%%  Matt Valley, December 2013
%%  Modified 2017-02-07 to keep track of original filenames Kurt Sailor
%%  This code loads data from tif stacks containing two interleaved channels
%%  of image data, Ch1 and Ch2 assuming that the signal in Ch1 is not time variant.
%%  Typically, Ch1 will be a morphological label, and Ch2 the calcium dye.
%%  Tif stacks can be generated from t-series data exported by Prairieview (Bruckerview?)
%%  by first running TiftoStack.m
%%
%%  Unique function calls:
%%  1.  Load Data from tif stacks
%%      loadtif.m
%%  2.  Identify frames with z-shift from Ch1
%%      zcorr_cpu.m
%%
%% THEN... zcorr_solo to find good threshold for z-correction
%% and enable tif saving to output single .tif of valid images
%% THEN... block_reg to register all blocks and median filter

%%Kurt modified this to be batched on 2015-01-29.
%%Put files in separate folders for different mice and days
%%Structure of files:
%Root directory
%--Directories segregated by mice
%----Directories segregated by date containing 3D TIFFs


clear all

rootdir = 'E:\MC\odor+light\400\New folder (2)'; % full path to the different mouse and day folders
BackupALLBLOCKS = 0;
BackupDir = 'E:\2017 Jan Feb March Exc DREADD\Activity\All_days_all_animals\120316-03';
blocksize = 20; %Number of trials in each block

cd(rootdir);
List = dir;
for w = 3:length(List)
    if List(w).isdir == 1;
        cd([rootdir '\' List(w).name]);
        ListSub = dir;
        for v = 3:length(ListSub)
            if ListSub(v).isdir == 1;
                TifDir = [rootdir '\' List(w).name '\' ListSub(v).name];
                cd(TifDir);
                ImgExtension = '.tif'; % specify image extension
                ImgList1 = dir(['*Ch1*' ImgExtension]); % get all Ch1 file names
                ImgList2 = dir(['*Ch2*' ImgExtension]); % get all Ch2 file names
                
                %chunk trials in appropriately sized blocks for analysis
                numtrials = length(ImgList1); % take blocks from Ch1, but will apply the same to Ch2
                numblocks = numtrials/blocksize;
                if ceil(numblocks) - numblocks > .5
                    numblocks = ceil(numblocks) + 1; %make new block if num of trials is above 50% the size of the rest of the blocks
                else
                    numblocks = ceil(numblocks);
                end
                for n = 1:numblocks
                    if n<numblocks
                        blockstart = 1+(blocksize*n)-blocksize;
                        ALLBLOCKS(n).triallist = blockstart:(blockstart+blocksize-1);
                    else
                        blockstart = 1+(blocksize*n)-blocksize;
                        ALLBLOCKS(n).triallist = blockstart:numtrials; %last block contains trials ending at numtrials
                    end
                end
                
                %%%%%%% 1. Load Data from tif stacks, consolidate into blocks
                for block = 1:length(ALLBLOCKS)
                    block1data = [];block2data = [];
                    triallist = ALLBLOCKS(block).triallist;
                    for i = 1:length(triallist)
                        trial = triallist(i);
                        stack1 = loadtif(ImgList1(trial).name, TifDir);
                        stack2 = loadtif(ImgList2(trial).name, TifDir);
                        if size(stack1,3) ~= size(stack2,3) %make number of frames match in each stack
                            trunc = min([size(stack1,3), size(stack2,3)]);
                            stack1 = stack1(:,:,1:trunc);
                            stack2 = stack2(:,:,1:trunc);
                        end
                        disp(['loading trial ' num2str(trial) ', file ' num2str(ImgList1(trial).name)]);
                        nimg(i) = size(stack1,3); %applies equally
                        block1data = cat(3,block1data,stack1);
                        block2data = cat(3,block2data,stack2);
                        ALLBLOCKS(block).imgindx{i} = 1:nimg(i);
                        ALLBLOCKS(block).imgName{i} = ImgList2(i).name;%Save original image name in ALLBLOCKS
                        clear stack1 stack2
                    end
                    
                    %%%%%%% 2. Get frame correlations to identify z-shifts from Ch1
                    [corrs] = zcorr_cpu(block1data);
                    ALLBLOCKS(block).corrs = corrs;
                end
            end
            save(['ALLBLOCKS.mat'], 'ALLBLOCKS');
            clear ALLBLOCKS block block1data block2data corrs ImgList1 ImgList2 nimg trial triallist numblocks numtrialsblockstart;
        end
    end
end

if BackupALLBLOCKS == 1
    cd(rootdir);
    AnimalDir = dir;
    for u = 3:length(AnimalDir)
        if AnimalDir(u).isdir == 1
            cd(BackupDir)
            mkdir(AnimalDir(u).name);
            cd([rootdir '\' AnimalDir(u).name])
            Dates = dir;
            for k = 3:length(Dates)
                if Dates(k).isdir == 1
                    cd([rootdir '\' AnimalDir(u).name '\' Dates(k).name]);
                    A = dir('ALLBLOCKS.mat');
                    if size(A,1) == 1
                        copyfile('ALLBLOCKS.mat',[BackupDir '\' AnimalDir(u).name]);
                        cd([BackupDir '\' AnimalDir(u).name]);
                        movefile('ALLBLOCKS.mat',[Dates(k).name '_ALLBLOCKS.mat'])
                    end
                end
            end
        end
    end
end

