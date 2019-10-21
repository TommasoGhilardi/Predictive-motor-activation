%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Preprocessing EEG prediction                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info_var;
FA= Functions_preprocessing_prediction;
subject = Subjects(30).name;  % define the data path and its name 

%% ========================% Action Prediction Preprocessing %======================= %%

% Trial definition execution
cfg_pred = FA.Trialdef(subject, [Triggers.predictive_window.low,...
    Triggers.predictive_window.medium1,Triggers.predictive_window.medium2...
    Triggers.predictive_window.high1, Triggers.predictive_window.high2...
    Triggers.predictive_window.deterministic, Triggers.fixation_cross]);

% Preprocessing of data
data_pred = FA.Preprocess(cfg_pred,1,40);
save(['Saved_steps\prediction\preprocessing_',subject(1:9),'.mat'],'data_pred')

% Rough Summary Rejection 
% what=1->summary ; what=2->summary+databeowser ; what=3->summary+databeowser+reref
data_pred = FA.Visual_rejection(data_pred,1);
save(['Saved_steps\prediction\first_rejection_',subject(1:9),'.mat'],'data_pred')

% ICA
data_pred = FA.ICA(data_pred,20,cap_conf);
save(['Saved_steps\prediction\ICA_',subject(1:9),'.mat'],'data_pred')

% Final Visual Rejection+ Rereference
% what=1->summary ; what=2->summary+databeowser ; what=3->summary+databeowser+reref
data_pred = FA.Visual_rejection(data_pred,3);
save(['Saved_steps\prediction\rejected_',subject(1:9),'.mat'],'data_pred')

%% ===================% FFT and Division baseline and execution %================== %%

% FFT
fft_pred = FA.FFT(data_pred,'all');
save(['Saved_steps\prediction\FFT_pred_',subject(1:9),'.mat'],'fft_pred')

cfg = [];
cfg.trials=find(fft_pred.trialinfo==50);
cfg.avgoverrpt='yes';
cfg.channel= channels.motor;
fix= ft_selectdata(cfg, fft_pred);

cfg = [];
cfg.trials=find(fft_pred.trialinfo==11 | fft_pred.trialinfo==21 |fft_pred.trialinfo==31 | fft_pred.trialinfo==41);
cfg.avgoverrpt='yes';
cfg.channel= channels.motor;
low= ft_selectdata(cfg, fft_pred);

cfg = [];
cfg.trials=find(fft_pred.trialinfo==12 | fft_pred.trialinfo==22 |fft_pred.trialinfo==32 | fft_pred.trialinfo==42);
cfg.avgoverrpt='yes';
cfg.channel= channels.motor;
medium1= ft_selectdata(cfg, fft_pred);

cfg = [];
cfg.trials=find(fft_pred.trialinfo==13 | fft_pred.trialinfo==23 |fft_pred.trialinfo==33 | fft_pred.trialinfo==43);
cfg.avgoverrpt='yes';
cfg.channel= channels.motor;
medium2= ft_selectdata(cfg, fft_pred);

cfg = [];
cfg.trials=find(fft_pred.trialinfo==14 | fft_pred.trialinfo==24 |fft_pred.trialinfo==34 | fft_pred.trialinfo==44);
cfg.avgoverrpt='yes';
cfg.channel= channels.motor;
high1= ft_selectdata(cfg, fft_pred);

cfg = [];
cfg.trials=find(fft_pred.trialinfo==15 | fft_pred.trialinfo==25 |fft_pred.trialinfo==35 | fft_pred.trialinfo==45);
cfg.avgoverrpt='yes';
cfg.channel= channels.motor;
high2= ft_selectdata(cfg, fft_pred);

cfg = [];
cfg.trials=find(fft_pred.trialinfo==16 | fft_pred.trialinfo==26 |fft_pred.trialinfo==36 | fft_pred.trialinfo==46);
cfg.avgoverrpt='yes';
cfg.channel= channels.motor;
det= ft_selectdata(cfg, fft_pred);

%% ========================% Plot frequencies %======================= %% 
FA.Plot_bar(fix,low,medium1,medium2,high1,high2,det)

%% ========================% Clear for next subject %======================= %%
clear
clc

