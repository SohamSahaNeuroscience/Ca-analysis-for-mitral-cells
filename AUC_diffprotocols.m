clear all
dir = 'Z:\Soham Experiments\2017 Mitral cell recording photostim\MC\Animal 3\MC2';
cd(dir)
load('ALLBLOCKS.mat');
%indiv blocks
for i = 1:length(ALLBLOCKS)
    AUC(i).light = nansum(ALLBLOCKS(i).Light_Mean, 1);
    AUC(i).OdorA = nansum(ALLBLOCKS(i).OdorA_Mean, 1);
    AUC(i).OdorB = nansum(ALLBLOCKS(i).OdorB_Mean, 1);
end


save('AUC.mat', 'AUC');
    
    