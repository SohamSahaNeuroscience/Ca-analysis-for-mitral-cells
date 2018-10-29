% takes cell matched mean of the responses
% pca on all the data across conditions
% ranksum test to bring out significant responses
% combined PCA on the data
% removes frame 1-15 and 105-135 and normalizes pca outputs

close all
clear all
clc

dir = 'C:\Users\3D analysis 3\Desktop\Camille';
cd(dir)

load('GLCELLS_final.mat');

%% Only Light
Light = GLCELLS_final(1).light;
blah = [];
for i = 1:length(Light)
    blah = [blah Light(i).mean];
end

for j = 1:size(blah,2)
    [p(j),h(j)] = ranksum(blah(15:90,j),blah(135:210,j),'alpha',0.01,'tail','both');
end
clear j
ind = find(h == 0);
corr = blah;
corr(:,ind)=[];

[coeff, score, latent] = pca(blah);
GLCELLS_final(1).light(1).allcells = blah;
GLCELLS_final(1).light(1).allcells_ttest = corr;
GLCELLS_final(1).light(1).latent = latent;

for j = 1:size(score,2)
    norm_score(:,j) = (score(:,j) - mean(score(15:90,j)));
    norm_score(105:135,j) = NaN;
    norm_score(1:15,j) = NaN;
end
GLCELLS_final(1).light(1).score = norm_score(:,1:6);

clear blah j i p h Light coeff score norm_score latent p h ind corr


%% Odor Light
Odor_Light = GLCELLS_final(1).odor_light;
blah = [];
blah1 = [];
for i = 1:length(Odor_Light)
    blah = [blah Odor_Light(i).OdorA_Mean];
    blah1 = [blah1 Odor_Light(i).OdorB_Mean];
end
for j = 1:size(blah,2)
    [p(j),h(j)] = ranksum(blah(15:90,j),blah(135:210,j),'alpha',0.01,'tail','both');
    [p1(j),h1(j)] = ranksum(blah1(15:90,j),blah1(135:210,j),'alpha',0.01,'tail','both');
end
ind = find(h == 0); ind1 = find(h1 == 0);
ind2 = union(ind,ind1);
corr = blah;
corr1 = blah1;
corr(:,ind2)=[];
corr1(:,ind2)=[];


[coeff, score, latent] = pca(blah);
[coeff1, score1, latent1] = pca(blah1);
blah2 = [blah blah1];
blah3 =[corr corr1];
[coeff2, score2, latent2] = pca(blah2);

for j = 1:size(score,2)
    norm_score(:,j) = (score(:,j) - mean(score(15:90,j)));
    norm_score(105:135,j) = NaN;
    norm_score(1:15,j) = NaN;
end
clear j
for j = 1:size(score1,2)
    norm_score1(:,j) = (score1(:,j) - mean(score1(15:90,j)));
    norm_score1(105:135,j) = NaN;
    norm_score1(1:15,j) = NaN;
end
clear j
for j = 1:size(score2,2)
    norm_score2(:,j) = (score2(:,j) - mean(score2(15:90,j)));
    norm_score2(105:135,j) = NaN;
    norm_score2(1:15,j) = NaN;
end


GLCELLS_final(1).odor_light(1).OdorA = blah;
GLCELLS_final(1).odor_light(1).OdorA_ttest = corr;
GLCELLS_final(1).odor_light(1).OdorAlatent = latent;

GLCELLS_final(1).odor_light(1).OdorB = blah1;
GLCELLS_final(1).odor_light(1).OdorB_ttest = corr1;
GLCELLS_final(1).odor_light(1).OdorBlatent = latent1;

GLCELLS_final(1).odor_light(1).combined = blah2;
GLCELLS_final(1).odor_light(1).combined_ttest = blah3;
GLCELLS_final(1).odor_light(1).combinedlatent = latent2;

GLCELLS_final(1).odor_light(1).OdorAscore = norm_score(:,1:6);
GLCELLS_final(1).odor_light(1).OdorBscore = norm_score1(:,1:6);
GLCELLS_final(1).odor_light(1).combinedscore = norm_score2(:,1:6);

clear blah i j p p1 h h1 blah1 blah2 norm_score norm_score1 norm_score2 blah3 Odor_Light coeff score latent coeff1 score1 latent1 coeff2 score2 latent2 ind ind1 ind2 corr corr1


%% Only Odor
Odor = GLCELLS_final(1).odor;
blah = [];
blah1 = [];
for i = 1:length(Odor)
    blah = [blah Odor(i).OdorA_Mean];
    blah1 = [blah1 Odor(i).OdorB_Mean];
end
for j = 1:size(blah,2)
    [p(j),h(j)] = ranksum(blah(15:90,j),blah(135:210,j),'alpha',0.01,'tail','both');
    [p1(j),h1(j)] = ranksum(blah1(15:90,j),blah1(135:210,j),'alpha',0.01,'tail','both');
end
ind = find(h == 0); ind1 = find(h1 == 0);
ind2 = union(ind,ind1);
corr = blah;
corr1 = blah1;
corr(:,ind2)=[];
corr1(:,ind2)=[];


[coeff, score, latent] = pca(blah);
[coeff1, score1, latent1] = pca(blah1);
blah2 = [blah blah1];
blah3 = [corr corr1];


[coeff2, score2, latent2] = pca(blah2);

for j = 1:size(score,2)
    norm_score(:,j) = (score(:,j) - mean(score(15:90,j)));
    norm_score(1:15,j) = NaN;
end
clear j
for j = 1:size(score1,2)
    norm_score1(:,j) = (score1(:,j) - mean(score1(15:90,j)));
    norm_score1(1:15,j) = NaN;
end
clear j
for j = 1:size(score2,2)
    norm_score2(:,j) = (score2(:,j) - mean(score2(15:90,j)));
    norm_score2(1:15,j) = NaN;

end

GLCELLS_final(1).odor(1).OdorA = blah;
GLCELLS_final(1).odor(1).OdorA_ttest = corr;
GLCELLS_final(1).odor(1).OdorAlatent = latent;

GLCELLS_final(1).odor(1).OdorB = blah1;
GLCELLS_final(1).odor(1).OdorB_ttest = corr1;
GLCELLS_final(1).odor(1).OdorBlatent = latent1;

GLCELLS_final(1).odor(1).combined = blah2;
GLCELLS_final(1).odor(1).combined_ttest = blah3;
GLCELLS_final(1).odor(1).combinedlatent = latent2;

GLCELLS_final(1).odor(1).OdorAscore = norm_score(:,1:6);
GLCELLS_final(1).odor(1).OdorBscore = norm_score1(:,1:6);
GLCELLS_final(1).odor(1).combinedscore = norm_score2(:,1:6);

clear blah i p p1 h h1 blah1 blah2 blah3 norm_score norm_score1 norm_score2 Odor coeff score latent coeff1 score1 latent1 coeff2 score2 latent2 ind ind1 ind2 corr corr1

save('GLCELLS_final.mat', 'GLCELLS_final');
