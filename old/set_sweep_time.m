function set_sweep_time(v,t_sweep,docheck)
t_sweep=10;
fprintf(v,':SWEep:TIME %f',t_sweep)

if docheck
    if ~isequal(t_sweep,get_sweep_time(v))
        error('read back failed')
    end
end

end