function [VeloName,TableVelo]=ReadGNSSVelo(fullFileName)
% Manage different file formats:

[~,nameWOext,ext] = fileparts(fullFileName);
VeloName=nameWOext+ext;

if(endsWith(char(fullFileName), '.sta.data'))
    veloStaData=readtable(fullFileName,"FileType","text","NumHeaderLines",1);
    Lon=veloStaData.Var1;
    Lat=veloStaData.Var2;
    Ve=veloStaData.Var3;
    Vn=veloStaData.Var4;
    Vu=nan(length(Lon),1);
    Se=veloStaData.Var5;
    Sn=veloStaData.Var6;
    Su=nan(length(Lon),1);
    Name=string(veloStaData.Var10);
    velocity=table(Lon,Lat,Ve,Vn,Vu,Se,Sn,Su,Name);
    velocity.Properties.VariableNames={'lon','lat','ve','vn','vu','se','sn','su','name'};
    TableVelo=velocity;
elseif(endsWith(char(fullFileName), '.sta'))
    veloSta=readtable(fullFileName,"FileType","text","NumHeaderLines",0);
    Lon=veloSta.Var1;
    Lat=veloSta.Var2;
    Ve=veloSta.Var3;
    Vn=veloSta.Var4;
    Vu=nan(length(Lon),1);
    Se=zeros(length(Lon),1);
    Sn=zeros(length(Lon),1);
    Su=zeros(length(Lon),1);
    Name=string(veloSta.Var10);
    velocity=table(Lon,Lat,Ve,Vn,Vu,Se,Sn,Su,Name);
    velocity.Properties.VariableNames={'lon','lat','ve','vn','vu','se','sn','su','name'};
    TableVelo=velocity;
else
    TableVelo=readtable(fullFileName,"FileType","text","NumHeaderLines",1);
    % Modify the variable names to be in a std form used by the
    % program:
    TableVelo.Properties.VariableNames={'lon','lat','ve','vn','vu','se','sn','su','name'};
    TableVelo.name=string(TableVelo.name);
end
end