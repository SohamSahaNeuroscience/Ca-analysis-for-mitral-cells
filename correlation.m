
for i = 1:length(TCCELLS_final.light)
    
    TCCELLS_final.light(i).sum_after = nansum(TCCELLS_final.light(i).mean(135:180,:),1);
    TCCELLS_final.light(i).sum_before = nansum(TCCELLS_final.light(i).mean(15:100,:),1);
    
    TCCELLS_final.odor(i).sumA = nansum(TCCELLS_final.odor(i).OdorA_Mean(105:180,:),1);
    TCCELLS_final.odor(i).sumB = nansum(TCCELLS_final.odor(i).OdorB_Mean(105:180,:),1);
    
    TCCELLS_final.odor_light(i).sumA = nansum(TCCELLS_final.odor_light(i).OdorA_Mean(135:180,:),1);
    TCCELLS_final.odor_light(i).sumB = nansum(TCCELLS_final.odor_light(i).OdorB_Mean(135:180,:),1);
    
end


blah = [];
for i = 1:length(TCCELLS_final.light)
    blah = [blah TCCELLS_final.light(i).sum_before];
end


mini = min(min(x));
maxi = max(max(x));


x1 = (x-mini)/(maxi-mini);

imagesc(x1);colormap(RWBmap)
