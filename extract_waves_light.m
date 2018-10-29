close all
clear all
clc

rootdir = 'I:\Soham Experiments\2017 Mitral cell recording photostim\GL cells\Animal 3';
cd(rootdir)

load('ALLBLOCKS.mat');

for j = 1:length(ALLBLOCKS)
     if ALLBLOCKS(j).Olf_data == 0
        blocksize = 20;
        length = 300;
        
        for rois = 1:size(ALLBLOCKS(j).dffNaN,1)
            for k = 1:blocksize
                ALLBLOCKS(j).dffNaN_light(k,:,rois) = ALLBLOCKS(j).dffNaN(rois,((k-1)*length)+1:(k*length));
            end
        end
    end  
 end

cd(rootdir)
save('ALLBLOCKS.mat','ALLBLOCKS');