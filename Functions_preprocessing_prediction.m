classdef Functions_preprocessing_prediction 
    methods(Static)
        function [cfg_tr_def] = Trialdef(path,triggers)
            cfg                         = [];
            cfg.dataset                 = path;
            cfg.trialdef.eventtype      = 'Stimulus';
            cfg.trialdef.eventvalue     = triggers; % the value of the stimulus trigger for fully incongruent (FIC).
            cfg.trialdef.prestim        = 0; % in seconds
            cfg.trialdef.poststim       = 1; % in seconds
            cfg_tr_def = ft_definetrial(cfg);
        end
        
        function [result] = Preprocess(cfg,hp,lp)
            % read data and segment
            cfg.hpfilter    = 'yes';        % enable high-pass filtering
            cfg.lpfilter    = 'yes';        % enable low-pass filtering
            cfg.hpfreq      = hp;           % set up the frequency for high-pass filter
            cfg.lpfreq      = lp;
            cfg.detrend     = 'yes';
            cfg.demean      = 'yes';    
            result          = ft_preprocessing(cfg); % read raw data
            if isequal(result.label{end},'FP1')
                result.label{end}='Fp1';
            else
                disp('ERROR FP1... CHECK PLEASE')
            end
        end 
        
        function [result] = Visual_rejection(input,what)
            if what > 0
                % Visual rejection with summary
                cfg = [];
                cfg.metric      = 'kurtosis';  % use by default zvalue method
                cfg.method      = 'summary'; % use by default summary method
                result    = ft_rejectvisual(cfg,input);
                
                if what > 1
                    % Trial rejection
                    cfg = [];
                    cfg.method  = 'trial';
                    result        = ft_rejectvisual(cfg,result);
                
                    if what > 2
                        % Rereference to average
                        cfg.reref       = 'yes';
                        cfg.refchannel  = 'all';
                        cfg.refmethod   = 'avg';
                        result          = ft_preprocessing(cfg,result);
            
                    end
                end
            end
        end
        
        function[result] = ICA(input,components,cap)
            cfg             = [];
            cfg.method      = 'runica'; % default implementation from EEGLAB
            componenti            = ft_componentanalysis(cfg, input);

            % plot the components for visual inspection
            figure('units','normalized','outerposition',[0 0 1 1])
            cfg             = [];
            cfg.component   = 1:components;       % specify the component(s) that should be plotted
            cfg.layout      = cap; % specify the layout file that should be used for plotting
            cfg.comment     = 'no';
            ft_topoplotIC(cfg, componenti)

            prompt      = {'Components to reject: '};
            dlgtitle    = 'Input';
            dims        = [1 60];
            answer      = inputdlg(prompt,dlgtitle,dims);
            answer      = str2num(char(answer{1}));

            %rejecting
            cfg             = [];
            cfg.component   = answer; % to be removed component(s)
            result            = ft_rejectcomponent(cfg, componenti, input);
            close
        end
        
        function [result] = FFT(input,channel)
            %FFT decomposition
            cfg              = [];
            cfg.output       = 'pow';
            cfg.channel      = 'EEG';
            cfg.method       = 'mtmfft';
            cfg.taper        = 'hanning';
            cfg.pad          = 'maxperlen';
            cfg.padtype      = 'zero';
            cfg.channel      = channel;
            cfg.keeptrials  = 'yes';
            cfg.foi          = 3:1:30; % analysis 3 to 30 Hz in steps of 1 Hz
            result           = ft_freqanalysis(cfg, input);
        end
        
        function [] = Plot_bar(fix,low,medium1,medium2,high1,high2,det)
            mean_elec=([mean(fix.powspctrm);...
                mean(low.powspctrm);...
                mean(medium1.powspctrm); mean(medium2.powspctrm);...
                mean(high1.powspctrm); mean(high2.powspctrm);...
                mean(det.powspctrm)]);

            sem_elec=[std((fix.powspctrm))/sqrt(length(mean(log(fix.powspctrm))));...
                std((low.powspctrm))/sqrt(length(mean(log(low.powspctrm))));...
                std((medium1.powspctrm))/sqrt(length(mean(log(medium1.powspctrm))));...
                std((medium2.powspctrm))/sqrt(length(mean(log(medium2.powspctrm))));...
                std((high1.powspctrm))/sqrt(length(mean(log(high1.powspctrm))));...
                std((high2.powspctrm))/sqrt(length(mean(log(high2.powspctrm))));...
                 std((det.powspctrm))/sqrt(length(mean(log(det.powspctrm))))];

            ax= det.freq;

            color=[[0, 0.4470, 0.7410];[0.8500, 0.3250, 0.0980];[0.9290, 0.6940, 0.1250];...
                [0.4940, 0.1840, 0.5560];[0.4660, 0.6740, 0.1880];[0.6350, 0.0780, 0.1840];...
                [0.3010, 0.7450, 0.9330]];

            legend_label={'Baseline', 'Low' , 'Medium1', 'Medium2' , 'High1', 'High2' , 'Determinsitic'};

            figure
            rectangle('Position',[8 0 5 max(max(mean_elec))+4],'FaceColor',[0 0 0 0.1],'EdgeColor',[0 0 0 0.1]);
            hold on
            for x = 1:7
                patch = fill([ax, fliplr(ax)], [mean_elec(x,:)+sem_elec(x,:), fliplr(mean_elec(x,:)-sem_elec(x,:))], color(x,:));
                set(patch, 'edgecolor', 'none');
                set(patch, 'FaceAlpha', 0.2);
                plot1(x) = plot(ax,mean_elec(x,:),'Color',color(x,:));
            end
            
            xlabel('Frequency (Hz)');
            ylabel('absolute power (uV^2)');
            xlim([2.5 31]);
            ylim([0,max(max(mean_elec))+1])

            [~, hobj, ~, ~] = legend(plot1,legend_label(),'FontSize',14);
            hl = findobj(hobj,'type','line');
            set(hl,'LineWidth',3);  
            hold off
        end
        
    end
end