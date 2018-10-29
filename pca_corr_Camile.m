close all
clear all
clc

rootdir = 'I:\Soham Experiments\2017 Mitral cell recording photostim\GL cells';
cd(rootdir)

List = dir;
for z = 3:length(List)
    if List(z).isdir == 1
        subdir = [rootdir '\' List(z).name];
        cd(subdir)
        Dirs = dir;
        for y = 3:length(Dirs)
            if Dirs(y).isdir == 1
                subsubdir = [subdir '\' Dirs(y).name];
                cd(subsubdir)
                load('ALLBLOCKS.mat')
                
                
                for i = 1:length(ALLBLOCKS)
                    if ALLBLOCKS(i).Olf_data == 0
                        Data = ALLBLOCKS(i).Light_Mean(136:end,:);
                        Ref_data = ALLBLOCKS(i).pca_light;
                        
                        vals = corr(Data, Ref_data);
                        for m = 1:size(vals,1)
                            for n = 1:size(vals, 2)
                                if vals(m,n)<0.6
                                    vals(m,n) = 0;
                                end
                            end
                        end
                        vals_l = logical(vals);
                        blah = sum(vals_l,1);
                        ALLBLOCKS(i).corrvals = vals;
                        ALLBLOCKS(i).sum_corrvals = blah;
                        clear vals Data Ref blah
                        
                    elseif ALLBLOCKS(i).Olf_data == 1
                        Raw = ['OdorA_Mean'; 'OdorB_Mean'];
                        Raw = eval('Raw');
                        pca = ['pca_odorA'; 'pca_odorB'];
                        pca = eval('pca');
                        output = ['corrvals_odorA'; 'corrvals_odorB'];
                        output = eval('output');
                        output1 = ['sum_corrvals_odorA'; 'sum_corrvals_odorB'];
                        output1 = eval('output1');
                        for j = 1:size(Raw,1)
                            Data = ALLBLOCKS(i).(Raw(j,:))(136:end,:);
                            Ref = ALLBLOCKS(i).(pca(j,:));
                            vals = corr(Data, Ref);
                            for m = 1:size(vals,1)
                                for n = 1:size(vals, 2)
                                    if vals(m,n)<0.6
                                        vals(m,n) = 0;
                                    end
                                end
                            end
                            vals_l = logical(vals);
                            blah = sum(vals_l,1);
                            ALLBLOCKS(i).(output(j,:))= vals;
                            ALLBLOCKS(i).(output1(j,:))= blah;
                            clear vals Data Ref blah
                        end 
                    end
                end
                save('ALLBLOCKS.mat', 'ALLBLOCKS')
                
            end
            clear ALLBLOCKS
        end
    end
end
