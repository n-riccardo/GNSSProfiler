function ProfilePlot(distances, velocity_data, sigma_data, varargin)
%%ProfilePlot creates a customized profile plot

% Parse optional inputs
p = inputParser;

addParameter(p, 'Marker', '.', @ischar);
addParameter(p, 'Color', 'black', @ischar);
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

Tag=p.Results.Tag;

if(Tag=="")
    errorbar(ax,distances, velocity_data, sigma_data,'Marker',p.Results.Marker,'Color',p.Results.Color,'MarkerSize',10,'LineStyle', 'none')
else
    errorbar(ax,distances, velocity_data, sigma_data,'Marker',p.Results.Marker,'Color',p.Results.Color,'MarkerSize',10,'LineStyle', 'none',"Tag",Tag)   
end
axis(ax, 'auto');

end
