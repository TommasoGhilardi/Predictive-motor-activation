%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Preprocessing EEG prediction                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info_var;
AF= Functions_preprocessing_execution;
subject = Subjects(4).name;  % define the data path and its name 

%% ========================% Action Execution %======================= %%

% Trial definition execution
[cfg_ex,event]=AF.Trialdef_execution(subject);

% Preprocessing of data
data_ex = AF.Preprocess(cfg_ex,1,40);
save(['Saved_steps\Execution\preprocessing_',subject(1:9),'.mat'],'data_ex')

% Rough Summary Rejection 
% what=1->summary ; what=2->summary+databeowser ; what=3->summary+databeowser+reref
data_ex = AF.Visual_rejection(data_ex,1);
save(['Saved_steps\Execution\first_rejection_',subject(1:9),'.mat'],'data_ex')

% ICA
data_ex = AF.ICA(data_ex,20,cap_conf);
save(['Saved_steps\Execution\ICA_',subject(1:9),'.mat'],'data_ex')

% Final Visual Rejection+ Rereference
% what=1->summary ; what=2->summary+databeowser ; what=3->summary+databeowser+reref
data_ex = AF.Visual_rejection(data_ex,3);
save(['Saved_steps\Execution\rejected_',subject(1:9),'.mat'],'data_ex')

%% ===================% FFT and Division baseline and execution %================== %%

% FFT
fft_ex = AF.FFT(data_ex,'all');
save(['Saved_steps\Execution\FFT_ex_',subject(1:9),'.mat'],'fft_ex')

cfg = [];
cfg.trials=find(fft_ex.trialinfo==100);
cfg.avgoverrpt  ='yes';
cfg.channel     = channels.motor;
fft_exec        = ft_selectdata(cfg, fft_ex);

cfg = [];
cfg.trials      = find(fft_ex.trialinfo==80);
cfg.avgoverrpt  ='yes';
cfg.channel     = channels.motor;
fft_base        = ft_selectdata(cfg, fft_ex);

%% ========================% Differences 6-13 HZ %======================= %%

%Plot
AF.Plot_fft(fft_exec,fft_base,'noo')

%% ========================% Save freq range %======================= %%
AF.Saving_range(subject)

%% ========================% Clear for next subject %======================= %%
clear
clc

