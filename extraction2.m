close all
clear all
clc

load('TCCELLS.mat');

exp = {'light' 'odor_light' 'odor'};
exp = eval('exp');

exp1 = {'Light_Mean' 'OdorA_Mean' 'OdorB_Mean'};
exp1 = eval('exp1');
d = {'OdorA' 'OdorB'};
d = eval('d');

for f = 1:length(exp)
    if f == 1
        
        for i = 1:length(TCCELLS(1).(exp{f}))
            a(i) = size(TCCELLS(1).(exp{f})(i).(exp1{1}),2);
        end
        [b, index] = unique(a);
        
        for j = 1:length(b)
            blah = [];
            x = find(a == b(j));
            for k = 1:length(x)
                blah(:,:,k) = TCCELLS(1).(exp{f})(x(k)).(exp1{1});
            end
            TCCELLS_final(1).(exp{f})(j).mean = nanmean(blah,3);
            clear blah x
        end
        clear j k i
        
        blah = [];
        for j = 1:length(TCCELLS_final(1).(exp{f}))
            blah = [blah TCCELLS_final(1).(exp{f})(j).mean];
            TCCELLS_final.(exp{f})(1).allcells = blah;
        end
        clear blah j
        
    end
    
    if f > 1
        g = [2,3];
        
        for q = 1:length(g)
            for i = 1:length(TCCELLS(1).(exp{f}))
                a(i) = size(TCCELLS(1).(exp{f})(i).(exp1{g(q)}),2);
            end
            [b, index] = unique(a);
            
            for j = 1:length(b)
                blah = [];
                x = find(a == b(j));
                for k = 1:length(x)
                    blah(:,:,k) = TCCELLS(1).(exp{f})(x(k)).(exp1{g(q)});
                end
                TCCELLS_final(1).(exp{f})(j).(exp1{g(q)}) = nanmean(blah,3);
                clear blah x
            end
            clear j k i
            
            blah = [];
            for j = 1:length(TCCELLS_final.(exp{f}))
                blah = [blah TCCELLS_final.(exp{f})(j).(exp1{g(q)})];
                TCCELLS_final.(exp{f})(1).(d{q}) = blah;
            end
            clear blah j
        end
    end
end

