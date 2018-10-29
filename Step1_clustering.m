close all
clear all
clc

rootdir = 'E:\MC\odor+light\400\New folder (2)\New folder\New folder';
cd(rootdir)

List = dir('waves_*.mat');

%for Cam
load('ALLBLOCKS.mat');
for i = 1:length(List)
    x = load(List(i).name);
    ALLBLOCKS(i).data = x.waves;
    clear x
end
%end for Cam

List = dir('waves_*.mat');

blah = [];
for i = 1:length(List)
    x = load(List(i).name);
    w = x.waves;
    blah = [blah, w];
    clear x w
end

variance = sort(var(blah'), 'descend');
rat = variance/max(variance);
v1 = numel(find(rat > 0.75*mean(rat)));
A2=im2double(blah);
S2=size(A2);
A3= A2(:,:);
S3=size(A3);
idx = [];

for i=1:S3(1)
    idx=[idx i];
end

idx=idx';
no = v1;
clust = clusterdata(A3,'maxclust',no,'distance','correlation','linkage','average');%hierarchial
Final=zeros(1,S2(1));
Final=Final';

for i=1:S3(1)
    Final(idx(i))=clust(i);
end

[c idx1] = sort(clust, 'descend');
m=1;

for i= 1:size(idx1,1)
    sorted(m,:) = blah(c(i),:);
    m=m+1;
end

n=1;
for k = 1:no
    x = find(clust == k);
    for o = 1:length(x)
        temp1(:,:) = sorted(x,:);
    end
    clustered_pixels(n,:) = mean(temp1,1);
    n=n+1;
    clear temp1
end
clear k o

save('Clustered_pixels_var.mat','clustered_pixels');
save('Indexedclusters.mat','clust');
save('Sorted_ROIs.mat','sorted');
save('ALLBLOCKS.mat', 'ALLBLOCKS');
clear clustered_pixels sorted
