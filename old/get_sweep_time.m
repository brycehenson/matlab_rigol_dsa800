function sweep_time=get_sweep_time(v)
    fprintf(v,':SWEep:TIME?');
    st=fgets(v);
    sweep_time=str2num(st);
end