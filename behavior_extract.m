close all; clear all; clc

BehaviorFolderName = 'Behavior';
AnimalIDdir = 'E:\MC\odor+light';

o1 = 'VALDE*';
o2 = 'CIN*';
o3 = 'HEX*';
o4 = 'ETHY*';
o5 = '60EB40AA';
o6 = '40EB60AA';
o7 = '55EB 45AA';
o8 = '45EB 55AA';
o9 = 'Min-L*';
o10 = 'Butyric*';
o11 = 'VALVE 1';
o12 = 'VALVE 2';
o13 = '6EB 4AA';
o14 = '4EB 6AA';

b1 = 'MISS';
b2 = 'CR';
b3 = 'HIT';
b4 = 'FA';

Rew1 = '+';
Rew2 = '-';
Directory = AnimalIDdir;
cd(Directory);
dates = dir;
for g = 3:length(dates)
    if dates(g).isdir == 1
        cd([Directory '\' dates(g).name]);
        load('ALLBLOCKS.mat');
        %ALLBLOCKS = rmfield(ALLBLOCKS,'OdorsBeh');
        cd([Directory '\' dates(g).name '\' BehaviorFolderName]);
        files = dir('*.csv');
        countero = 1;
        counterb = 1;
        counterc = 1;
        for f = 1:length(files)
            delimiter = ',';
            startRow = 48;
            formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';
            fileID = fopen([Directory '\' dates(g).name '\' BehaviorFolderName '\' files(f).name],'r');
            textscan(fileID, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);
            fclose(fileID);
            raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
            for col=1:length(dataArray)-1
                raw(1:length(dataArray{col}),col) = dataArray{col};
            end
            numericData = NaN(size(dataArray{1},1),size(dataArray,2));
            rawData = dataArray{2};
            for row=1:size(rawData, 1);
                regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                try
                    result = regexp(rawData{row}, regexstr, 'names');
                    numbers = result.numbers;
                    invalidThousandsSeparator = false;
                    if any(numbers==',');
                        thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                        if isempty(regexp(thousandsRegExp, ',', 'once'));
                            numbers = NaN;
                            invalidThousandsSeparator = true;
                        end
                    end
                    if ~invalidThousandsSeparator;
                        numbers = textscan(strrep(numbers, ',', ''), '%f');
                        numericData(row, 2) = numbers{1};
                        raw{row, 2} = numbers{1};
                    end
                catch me
                end
            end
            rawNumericColumns = raw(:, 2);
            rawCellColumns = raw(:, [1,3,4,5,6,7]);
            R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
            rawNumericColumns(R) = {NaN};
            OdorsBeh = raw;
            clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns R;
            odors = OdorsBeh(:,3);
            behaviors = OdorsBeh(:,7);
            Rewards = OdorsBeh(:,5);
            o1Ind = regexp(odors,o1);
            o2Ind = regexp(odors,o2);
            o3Ind = regexp(odors,o3);
            o4Ind = regexp(odors,o4);
            o5Ind = regexp(odors,o5);
            o6Ind = regexp(odors,o6);
            o7Ind = regexp(odors,o7);
            o8Ind = regexp(odors,o8);
            o9Ind = regexp(odors,o9);
            o10Ind = regexp(odors,o10);
            o11Ind = regexp(odors,o11);
            o12Ind = regexp(odors,o12);
            o13Ind = regexp(odors,o13);
            o14Ind = regexp(odors,o14);
            b1Ind = regexp(behaviors,b1);
            b2Ind = regexp(behaviors,b2);
            b3Ind = regexp(behaviors,b3);
            b4Ind = regexp(behaviors,b4);
            Rew1Ind = regexp(Rewards,Rew1);
            Rew2Ind = regexp(Rewards,Rew2);
            for h = 1:length(o1Ind)
                if o1Ind{h} == 1
                    FinalOdors{countero,1} = 'VALDEHYDE';
                    countero = countero + 1;
                elseif o2Ind{h} == 1
                    FinalOdors{countero,1} = 'CINEOLE';
                    countero = countero + 1;
                elseif o3Ind{h} == 1
                    FinalOdors{countero,1} = 'HEXANONE';
                    countero = countero + 1;
                elseif o4Ind{h} == 1
                    FinalOdors{countero,1} = 'ETHYL TIGLATE';
                    countero = countero + 1;
                elseif o5Ind{h} == 1
                    FinalOdors{countero,1} = '60EB 40AA';
                    countero = countero + 1;
                elseif o6Ind{h} == 1
                    FinalOdors{countero,1} = '40EB 60AA';
                    countero = countero + 1;
                elseif o7Ind{h} == 1
                    FinalOdors{countero,1} = '55EB 45AA';
                    countero = countero + 1;
                elseif o8Ind{h} == 1
                    FinalOdors{countero,1} = '45EB 55AA';
                    countero = countero + 1;
                elseif o9Ind{h} == 1
                    FinalOdors{countero,1} = 'Min-Limonen';
                    countero = countero + 1;
                elseif o10Ind{h} == 1
                    FinalOdors{countero,1} = 'BUTYRIC ACID';
                    countero = countero + 1;
                elseif o11Ind{h} == 1
                    FinalOdors{countero,1} = 'VALVE 1';
                    countero = countero + 1;
                elseif o12Ind{h} == 1
                    FinalOdors{countero,1} = 'VALVE 2';
                    countero = countero + 1;
                elseif o13Ind{h} == 1
                    FinalOdors{countero,1} = '60EB 40AA';
                    countero = countero + 1;
                elseif o14Ind{h} == 1
                    FinalOdors{countero,1} = '40EB 60AA';
                    countero = countero + 1;
                end
            end
            for j = 1:length(b1Ind)
                if b1Ind{j} == 1
                    FinalBeh{counterb,1} = 'MISS';
                    counterb = counterb + 1;
                elseif b2Ind{j} == 1
                    FinalBeh{counterb,1} = 'CR';
                    counterb = counterb + 1;
                elseif b3Ind{j} == 1
                    FinalBeh{counterb,1} = 'HIT';
                    counterb = counterb + 1;
                elseif b4Ind{j} == 1
                    FinalBeh{counterb,1} = 'FA';
                    counterb = counterb + 1;
                end
            end
            for k = 1:length(Rew1Ind)
                if Rew1Ind{k} == 1
                    FinalRew{counterc,1} = '+';
                    counterc = counterc + 1;
                elseif Rew2Ind{k} == 1
                    FinalRew{counterc,1} = '-';
                    counterc = counterc + 1;
                end
            end
            Merged = [FinalOdors FinalBeh FinalRew];
        end
        for a = 1:length(ALLBLOCKS);
            b = ((a-1)*20) + 1;
            ALLBLOCKS(a).OdorsBeh = Merged(b:(a*20),:);
        end
        cd([Directory '\' dates(g).name]);
        save('ALLBLOCKS.mat','ALLBLOCKS');
        %clear Merged FinalOdors FinalBeh;
    end
end

