function PlotProfileGrid(GridProfile,PercentileDown,PercentileUp,varargin)

% Parse optional inputs
p = inputParser;

addParameter(p, 'Color', '#000000', @ischar);
addParameter(p, 'ShadingColor', '#8F8F8F', @ischar);
isAxes = @(x) isempty(x) || isa(x, 'matlab.graphics.axis.Axes');
addParameter(p, 'Axes', [], isAxes);
addParameter(p, 'Tag', "", @isstring)

% Parse inputs
parse(p, varargin{:});

ax = p.Results.Axes;

% Se non specificato, crea un nuovo geoaxes
if isempty(ax)
    figure;
    ax = axes;
end

DownValues=zeros(length(GridProfile),1);
UpValues=zeros(length(GridProfile),1);
MedianValues=zeros(length(GridProfile),1);
DistancesValues=zeros(length(GridProfile),1);

for i=1:length(GridProfile)
    DistancesValues(i)=GridProfile(i).Distance;
    values=GridProfile(i).Values;
    MedianValues(i) = prctile(values, 50);
    DownValues(i) = prctile(values, PercentileDown);
    UpValues(i) = prctile(values, PercentileUp);
end

BndValues=[DownValues;flip(UpValues);DownValues(1)];
DistBndValues=[DistancesValues;flip(DistancesValues);DistancesValues(1)];

Tag=p.Results.Tag;

%hold(ax, 'on');
if(Tag=="")
    patch(ax, DistBndValues, BndValues,'w','FaceColor', p.Results.ShadingColor ,'EdgeColor',p.Results.ShadingColor,'FaceAlpha', 0.3)
    plot(ax,DistancesValues,MedianValues, 'Color',p.Results.Color)
else
    patch(ax, DistBndValues, BndValues, 'w', 'FaceColor',p.Results.ShadingColor ,'EdgeColor',p.Results.ShadingColor,'FaceAlpha', 0.3, 'Tag', Tag)
    plot(ax,DistancesValues,MedianValues, 'Color',p.Results.Color,'Tag',Tag)
end
%hold(ax, 'off');
axis(ax, 'auto');

end

