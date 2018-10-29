blah1 = [];
% blah2 = [];
for j = 1:length(MCCELLS_final.light)
    blah1 = [blah1 MCCELLS_final.light(j).mean];
%     blah2 = [blah2 MCCELLS_final.odor_light(j).OdorB_Mean];
    

end
MCCELLS_final.light(1).allcells = blah1;
% MCCELLS_final.odor_light(1).OdorB = blah2;
clear blah j



light_resp = GLCELLS_final.light(1).allcells;
OdorA_resp = GLCELLS_final.odor_light(1).OdorA;
OdorB_resp = GLCELLS_final.odor_light(1).OdorB;
OdorAonly_resp = GLCELLS_final.odor(1).OdorA;
OdorBonly_resp = GLCELLS_final.odor(1).OdorB;

light_resp(105:135,:) = NaN;
OdorA_resp(105:135,:) = NaN;
OdorB_resp(105:135,:) = NaN;

%%
[coeff, score_light, latent, explained, tsquared_light] = pca(light_resp);
clear coeff explained latent
[coeff, score_odAlight, latent, explained, tsquared_odAlight] = pca(OdorA_resp);
clear coeff explained latent
[coeff, score_odBlight, latent, explained, tsquared_odBlight] = pca(OdorB_resp);
clear coeff explained latent
[coeff, score_odA, latent, explained, tsquared_odA] = pca(OdorAonly_resp);
clear coeff explained latent
[coeff, score_odB, latent, explained, tsquared_odB] = pca(OdorBonly_resp);
clear coeff explained latent

score(1).exp = score_light(:,1:3);
score(2).exp = score_odAlight(:,1:3);
score(3).exp = score_odBlight(:,1:3);
score(4).exp = score_odA(:,1:3);
score(5).exp = score_odB(:,1:3);

for i = 1:size(score,2)
    blah = score(i).exp;
    for j = 1:size(blah,2)
        norm_blah(:,j) = (blah(:,j) - mean(blah(15:90,j)));
        norm_blah(1:15,j) = NaN;
    end
    score(i).exp_n = norm_blah;
    clear norm_blah
end

figure;
for i = 1:length(score)
subplot(5,1,i); plot(score(i).exp_n,'Linewidth', 2);ylim([-3 3]);
end


%%
auc_odorAonly_after = min(light_resp(136:end,:));
[x1, index] = sort(auc_odorAonly_after, 'ascend');

% plot responses
%light
rlight = light_resp(:,index(1:10));
for i = 1:size(rlight,2)
   rlight_sm(:,i) = smooth(rlight(:,i),10); 
end
rlight_sm(105:135,:) = NaN;
figure;
for i = 1:10
    subplot(10,1,i); plot(rlight_sm(:,i),'Linewidth', 2);ylim([-0.3 0.5]);
end


%odorA-light
alight = OdorA_resp(:,index(1:10));
for i = 1:size(alight,2)
   alight_sm(:,i) = smooth(alight(:,i),10); 
end
alight_sm(105:135,:) = NaN;
figure;
for i = 1:10
    subplot(10,1,i); plot(alight_sm(:,i),'Linewidth', 2);ylim([-0.3 0.5]);
end

%odorB-light
blight = OdorB_resp(:,index(1:10));
for i = 1:size(blight,2)
   blight_sm(:,i) = smooth(blight(:,i),10); 
end
blight_sm(105:135,:) = NaN;
figure;
for i = 1:10
    subplot(10,1,i); plot(blight_sm(:,i),'Linewidth', 2);ylim([-0.3 0.5]);
end

%odorA
figure;
aonly = OdorAonly_resp(:,index(1:10));
for i = 1:size(aonly,2)
   aonly_sm(:,i) = smooth(aonly(:,i),10); 
end
for i = 1:10
    subplot(10,1,i); plot(aonly_sm(:,i),'Linewidth', 2);ylim([-0.2 0.5]);
end

%odorB
figure;
bonly = OdorBonly_resp(:,index(1:10));
for i = 1:size(bonly,2)
   bonly_sm(:,i) = smooth(bonly(:,i),10); 
end
for i = 1:10
    subplot(10,1,i); plot(bonly_sm(:,i),'Linewidth', 2);ylim([-0.2 0.5]);
end


%%

auc_l_a = (2*(auc_light_after-min(auc_light_after))/(max(auc_light_after)-min(auc_light_after)))-1;
auc_l_b = (2*(auc_light_before-min(auc_light_before))/(max(auc_light_before)-min(auc_light_before)))-1;

auc_l_a1 = (2*(auc_odorA_after-min(auc_odorA_after))/(max(auc_odorA_after)-min(auc_odorA_after)))-1;
auc_l_a2 = (2*(auc_odorAonly_after-min(auc_odorAonly_after))/(max(auc_odorAonly_after)-min(auc_odorAonly_after)))-1;

