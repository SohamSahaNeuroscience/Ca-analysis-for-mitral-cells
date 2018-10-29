close all
clear all
clc

rootdir = 'I:\Soham Experiments\2017 Mitral cell recording photostim\MC\Animal 1 side 1\MC';
load('ALLBLOCKS.mat');
cd(rootdir)

List = dir('block*');


for i = 3:length(List)
   im = loadtif(List(i).name, rootdir);
   zproj = mean(im,3);
   for j = 1:size(im,3)
      corrs(j,:) = corr2(im(:,:,j), zproj);
   end
   thresh = find(corrs<mean(corrs)-0.5*std(corrs));
   corrs(thresh,:) = 0;
   corrs = logical(corrs);
   x = find(ALLBLOCKS(i).include == 1);
   y = find(corrs == 1);
   z = x(y);
   allcorrs = zeros(6000,1);
   allcorrs(z) = 1;
   allcorrs = logical(allcorrs);
   ALLBLOCKS(i).include = allcorrs;
   
   clear x y z allcorrs im zproj corrs thresh
end
