%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Preprocessing EEG prediction                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
info_var;
[Subject,Probability,Area,Frequency,Power]=deal({'0'},0,{'0'},{'0'},0); %creating table to store subject data

names_area=fieldnames(channels); %defining the area names
DF= table(Subject,Probability,Area,Frequency,Power);

for area =1:2
    %% Loop over areas
    area_interest=channels.(names_area{area});

    
    names_freq = fieldnames(Freq_peak); %defining the frequency names
    for range = 1:2
        %% Loop over frequencies
        freq_of_interest=Freq_peak.(names_freq{range}); 
        
        % Creating empty dataframe from emty values
                
        for x = 1:30%length(Subjects)
            %% Loop for subjects
            if not(ismember(Subjects(x).name(1:9),Rejected)) %check if the subject is rejected
                load(['Saved_steps\prediction\FFT_pred_',Subjects(x).name(1:9),'.mat'],'fft_pred');    

                cfg           = [];
                cfg.parameter = 'powspctrm';
                cfg.operation = 'log10';
                fft_pred    = ft_math(cfg, fft_pred);   %log transformation

                trials(x)=length(fft_pred.trialinfo); %number fo trials after rejection

                %checking for trail number rpoblems
                number_of_trials=num2str(fft_pred.trialinfo);
                number_of_trials=str2num(number_of_trials(:,end));
                [repetition,condition]=hist(number_of_trials,unique(number_of_trials));
                if length(find(repetition<16)) > 0
                    Subject_err(x)={Subjects(x).name(1:9)};
                    warning(['Subject ' Subjects(x).name(1:9) ' has been excluded, not enough trials']);
                end

                cfg = [];
                cfg.trials=find(fft_pred.trialinfo==50);
                cfg.avgoverfreq='yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel= area_interest;
                cfg.frequency = freq_of_interest;
                fix= ft_selectdata(cfg, fft_pred);
                DF(end+1,:)={Subjects(x).name(1:9),0,names_area{area},names_freq{range},mean(fix.powspctrm)};

                cfg = [];
                cfg.trials=find(fft_pred.trialinfo==11 | fft_pred.trialinfo==21 |fft_pred.trialinfo==31 | fft_pred.trialinfo==41);
                cfg.avgoverfreq='yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel= area_interest;
                cfg.frequency = freq_of_interest;
                low= ft_selectdata(cfg, fft_pred);
                DF(end+1,:)={Subjects(x).name(1:9),1,names_area{area},names_freq{range},mean(low.powspctrm)};

                cfg = [];
                cfg.trials=find(fft_pred.trialinfo==12 | fft_pred.trialinfo==22 |fft_pred.trialinfo==32 | fft_pred.trialinfo==42);
                cfg.avgoverfreq='yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel= area_interest;
                cfg.frequency = freq_of_interest;
                medium1= ft_selectdata(cfg, fft_pred);
                DF(end+1,:)={Subjects(x).name(1:9),2,names_area{area},names_freq{range},mean(medium1.powspctrm)};

                cfg = [];
                cfg.trials=find(fft_pred.trialinfo==13 | fft_pred.trialinfo==23 |fft_pred.trialinfo==33 | fft_pred.trialinfo==43);
                cfg.avgoverfreq='yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel= area_interest;
                cfg.frequency = freq_of_interest;
                medium2= ft_selectdata(cfg, fft_pred);
                DF(end+1,:)={Subjects(x).name(1:9),3,names_area{area},names_freq{range},mean(medium2.powspctrm)};

                cfg = [];
                cfg.trials=find(fft_pred.trialinfo==14 | fft_pred.trialinfo==24 |fft_pred.trialinfo==34 | fft_pred.trialinfo==44);
                cfg.avgoverfreq='yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel= area_interest;
                cfg.frequency = freq_of_interest;
                high1= ft_selectdata(cfg, fft_pred);
                DF(end+1,:)={Subjects(x).name(1:9),4,names_area{area},names_freq{range},mean(high1.powspctrm)};

                cfg = [];
                cfg.trials=find(fft_pred.trialinfo==15 | fft_pred.trialinfo==25 |fft_pred.trialinfo==35 | fft_pred.trialinfo==45);
                cfg.avgoverfreq='yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel= area_interest;
                cfg.frequency = freq_of_interest;
                high2= ft_selectdata(cfg, fft_pred);
                DF(end+1,:)={Subjects(x).name(1:9),5,names_area{area},names_freq{range},mean(high2.powspctrm)};

                cfg = [];
                cfg.trials=find(fft_pred.trialinfo==16 | fft_pred.trialinfo==26 |fft_pred.trialinfo==36 | fft_pred.trialinfo==46);
                cfg.avgoverfreq='yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel= area_interest;
                cfg.frequency = freq_of_interest;
                det= ft_selectdata(cfg, fft_pred);
                DF(end+1,:)={Subjects(x).name(1:9),6,names_area{area},names_freq{range},mean(det.powspctrm)};


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
        end
%          save('U:\Desktop\Baby_BRAIN\Projects\EEG_probabilities_adults\Data\Raw data\Neural\Saved_steps\Prediction\Clean_prediction.mat','db')

    end
end
DF(1,:)=[];
writetable(DF,['U:\Desktop\Baby_BRAIN\Projects\EEG_probabilities_adults\Data\Raw data\Neural\Saved_steps\Prediction\'...
    'Clean_prediction.csv'],'Delimiter',',');

display(['THE AVERAGE NUMBER OF TRIALS IS ' num2str(mean(trials))])
display(['BAD SUBJECTS: ' Subject_err])


