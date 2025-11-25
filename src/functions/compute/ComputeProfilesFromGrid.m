function [GridProfile, trackInfo, poly, geopoly] = ComputeProfilesFromGrid(grid_data, w, start_end_points, varargin)
% COMPUTEPROFILESFROMGRID Computes profiles and cross-sections from a scalar field on a geographical grid.
% This function works with rhumb lines and extracts data along a specified transect.
%
% Mandatory Inputs:
% 1. grid_data (struct): Contains the geographical grid with the following fields:
%    - Long (vector): Longitudes defining the grid
%    - Lat (vector): Latitudes defining the grid
%    - Val (matrix): Scalar field values (Lon along rows, Lat along columns)
%
% 2. w (numeric): Half-width of the profile in kilometers.
%
% 3. start_end_points (vector): Specifies the transect as [start_Long, start_Lat, end_Long, end_Lat].
%
% Optional Name-Value Pair Arguments:
% - 'SamplingDistOnTrack' (numeric, default = 10 km): Spacing between cross-profiles along the track.
% - 'SamplingDistCrossTrack' (numeric, default = 50): Number of points sampled within each cross-profile.
% - 'Npoints_GMT' (numeric, default = 500): Number of points defining the rectangular area.
% - 'Interpolation' (char, default='linear'): Specify the interpolation
%   scheme to be used when interpolating the scalar field along the
%   crossprofiles ('linear', 'nearest', 'cubic', 'makima', or 'spline')
%
% Dependencies:
% - Requires the function 'compute_tracks_mat'.
%
% Author: Riccardo Nucci (riccardo.nucci4@unibo.it)
% Last updated: 29/01/2025

%% Input Parsing
p = inputParser;
addRequired(p, 'grid_data', @isstruct);
addRequired(p, 'w', @isnumeric);
addRequired(p, 'start_end_points', @isnumeric);
addParameter(p, 'SamplingDistOnTrack', 10, @isnumeric);
addParameter(p, 'NSamplingCrossTrack', 50, @isnumeric);
addParameter(p, 'Npoints_GMT', 500, @isnumeric);
addParameter(p, 'Interpolation', 'linear', @ischar);
parse(p, grid_data, w, start_end_points, varargin{:});

% Extract parsed values
SamplingDistOnTrack = p.Results.SamplingDistOnTrack;
NSamplingCrossTrack = p.Results.NSamplingCrossTrack;
Npoints_GMT = p.Results.Npoints_GMT;
InterpScheme = p.Results.Interpolation;

%% Reference Sphere Definition (WGS84)
reference_earth = referenceEllipsoid('earth');
reference_earth.LengthUnit = 'kilometer';

%% Extract Grid Data
lonGrid = grid_data.Long;
latGrid = grid_data.Lat;
scalarValues = grid_data.Val;

%% Compute Track Information
trackInfo = Compute_tracks_mat(w, start_end_points, Npoints_GMT, NaN, "");
lat_rect = trackInfo.lat_rect;
lon_rect = trackInfo.lon_rect;
azimuth_ = trackInfo.azimuth;
geopoly = geopolyshape(lat_rect, lon_rect);

distance_vec = 0:SamplingDistOnTrack:(trackInfo.total_distance);

%% Initialize Output Structure
GridProfile = struct();

%% Loop Over Distances to Compute Cross-Profiles
for i = 1:length(distance_vec)
    tempDist = distance_vec(i);
    
    % Compute the center point of the cross-profile at tempDist
    [temp_lat, temp_lon] = track1('rh', start_end_points(2), start_end_points(1), azimuth_, tempDist, reference_earth, 'degrees', 1);
    
    % Compute the end points of the cross-section
    [temp_lat2, temp_lon2] = track1('rh', temp_lat, temp_lon, azimuth_ + 90, w, reference_earth, 'degrees', 1);
    [interpLat, interpLon] = track1('rh', temp_lat2, temp_lon2, azimuth_ - 90, 2 * w, reference_earth, 'degrees', NSamplingCrossTrack);
    
    % Interpolate scalar values along the cross-profile
    InterpValues = interp2(latGrid, lonGrid, scalarValues, interpLat, interpLon, InterpScheme);
    
    % Store results in GridProfile struct
    GridProfile(i).Values = InterpValues;
    GridProfile(i).Distance = tempDist;
    GridProfile(i).Lons = interpLon;
    GridProfile(i).Lats = interpLat;
end

%% Create Polygon for Visualization
poly = polyshape(lon_rect, lat_rect);

end
