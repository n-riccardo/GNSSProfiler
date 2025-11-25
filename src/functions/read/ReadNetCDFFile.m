function [NetCDFame,LonScalarF,LatScalarF,GridVe,GridVn,GridVu]=ReadNetCDFFile(fullFileName)

[~,nameWOext,ext] = fileparts(fullFileName);

disp(ext)
NetCDFame=string(nameWOext)+string(ext);

LonScalarF=ncread(fullFileName,'lon');
LatScalarF=ncread(fullFileName,'lat');

GridVe=ncread(fullFileName,'Ve');
GridVn=ncread(fullFileName,'Vn');

info = ncinfo(fullFileName);
existsVertical = any(strcmp({info.Variables.Name}, 'Vu'));

if(existsVertical)
    GridVu=ncread(fullFileName,'Vu');
else
    GridVu=GridVe .* NaN;
end

end