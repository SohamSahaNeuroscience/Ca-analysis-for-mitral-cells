%2017-11-08 by Soham Saha
%1) Segregate between OdorA and OdorB.
%2) Saves ALLBLOCKS.

%--AnimalID

clear all; close all; clc
%%%%%%%%%%%%%%%%%%%%INPUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Animaldir = 'I:\Soham Experiments\2017 Mitral cell recording photostim\GL cells\Animal 3';
cd(Animaldir);

TrialSize = 300;% #frames per trial
BlockSize = 20;% SET TO 20 FOR 10 ODORA AND 10 ODOR B
O1 = 'VALVE 1';% Put exact name as appears in ALLBLOCKS.OdorsBeh
O2 = 'VALVE 2';
O3 = 'Ethyl buyterate';
O4 = 'Amyl acetate';
O5 = '60EB 40AA';
O6 = '40EB 60AA';
O7 = '55EB 45AA';
O8 = '45EB 55AA';
O9 = 'Min-Limonen';
O10 = 'ISOAMYL ACETATE';
O11 = 'ETHYL BUTYRATE';
O12 = 'BUTYRIC ACID';
%%%%%%%%%%%%%%%%%%%%INPUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('ALLBLOCKS.mat');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SEGREGATE BETWEEN ODORA AND ODORB%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(ALLBLOCKS)
    if ALLBLOCKS(k).Olf_data == 1
    O1reg = strcmp(O1,ALLBLOCKS(k).OdorsBeh(:,1));
    O2reg = strcmp(O2,ALLBLOCKS(k).OdorsBeh(:,1));
    O3reg = strcmp(O3,ALLBLOCKS(k).OdorsBeh(:,1));
    O4reg = strcmp(O4,ALLBLOCKS(k).OdorsBeh(:,1));
    O5reg = strcmp(O5,ALLBLOCKS(k).OdorsBeh(:,1));
    O6reg = strcmp(O6,ALLBLOCKS(k).OdorsBeh(:,1));
    O7reg = strcmp(O7,ALLBLOCKS(k).OdorsBeh(:,1));
    O8reg = strcmp(O8,ALLBLOCKS(k).OdorsBeh(:,1));
    O9reg = strcmp(O9,ALLBLOCKS(k).OdorsBeh(:,1));
    O10reg = strcmp(O10,ALLBLOCKS(k).OdorsBeh(:,1));
    O11reg = strcmp(O11,ALLBLOCKS(k).OdorsBeh(:,1));
    O12reg = strcmp(O12,ALLBLOCKS(k).OdorsBeh(:,1));
    ALLOdors = [O1reg O2reg O3reg O4reg O5reg O6reg O7reg O8reg O9reg O10reg O11reg O12reg];
    Odorsets = iszero(sum(ALLOdors,1));
    InxOdors = find(Odorsets == 0);
    OdorA = ALLOdors(:,InxOdors(1));
    OdorB = ALLOdors(:,InxOdors(2));
    
    for roi = 1:size(ALLBLOCKS(k).dffNaN,1)
        counterA = 1;
        counterB = 1;
        for h = 1:BlockSize
            first = ((h-1)*TrialSize)+1;
            last = h*TrialSize;
            if OdorA(h) == 1
                OdorAdat(counterA,:) = ALLBLOCKS(k).dffNaN(roi,first:last);
                counterA = counterA + 1;
            elseif OdorB(h) == 1
                OdorBdat(counterB,:) = ALLBLOCKS(k).dffNaN(roi,first:last);
                counterB = counterB + 1;
            end
        end
        OdorAROI(:,:,roi) = OdorAdat;
        OdorBROI(:,:,roi) = OdorBdat;
    end
    ALLBLOCKS(k).OdorA = OdorAROI;
    ALLBLOCKS(k).OdorB = OdorBROI;
    clear OdorAROI OdorBROI
    end
end

cd(Animaldir);
save('ALLBLOCKS.mat', 'ALLBLOCKS', '-v7.3');
       