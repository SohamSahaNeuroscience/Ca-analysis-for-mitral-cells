close all
clear all

clc

rootdir = '/Users/sophiesoham/Desktop/Camille Expt/MC';
cd(rootdir)

load('MCCELLS.mat');
exp = {'light' 'odor_light' 'odor'};

Light = MCCELLS.light;
blah = [];
for j = 1:length(Light)
    blah = [blah Light(j).Light_Mean];
end
frame = blah(135:end,:);
[coeff, score, latent, explained, tsquared] = pca(frame);
ref = score(:, 1:6);
cells = corr(ref, frame);
for m = 1:size(cells,1)
    for n = 1:size(cells,2)
        if cells(m,n)< 0.56
            cells(m,n) = 0;
        end
    end
end

totalcells = round(sum(cells,2));
auc_before = trapz(blah(10:90,:));
auc_after = trapz(blah(130:end,:));
auc_norm = auc_after - auc_before;
sorted = sort(auc_norm, 'ascend');


Odor_light = MCCELLS.odor_light;   
%OdorA
blah1 = [];
for j = 1:length(Odor_light)
    blah1= [blah1 Odor_light(j).OdorA_Mean];
end
frame1 = blah1(135:end,:);
[coeff1, score1, latent1, explained1, tsquared1] = pca(frame1);
ref1 = score1(:, 1:6);
cells1 = corr(ref1, frame1);
for m = 1:size(cells1,1)
    for n = 1:size(cells1,2)
        if cells1(m,n)< 0.56
            cells1(m,n) = 0;
        end
    end
end

totalcells1 = round(sum(cells1,2));
auc_before1 = trapz(blah1(10:90,:));
auc_after1 = trapz(blah1(130:end,:));
auc_norm1 = auc_after1 - auc_before1;
sorted1 = sort(auc_norm1, 'ascend');

%OdorB
blah2 = [];
for j = 1:length(Odor_light)
    blah2= [blah2 Odor_light(j).OdorB_Mean];
end
frame2 = blah2(135:end,:);
[coeff2, score2, latent2, explained2, tsquared2] = pca(frame2);
ref2 = score2(:, 1:6);
cells2 = corr(ref2, frame2);
for m = 1:size(cells2,1)
    for n = 1:size(cells2,2)
        if cells2(m,n)< 0.56
            cells2(m,n) = 0;
        end
    end
end

totalcells2 = round(sum(cells2,2));
auc_before2 = trapz(blah2(10:90,:));
auc_after2 = trapz(blah2(130:end,:));
auc_norm2 = auc_after2 - auc_before2;
sorted2 = sort(auc_norm2, 'ascend');
    


Odor = MCCELLS.odor;   
%OdorA
blah3 = [];
for j = 1:length(Odor)
    blah3= [blah3 Odor(j).OdorA_Mean];
end
frame3 = blah3(135:end,:);
[coeff3, score3, latent3, explained3, tsquared3] = pca(frame3);
ref3 = score3(:, 1:6);
cells3 = corr(ref3, frame3);
for m = 1:size(cells3,1)
    for n = 1:size(cells3,2)
        if cells3(m,n)< 0.56
            cells3(m,n) = 0;
        end
    end
end

totalcells3 = round(sum(cells3,2));
auc_before3 = trapz(blah3(10:90,:));
auc_after3 = trapz(blah3(130:end,:));
auc_norm3 = auc_after3 - auc_before3;
sorted3 = sort(auc_norm3, 'ascend');

%OdorB
blah4 = [];
for j = 1:length(Odor)
    blah4= [blah4 Odor(j).OdorB_Mean];
end
frame4 = blah4(135:end,:);
[coeff4, score4, latent4, explained4, tsquared4] = pca(frame4);
ref4 = score4(:, 1:6);
cells4 = corr(ref4, frame4);
for m = 1:size(cells4,1)
    for n = 1:size(cells4,2)
        if cells4(m,n)< 0.56
            cells4(m,n) = 0;
        end
    end
end

totalcells4= round(sum(cells4,2));
auc_before4 = trapz(blah4(10:90,:));
auc_after4 = trapz(blah4(130:end,:));
auc_norm4 = auc_after4 - auc_before4;
sorted4 = sort(auc_norm4, 'ascend');
