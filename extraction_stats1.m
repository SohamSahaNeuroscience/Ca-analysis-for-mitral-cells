close all
clear all
clc


load('MCCELLS_final.mat')

%% Light only
%take light responses of all cells
%remove cells that are not in all experiments
blah = [];
for j = 1:length(MCCELLS_final.light)
    blah = [blah MCCELLS_final.light(j).mean];
    MCCELLS_final.light(1).allcells = blah;
end
clear blah j

light_resp = MCCELLS_final.light.allcells;

%remove NaNs
sums = sum(light_resp,2);
index = find(isnan(sums)==1);
light_resp(index,:)= [];
%remove first 15 frames
light_resp(1:15,:)= [];
light_resp(91:95,:)=[];

%AUC for all cells before and after
auc_light_before = trapz(light_resp(1:90,:));
auc_light_after = trapz(light_resp(91:end,:));

%% Odor and light
%take light responses of all cells
%remove cells that are not in all experiments
blah = [];
blah1 = [];
for j = 1:length(MCCELLS_final.odor_light)
    blah = [blah MCCELLS_final.odor_light(j).OdorA_Mean];
    blah1 = [blah1 MCCELLS_final.odor_light(j).OdorB_Mean];
    MCCELLS_final.odor_light(1).OdorA = blah;
    MCCELLS_final.odor_light(1).OdorB = blah1;
    
end
clear blah blah1 j

OdorA_resp = MCCELLS_final.odor_light.OdorA;
OdorB_resp = MCCELLS_final.odor_light.OdorB;

%remove identical frames as light response
OdorA_resp(index,:)= [];
OdorB_resp(index,:)= [];
%remove first 15 frames
OdorA_resp(1:15,:)= [];
OdorA_resp(91:95,:)=[];
OdorB_resp(1:15,:)= [];
OdorB_resp(91:95,:)=[];

%AUC for all cells before and after
auc_odorA_before = trapz(OdorA_resp(1:90,:));
auc_odorA_after = trapz(OdorA_resp(91:end,:));
auc_odorB_before = trapz(OdorB_resp(1:90,:));
auc_odorB_after = trapz(OdorB_resp(91:end,:));


%% Odor
%take light responses of all cells
%remove cells that are not in all experiments
blah = [];
blah1 = [];
for j = 1:length(MCCELLS_final.odor)
    blah = [blah MCCELLS_final.odor(j).OdorA_Mean];
    blah1 = [blah1 MCCELLS_final.odor(j).OdorB_Mean];
    MCCELLS_final.odor(1).OdorA = blah;
    MCCELLS_final.odor(1).OdorB = blah1;
    
end
clear blah blah1 j

OdorAonly_resp = MCCELLS_final.odor.OdorA;
OdorBonly_resp = MCCELLS_final.odor.OdorB;

%remove identical frames as light response
OdorAonly_resp(index,:)= [];
OdorBonly_resp(index,:)= [];
%remove first 15 frames
OdorAonly_resp(1:15,:)= [];
OdorAonly_resp(91:95,:)=[];
OdorBonly_resp(1:15,:)= [];
OdorBonly_resp(91:95,:)=[];

%AUC for all cells before and after
auc_odorAonly_before = trapz(OdorAonly_resp(1:90,:));
auc_odorAonly_after = trapz(OdorAonly_resp(91:end,:));
auc_odorBonly_before = trapz(OdorBonly_resp(1:90,:));
auc_odorBonly_after = trapz(OdorBonly_resp(91:end,:));
clear index

%% Track auc of same cells
[x1, index] = sort(auc_odorAonly_after, 'descend');

