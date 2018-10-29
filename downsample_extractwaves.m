%% clear workspace
clear all; clc; close all;

rootdir = 'E:\MC\odor+light\400\New folder (2)\New folder\New folder';
cd(rootdir)

%% select data and map it to the RAM
if ~exist('nam', 'var') || isempty(nam)
    try
        load .dir.mat; %load previous path
    catch
        dir_nm = [cd(), filesep]; %use the current path
    end
    [file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.tif;*.mat'));
    if dir_nm~=0
        save .dir.mat dir_nm;
    else
        fprintf('no file was selected. STOP!\N');
        return;
    end
    nam = [dir_nm, file_nm];  % full name of the data file
    [~, file_nm, file_type] = fileparts(nam);
end

% convert the data to mat file
nam_mat = [dir_nm, file_nm, '.mat'];
if strcmpi(file_type, '.mat')
    fprintf('The selected file is *.mat file\n');
elseif  exist(nam_mat', 'file')
    % the selected file has been converted to *.mat file already
    fprintf('The selected file has been replaced with its *.mat version\n');
elseif or(strcmpi(file_type, '.tif'), strcmpi(file_type, '.tiff'))
    % convert
    tic;
    fprintf('converting the selected file to *.mat version...\n');
    nam_mat = tif2mat(nam);
    fprintf('Time cost in converting data to *.mat file:     %.2f seconds\n', toc);
else
    fprintf('The selected file type was not supported yet! email me to get support (zhoupc1988@gmail.com)\n');
    return;
end

data = matfile(nam_mat);
Ysiz = data.Ysiz;
d1 = Ysiz(1);   %height
d2 = Ysiz(2);   %width
numFrame = Ysiz(3);    %total number of frames

fprintf('\nThe data has been mapped to RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1, d2, numFrame, prod(Ysiz)*8/(2^30));

%% create Source2D class object for storing results and parameters
neuron_raw = Sources2D('d1',d1,'d2',d2);   % dimensions of datasets
neuron_raw.Fs = 40;         % frame rate
ssub = 3;           % spatial downsampling factor
tsub = 1;           % temporal downsampling factor
neuron_raw.updateParams('ssub', ssub,...  % spatial downsampling factor
    'tsub', tsub, ...  %temporal downsampling factor
    'gSig', 3,... %width of the gaussian kernel, which can approximates the average neuron shape
    'gSiz', 15, ...% maximum diameter of neurons in the image plane. larger values are preferred.
    'dist', 2, ... % maximum size of the neuron: dist*gSiz
    'search_method', 'ellipse', ... % searching method
    'merge_thr', 0.6, ... % threshold for merging neurons
    'bas_nonneg', 1);   % 1: positive baseline of each calcium traces; 0: any baseline

% create convolution kernel to model the shape of calcium transients
nframe_decay = 30;
tau_decay = 0.6;  % unit: second
tau_rise = 0.1;
bound_pars = false;
neuron_raw.kernel = create_kernel('exp2', [tau_decay, tau_rise]*neuron_raw.Fs, nframe_decay, [], [], bound_pars);

%% downsample data for fast and better initialization
sframe=1;						% user input: first frame to read (optional, default:1)
num2read= numFrame;             % user input: how many frames to read   (optional, default: until the end)

tic;
if and(ssub==1, tsub==1)
    neuron = neuron_raw;
    Y1 = double(data.Y(:, :, sframe+(1:num2read)-1));
    [d1s,d2s, T] = size(Y1);
    fprintf('\nThe data has been loaded into RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1s, d2s, T, d1s*d2s*T*8/(2^30));
else
    [Y1, neuron] = neuron_raw.load_data(nam_mat, sframe, num2read);
    [d1s,d2s, T] = size(Y1);
    fprintf('\nThe data has been downsampled and loaded into RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1s, d2s, T, d1s*d2s*T*8/(2^30));
end
%Y = neuron.reshape(Y, 1);
%neuron_raw.P.p = 2;      %order of AR model

fprintf('Time cost in downsapling data:     %.2f seconds\n', toc);

%% extracts waves from saved contours
load('E:\MC\odor+light\300\Contours.mat');
for t = 1:length(Contours)
    Xval = Contours{t,1}(1,:);
    Yval = Contours{t,1}(end,:);
    for y = 1:length(Xval)
        for u = 1:size(Y1,3)
            ROIs(t).pixels(:,y,u) = Y1(ceil(Xval(y)),ceil(Yval(y)),u);
        end
    end
end

for k = 1:length(ROIs)
    Roival = squeeze(ROIs(k).pixels);
    meanval = mean(Roival,1);
    in = find(meanval == 0);
    meanval(:,in) = meanval(:,in+1);
    ROIs(k).mean_vals = meanval;
    clear Roival meanval
end

%%
for dffnum = 1:size(ROIs,2)
    f0 = mean(ROIs(dffnum).mean_vals);
    FminF0 = ROIs(dffnum).mean_vals - f0;
    ROIs(dffnum).dff = FminF0 ./ f0;
    clear f0 FminF0;
end

waves = [];
for i = 1:length(ROIs)
    waves = [waves; ROIs(i).dff];
end

save(['waves_' file_nm '.mat'], 'waves')