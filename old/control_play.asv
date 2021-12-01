resourceList = visadevlist
idx=find(resourceList.Model=="DSA815")
dev_name=resourceList.ResourceName(idx)
%%

%v = visadev(dev_name)
v=visa('NI',dev_name)
v.InputBufferSize=20000
v.Timeout=1; %go fast
fopen(v)

%%


%%
fprintf(v,"*IDN?");
fgets(v)

%%
tic
sp=get_spectrum(v)
plot(sp.freqs*1e-6,sp.pow)

%%
t_sweep=10;
fprintf(v,':SWEep:TIME %f',t_sweep)
pause(0.1)
fprintf(v,':SWEep:TIME?');
fgets(v)

%%
tic
set_f_lims(v,106e6,107e6,1)
toc
tic
set_f_lims(v,106e6,107e6,0)
toc

