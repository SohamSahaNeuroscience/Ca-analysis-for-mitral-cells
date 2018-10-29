close all
clear all
clc

%for GLs
load('MCCELLS_final.mat');
exp = {'light' 'odor_light' 'odor'};
exp = eval('exp');

for i = 1:length(exp)
    if i == 1
        exp1 = {'mean'};
        prin = {'allcells_pca'};
        c = {'corr_light'};
        d = {'sum_light'};
    elseif i == 2 || i == 3
        exp1 = {'OdorA_Mean' 'OdorB_Mean'};
        prin = {'OdorA_pca' 'OdorB_pca'};
        c = {'corr_odorA' 'corr_odorB'};
        d = {'sum_odorA' 'sum_odorB'};
        
    end
    exp1 = eval('exp1');
    prin = eval('prin');
    
    for m = 1:length(exp1)
        for j = 1:length(MCCELLS_final.(exp{i}))
            
            data = MCCELLS_final.(exp{i})(j).(exp1{m});
            [coeff, score, latent, explained, tsquared] = pca(data);
            MCCELLS_final.(exp{i})(j).(prin{m}) = score(:,1:5);
            clear coeff score latent explained tsquared y z
            
        end
        clear j
        
        for k = 1:length(MCCELLS_final.(exp{i}))
            ref = MCCELLS_final.(exp{i})(k).(prin{m});
            %remove NaNs
            blah = sum(ref,2);
            clah = find(isnan(blah)==1);
            ref(clah,:)= [];
            
            comp = MCCELLS_final.(exp{i})(k).(exp1{m});
            
            for w = 1:size(comp,2)
                [rs(w).pval rs(w).h] = ranksum(comp(15:90,w),comp(165:end,w));
            end
            
            pvalue = [];
            for w1 = 1:length(rs)
                pvalue = [pvalue, rs(w1).h];
            end
            clear rs
            
            comp(clah,:) = [];
            clear blah clah
            
            XC = corr(comp,ref);
            for r = 1:size(XC,1)
                for s = 1:size(XC,2)
                    if XC(r,s) < 0.67
                        XC(r,s) = 0;
                    end
                end
            end
            XC = logical(XC);
            q = XC.*pvalue';
            
            MCCELLS_final.(exp{i})(k).(c{m}) = q;
            MCCELLS_final.(exp{i})(k).(d{m}) = sum(q,1);
            clear XC pvalue q ref comp r s
        end
    end
end

save('MCCELLS_final.mat', 'MCCELLS_final');