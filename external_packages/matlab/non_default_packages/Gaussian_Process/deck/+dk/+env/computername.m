function h = computername()
    if ismac
        [~,h] = unix('scutil --get ComputerName');
    else
        [~,h] = unix('hostname -s'); % no difference in Linux systems
    end
    h = deblank(h);
end
