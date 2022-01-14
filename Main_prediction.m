%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             MAIN EEG prediction                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the directory to this script location
p = matlab.desktop.editor.getActiveFilename;
idcs = strfind(p,'\');
cd(p(1:idcs(end)-1));

info_var;

%% checking what you would like to extract
names_area = fieldnames(single_channles);
AREA = struct2cell(single_channles);

[Subject,Probability,Area,Frequency,Power] = deal({'0'},0,{'0'},{'0'},0); %creating table to store subject data
DF = table(Subject,Probability,Area,Frequency,Power);

%% LOOPS ON LOOOPS

for area = 1:length(names_area)
    %% Loop over areas
    area_interest = AREA{area};
    
    names_freq = fieldnames(Freq_peak); %defining the frequency names
    
    for range = 1:2
        %% Loop over frequencies
        freq_of_interest = Freq_peak.(names_freq{range}); 
                        
        for x = 1:length(Subjects)
            %% Loop for subjects
            if not(ismember(Subjects(x).name(1:6),Rejected)) %check if the subject is rejected
                load([output_dir '\prediction\FFT_pred_',Subjects(x).name(1:9),'.mat'],'fft_pred');    
                display(Subjects(x).name(1:9))
                
                %log transform
                cfg           = [];
                cfg.parameter = 'powspctrm';
                cfg.operation = 'log10';
                fft_pred      = ft_math(cfg, fft_pred);   %log transformation                      
                
                trials(x)=length(fft_pred.trialinfo); %number fo trials after rejection

                %checking for trail number rpoblems
                number_of_trials       = num2str(fft_pred.trialinfo);
                number_of_trials       = str2num(number_of_trials(:,end));
                [repetition,condition] = hist(number_of_trials,unique(number_of_trials));
                if length(find(repetition<10)) > 0
                    Subject_err(x) = {Subjects(x).name(1:9)};
                    warning(['Subject ' Subjects(x).name(1:9) ' has been excluded, not enough trials']);
                end

                %deterministic
                cfg = [];
                cfg.trials      = find(fft_pred.trialinfo==50);
                cfg.avgoverfreq = 'yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel     = area_interest;
                cfg.frequency   = freq_of_interest;
                fix             = ft_selectdata(cfg, fft_pred);
                
                Subject     = repmat({Subjects(x).name(1:9)},length(fix.powspctrm),1);
                Probability = repmat(0,length(fix.powspctrm),1);
                Area        = repmat({names_area{area}},length(fix.powspctrm),1);
                Frequency   = repmat({names_freq{range}},length(fix.powspctrm),1);
                Power       = fix.powspctrm;
                DF          = [DF;table(Subject,Probability,Area,Frequency,Power)];
                
                %low
                cfg = [];
                cfg.trials      = find(fft_pred.trialinfo==11 | fft_pred.trialinfo==21 |fft_pred.trialinfo==31 | fft_pred.trialinfo==41);
                cfg.avgoverfreq = 'yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel     = area_interest;
                cfg.frequency   = freq_of_interest;
                low             = ft_selectdata(cfg, fft_pred);
                
                Subject     = repmat({Subjects(x).name(1:9)},length(low.powspctrm),1);
                Probability = repmat(1,length(low.powspctrm),1);
                Area        = repmat({names_area{area}},length(low.powspctrm),1);
                Frequency   = repmat({names_freq{range}},length(low.powspctrm),1);
                Power       = low.powspctrm;
                DF          = [DF;table(Subject,Probability,Area,Frequency,Power)];
               
                %medium1
                cfg = [];
                cfg.trials      = find(fft_pred.trialinfo==12 | fft_pred.trialinfo==22 |fft_pred.trialinfo==32 | fft_pred.trialinfo==42);
                cfg.avgoverfreq = 'yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel     = area_interest;
                cfg.frequency   = freq_of_interest;
                medium1         = ft_selectdata(cfg, fft_pred);
                
                Subject     = repmat({Subjects(x).name(1:9)},length(medium1.powspctrm),1);
                Probability = repmat(2,length(medium1.powspctrm),1);
                Area        = repmat({names_area{area}},length(medium1.powspctrm),1);
                Frequency   = repmat({names_freq{range}},length(medium1.powspctrm),1);
                Power       = medium1.powspctrm;
                DF          = [DF;table(Subject,Probability,Area,Frequency,Power)];
               
                %medium2
                cfg = [];
                cfg.trials      = find(fft_pred.trialinfo==13 | fft_pred.trialinfo==23 |fft_pred.trialinfo==33 | fft_pred.trialinfo==43);
                cfg.avgoverfreq = 'yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel     = area_interest;
                cfg.frequency   = freq_of_interest;
                medium2         = ft_selectdata(cfg, fft_pred);
                
                Subject     = repmat({Subjects(x).name(1:9)},length(medium2.powspctrm),1);
                Probability = repmat(3,length(medium2.powspctrm),1);
                Area        = repmat({names_area{area}},length(medium2.powspctrm),1);
                Frequency   = repmat({names_freq{range}},length(medium2.powspctrm),1);
                Power       = medium2.powspctrm;
                DF          = [DF;table(Subject,Probability,Area,Frequency,Power)];

                %high1
                cfg = [];
                cfg.trials      = find(fft_pred.trialinfo==14 | fft_pred.trialinfo==24 |fft_pred.trialinfo==34 | fft_pred.trialinfo==44);
                cfg.avgoverfreq = 'yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel     = area_interest;
                cfg.frequency   = freq_of_interest;
                high1           = ft_selectdata(cfg, fft_pred);
                
                Subject     = repmat({Subjects(x).name(1:9)},length(high1.powspctrm),1);
                Probability = repmat(4,length(high1.powspctrm),1);
                Area        = repmat({names_area{area}},length(high1.powspctrm),1);
                Frequency   = repmat({names_freq{range}},length(high1.powspctrm),1);
                Power       = high1.powspctrm;
                DF          = [DF;table(Subject,Probability,Area,Frequency,Power)];
               
                %high2
                cfg = [];
                cfg.trials      = find(fft_pred.trialinfo==15 | fft_pred.trialinfo==25 |fft_pred.trialinfo==35 | fft_pred.trialinfo==45);
                cfg.avgoverfreq = 'yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel     = area_interest;
                cfg.frequency   = freq_of_interest;
                high2           = ft_selectdata(cfg, fft_pred);
                
                Subject     = repmat({Subjects(x).name(1:9)},length(high2.powspctrm),1);
                Probability = repmat(5,length(high2.powspctrm),1);
                Area        = repmat({names_area{area}},length(high2.powspctrm),1);
                Frequency   = repmat({names_freq{range}},length(high2.powspctrm),1);
                Power       = high2.powspctrm;
                DF          = [DF;table(Subject,Probability,Area,Frequency,Power)];
               
                %det
                cfg = [];
                cfg.trials      = find(fft_pred.trialinfo==16 | fft_pred.trialinfo==26 |fft_pred.trialinfo==36 | fft_pred.trialinfo==46);
                cfg.avgoverfreq = 'yes'; %averaging over frequencies
                cfg.avgoverchan = 'yes'; %averaging over the channels
                cfg.channel     = area_interest;
                cfg.frequency   = freq_of_interest;
                det             = ft_selectdata(cfg, fft_pred);
                
                Subject     = repmat({Subjects(x).name(1:9)},length(det.powspctrm),1);
                Probability = repmat(6,length(det.powspctrm),1);
                Area        = repmat({names_area{area}},length(det.powspctrm),1);
                Frequency   = repmat({names_freq{range}},length(det.powspctrm),1);
                Power       = det.powspctrm;
                DF          = [DF;table(Subject,Probability,Area,Frequency,Power)];
               

                clear fft_pred cfg x fix low medium1 medium2 high1 high2 det
            end
        end
    end
end
DF(1,:)=[]; %remove first empty line

writetable(DF,[output_dir '\Prediction\Single_Channel_Clean_prediction.csv'],'Delimiter',',');


display(['THE AVERAGE NUMBER OF TRIALS IS ' num2str(mean(trials))])
if exist('Subject_err')
    display(['BAD SUBJECTS: ' Subject_err])
end