alldata_before = [auc_light_before; auc_odorA_before; auc_odorB_before; auc_odorAonly_before; auc_odorBonly_before];
figure;imagesc(alldata_before(:,index)');
load('RWBmap2.mat')
caxis([-5 30])
colormap(RWBmap)

alldata_after = [auc_light_after; auc_odorA_after; auc_odorB_after; auc_odorAonly_after; auc_odorBonly_after];
figure;imagesc(alldata_after(:,index)');
caxis([-5 30])
colormap(RWBmap)

%% PCA rotations

[coeff1, score, latent, explained, tsquared] = pca(GLCELLS_final.light(1).allcells);
% [coeff2, score, latent, explained, tsquared] = pca(OdorA_resp);
% [coeff3, score, latent, explained, tsquared] = pca(OdorB_resp);
% [coeff4, score, latent, explained, tsquared] = pca(OdorAonly_resp);
% [coeff5, score, latent, explained, tsquared] = pca(OdorBonly_resp);
% 
% a = rotatefactors(coeff1(:,1:2),'Method','varimax')
% b = rotatefactors(coeff2(:,1:2),'Method','varimax')
% c = rotatefactors(coeff3(:,1:2),'Method','varimax')
% d = rotatefactors(coeff4(:,1:2),'Method','varimax')
% e = rotatefactors(coeff5(:,1:2),'Method','varimax')
% 
% 
% figure;
% subplot(1,5,1);biplot(a);
% subplot(1,5,2);biplot(b);
% subplot(1,5,3);biplot(c);
% subplot(1,5,4);biplot(d);
% subplot(1,5,5);biplot(e);

%% correlations

%indexing and sorting
% [x1, index] = sort(auc_light_after, 'descend');

C1 = corr(OdorAonly_resp(91:end,index), OdorBonly_resp(91:end,index));
C2 = corr(OdorA_resp(91:end,index), OdorAonly_resp(91:end,index));
C3 = corr(OdorAonly_resp(91:end,index), light_resp(91:end,index));
C4 = corr(OdorB_resp(91:end,index), OdorBonly_resp(91:end,index));
C5 = corr(OdorBonly_resp(91:end,index), light_resp(91:end,index));

for i = 1:size(C1,1)
    for j = 1:size(C1,2)
        if C1(i,j) < 0.5 && C1(i,j)>0
            C1(i,j) = 0;
        end
    end
end

for i = 1:size(C2,1)
    for j = 1:size(C2,2)
        if C2(i,j) < 0.5 && C2(i,j)>0
            C2(i,j) = 0;
        end
    end
end

for i = 1:size(C3,1)
    for j = 1:size(C3,2)
        if C3(i,j) < 0.5 && C3(i,j)>0
            C3(i,j) = 0;
        end
    end
end

for i = 1:size(C4,1)
    for j = 1:size(C4,2)
        if C4(i,j) < 0.5 && C4(i,j)>0
            C4(i,j) = 0;
        end
    end
end

for i = 1:size(C5,1)
    for j = 1:size(C5,2)
        if C5(i,j) < 0.5 && C5(i,j)>0
            C5(i,j) = 0;
        end
    end
end
figure; imagesc(C1); colormap(RWBmap)
figure; imagesc(C2); colormap(RWBmap)
figure; imagesc(C3); colormap(RWBmap)
figure; imagesc(C4); colormap(RWBmap)
figure; imagesc(C5); colormap(RWBmap)


figure;
subplot(5,1,1);plot(diag(C1));
subplot(5,1,2);plot(diag(C2));
subplot(5,1,3);plot(diag(C3));
subplot(5,1,4);plot(diag(C4));
subplot(5,1,5);plot(diag(C5));

% plot responses

light
figure;
for i = 1:10
    subplot(10,1,i); plot(MCCELLS_final.light(1).allcells(:,index(i)));
end

%odorA-light
figure;
for i = 1:10
    subplot(10,1,i); plot(MCCELLS_final.odor_light(1).OdorA(:,index(i)));
end

%odorB-light
figure;
for i = 1:10
    subplot(10,1,i); plot(MCCELLS_final.odor_light(1).OdorB(:,index(i)));
end

%odorA
figure;
for i = 1:10
    subplot(10,1,i); plot(MCCELLS_final.odor(1).OdorA(:,index(i)));
end

%odorB
figure;
for i = 1:10
    subplot(10,1,i); plot(MCCELLS_final.odor(1).OdorB(:,index(i)));
end

