clear all; close all; clc
Rootdir = 'E:\MC\August';

cd(Rootdir)
AnimalDir = dir;
for j = 5%:length(AnimalDir)
    if AnimalDir(j).isdir == 1
        cd([Rootdir '\' AnimalDir(j).name])
        load('ALLDAYS.mat');
        
        for k = 1%:length(ALLDAYS)
            if ALLDAYS(k).Code == 2 %for odor evoked
                preevoked_period = 10:70;
                postevoked_period = 130:300;
                MC_act = ALLDAYS(k).MCNaN;
                baseline = MC_act(:,preevoked_period,:);
                activity = MC_act(:,postevoked_period,:);
                
                analysis(k).baseline = baseline;
                analysis(k).activity = activity;
                clear baseline activity
                
                
            elseif ALLDAYS(k).Code == 1 %for spontaneous
                MC_act = ALLDAYS(k).ClustNaN;
                data = medfilt1(MC_act,2);
                for i = 1:size(MC_act,1)
                    x = data(i,:);
                    area = nansum(x,2);
                    maxAmp = max(x);
                    variance = nanvar(x);
                    clear ind
                    thresh = nanmean(x)+2.5*nanstd(x);
                    pks = find(x > thresh);
                    for m = 2:length(pks)
                        diff(m-1) = pks(m)-pks(m-1);
                    end
                     clear m
                    y = find(diff >3);
                    index_final = [pks(1) pks(y+1)];
                    for m=5:length(index_final)-5
                        spike_wave(m-4,:)=x(1,index_final(m)-20:(index_final(m)+20));
                     end
                    clear diff thresh pks
                    spikes(i).spikedata = spike_wave;
                    
                    
                    analysis(k).AUC(i).areaundercurve = [area];
                    analysis(k).MAXAMP(i).maxampl = [maxAmp];
                    analysis(k).VAR(i).variances = [variance];
                    
                    clear area maxAmp ind variance ;
                end
                analysis(k).SPKS = spikes;
            end
        end
        
    end
    %     save('analysis.mat','analysis')
    
end
