function [ResultTable, trackInfo, poly, geopoly] = ComputeGNSSProfile(velo_data, w, start_end_points, varargin)
% COMPUTEGNSSPROFILE Computes GNSS velocity parallel and orthogonal profiles with uncertainties.
% This function processes velocity data along rhumb lines to analyze GNSS station velocities.
%
% Mandatory Inputs:
% 1. velo_data (table): Contains GNSS velocity data with the following fields:
%    - Long (Longitude)
%    - Lat (Latitude)
%    - E_Rate (Velocity in East direction)
%    - N_Rate (Velocity in North direction)
%    - U_Rate (Velocity in Up direction)
%    - x__E (Uncertainty in East direction)
%    - x__N (Uncertainty in North direction)
%    - x__U (Uncertainty in Up direction)
%
% 2. w (numeric): Half-width of the profile in kilometers.
%
% 3. start_end_points (vector): Defines the profile as [start_Long, start_Lat, end_Lon, end_Lat].
%
% Optional Name-Value Pair Arguments:
% - 'Npoints_GMT' (numeric, default = 500): Number of points defining the rectangular area.
% - 'StationNames' (vector, default = []): Names of GNSS stations.
%
% Dependencies:
% - Requires the function 'compute_tracks_mat'.
%
% Author: Riccardo Nucci (riccardo.nucci4@unibo.it)
% Last updated: 24/01/2025

%% Input Parsing
p = inputParser;
addRequired(p, 'velo_data', @istable);
addRequired(p, 'w', @isnumeric);
addRequired(p, 'start_end_points', @isnumeric);
addParameter(p, 'Npoints_GMT', 500, @isnumeric);
addParameter(p, 'StationNames', [], @isvector);
parse(p, velo_data, w, start_end_points, varargin{:});

% Extract parsed values
Npoints_GMT = p.Results.Npoints_GMT;
StationNames = string(p.Results.StationNames);

%% Reference Sphere Definition (WGS84)
reference_earth = referenceEllipsoid('earth');
reference_earth.LengthUnit = 'kilometer';

%% Extract GNSS Data
x_data = velo_data.Long;
y_data = velo_data.Lat;
ve_data = velo_data.E_Rate;
vn_data = velo_data.N_Rate;
vu_data = velo_data.U_Rate;
se_data = velo_data.x__E;
sn_data = velo_data.x__N;
su_data = velo_data.x__U;

%% Compute Track Information
trackInfo = Compute_tracks_mat(w, start_end_points, Npoints_GMT, NaN, "");
lat_rect = trackInfo.lat_rect;
lon_rect = trackInfo.lon_rect;
azimuth_ = trackInfo.azimuth;
geopoly = geopolyshape(lat_rect, lon_rect);

%% Identify Stations Within Rectangle
stations_geo = geopointshape(y_data, x_data);
indices = isinterior(geopoly, stations_geo);

% Filter data for stations inside the profile area
x_data_cut = x_data(indices);
y_data_cut = y_data(indices);
ve_data_cut = ve_data(indices);
vn_data_cut = vn_data(indices);
vu_data_cut = vu_data(indices);
se_data_cut = se_data(indices);
sn_data_cut = sn_data(indices);
su_data_cut = su_data(indices);

%% Compute Parallel and Orthogonal Velocity Components
dim_data_r = length(x_data_cut);
distances = zeros(dim_data_r, 1);
velocity_parallel_data = zeros(dim_data_r, 1);
sigma_parallel_data = zeros(dim_data_r, 1);
velocity_orthogonal_data = zeros(dim_data_r, 1);
sigma_orthogonal_data = zeros(dim_data_r, 1);

for i = 1:dim_data_r
    % Compute intersection point of rhumb lines
    [int_lat, int_lon] = rhxrh(y_data_cut(i), x_data_cut(i), azimuth_, start_end_points(2), start_end_points(1), azimuth_ - 90);
    
    % Compute distance from station to profile center
    distances(i) = distance('rh', [int_lat, int_lon], [y_data_cut(i), x_data_cut(i)], reference_earth);
    
    % Compute velocity components
    velocity_parallel_data(i) = ve_data_cut(i) * sind(azimuth_) + vn_data_cut(i) * cosd(azimuth_);
    velocity_orthogonal_data(i) = ve_data_cut(i) * cosd(azimuth_) - vn_data_cut(i) * sind(azimuth_);
    sigma_parallel_data(i) = sqrt(sind(azimuth_)^2 * se_data_cut(i)^2 + cosd(azimuth_)^2 * sn_data_cut(i)^2);
    sigma_orthogonal_data(i) = sqrt(cosd(azimuth_)^2 * se_data_cut(i)^2 + sind(azimuth_)^2 * sn_data_cut(i)^2);
end

%% Construct Output Table
if ~isempty(StationNames)
    StationNames_cut = StationNames(indices);
    ResultTable = table(distances, x_data_cut, y_data_cut, velocity_parallel_data, velocity_orthogonal_data, vu_data_cut, sigma_parallel_data, sigma_orthogonal_data, su_data_cut, StationNames_cut);
    ResultTable.Properties.VariableNames = {'Distances_km', 'Lon', 'Lat', 'Vpara', 'Vorth', 'Vu', 'Spara', 'Sorth', 'Su', 'Name'};
else
    ResultTable = table(distances, x_data_cut, y_data_cut, velocity_parallel_data, velocity_orthogonal_data, vu_data_cut, sigma_parallel_data, sigma_orthogonal_data, su_data_cut);
    ResultTable.Properties.VariableNames = {'Distances_km', 'Lon', 'Lat', 'Vpara', 'Vorth', 'Vu', 'Spara', 'Sorth', 'Su'};
end

%% Create Polygon for simple visualization
poly = polyshape(lon_rect, lat_rect);

end
