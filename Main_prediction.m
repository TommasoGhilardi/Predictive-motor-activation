%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Preprocessing EEG prediction                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info_var;
[Subject,Probability,Power]=deal({'0'},0,0); %creating table to store subject data

names_area=fieldnames(channels); %defining the area names
for area =1:2
    %% Loop over areas
    area_interest=channels.(names_area{area});

    
    names_freq = fieldnames(Freq_peak); %defining the frequency names
    for range = 1:2
        %% Loop over frequencies
        freq_of_interest=Freq_peak.(names_freq{range}); 
        
        % Creating empty dataframe from emty values
        DF= table(Subject,Probability,Power);
                
        for x = 1:length(Subjects)-1
            %% Loop for subjects

            load(['Saved_steps\prediction\FFT_pred_',Subjects(x).name(1:9),'.mat'],'fft_pred');    
            fft_pred.powspctrm=log(fft_pred.powspctrm);    %log transformation

            trials(x)=length(fft_pred.trialinfo); %number fo trials after rejection

            cfg = [];
            cfg.trials=find(fft_pred.trialinfo==50);
            cfg.avgoverfreq='yes'; %averaging over frequencies
            cfg.avgoverchan = 'yes'; %averaging over the channels
            cfg.channel= area_interest;
            cfg.frequency = freq_of_interest;
            fix= ft_selectdata(cfg, fft_pred);
            DF(end+1,:)={Subjects(x).name(1:9),0,mean(fix.powspctrm)};

            cfg = [];
            cfg.trials=find(fft_pred.trialinfo==11 | fft_pred.trialinfo==21 |fft_pred.trialinfo==31 | fft_pred.trialinfo==41);
            cfg.avgoverfreq='yes'; %averaging over frequencies
            cfg.avgoverchan = 'yes'; %averaging over the channels
            cfg.channel= area_interest;
            cfg.frequency = freq_of_interest;
            low= ft_selectdata(cfg, fft_pred);
            DF(end+1,:)={Subjects(x).name(1:9),1,mean(low.powspctrm)};

            cfg = [];
            cfg.trials=find(fft_pred.trialinfo==12 | fft_pred.trialinfo==22 |fft_pred.trialinfo==32 | fft_pred.trialinfo==42);
            cfg.avgoverfreq='yes'; %averaging over frequencies
            cfg.avgoverchan = 'yes'; %averaging over the channels
            cfg.channel= area_interest;
            cfg.frequency = freq_of_interest;
            medium1= ft_selectdata(cfg, fft_pred);
            DF(end+1,:)={Subjects(x).name(1:9),2,mean(medium1.powspctrm)};

            cfg = [];
            cfg.trials=find(fft_pred.trialinfo==13 | fft_pred.trialinfo==23 |fft_pred.trialinfo==33 | fft_pred.trialinfo==43);
            cfg.avgoverfreq='yes'; %averaging over frequencies
            cfg.avgoverchan = 'yes'; %averaging over the channels
            cfg.channel= area_interest;
            cfg.frequency = freq_of_interest;
            medium2= ft_selectdata(cfg, fft_pred);
            DF(end+1,:)={Subjects(x).name(1:9),3,mean(medium2.powspctrm)};

            cfg = [];
            cfg.trials=find(fft_pred.trialinfo==14 | fft_pred.trialinfo==24 |fft_pred.trialinfo==34 | fft_pred.trialinfo==44);
            cfg.avgoverfreq='yes'; %averaging over frequencies
            cfg.avgoverchan = 'yes'; %averaging over the channels
            cfg.channel= area_interest;
            cfg.frequency = freq_of_interest;
            high1= ft_selectdata(cfg, fft_pred);
            DF(end+1,:)={Subjects(x).name(1:9),4,mean(high1.powspctrm)};

            cfg = [];
            cfg.trials=find(fft_pred.trialinfo==15 | fft_pred.trialinfo==25 |fft_pred.trialinfo==35 | fft_pred.trialinfo==45);
            cfg.avgoverfreq='yes'; %averaging over frequencies
            cfg.avgoverchan = 'yes'; %averaging over the channels
            cfg.channel= area_interest;
            cfg.frequency = freq_of_interest;
            high2= ft_selectdata(cfg, fft_pred);
            DF(end+1,:)={Subjects(x).name(1:9),5,mean(high2.powspctrm)};

            cfg = [];
            cfg.trials=find(fft_pred.trialinfo==16 | fft_pred.trialinfo==26 |fft_pred.trialinfo==36 | fft_pred.trialinfo==46);
            cfg.avgoverfreq='yes'; %averaging over frequencies
            cfg.avgoverchan = 'yes'; %averaging over the channels
            cfg.channel= area_interest;
            cfg.frequency = freq_of_interest;
            det= ft_selectdata(cfg, fft_pred);
            DF(end+1,:)={Subjects(x).name(1:9),6,mean(det.powspctrm)};
            
            
            %% Creation of an Unique structure for all the subjects
            if area==1 && range==1
                %selecting data for all freq and area
                cfg = [];
                cfg.channel= [channels.motor, channels.occipital];
                cfg.frequency = 'all';
                tot= ft_selectdata(cfg, fft_pred);

                if exist('db') ~= 1
                    db = tot; 
                elseif exist('db') == 1
                    cfg=[];
                    db = ft_appendfreq(cfg,db,tot);
                end
            end
        
            clear fft_pred cfg x fix low medium1 medium2 high1 high2 det
        end
        save('U:\Desktop\Baby_BRAIN\Projects\EEG_probabilities_adults\Data\Raw data\Neural\Saved_steps\Prediction\Clean_prediction.mat','db')

        
        DF(1,:)=[];
        writetable(DF,['U:\Desktop\Baby_BRAIN\Projects\EEG_probabilities_adults\Data\Raw data\Neural\Saved_steps\Prediction\Clean_Prediction_'...
            names_area{area} '_' names_freq{range} '.csv'],'Delimiter',',');
    end
end
display(['THE AVERAGE NUMBER OF TRIALS IS ' num2str(mean(trials))])


%% ========================% barplot frequencies %======================= %%
mean_power = ([mean(mean(log(fix.powspctrm))),...
    mean(mean(log(low.powspctrm))),...
    mean(mean(log(medium1.powspctrm))), mean(mean(log(medium2.powspctrm))),...
    mean(mean(log(high1.powspctrm))), mean(mean(log(high2.powspctrm))),...
    mean(mean(log(det.powspctrm)))]);

sem_power = [std(mean(log(fix.powspctrm)))/sqrt(length(mean(log(fix.powspctrm)))),...
    std(mean(log(low.powspctrm)))/sqrt(length(mean(log(low.powspctrm)))),...
    std(mean(log(medium1.powspctrm)))/sqrt(length(mean(log(medium1.powspctrm)))),...
    std(mean(log(medium2.powspctrm)))/sqrt(length(mean(log(medium2.powspctrm)))),...
    std(mean(log(high1.powspctrm)))/sqrt(length(mean(log(high1.powspctrm)))),...
    std(mean(log(high2.powspctrm)))/sqrt(length(me\an(log(high2.powspctrm)))),...
     std(mean(log(det.powspctrm)))/sqrt(length(mean(log(det.powspctrm))))];

XTick=[1,3,5,6,8,9,11];

figure
hold on
for x =1:length(mean_power)
   h= bar(XTick(x),mean_power(x));
   er = errorbar(XTick(x),mean_power(x),sem_power(x),'.');
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
