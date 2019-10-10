function [trl] = your_trialfun_name1(cfg);
    event = ft_read_event('pilot_5.eeg');
    trl=[];
    for x = 3:(length(event)-1)
        if (str2num(event(x).value(2:end)))>80 && (str2num(event(x).value(2:end)))<87
            trlbegin = event(x).sample-500;
            trlend   = event(x).sample;
            offset = 0;
            newtrl   = [trlbegin trlend offset];
            trl      = [trl; newtrl];
        end        
    end
end