function [FaultsName,FaultsLonLat]=ReadFaultsFile(fullFileName)

[~,nameWOext,ext] = fileparts(fullFileName);
if(ext==".segment")
    FaultsLonLat=ReadSegment(char(fullFileName));
else
    faults=readtable(fullFileName,"FileType","text","NumHeaderLines",1);
    FaultsLonLat=table2array(faults);
end
FaultsName=nameWOext+ext;
end