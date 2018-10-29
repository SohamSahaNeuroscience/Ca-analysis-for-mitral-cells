rootdir = 'C:\Users\camera\Desktop\NAND2017\doric sample data\registered\Pcp2Crem\20170628_Pcp2Cremk053017_27';
cd(rootdir)

List = dir('Cn_*.mat');

for i = 1:length(List)
   load(List(i).name);
   Contour(:,:,i) = Cn;
   clear Cn
end

Cn_total = sum(Contour,3);
save('Cn_total.mat','Cn_total')