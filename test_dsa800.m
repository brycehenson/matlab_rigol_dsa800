if exist('sa','var')
    delete(sa)
    clear('sa')
end


sa=dsa800;


%%
new_sweep_time=rand(1,1)*2;
sa.sweep_time
sa.sweep_time=new_sweep_time;
if abs(sa.sweep_time-new_sweep_time)>new_sweep_time/1e3
    error('sweep time readback failed')
end

%%
new_stop_freq=rand(1,1)*1e6+100e6;
sa.freq_stop=new_stop_freq;
if abs(sa.freq_stop-new_stop_freq)>1e3
    error('sweep time readback failed')
end


%%
new_start_freq=rand(1,1)*1e6+120e6;
sa.freq_start=new_start_freq;
if abs(sa.freq_start-new_start_freq)>1e3
    error('sweep time readback failed')
end

%%
new_val=rand(1,1)*10e6+120e6;
sa.freq_cen=new_val;
if abs(sa.freq_cen-new_val)>1e3
    error('sweep time readback failed')
end

%%

new_val=rand(1,1)*50e6;
sa.freq_span=new_val;
if abs(sa.freq_span-new_val)>1e3
    error('sweep time readback failed')
end

%%

sa.freq_rbw=300;

%%
sa.auto_rbw=true;
assert(sa.auto_rbw)
sa.auto_rbw=false;
assert(~sa.auto_rbw)

%%
sa.det_type='POS';

%%
sa.trace_mode='POW'
sa.trace_mode='WRIT';
%%
sa.trace_avg_count=3;
sa.trace_avg_curr

%%
sa.freq_start=120e6
sa.freq_stop=100e6
spectrum=sa.spectrum

spectrum=sa.spectrum
plot(sp.freqs*1e-6,sp.pow)
%%


%%
delete(sa)
clear('sa')