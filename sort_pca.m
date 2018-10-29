close all; clear all; clc
rootdir = 'I:\Soham Experiments\2017 Mitral cell recording photostim\MC set 2';
cd(rootdir)

List = dir;

B = ['pca_light'; 'pca_odorA'; 'pca_odorB'];
B = eval('B');


for i = 3:7%length(List)
    if List(i).isdir == 1
        cd([rootdir '\' List(i).name]);
        subdirlist = dir;
        for j = 3:length(subdirlist)
            if subdirlist(j).isdir == 1
            cd([rootdir '\' List(i).name '\' subdirlist(j).name]);
            
            load('ALLBLOCKS.mat');
            blah = [];
            blah1 = [];
            blah2 = [];
            for k =1:length(ALLBLOCKS)
                if ALLBLOCKS(k).Olf_data == 0
                    blah = [blah ALLBLOCKS(k).pca_light];
                    PCA_output(i-2).(subdirlist(j).name).(B(1,:)) = blah;
                
                elseif ALLBLOCKS(k).Olf_data == 1
                    blah1 = [blah1 ALLBLOCKS(k).pca_odorA];
                    blah2 = [blah2 ALLBLOCKS(k).pca_odorB];
                    
                    PCA_output(i-2).(subdirlist(j).name).(B(2,:)) = blah1;
                    PCA_output(i-2).(subdirlist(j).name).(B(3,:)) = blah2;
                end
            end
            clear blah1 blah2 blah
            end
        end
    end
end
cd(rootdir)
save('PCA_output.mat', 'PCA_output')
