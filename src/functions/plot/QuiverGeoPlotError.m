function QuiverGeoPlotError(lon, lat, ve, vn, sigmax, sigmay, rho, scale, varargin)
%%Plot a vector field with error ellipses in a geoplot. It serves as proxy
%%for quiver in such a situation (the compromise is lower performances)
%%*
%%Mandatory arguments are: lon, lat, ve, vn, sigmax, sigmay, rho, scale
%%*
%%Optional arguments are: coverage, angle, LineWidth, Color, Axes
%%*
%%Additional notes:
% Last check on 14/06/25
%%*
%%Author: Riccardo Nucci (riccardo.nucci4@unibo.it)

% Create input parser
p = inputParser;
% Add required arguments

addRequired(p, 'lon', @isvector);
addRequired(p, 'lat', @isvector);
addRequired(p, 've', @isvector);
addRequired(p, 'vn', @isvector);
addRequired(p, 'sigmax', @isvector);
addRequired(p, 'sigmay', @isvector);
addRequired(p, 'rho', @isvector);
addRequired(p, 'scale', @isnumeric);

% Add optional name-value pairs
addParameter(p, 'coverage', 2.4477, @isnumeric);
addParameter(p, 'angle', 70, @isnumeric);
addParameter(p, 'LineWidth', 1.5, @isnumeric);
addParameter(p, 'Color', 'blue', @ischar);
addParameter(p, 'ColorEllipse', 'red', @ischar);

isGeoAxes = @(x) isempty(x) || isa(x, 'matlab.graphics.axis.GeographicAxes');
addParameter(p, 'Axes', [], isGeoAxes);
addParameter(p, 'Tag', "", @(x) ischar(x) || isstring(x))

% Parse inputs
parse(p, lon, lat, ve, vn, sigmax, sigmay, rho, scale, varargin{:});

% Retrieve results
coverage = p.Results.coverage;
arrowAngle=p.Results.angle;
LineWidth=p.Results.LineWidth;
Color=p.Results.Color;
ColorEllipse=p.Results.ColorEllipse;
ax = p.Results.Axes;
Tag=p.Results.Tag;

% Se non specificato, crea un nuovo geoaxes
if isempty(ax)
    figure;
    ax = geoaxes;
end

% Constants and initialization
R = 1;

% Working with the cartesian coordinates of the map projection
x_start = R * (lon * pi / 180);
y_start = R * log(tan(pi / 4 + (lat * pi / 180) / 2));
x_end = x_start + ve * scale;
y_end = y_start + vn * scale;

% Precompute angles and lengths
arrowLengths = 0.2 * sqrt((x_end - x_start).^2 + (y_end - y_start).^2);
angles = atan2(y_end - y_start, x_end - x_start);
angles(angles<0) = angles(angles<0) + 2*pi;
tangent_vectors = [(-sin(angles))'; (cos(angles))'];

% Rotation matrices
R1 = [cosd(arrowAngle), -sind(arrowAngle); sind(arrowAngle), cosd(arrowAngle)];
R2 = [cosd(180 - arrowAngle), -sind(180 - arrowAngle); sind(180 - arrowAngle), cosd(180 - arrowAngle)];

% Loop through each vector

ellipsesLat = [];
ellipsesLon = [];
linevectorsLat = [];
linevectorsLon = [];
arrows1Lat = [];
arrows1Lon = [];
arrows2Lat = [];
arrows2Lon = [];

for i = 1:length(lon)
    % Arrowheads
    arrow1vector = [x_end(i); y_end(i)] + arrowLengths(i) * R1 * tangent_vectors(:, i);
    arrow2vector = [x_end(i); y_end(i)] + arrowLengths(i) * R2 * tangent_vectors(:, i);

    % Covariance matrix and ellipse points
    cov_matrix = [sigmax(i)^2, rho(i) * sigmax(i) * sigmay(i); rho(i) * sigmax(i) * sigmay(i), sigmay(i)^2];
    [eig_vec, eig_val] = eig(cov_matrix);
    theta = linspace(0, 2 * pi, 25);
    ellipse_points = eig_vec * sqrt(eig_val) * [cos(theta); sin(theta)];

    % Ellipse coordinates
    ellipse_x = x_end(i) + ellipse_points(1, :) * coverage * scale;
    ellipse_y = y_end(i) + ellipse_points(2, :) * coverage * scale;
    ellipse_lon = ellipse_x * (180 / pi) / R;
    ellipse_lat = (2 * atan(exp(ellipse_y / R)) - pi / 2) * 180 / pi;
    ellipsesLat = [ellipsesLat, [ellipse_lat, NaN]];
    ellipsesLon = [ellipsesLon, [ellipse_lon, NaN]];

    % Convert to lat-lon coordinates
    begin_latlon = [(2 * atan(exp(y_start(i) / R)) - pi / 2) * 180 / pi, x_start(i) * (180 / pi) / R];
    end_latlon = [(2 * atan(exp(y_end(i) / R)) - pi / 2) * 180 / pi, x_end(i) * (180 / pi) / R];

    linevectorsLat=[linevectorsLat,begin_latlon(1),end_latlon(1),NaN];
    linevectorsLon=[linevectorsLon,begin_latlon(2),end_latlon(2),NaN];

    arrow1_latlon = [(2 * atan(exp(arrow1vector(2) / R)) - pi / 2) * 180 / pi, arrow1vector(1) * (180 / pi) / R];
    arrow2_latlon = [(2 * atan(exp(arrow2vector(2) / R)) - pi / 2) * 180 / pi, arrow2vector(1) * (180 / pi) / R];

    arrows1Lat=[arrows1Lat, end_latlon(1), arrow1_latlon(1), NaN];
    arrows1Lon=[arrows1Lon, end_latlon(2), arrow1_latlon(2), NaN];
    arrows2Lat=[arrows2Lat, end_latlon(1), arrow2_latlon(1), NaN];
    arrows2Lon=[arrows2Lon, end_latlon(2), arrow2_latlon(2), NaN];
    
end

% Plot the ellipse and the vector with arrowheads
if(Tag=="")
    plot(ax,ellipsesLat, ellipsesLon, 'Color', ColorEllipse, 'LineWidth',LineWidth);
    geoplot(ax,linevectorsLat, linevectorsLon, 'Color', Color, 'LineWidth', LineWidth); % Vector line
    geoplot(ax,arrows1Lat, arrows1Lon, 'Color', Color, 'LineWidth', LineWidth); % Arrowhead 1
    geoplot(ax,arrows2Lat, arrows2Lon, 'Color', Color, 'LineWidth', LineWidth); % Arrowhead 2
else
    plot(ax,ellipsesLat, ellipsesLon, 'Color', ColorEllipse, 'LineWidth',LineWidth,'Tag',Tag);
    geoplot(ax,linevectorsLat, linevectorsLon, 'Color', Color, 'LineWidth', LineWidth,'Tag',Tag); % Vector line
    geoplot(ax,arrows1Lat, arrows1Lon, 'Color', Color, 'LineWidth', LineWidth,'Tag',Tag); % Arrowhead 1
    geoplot(ax,arrows2Lat, arrows2Lon, 'Color', Color, 'LineWidth', LineWidth,'Tag',Tag); % Arrowhead 2
end

end