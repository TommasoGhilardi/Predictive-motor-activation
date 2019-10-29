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
            cfg.marker      = 'labels';
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
            mean_power=[fix.powspctrm, low.powspctrm,medium1.powspctrm,medium2.powspctrm,...
            high1.powspctrm,high2.powspctrm,det.powspctrm];

            XTick=[1,3,5,6,8,9,11];

            figure
            hold on
            for x =1:length(mean_power)
               h= bar(XTick(x),mean_power(x));
            %    er = errorbar(XTick(x),mean_power(x),sem_power(x),'.');
               er.Color= 'k';
               if XTick(x)==1
                   set(h,'FaceColor',[0, 0.4470, 0.7410]);
               elseif XTick(x)<5
                   set(h,'FaceColor',[0.8500, 0.3250, 0.0980]);
               elseif XTick(x)<8
                   set(h,'FaceColor',[0.9290, 0.6940, 0.1250]);
               elseif XTick(x)<11
                   set(h,'FaceColor',[0.4940, 0.1840, 0.5560]);
               else
                   set(h,'FaceColor',[0.4660, 0.6740, 0.1880]);
               end
            end

            XTickLabel={'Baseline'; 'Low' ; 'Medium1'; 'Medium2' ; 'High1'; 'High2' ; 'Determinsitic'};
            set(gca, 'XTick',XTick);
            set(gca, 'XTickLabel', XTickLabel);

        end
        
    end
end