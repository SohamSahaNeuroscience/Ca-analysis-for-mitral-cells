blah = [];
for i = 1:length(MCCELLS_final.light)
blah = [blah; MCCELLS_final.light(i).sum_light];
end


x = TCCELLS_final.odor_light.OdorB;
[coeff, score, latent, explained, tsquared] = pca(x);
 score(90:135,:)=NaN;
plot(score(15:end,1:3),'DisplayName','score(:,1:3)','Linewidth', 2)
ylim([min(score(15:end,1:2)) max(score(15:end,1:2))])



x = MCCELLS_final.light.allcells;
auc_before = trapz(x(10:90,:));
auc_after = trapz(x(135:end,:));

auc = (auc_after-auc_before);



%% plot responses
%light

x = TCCELLS_final.odor_light(1).OdorA;
figure;imagesc(x(15:end,:))';

figure;
for i = 1:10
    subplot(10,1,i); plot(TCCELLS_final.light(1).allcells(:,index(i)));ylim([-0.5 1])
end

%odorA-light
figure;
for i = 1:10
    subplot(10,1,i); plot(TCCELLS_final.odor_light(1).OdorA(:,index(i)));ylim([-0.4 1])
end

%odorB-light
figure;
for i = 1:10
    subplot(10,1,i); plot(TCCELLS_final.odor_light(1).OdorB(:,index(i)));ylim([-0.4 1])
end

%odorA
figure;
for i = 1:10
    subplot(10,1,i); plot(TCCELLS_final.odor(1).OdorA(:,index(i)));ylim([-0.4 1])
end

%odorB
figure;
for i = 1:10
    subplot(10,1,i); plot(TCCELLS_final.odor(1).OdorB(:,index(i)));ylim([-0.4 1])
end