%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              EEG Main execution                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info_var;

blu_area    = [128 193 219]./255;    % Blue theme
blu_line    = [ 52 148 186]./255;
orange_area = [243 169 114]./255;    % Orange theme
orange_line = [236 112  22]./255;


for x = 1:length(Subjects)
    load(['Saved_steps\execution\FFT_ex_',Subjects(x).name(1:9),'.mat']);
    
    %selecting channels and freq
    cfg = [];
    cfg.channel= [channels.motor, channels.occipital];
    cfg.frequency = 'all';
    tot= ft_selectdata(cfg, fft_ex);

    if exist('db') ~= 1
        db = tot; 
    elseif exist('db') == 1
        cfg=[];
        db = ft_appendfreq(cfg,db,tot);
    end
    clear fft_ex cfg x;
end

%% ========================% Division baseline and execution %======================= %%
cfg = [];
cfg.trials=find(db.trialinfo==100);
cfg.avgoverfreq='no'; %averaging over frequencies
cfg.avgoverchan = 'yes'; %averaging over the channels
cfg.channel= channels.motor;
cfg.frequency = 'all';
execution= ft_selectdata(cfg, db);

cfg = [];
cfg.trials=find(db.trialinfo==80);
cfg.avgoverfreq='no'; %averaging over frequencies
cfg.avgoverchan = 'yes'; %averaging over the channels
cfg.channel= channels.motor;
cfg.frequency = 'all';
baseline= ft_selectdata(cfg, db);

%% ========================% Plot frequencies %======================= %%

%Preparation of data
mean_ex=mean(execution.powspctrm,1);
mean_ba=mean(baseline.powspctrm,1);

std_ex=std(execution.powspctrm,0,1);
std_ba=std(baseline.powspctrm,0,1);

err_ex=(std_ex/sqrt(size(execution.powspctrm,1)));
err_ba=(std_ba/sqrt(size(baseline.powspctrm,1)));

% SUBPLOT 1 two lines
figure;
a=subplot(2,1,1);
hold on

%Execution line
plot_ex = fill([execution.freq(:); flipud(execution.freq(:))],  [mean_ex(:)-err_ex(:); flipud(mean_ex(:)+err_ex(:))], blu_area);
set(plot_ex, 'edgecolor', 'none');
set(plot_ex, 'FaceAlpha', 0.2);
plott(1) = plot(execution.freq(:), mean_ex(:),'color', blu_line,'LineWidth', 2);

% Baseline line
plot_ex = fill([baseline.freq(:); flipud(baseline.freq(:))],  [mean_ba(:)-err_ba(:); flipud(mean_ba(:)+err_ba(:))], orange_area);
set(plot_ex, 'edgecolor', 'none');
set(plot_ex, 'FaceAlpha', 0.2);
plott(2) = plot(baseline.freq(:), mean_ba(:),'color', orange_line,'LineWidth', 2);
%legend
xlabel('Frequency (Hz)');
ylabel('absolute power (uV^2)');
legend(plott,{'Execution','Baseline'});

% SUBPLOT 2 the difference
subplot(2,1,2);
hold on
mean_diff=mean(execution.powspctrm,1)-mean(baseline.powspctrm,1);
[peaksY,peaksX,w,p]     = findpeaks(-mean_diff(:));
xpeaks                  = execution.freq(peaksX);
ind_peaks_mu            = find(execution.freq(peaksX)>7 & execution.freq(peaksX)<12);
ind_peaks_beta          = find(execution.freq(peaksX)>12 & execution.freq(peaksX)<30);
xlabel('Frequency (Hz)');
ylabel('absolute power (uV^2)');
xlim([2.5 31]);
ylim([min(mean_diff)-0.1, max(mean_diff)+0.1])

plot(execution.freq, mean_diff(:),'k',...
    xpeaks(ind_peaks_mu),-peaksY(ind_peaks_mu),'ro','LineWidth',1.5);
plot(xpeaks(ind_peaks_beta),-peaksY(ind_peaks_beta),'bo')

legend('Difference');

% Writin the labels of the points
for x = 1:length(ind_peaks_mu)
    text(xpeaks(ind_peaks_mu(x)),-peaksY(ind_peaks_mu(x))-(peaksY(ind_peaks_mu(x))/100*50),num2str(xpeaks(ind_peaks_mu(x))))
end

for x = 1:length(ind_peaks_beta)
    text(xpeaks(ind_peaks_beta(x)),-peaksY(ind_peaks_beta(x))-(peaksY(ind_peaks_beta(x))/100*50),num2str(xpeaks(ind_peaks_beta(x))))
end

%add square 
rectangle('Position',[9 min(mean_diff)-0.2 2 max(mean_diff)-min(mean_diff)+0.5],'FaceColor',[0 0 0 0.1],'EdgeColor',[0 0 0 0.1]...
    ,'Curvature',0.1);

