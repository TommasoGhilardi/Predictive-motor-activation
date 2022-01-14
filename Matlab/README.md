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

-----------------

## Triggers definition

256 possible:<br/>

- Action Observation
    - 1 number alone define first blank toy and its orientation or additional
        - 1 orientation
        - 2 orientation
        - 3 orientation
        - 4 orientation
        - 5 fixation cross

    - 2 numbers identify second blank [predictive windows] orientation
      - 11 orientation 1 and [25%] of transitional probability
      - 12 orientation 1 and [50%] of transitional probability + high entropy [50%+25%+25%= 1.5]
      - 13 orientation 1 and [50%] of transitional probability + low entropy [50%+50% = 1]
      - 14 orientation 1 and [75%] of transitional probability + high entropy [75%+12.5%+12.5% =1.06] 
      - 15 orientation 1 and [75%] of transitional probability + low entropy [75%+25% = 0.86]
      - 16 orientation 1 and [100%] 
      - [...]
      - 23 orientation 2 and [50%] of transitional probability + high entropy [50%+25%+25%= 1.5]
      - 34 orientation 3 and [75%] of transitional probability + low entropy [75%+25% = 1.06]
      - 41 orientation 4 and [25%] of transitional probability


    - 3 numbers identify action occurrence, orientation and type of action
      - 123 first action of the pair in orientation 2 and action number 3
      - 245 second action of the pair orientation 4 and action number 5
      - 132 first action of the pair in orientation 3 and action number 2
      - 214 second action of the pair in orientation 1 and action number 4

    - Specific numbers:
      - 50 fixation cross
      - 60 attention catcher  
<br/>

- Action Execution
    - 100 action execution stop
    - 101 start action open
    - 102 start action push
    - 103 start action slide
    - 104 start action spin
    - 105 start action squeeze
    - 106 start action tilt
