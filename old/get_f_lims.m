function [f_low,f_up] =get_f_lims(v)
    fprintf(v,':FREQuency:STARt?');
    st_f_low=fgets(v);
    f_low=str2num(st_f_low);

    fprintf(v,':FREQuency:STOP?');
    st_f_up=fgets(v);
    f_up=str2num(st_f_up);
end
