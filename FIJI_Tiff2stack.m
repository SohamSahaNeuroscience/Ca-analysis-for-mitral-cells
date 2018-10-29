%Code for automatic x-y registration of tiffs before running z-corr
%1) Load TSeries from individual 3d Tiffs in a directory (after TIFFtoStack).
%2) Run image stabilizer on Ch1.
%3) Apply transformation to Ch3.
%%
%Structure of files
%Root directory
%--Directories segregated by date (ExperimentalDayDirs)
%----Directories segregated by TIFF series folders (TiffSerDirs)
close all
clear all
clc

ComputerID = 3;%1 for left Analysis computer
               %2 for Lwoff 2p
               %3 for right analysis computer

rootdir = 'I:\Raw 2-photon data\___LWoff\__Soham\MC';
OutputDir = 'I:\Raw 2-photon data\___LWoff\__Soham\MC_output';
StartFolder = 4;
BlockSize =300;
AfterCRASH = 0;
%Image stabilizer registration
if ComputerID == 2;
    javaaddpath 'C:\Program Files\MATLAB\R2015a\java\jar\mij.jar';
    javaaddpath 'C:\Program Files\MATLAB\R2015a\java\jar\ij.jar';
    MIJ.start('C:\ImageJ');
elseif ComputerID == 1;
    javaaddpath 'C:\Program Files\MATLAB\R2014a\java\jar\mij.jar';
    javaaddpath 'C:\Program Files\MATLAB\R2014a\java\jar\ij.jar';
    MIJ.start('F:\ImageJ');
elseif ComputerID == 3;
    javaaddpath 'C:\Program Files\MATLAB\R2015a\java\jar\mij.jar';
    javaaddpath 'C:\Program Files\MATLAB\R2015a\java\jar\ij.jar';
    MIJ.start('E:\ImageJ');
end
cd(rootdir);
ExperimentDayDirs = dir;
cd(OutputDir);
Outputfolders = dir;
%Loop to find what files where converted after a crash

