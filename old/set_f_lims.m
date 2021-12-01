function  set_f_lims(v,f_low,f_up,docheck)
    if f_low>f_up
        error('need f_low to be less than f_up')
    end 
    bounds=[0,1.5e9];
    if ~isempty(f_low)
        if f_low<bounds(1) || f_low>bounds(2)
            error('input freq out of bounds')
        end
        fprintf(v,':FREQuency:STARt %f',f_low);
    end

    if ~isempty(f_up)
        if f_up<bounds(1) || f_up>bounds(2)
            error('input freq out of bounds')
        end
        fprintf(v,':FREQuency:STOP %f',f_up);
    end
    
    if nargin<3 || isempty(docheck)
        docheck=0;
    end
    if docheck
        [read_low,read_up]=get_f_lims(v);
        % if not empty then check if the read back value is right
        if (~isempty(f_low)&& abs(read_low-f_low)>1) || ...
            (~isempty(f_up)&& abs(read_up-f_up)>1)
            error('read back did not return what was set')
        end
    end
    
end
