%% cant get some communication working with the visadev command
% dont understand why
% tried different end of line's


resourceList = visadevlist
idx=find(resourceList.Model=="DSA815")
dev_name=resourceList.ResourceName(idx)

%%

v=visadev(dev_name)

%%
configureTerminator(v,"CR/LF")
resp=writeread(v,":TRACe:DATA? TRACE1");
   