if AfterCRASH == 1
    cd([OutputDir '\' Outputfolders(3+(StartFolder - 1)).name]);
    Filesdone = dir('TSeries*');
    if strfind(Filesdone(end).name(end-10), '1');
        delete(Filesdone(end).name);
    else
        delete(Filesdone(end).name, Filesdone(end-1).name);
    end
    Ch1Files = dir('*Ch1*');
    LastFileName = Ch1Files(end).name(1:end-14);
    cd([rootdir '\' ExperimentDayDirs(3+(StartFolder - 1)).name]);
    TiffSerDirs = dir('TSeries*');
    for h = 1:length(TiffSerDirs)
        Folder2startList(h,:) = strcmp(LastFileName,TiffSerDirs(h).name);
    end
    Folder2Start = find(Folder2startList == 1) + 1;
    DaysDirs = [rootdir '\' ExperimentDayDirs(3+(StartFolder - 1)).name];
    DirForFIJI = strrep(DaysDirs, '\', '\\');
    for a = Folder2Start:length(TiffSerDirs);
        cd([rootdir '\' ExperimentDayDirs(3+(StartFolder - 1)).name '\' TiffSerDirs(a).name]);
        NumFiles = dir('*Ch1*');
        cd([OutputDir '\' Outputfolders(3+(StartFolder - 1)).name]);
        if length(NumFiles) == BlockSize;
            %Load Channel 1
            FileNameCh1 = [TiffSerDirs(a).name '_Ch1_stack.tif'];
            FileNameCh2 = [TiffSerDirs(a).name '_Ch2_stack.tif'];
            MIJ.run('Image Sequence...', ['open=[' DirForFIJI '\\' TiffSerDirs(a).name '\\' TiffSerDirs(a).name '_Cycle00001_Ch1_000001.ome.tif] file=Ch1 sort']);
            MIJ.run('Image Stabilizer', ['transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients']);
            ImgReg = MIJ.getCurrentImage;
            ImgReg = uint16(ImgReg);
            saveastiff(ImgReg, FileNameCh1);
            MIJ.selectWindow(TiffSerDirs(a).name);
            MIJ.run('Close');
            clear ImgReg
            %Load Channel 2
            MIJ.run('Image Sequence...', ['open=[' DirForFIJI '\\' TiffSerDirs(a).name '\\' TiffSerDirs(a).name '_Cycle00001_Ch1_000001.ome.tif] file=Ch2 sort']);
            %MIJ.run('Image Stabilizer', ['transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients']);
            MIJ.run('Image Stabilizer Log Applier', 'OK=1');
            ImgReg = MIJ.getCurrentImage;
            ImgReg = uint16(ImgReg);
            saveastiff(ImgReg, FileNameCh2);
            MIJ.run('Close');
            MIJ.selectWindow([TiffSerDirs(a).name '.log']);
            MIJ.run('Close');
            clear ImgReg FileNameCh1 FileNameCh2
        end
    end
    
    for k = 3+(StartFolder):length(ExperimentDayDirs)
        if ExperimentDayDirs(k).isdir ==1
            DaysDirs = [rootdir '\' ExperimentDayDirs(k).name];
            DirForFIJI = strrep(DaysDirs, '\', '\\');
            cd([rootdir '\' ExperimentDayDirs(k).name]);
            TiffSerDirs = dir('TSeries*');
            cd(OutputDir)
            mkdir(ExperimentDayDirs(k).name);
            %for a=1:length(TiffSerDirs)
            for a=15:length(TiffSerDirs)
                if TiffSerDirs(a).isdir
                    cd([rootdir '\' ExperimentDayDirs(k).name '\' TiffSerDirs(a).name]);
                    NumFiles = dir('*Ch1*');
                    cd([OutputDir '\' ExperimentDayDirs(k).name]);
                    if length(NumFiles) == BlockSize;
                        %Load Channel 1
                        FileNameCh1 = [TiffSerDirs(a).name '_Ch1_stack.tif'];
                        FileNameCh2 = [TiffSerDirs(a).name '_Ch2_stack.tif'];
                        MIJ.run('Image Sequence...', ['open=[' DirForFIJI '\\' TiffSerDirs(a).name '\\' TiffSerDirs(a).name '_Cycle00001_Ch1_000001.ome.tif] file=Ch1 sort']);
                        MIJ.run('Image Stabilizer', ['transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients']);
                        ImgReg = MIJ.getCurrentImage;
                        ImgReg = uint16(ImgReg);
                        saveastiff(ImgReg, FileNameCh1);
                        MIJ.selectWindow(TiffSerDirs(a).name);
                        MIJ.run('Close');
                        clear ImgReg
                        %Load Channel 2
                        MIJ.run('Image Sequence...', ['open=[' DirForFIJI '\\' TiffSerDirs(a).name '\\' TiffSerDirs(a).name '_Cycle00001_Ch1_000001.ome.tif] file=Ch2 sort']);
                        %MIJ.run('Image Stabilizer', ['transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients']);
                        MIJ.run('Image Stabilizer Log Applier', 'OK=1');
                        ImgReg = MIJ.getCurrentImage;
                        ImgReg = uint16(ImgReg);
                        saveastiff(ImgReg, FileNameCh2);
                        MIJ.run('Close');
                        MIJ.selectWindow([TiffSerDirs(a).name '.log']);
                        MIJ.run('Close');
                        clear ImgReg FileNameCh1 FileNameCh2
                    end
                end
            end
        end
    end
end


if AfterCRASH == 0
    for k = 3+(StartFolder - 1):length(ExperimentDayDirs)
        if ExperimentDayDirs(k).isdir == 1
            DaysDirs = [rootdir '\' ExperimentDayDirs(k).name];
            DirForFIJI = strrep(DaysDirs, '\', '\\');
            cd([rootdir '\' ExperimentDayDirs(k).name]);
            TiffSerDirs = dir('TSeries*');
            cd(OutputDir)
           mkdir(ExperimentDayDirs(k).name);
           cd([OutputDir '\' ExperimentDayDirs(k).name]);
            mkdir('VoltFiles');
           for a=1:length(TiffSerDirs)
                if TiffSerDirs(a).isdir
                    cd([rootdir '\' ExperimentDayDirs(k).name '\' TiffSerDirs(a).name]);
                    NumFiles = dir('*Ch1*');
                      VoltFiles = dir('*.csv');
                      copyfile(VoltFiles(1).name, [OutputDir '\' ExperimentDayDirs(k).name '\VoltFiles']);
                    cd([OutputDir '\' ExperimentDayDirs(k).name]);
                    if length(NumFiles) <= BlockSize;
                        %Load Channel 1
                        FileNameCh1 = [TiffSerDirs(a).name '_Ch1_stack.tif'];
                        FileNameCh2 = [TiffSerDirs(a).name '_Ch2_stack.tif'];
                        MIJ.run('Image Sequence...', ['open=[' DirForFIJI '\\' TiffSerDirs(a).name '\\' TiffSerDirs(a).name '_Cycle00001_Ch1_000001.ome.tif] file=Ch1 sort']);
                        MIJ.run('Image Stabilizer', ['transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients']);
                        ImgReg = MIJ.getCurrentImage;
                        ImgReg = uint16(ImgReg);
                        saveastiff(ImgReg, FileNameCh1);
                        MIJ.selectWindow(TiffSerDirs(a).name);
                        MIJ.run('Close');
                        clear ImgReg
                        %Load Channel 2
                        MIJ.run('Image Sequence...', ['open=[' DirForFIJI '\\' TiffSerDirs(a).name '\\' TiffSerDirs(a).name '_Cycle00001_Ch1_000001.ome.tif] file=Ch2 sort']);
                        %MIJ.run('Image Stabilizer', ['transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001 log_transformation_coefficients']);
                        MIJ.run('Image Stabilizer Log Applier', 'OK=1');
                        ImgReg = MIJ.getCurrentImage;
                        ImgReg = uint16(ImgReg);
                        saveastiff(ImgReg, FileNameCh2);
                        MIJ.run('Close');
                        MIJ.selectWindow([TiffSerDirs(a).name '.log']);
                        MIJ.run('Close');
                        clear ImgReg FileNameCh1 FileNameCh2
                    end
                end
            end
        end
    end
end



