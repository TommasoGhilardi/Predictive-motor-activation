classdef Functions_preprocessing_execution
    methods(Static) 
        
        function [cfg_tr_def,events] = Trialdef_execution(path)
            cfg             = [];
            cfg.dataset     = path;
            cfg.trialfun    = 'trial_fun_execution';
            cfg_tr_def      = ft_definetrial(cfg);   % read the list of the specific stimulus
            events          = cfg_tr_def.event;
        end
        
        function [cfg_tr_def,events] = Trialdef_baseline(path)
            cfg             = [];
            cfg.dataset     = path;
            cfg.trialfun    = 'trial_fun_baseline';
            cfg_tr_def      = ft_definetrial(cfg);   % read the list of the specific stimulus
            events          = cfg_tr_def.event;
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
            comp            = ft_componentanalysis(cfg, input);

            % plot the components for visual inspection
            figure('units','normalized','outerposition',[0 0 1 1])
            cfg             = [];
            cfg.marker      = 'labels';
            cfg.component   = 1:components;       % specify the component(s) that should be plotted
            cfg.layout      = cap; % specify the layout file that should be used for plotting
            cfg.comment     = 'no';
            
            ft_topoplotIC(cfg, comp)

            prompt      = {'Components to reject: '};
            dlgtitle    = 'Input';
            dims        = [1 60];
            answer      = inputdlg(prompt,dlgtitle,dims);
            if isempty(answer)
                answer=[];
            else
                answer      = str2num(char(answer{1}));
            end
            %rejecting
            cfg             = [];
            cfg.component   = answer; % to be removed component(s)
            result          = ft_rejectcomponent(cfg, comp, input);
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
            cfg.keeptrials   = 'yes';
            cfg.foi          = 3:1:30; % analysis 3 to 30 Hz in steps of 1 Hz
            result           = ft_freqanalysis(cfg, input);
        end
        
        function [] = Plot_fft(Freq1,Freq2)
            data1   = Freq1.powspctrm;
            data2   = Freq2.powspctrm;
            x1      = Freq1.freq;
            x2      = Freq2.freq;

            blu_area    = [128 193 219]./255;    % Blue theme
            blu_line    = [ 52 148 186]./255;
            orange_area = [243 169 114]./255;    % Orange theme
            orange_line = [236 112  22]./255;
            alpha       = 0.2;
            line_width  = 2;

            % Computing the mean and standard deviation of the data matrix
            data_mean1  = mean(data1,1);
            data_mean2  = mean(data2,1);
            data_std1   = std(data1,0,1);
            data_std2   = std(data2,0,1);
            % Type of error plot
            error1      = (data_std1./sqrt(size(data1,1)));
            error2      = (data_std2./sqrt(size(data2,1)));

            figure;
            a=subplot(2,1,1);
            hold on
            %first line
            patch = fill([x1, fliplr(x1)], [data_mean1+error1, fliplr(data_mean1-error1)], blu_area);
            set(patch, 'edgecolor', 'none');
            set(patch, 'FaceAlpha', alpha);
            plott(1)=plot(x1, data_mean1,'color', blu_line,'LineWidth', line_width);
            %second line
            patch = fill([x2, fliplr(x2)], [data_mean2+error2, fliplr(data_mean2-error2)], orange_area);
            set(patch, 'edgecolor', 'none');
            set(patch, 'FaceAlpha', alpha);
            plott(2)=plot(x2, data_mean2,'color', orange_line,'LineWidth', line_width);
            xlabel('Frequency (Hz)');
            ylabel('absolute power (uV^2)');
            legend(plott,{'Execution','Baseline'});
            xlim([2.5 31]);

            subplot(2,1,2);
            hold on
            Freq=Freq1;
            Freq.powspctrm=Freq1.powspctrm-Freq2.powspctrm;
            [peaksY,peaksX,w,p]     = findpeaks(-mean(Freq.powspctrm(:,:)));
            xpeaks                  = Freq.freq(peaksX);
            ind_peaks_mu            = find(Freq.freq(peaksX)>7 & Freq.freq(peaksX)<13);
            ind_peaks_beta          = find(Freq.freq(peaksX)>12 & Freq.freq(peaksX)<30);
            
            width                   = w(ind_peaks_mu);
            xlabel('Frequency (Hz)');
            ylabel('absolute power (uV^2)');
            xlim([2.5 31]);
            ylim([min(mean(Freq.powspctrm(:,:)))-0.5 max(mean(Freq.powspctrm(:,:)))+0.5]);
            plot(Freq.freq, mean(Freq.powspctrm(:,:)),'k',...
                xpeaks(ind_peaks_mu),-peaksY(ind_peaks_mu),'ro',...
                xpeaks(ind_peaks_beta),-peaksY(ind_peaks_beta),'bo','LineWidth',1);
            
            legend('Execution-Baseline');
            disp(['Peak at:  ', num2str(xpeaks(ind_peaks_mu)),'Hz']);
            disp(['Peak at:  ', num2str(xpeaks(ind_peaks_beta)),'Hz']);

        end
              
    end
end    