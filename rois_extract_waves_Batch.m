%2016-07-12 rois_extract_waves_Batch code by Kurt Sailor
%This code requires runing Extract_Ellipse_ROIs.m first in order to make
%'waves' folder containing the ROI maps.
%the waves are extracted from raw image files which are corrected for x-y-z
%motion artifacts.
%
%Copy explained variance file from the PCA outputs
%File driectory structure
%Rootdir containing all animal folders
%--AnimalID
%----Date
%Will search for files with the starting of "Stackreg_block*"


clear all
Rootdir = 'Y:\Soham Experiments\2017 Mitral cell recording photostim\GL cells';%For reading raw registered image (NOT PCA)
%Rootdir2 = 'F:\2016 March-April\Analysis\PCA done\012216-02\2016-03-22 EBAA\waves';%Matrix containing coordinates
%ROICoor = 'PCA_block_1_Ch2.mat';%ROI coordinate files
cd(Rootdir)
Animals = dir;

for qw = 3:length(Animals)
    if Animals(qw).isdir == 1
        cd([Rootdir '\' Animals(qw).name]);
        Dates = dir;
        for we = 3:length(Dates)
            if Dates(we).isdir == 1
                cd([Rootdir '\' Animals(qw).name '\' Dates(we).name]);
                load('ALLBLOCKS.mat');
                mkdir('maps');
                 Images = dir('Reg2_*');
%Images = dir('block_1_Ch2*');
                for ef = 1:length(Images)
                    stack = loadtif(Images(ef).name, [Rootdir '\' Animals(qw).name '\' Dates(we).name]);
                    stack = double(stack);
                    cd([Rootdir '\' Animals(qw).name '\' Dates(we).name '\waves']);
                     ROICoors = dir('Reg2_*');
%ROICoors = dir('PCA_block*');
                    load(ROICoors(ef).name);%This saved mat file will have variable name "ROIs"
                    for k = 1:length(ROIs)
                        for ii = 1:length(ROIs(k).XY)
                            temp(ii,:) = stack(ROIs(k).XY(ii,1), ROIs(k).XY(ii,end),:);
                        end
                        allmean(k,:) = mean(temp,1);
                        clear temp;
                    end
                    cd([Rootdir '\' Animals(qw).name '\' Dates(we).name '\maps']);
                    savefile = ['waves_' Images(ef).name(1:end-3) 'mat'];
                    save(savefile,'allmean');
                    ALLBLOCKS(ef).meanwaves = allmean;
                    %                   cd([Rootdir '\' Animals(qw).name '\' Dates(we).name '\waves']);
                    
                    %determine number of clusters
                    %                     stdev = sort(std(allmean'),'descend');
                    %                     rat = stdev/max(stdev);
                    %                     df = sort(diff(rat),'ascend');
                    %                     v = numel(find(df < -0.0015));
                    variance = sort(var(allmean'), 'descend');
                    rat = variance/max(variance);
                    df = sort(diff(rat),'ascend');
                    v = numel(find(rat > 0.5*mean(rat)));
                    
                    %cluster waves extracted from ROIs
                    A2=im2double(allmean);
                    S2=size(A2);
                    A3=A2(:,:);
                    S3=size(A3);
                    idx = [];
                    for i=1:S3(1)
                        idx=[idx i];
                    end
                    idx=idx';
                    no = v;
                    clust = clusterdata(A3,'maxclust',no,'distance','correlation','linkage','average');%hierarchial
                    Final=zeros(1,S2(1));
                    Final=Final';
                    for i=1:S3(1)
                        Final(idx(i))=clust(i);
                    end
                    [c idx1] = sort(clust, 'descend');
                    m=1;
                    for i= 1:size(idx1,1)
                        sorted(m,:) = allmean(c(i),:);
                        m=m+1;
                    end
                    
                    report = zeros(512,512);
                    for g = 1:length(ROIs)
                        for h = 1:length(ROIs(g).XY)
                            report(ROIs(g).XY(h,1), ROIs(g).XY(h,end))=c(g);
                        end
                    end
                    report_color = uint8(report(:,:)/no*255);
                    f = [c,idx1];
                    
                    x=1;
                    for t = 1:v
                        ROIs(x).image = zeros(512,512);
                        ROIs(x).image = (report(:, :) == t );
                        x=x+1;
                    end
                    clear m
                    m=1;
                    for q = 1:v
                        image(:,:,m) = ROIs(q).image/q*255;
                        m=m+1;
                    end
                    
                    
                    %                     %plot comps
                    %                     num = no;
                    %                     figure;
                    %                     for r = 1:size(image,3)
                    %                         subplot(5, ceil(no/5), r); imagesc(image(:,:,r));
                    %                     end
                    
                    %                     %plot unique data
                    %                     [tu,iu] = unique(c);
                    %                     unique_sorted = sorted(iu,:);
                    outputFileName1 = ['MAP_' Images(ef).name];
                    imwrite(report_color,outputFileName1,'tif');
                    clear n k
                    
                    %                     n=1;
                    %                     for k = 1:no
                    %                         x = find(c == k);
                    %                         for o = 1:length(x)
                    %                             temp1(:,:) = sorted(x,:);
                    %                         end
                    %                         allmean1(n,:) = mean(temp1,1);
                    %                         n=n+1;
                    %                         clear temp1
                    %                     end
                    
                    %                     for x = 1:44   %change number you need
                    %                         temp(x,:,:) = double(ROIs(x).image);
                    %                         temp(x,:,:) = x * temp(x,:,:);
                    %                     end
                    %                     color = squeeze(sum(temp,1));
                    %                     figure1 = figure('Colormap',...
                    %                         [0 0 0;0 0 0.134920626878738;0 0 0.269841253757477;0 0 0.404761880636215;0 0 0.539682507514954;0 0 0.674603164196014;0 0 0.80952376127243;0 0 0.944444417953491;0 0.00793650839477777 1;0 0.0714285671710968 1;0 0.134920626878738 1;0 0.19841268658638 1;0 0.261904746294022 1;0 0.325396806001663 1;0 0.388888865709305 1;0 0.452380925416946 1;0 0.51587301492691 1;0 0.579365074634552 1;0 0.642857134342194 1;0 0.706349194049835 1;0 0.769841253757477 1;0 0.833333313465118 1;0 0.89682537317276 1;0 0.960317432880402 1;0.0238095242530108 1 0.976190447807312;0.0873015820980072 1 0.91269838809967;0.150793641805649 1 0.849206328392029;0.21428570151329 1 0.785714268684387;0.277777761220932 1 0.722222208976746;0.341269820928574 1 0.658730149269104;0.404761880636215 1 0.595238089561462;0.468253970146179 1 0.531746029853821;0.531746029853821 1 0.468253970146179;0.595238089561462 1 0.404761880636215;0.658730149269104 1 0.341269820928574;0.722222208976746 1 0.277777761220932;0.785714268684387 1 0.21428570151329;0.849206328392029 1 0.150793641805649;0.91269838809967 1 0.0873015820980072;0.976190447807312 1 0.0238095242530108;1 0.960317432880402 0;1 0.89682537317276 0;1 0.833333313465118 0;1 0.769841253757477 0;1 0.706349194049835 0;1 0.642857134342194 0;1 0.579365074634552 0;1 0.51587301492691 0;1 0.452380925416946 0;1 0.388888865709305 0;1 0.325396806001663 0;1 0.261904746294022 0;1 0.19841268658638 0;1 0.134920626878738 0;1 0.0714285671710968 0;1 0.00793650839477777 0;0.944444417953491 0 0;0.88095235824585 0 0;0.817460298538208 0 0;0.753968238830566 0 0;0.690476179122925 0 0;0.626984119415283 0 0;0.563492059707642 0 0;0.5 0 0]);
                    %                     imagesc(color);
                    
                    %calculating df/f0
                    %                         r=1;
                    %                         for q = 1:size(allmean1,1)
                    %                             ROIs(r).f0 = mean(allmean1(q,:));
                    %                             ROIs(r).deltaf = (allmean1(q,:)-ROIs(r).f0)./ROIs(r).f0;
                    %                             r=r+1;
                    clear allmean sorted;
                end
                cd([Rootdir '\' Animals(qw).name '\' Dates(we).name]);
                save('ALLBLOCKS.mat','ALLBLOCKS');
                clear ALLBLOCKS;
            end
            
        end
    end
    
end

% clear r
%
% savefile = '2015-11-06_ROIs.mat';
% save(savefile, 'ROIs');%PUT THIS IN ALLBLOCKS


