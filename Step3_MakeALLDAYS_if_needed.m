Animaldir = 'E:\MC\odor+light';
cd(Animaldir)
dates = dir;
odorpres = 1;

counter = 1;
ALLDAYS = [];
for k = 3:length(dates)
    if dates(k).isdir == 1
        cd([Animaldir '\' dates(k).name]);
        load('Combined.mat')
        for i = 1:length(Combined)
            ALLDAYS = [ALLDAYS; Combined(i)];
            ALLDAYS(counter).ExpID = dates(k).name;
            counter = 1 + counter;
        end
    end

end
cd(Animaldir)
save('ALLDAYS.mat','ALLDAYS','-v7.3');
