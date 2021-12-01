function sp=get_spectrum(v)
    fprintf(v,':TRACe:DATA? TRACE1');
    st_pow=fgets(v);
    idx = strfind(st_pow,' ');
    idx=idx(1);
    st_pow=st_pow(idx:end);
    pow=textscan( st_pow, '%f', 'Delimiter',',' );
    pow=pow{1};

    [f_low,f_up] =get_f_lims(v);
    freqs=transpose(linspace(f_low,f_up,numel(pow)));

    sp=[];
    sp.pow=pow;
    sp.freqs=freqs;
end