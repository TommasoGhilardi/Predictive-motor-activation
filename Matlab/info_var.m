%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Variables to use  in the Scrip                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cap_conf = 'acticap-64ch-standard2.mat';

data_dir = 'U:\Baby_BRAIN\Projects\EEG_probabilities_adults\Data\Raw data\Bids';
output_dir = 'U:\Baby_BRAIN\Projects\EEG_probabilities_adults\Data\Raw data\Neural\Saved_steps';
Subjects = dir([data_dir '\**\*.eeg']); 

Rejected = {'S_UnPr_01','S_UnPr_10','S_UnPr_18','S_UnPr_25','S_UnPr_31'};

%% Triggers ID
Triggers.fixation_cross = 'S 50';

Triggers.predictive_window.low           = {'S 11','S 21','S 31','S 41'};
Triggers.predictive_window.medium1       = {'S 12','S 22','S 32','S 42'};
Triggers.predictive_window.medium2       = {'S 13','S 23','S 33','S 43'};
Triggers.predictive_window.high1         = {'S 14','S 24','S 34','S 44'};
Triggers.predictive_window.high2         = {'S 15','S 25','S 35','S 45'};
Triggers.predictive_window.deterministic = {'S 16','S 26','S 36','S 46'};
                        
Triggers.execution1 = {'S101','S102','S103','S104','S105','S106'};
Triggers.execution2 = {'S 81','S 82','S 83','S 84','S 85','S 86'};

%% Channels
channels.motor     = {'Cz','C3','C4'};
channels.occipital = {'Oz','O1','O2'};

single_channles.Cz ='CZ';
single_channles.C4 ='C4';
single_channles.C3 ='C3';
single_channles.Oz ='Oz';
single_channles.O1 ='O1';
single_channles.O2 ='O2';


%% Frequency
Freq_peak.mu   = [9 11];
Freq_peak.beta = [16 18];