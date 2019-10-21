function [trl,event] = your_trialfun_name(cfg);
    event = ft_read_event(cfg.dataset);
    diff=[];
    trl=[];
    for x = 4:(length(event)-1)
        if (str2num(event(x).value(2:end)))>100 && (str2num(event(x).value(2:end)))<107
            begin=event(x).sample;
            stop=event(x+1).sample;
            trlbegin = round(begin+(stop-begin-500)/2);
            trlend   = round(stop-(stop-begin-500)/2)-1;
            diff(x)  = trlend-trlbegin;
            offset   = 0;
            stimulus_value    = 100;
            newtrl   = [trlbegin trlend offset stimulus_value];
            trl      = [trl; newtrl];
            
            %baseline
            trlbegin_baseline = begin-499;
            trlend_baseline   = begin;
            stimulus_value    = 80;
            newtrl   = [trlbegin_baseline trlend_baseline offset stimulus_value];
            trl      = [trl; newtrl];
        end
    end
    mean_of_actions=mean(diff)/500;
end