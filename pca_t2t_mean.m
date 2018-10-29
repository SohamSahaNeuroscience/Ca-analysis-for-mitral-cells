close all
clear all
clc


rootdir = 'I:\Soham Experiments\2017 Mitral cell recording photostim\MC\Animal 1 side 1';
cd(rootdir)

List = dir;
for r = 3:length(List)
    if List(r).isdir == 1
        cd([rootdir '\' List(r).name]);
        load('ALLBLOCKS.mat');
        start1 = 11;
        end1 = 100;
        start2 = 135;
        end2 = 224;
        for i = 1: length(ALLBLOCKS)
            if ALLBLOCKS(i).Olf_data == 0
                response = ALLBLOCKS(i).dffNaN_light;
                ALLBLOCKS(i).Light_Mean = squeeze(nanmean(ALLBLOCKS(i).dffNaN_light,1));
                
                %trial by trial
                before = response(:,start1:end1,:);
                after = response(:,start2:end2,:);
                
                for x1 = 1:size(before,3)
                    for y1 = 1:size(before,1)
                        a = before(y1,:,x1);
                        b = after(y1,:,x1);
                        blah = nansum(a);
                        blah1 = nansum(b);
                        if blah == 0 || blah1 == 0
                            a = zeros(1,90,1);
                            b = zeros(1,90,1);
                        end
                        [pvalue(x1).ht(y1) pvalue(x1).p(y1)] = ranksum(a,b);
                    end
                    clear a b blah blah1
                end
                
                emp = [];
                for d = 1:length(pvalue)
                    q = pvalue(d).ht;
                    emp = [emp; q];
                end
                clear d x1 y1 pvalue
                
                for r = 1:size(emp,1)
                    for s = 1:size(emp,2)
                        if isnan(emp(r,s)) == 1
                            emp(r,s) = 0;
                        end
                    end
                end
                
                t2t = (sum(emp,2)/size(before,1))*100;
                ALLBLOCKS(i).Light_trialtotrial = t2t;
                clear t2t q emp r s
                
                %pca
                forpca = ALLBLOCKS(i).Light_Mean(136:end,:);
                [coeff,score,latent,tsquared,explained,mu] = pca(forpca);
                thresh = cumsum(explained);
                k = round((sum(latent).^2/sum(latent.*latent)));
                
                ALLBLOCKS(i).pca_light = score(:,1:k);
                ALLBLOCKS(i).explained_var = explained;
                %exc-inh
                ratio = after(:,1:40,:)./before(:,1:40,:);
                for g = 1:size(ratio,1)
                    for h = 1:size(ratio,2)
                        for m = 1:size(ratio,3)
                            if ratio(g,h,m) > 1
                                ratio(g,h,m) = 1;
                            elseif ratio(g,h,m) < 0
                                ratio(g,h,m) = -1;
                            elseif ratio(g,h,m) < 1 && ratio(g,h,m)>0
                                ratio(g,h,m) = 0;
                            end
                        end
                    end
                end
                summ = squeeze(nansum(ratio,2));
                ALLBLOCKS(i).exc_inh = summ;
                
                clear coeff score latent tsquared mu thresh k m ratio f summ
                
            elseif ALLBLOCKS(i).Olf_data == 1
                ALLBLOCKS(i).OdorA_Mean = squeeze(nanmean(ALLBLOCKS(i).OdorA,1));
                ALLBLOCKS(i).OdorB_Mean = squeeze(nanmean(ALLBLOCKS(i).OdorB,1));
                
                OdorID = ['OdorA'; 'OdorB'];
                OdorID = eval('OdorID');
                Result = ['OdorA_trialtotrial'; 'OdorB_trialtotrial'];
                Result = eval('Result');
                ResultA = ['OdorA_exc_inh'; 'OdorB_exc_inh'];
                ResultA = eval('ResultA');
                for k = 1:size(OdorID,1)
                    response = ALLBLOCKS(i).(OdorID(k,:));
                    
                    %trial by trial
                    before = response(:,start1:end1,:);
                    after = response(:,start2:end2,:);
                    
                    for x1 = 1:size(before,3)
                        for y1 = 1:size(before,1)
                            a = before(y1,:,x1);
                            b = after(y1,:,x1);
                            blah = nansum(a);
                            blah1 = nansum(b);
                            if blah == 0 || blah1 == 0
                                a = zeros(1,90,1);
                                b = zeros(1,90,1);
                            end
                            [pvalue(x1).ht(y1) pvalue(x1).p(y1)] = ranksum(a,b);
                        end
                        clear a b blah blah1
                    end
                    
                    clear blah blah1
                    emp = [];
                    for d = 1:length(pvalue)
                        q = pvalue(d).ht;
                        emp = [emp; q];
                    end
                    clear d x1 y1 pvalue
                    
                    for r = 1:size(emp,1)
                        for s = 1:size(emp,2)
                            if isnan(emp(r,s)) == 1
                                emp(r,s) = 0;
                            end
                        end
                    end
                    
                    t2t = sum(emp,2)/size(before,1);
                    ALLBLOCKS(i).(Result(k,:)) = t2t;
                    clear t2t q emp r s
                    
                    %exc-inh
                    ratio = after(:,1:40,:)./before(:,1:40,:);
                    for g = 1:size(ratio,1)
                        for h = 1:size(ratio,2)
                            for m = 1:size(ratio,3)
                                if ratio(g,h,m) > 1
                                    ratio(g,h,m) = 1;
                                elseif ratio(g,h,m) < 0
                                    ratio(g,h,m) = -1;
                                elseif ratio(g,h,m) < 1 && ratio(g,h,m)>0
                                    ratio(g,h,m) = 0;
                                end
                            end
                        end
                    end
                    summ = squeeze(nansum(ratio,2));
                    ALLBLOCKS(i).(ResultA(k,:)) = summ;
                    clear ratio f summ 
                end
                
                %pca
                forpcaA = ALLBLOCKS(i).OdorA_Mean(136:end,:);
                [coeffA,scoreA,latentA,tsquaredA,explainedA,muA] = pca(forpcaA);
                threshA = cumsum(explainedA);
                kA = round((sum(latentA).^2/sum(latentA.*latentA)));
                
                ALLBLOCKS(i).pca_odorA = scoreA(:,1:kA);
                ALLBLOCKS(i).exp_varA = explainedA;
                
                forpcaB = ALLBLOCKS(i).OdorB_Mean(136:end,:);
                [coeffB,scoreB,latentB,tsquaredB,explainedB,muB] = pca(forpcaB);
                threshB = cumsum(explainedB);
                kB = round((sum(latentB).^2/sum(latentB.*latentB)));
                
                ALLBLOCKS(i).pca_odorB = scoreB(:,1:kB);
                ALLBLOCKS(i).exp_varB = explainedB;
                
                
            end
            
        end
        save('ALLBLOCKS.mat','ALLBLOCKS','-v7.3');
    end
end
