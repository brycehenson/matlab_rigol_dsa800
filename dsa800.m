classdef dsa800 < handle
    % matlab instrument class for rigol dsa800 spectrum analysers
    % Bryce Henson 2021-12-01
    % Bugs:
    % our rigol dsa815 does not respond to the command
    % ':TRACe1:MODE?'
    properties
        inst_handle
        freq_start  {mustBeNumeric}
        freq_stop   {mustBeNumeric}
        freq_cen    {mustBeNumeric}
        freq_span   {mustBeNumeric}
        sweep_time  {mustBeNumeric}
        auto_sweep_time (1, 1) logical = true
        freq_rbw    {mustBeNumeric}
        auto_rbw    (1, 1) logical = true
        freq_vbw    {mustBeNumeric}
        auto_vbw    (1, 1) logical = true
        det_type    {mustBeText}= ''
        param_coupling (1, 1) logical = true
        % the manual defines this as the copupling relationships between 
            %CF step 
            %Reference level 
            %Input attenuation 
            %Resolution bandwidth (RBW) 
            %Video bandwidth (VBW) 
            %Sweep time
        trace_num {mustBeNumeric}=1
        trace_mode {mustBeText}= ''
        trace_avg_count {mustBeInteger}
    end
    properties (SetAccess = private)
        trace_avg_curr
    end
    properties (Dependent)
        spectrum
    end
    properties (SetAccess = immutable)
        freq_bounds
        valid_freq_rbw
        valid_freq_vbw
        valid_det_type
        valid_trace_mode
    end
    methods
        function obj = dsa800()
            resourceList = visadevlist;
            idx=find(resourceList.Model=="DSA815");
            dev_name=resourceList.ResourceName(idx);
            v=visa('NI',dev_name);
            v.InputBufferSize=20000;
            v.Timeout=1; %go fast
            fopen(v);
            obj.inst_handle=v;

            obj.freq_bounds=[0,1.5e9];

            % valid freq_rbw freqs
            magnitudes=10.^(1:6);
            obj.valid_freq_rbw=[magnitudes,magnitudes(1:end-1)*3];
            obj.valid_freq_rbw=sort(obj.valid_freq_rbw);

            magnitudes=10.^(0:6);
            obj.valid_freq_vbw=[magnitudes,magnitudes*3];
            obj.valid_freq_vbw=sort(obj.valid_freq_rbw);

            obj.valid_det_type={'NEG', 'NORM', 'POS', 'RMS', 'SAMP', 'VAV', 'QPEAK'};
            obj.valid_trace_mode={'WRIT', 'MAXH', 'MINH', 'VIEW', 'BLANK', 'VID', 'POW'};
        end
        
        % sweep time
        function set.sweep_time(obj,t_sweep)
            fprintf(obj.inst_handle,':SWEep:TIME %f',t_sweep);
        end
        function sweep_time=get.sweep_time(obj)
            fprintf(obj.inst_handle,':SWEep:TIME?');
            st=fgets(obj.inst_handle);
            sweep_time=str2num(st);
        end


        % parameter coupling
        function set.auto_sweep_time(obj,in_val)
            if ~islogical(in_val)
                error('input must be logical')
            end
            if in_val
                in_str='1';
            else
                in_str='0';
            end
            fprintf(obj.inst_handle,'SWEep:TIME:AUTO %s',in_str);
        end
        function val=get.auto_sweep_time(obj)
            fprintf(obj.inst_handle,'SWEep:TIME:AUTO?');
            string=fgets(obj.inst_handle);
            string=strip(string);
            if strcmp(string,'1')
                val=true;
            elseif strcmp(string,'0')
                val=false;
            else
                error('string invalid %s',string)
            end
        end



        % start frequency
        function set.freq_start(obj,in_freq_start)
            if in_freq_start<obj.freq_bounds(1) || in_freq_start>obj.freq_bounds(2)
                error('input freq out of bounds')
            end
            fprintf(obj.inst_handle,':FREQuency:STARt %f',in_freq_start)
        end
        function freq_start=get.freq_start(obj)
            fprintf(obj.inst_handle,':FREQuency:STARt?');
            st_freq_start=fgets(obj.inst_handle);
            freq_start=str2num(st_freq_start);
        end

        % stop frequency
        function set.freq_stop(obj,in_freq_stop)
            if in_freq_stop<obj.freq_bounds(1) || in_freq_stop>obj.freq_bounds(2)
                error('input freq out of bounds')
            end
            fprintf(obj.inst_handle,':FREQuency:STOP %f',in_freq_stop);
        end
        function freq_stop=get.freq_stop(obj)
            fprintf(obj.inst_handle,':FREQuency:STOP?');
            st_freq_stop=fgets(obj.inst_handle);
            freq_stop=str2num(st_freq_stop);
        end

        % center freq
        function set.freq_cen(obj,in_freq_cen)
            if in_freq_cen<obj.freq_bounds(1) || in_freq_cen>obj.freq_bounds(2)
                error('input freq out of bounds')
            end
            fprintf(obj.inst_handle,':FREQuency:CENTer %f',in_freq_cen);
        end
        function val=get.freq_cen(obj)
            fprintf(obj.inst_handle,':FREQuency:CENTer?');
            string=fgets(obj.inst_handle);
            val=str2num(string);
        end

        % freq span
        function set.freq_span(obj,in_val)
            if in_val<1 || in_val>diff(obj.freq_bounds)
                error('input freq out of bounds')
            end
            fprintf(obj.inst_handle,':FREQuency:SPAN  %f',in_val);
        end
        function val=get.freq_span(obj)
            fprintf(obj.inst_handle,':FREQuency:SPAN?');
            string=fgets(obj.inst_handle);
            val=str2num(string);
        end

        % parameter coupling
        function set.param_coupling(obj,in_val)
            if ~islogical(in_val)
                error('input must be logical')
            end
            if in_val
                cpl_str='ALL';
            else
                cpl_str='NONE';
            end
            fprintf(obj.inst_handle,':COUPle  %s',cpl_str);
        end
        function val=get.param_coupling(obj)
            fprintf(obj.inst_handle,':COUPle?');
            string=fgets(obj.inst_handle);
            string=strip(string);
            if strcmp(string,'ALL')
                val=true;
            elseif strcmp(string,'NONE')
                val=false;
            else
                error('string invalid %s',string)
            end
        end
        
       % 
       % freq_rbw
        function set.freq_rbw(obj,in_freq_rbw)
            if ~any(ismember(in_freq_rbw,obj.valid_freq_rbw))
                error('freq_rbw not set must specity one of the values in valid_freq_rbw')
            end
            fprintf(obj.inst_handle,':BANDwidth %f',in_freq_rbw);
        end
        function val=get.freq_rbw(obj)
            fprintf(obj.inst_handle,':BANDwidth?');
            string=fgets(obj.inst_handle);
            val=str2num(string);
        end

        % 
        % auto rbw
        function set.auto_rbw(obj,in_val)
            if ~islogical(in_val)
                error('input must be logical')
            end
            if in_val
                cpl_str='ON';
            else
                cpl_str='OFF';
            end
            fprintf(obj.inst_handle,':BANDwidth:AUTO  %s',cpl_str);
        end
        function val=get.auto_rbw(obj)
            fprintf(obj.inst_handle,':BANDwidth:AUTO?');
            string=fgets(obj.inst_handle);
            string=strip(string);
            if strcmp(string,'1')
                val=true;
            elseif strcmp(string,'0')
                val=false;
            else
                error('string invalid %s',string)
            end
        end


        % freq_vbw
        function set.freq_vbw(obj,in_freq_vbw)
            if ~any(ismember(in_freq_vbw,obj.valid_freq_rbw))
                error('freq_rbw not set must specity one of the values in valid_freq_rbw')
            end
            fprintf(obj.inst_handle,':BANDwidth:VIDeo %f',in_freq_vbw);
        end
        function val=get.freq_vbw(obj)
            fprintf(obj.inst_handle,':BANDwidth:VIDeo?');
            string=fgets(obj.inst_handle);
            val=str2num(string);
        end

        % 
        % auto vbw
        function set.auto_vbw(obj,in_val)
            if ~islogical(in_val)
                error('input must be logical')
            end
            if in_val
                cpl_str='ON';
            else
                cpl_str='OFF';
            end
            fprintf(obj.inst_handle,':BANDwidth:VIDeo:AUTO  %s',cpl_str);
        end
        function val=get.auto_vbw(obj)
            fprintf(obj.inst_handle,':BANDwidth:VIDeo:AUTO?');
            string=fgets(obj.inst_handle);
            string=strip(string);
            if strcmp(string,'1')
                val=true;
            elseif strcmp(string,'0')
                val=false;
            else
                error('string invalid %s',string)
            end
        end


        function set.det_type(obj,in_det_type)
            if ~any(ismember(in_det_type,obj.valid_det_type))
                error('detector tpype not validmust specity one of the values in valid_det_type')
            end
            fprintf(obj.inst_handle,':DETector %s',in_det_type);
        end
        function string=get.det_type(obj)
            fprintf(obj.inst_handle,':DETector?');
            string=fgets(obj.inst_handle);
            string=strip(string);
             if ~any(ismember(string,obj.valid_det_type))
                error('read value is not one of the valid types')
            end
        end

        % trace_avg_count
        function set.trace_avg_count(obj,in_avg_count)
            if in_avg_count>=1000 || in_avg_count<=1
                error('input freq out of bounds')
            end
            fprintf(obj.inst_handle,'TRACe:AVERage:COUNt %u',in_avg_count)
        end
        function val=get.trace_avg_count(obj)
            fprintf(obj.inst_handle,'TRACe:AVERage:COUNt?');
            st_val=fgets(obj.inst_handle);
            val=str2num(st_val);
        end

        function val=get.trace_avg_curr(obj)
            fprintf(obj.inst_handle,':TRACe:AVERage:COUNt:CURRent?');
            st_val=fgets(obj.inst_handle);
            val=str2num(st_val);
        end
        

        % spectrum
        function sp=get.spectrum(obj)
            fprintf(obj.inst_handle,':TRACe:DATA? TRACE1');
            st_pow=fgets(obj.inst_handle);
            % remove the header
            idx = strfind(st_pow,' ');
            idx=idx(1);
            st_pow=st_pow(idx:end);
            pow=textscan( st_pow, '%f', 'Delimiter',',' );
            pow=pow{1};
        
            freqs=transpose(linspace(obj.freq_start,obj.freq_stop,numel(pow)));
            sp=[];
            sp.pow=pow;
            sp.freqs=freqs;

        end

        function reset_avg(obj)
            fprintf(obj.inst_handle,':TRACe:AVERage:RESet');
        end

        

        function set.trace_mode(obj,in_det_type)
            if ~any(ismember(in_det_type,obj.valid_trace_mode))
                error('trace mode must be one of the values in valid_trace_mode')
            end
            cmd=sprintf(':TRACe%u:MODE %s',obj.trace_num,in_det_type);
            fprintf(obj.inst_handle,cmd);
        end
        function string=get.trace_mode(obj)
            % cant get  the query to work
%             cmd=sprintf(':TRACe%u:MODE?',obj.trace_num)
%             fprintf(obj.inst_handle,cmd)
%             string=fgets(obj.inst_handle)
            %%
%             fprintf(obj.inst_handle,':TRACe1:MODE?');
%             string=fgets(obj.inst_handle)
            %%
%             string=strip(string);
%              if ~any(ismember(string,obj.valid_trace_mode))
%                 error('read value is not one of the valid types')
%             end
            string='NOT WORKING';
        end
    end
    methods
        function delete(obj)
            fclose(obj.inst_handle);
            delete(obj.inst_handle)
        end
   end
end