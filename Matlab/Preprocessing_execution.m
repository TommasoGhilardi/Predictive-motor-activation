%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Preprocessing EEG prediction                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the directory to this script location
p = matlab.desktop.editor.getActiveFilename;
idcs = strfind(p,'\');
cd(p(1:idcs(end)-1));

info_var;
AF= Functions_preprocessing_execution;
subject = Subjects(33);  % define the data path and its name 

%% ========================% Action Execution %======================= %%

% Trial definition execution
[cfg_ex,event]=AF.Trialdef_execution(fullfile(subject.folder, subject.name));

% Preprocessing of data
data_ex = AF.Preprocess(cfg_ex,1,40);
save([output_dir '\Execution\preprocessing_',subject.name(1:6),'.mat'],'data_ex')

% Rough Summary Rejection 
% what=1->summary ; what=2->summary+databeowser ; what=3->summary+databeowser+reref
data_ex = AF.Visual_rejection(data_ex,1);
save([output_dir '\Execution\first_rejection_',subject.name(1:6),'.mat'],'data_ex')

% ICA
data_ex = AF.ICA(data_ex,20,cap_conf);
save([output_dir '\Execution\ICA_',subject.name(1:6),'.mat'],'data_ex')

% Final Visual Rejection+ Rereference
% what=1->summary ; what=2->summary+databeowser ; what=3->summary+databeowser+reref
data_ex = AF.Visual_rejection(data_ex,3);
save([output_dir '\Execution\rejected_',subject.name(1:6),'.mat'],'data_ex')

%% ===================% FFT and Division baseline and execution %================== %%

% FFT
fft_ex = AF.FFT(data_ex,'all');
save([output_dir '\Execution\FFT_ex_',subject.name(1:6),'.mat'],'fft_ex')

cfg = [];
cfg.trials=find(fft_ex.trialinfo==100);
cfg.avgoverchan ='yes'; %averaging over the chan
cfg.channel     = channels.motor;
fft_exec        = ft_selectdata(cfg, fft_ex);

cfg = [];
cfg.trials      = find(fft_ex.trialinfo==80);
cfg.avgoverchan ='yes'; %averaging over the chan
cfg.channel     = channels.motor;
fft_base        = ft_selectdata(cfg, fft_ex);

%% ========================% Differences 6-13 HZ %======================= %%

%Plot
AF.Plot_fft(fft_exec,fft_base)

%% ========================% Clear for next subject %======================= %%
clear
clc

            
            
            
            