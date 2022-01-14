# Matlab

Code used to perform frequency analysis on adults EEG data.
The script rely on [Fieltrip](http://www.fieldtriptoolbox.org/) toolbox to compute the analysis.

The analysis is divided in two parts:
- the first relative to the extraction of the sample specific mu and beta roladic rythms during an action execution task
- the second relative to the analysis during the observation adn rpediciton of actions

Files:
- Functions_##.m                  = contain fucntion that will be called by the Preprocessing_##.m scripts.
- Preprocessing_##.m              = basic prerocessing and ICA of the EEG data 
- Main_##.m                       = extract log-normalized index of freequency power
- Info_var.m                      = contain general information valid both for Functions/Preprocessing/Main
- trial_fun_##.m                  = allow specific epochs segmentation
