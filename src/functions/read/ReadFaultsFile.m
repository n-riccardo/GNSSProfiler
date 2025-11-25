function [FaultsName,FaultsLonLat]=ReadFaultsFile(fullFileName)

[~,nameWOext,ext] = fileparts(fullFileName);
FaultsName=nameWOext+ext;
faults=readtable(fullFileName,"FileType","text","NumHeaderLines",1);
FaultsLonLat=table2array(faults);

end