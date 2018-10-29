% Matt Valley, March, 2014
% Use correlation information within ALLBLOCKS.mat and re-plot the
% different thresholded distributrions of the dataset.
% 2017-01-26 modified by Kurt Sailor
% After running Preprocess_master_batch with BackupALLBLOCKS = 1 this code
% will go through each backed up ALLBLOCKS and popup a input for setting
% the threshold cutoff. rootdir is the individual animal directory
% containing all the ALLBLOCKS. Also, plot will be saved as dfp_ALLBLOCKS.

clear all
%rootdir is full path to root all the ALLBLOCKS
rootdir = 'E:\MC\odor+light\400\New folder (2)\New folder\New folder';
cd(rootdir);
Files = dir('*ALLBLOCKS.mat');
xcorrthresh = 0.59;

for u = 1:length(Files)
    fprintf(['File ' num2str(u) ' -- ' Files(u).name]);
    load(Files(u).name);
    corrs = [];
    for block = 1:length(ALLBLOCKS)
        includelist = zeros(size(ALLBLOCKS(block).corrs, 2), 1);
        corrs = ALLBLOCKS(block).corrs;
        for k = 1:size(ALLBLOCKS(block).corrs, 2)
            if corrs(k)> xcorrthresh
                includelist(k) = 1;
            end
        end
        ALLBLOCKS(block).include = logical(includelist);
        percent_rej = 100 - (sum(includelist)/length(includelist))*100;
        disp(['  block_' num2str(block) ' rejected ' num2str(percent_rej) '% frames']);
    end
    fig1 = figure;plot_allblocks(ALLBLOCKS, xcorrthresh, percent_rej);
    b = input(['Is ' num2str(xcorrthresh) ' threshold correct (y/n)? '], 's');
    while sum((strcmp(b,'y') + strcmp(b,'n')) < 1) == 1
        b = input(['Is ' num2str(xcorrthresh) ' threshold correct (y/n)? '], 's');
    end
    if strcmp(b,'y') == 1
        b = 1;
        savefig(['dfp_' Files(u).name(1:end-4) '.fig']);
        save(Files(u).name, 'ALLBLOCKS');
        close(fig1);
    end
    if strcmp(b,'n') == 1
        b = 0;
        close(fig1);
        while b == 0
            if exist('fig2') == 1
                close(fig2)
            end
            xcorrthresh = input('Set the xcorrthresh ');
            for block = 1:length(ALLBLOCKS)
                includelist = zeros(size(ALLBLOCKS(block).corrs, 2), 1);
                corrs = ALLBLOCKS(block).corrs;
                for k = 1:size(ALLBLOCKS(block).corrs, 2)
                    if corrs(k)> xcorrthresh
                        includelist(k) = 1;
                    end
                end
                ALLBLOCKS(block).include = logical(includelist);
                percent_rej = 100 - (sum(includelist)/length(includelist))*100;
                disp(['block_' num2str(block) ' rejected ' num2str(percent_rej) '% frames']);
            end
            fig2 = figure;plot_allblocks(ALLBLOCKS, xcorrthresh, percent_rej);
            c = input(['Is ' num2str(xcorrthresh) ' threshold correct (y/n)? '], 's');
            while sum((strcmp(c,'y') + strcmp(c,'n')) < 1) == 1
                c = input(['Is ' num2str(xcorrthresh) ' threshold correct (y/n)? '], 's');
            end
            b = isvector(strfind(c,'y'));
        end
        savefig(['dfp_' Files(u).name(1:end-4) '.fig']);
        save(Files(u).name, 'ALLBLOCKS');
        close(fig2);
    end
    clear fig1 fig2 corrs includelist k
end

