function TrackPlotLonLat(distances, velocity_parallel, sigma_data, varargin)
%%ProfilePlot creates a customized profile plot
%   hFig = ProfilePlot(distances, velocity_data, sigma_data, 'Name', Value, ...)
%       distances, velocity_data, sigma_data: Data for the plot.
%       'Title': Plot title (string).
%       'XLabel': Label for the x-axis (string).
%       'YLabel': Label for the y-axis (string).

subplot(1, 3, 3);
geoplot(rectangle)
hold on
geoplot(stations_geo,'*r')
geoplot(stations_geo_cut,'*b')
geoplot(int_point_lat_vect,int_point_lon_vect,'*y')
title("Profile details")
%S_f_2=0.2;
%quiver(distances*sind(azimuth_),distances*cosd(azimuth_),ve_data_cut*S_f,vn_data_cut*S_f,'r','AutoScale','off')
for i=1:length(begin_lat_lon(:,1))
    plot_arrow_geoplot(begin_lat_lon(i,:),end_lat_lon(i,:),'b-')
end
geolimits([min(stations_geo_cut.Latitude)-1,max(stations_geo_cut.Latitude)+1], ...
    [min(stations_geo_cut.Longitude)-1,max(stations_geo_cut.Longitude)+1])


savefig(fig1, output_folder_GNSS+"/hor_velo.fig");


velocity_parallelN=velocity_parallel*cosd(azimuth_);
velocity_parallelE=velocity_parallel*sind(azimuth_);

% Parse optional inputs
p = inputParser;
addParameter(p, 'Title', "", @isstring);
addParameter(p, 'XLabel', "Distance (km)", @isstring);
addParameter(p, 'YLabel', "Velocity (mm/yr)", @isstring);
addParameter(p, 'Marker', '*b', @ischar);

parse(p, varargin{:});

errorbar(distances, velocity_data, sigma_data,p.Results.Marker)
hold on
title(p.Results.Title, 'FontSize', 14, 'FontWeight', 'bold')
xlabel(p.Results.XLabel, 'FontSize', 12);
ylabel(p.Results.YLabel, 'FontSize', 12);

% Style adjustments
set(gca, 'FontSize', 10); % Adjust font size for axes
end
