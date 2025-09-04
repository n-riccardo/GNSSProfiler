topo_path="C:\Users\rikin\Documents\OneDrive_unibo\OneDrive - Alma Mater Studiorum Università di Bologna\Period_abroad\SeparateRegions\topo/output_STRM15Plus.nc";
topo.z=ncread(topo_path,"z");
topo.lon=ncread(topo_path,"x");
topo.lat=ncread(topo_path,"y");

M.Long=topo.lon;
M.Lat=topo.lat;
M.Val=topo.z;

[GridProfile,trackInfo,poly,geopoly] =ComputeProfilesFromGrid(M,50,[0,-70,0,70],'SamplingDistOnTrack',200,'NSamplingCrossTrack',50);

%%

figure
geoplot(geopoly)
hold on
for i=1:length(GridProfile)
        
    geoscatter(GridProfile(i).Lats,GridProfile(i).Lons,10);

end


%%

distances=[];
values=[];
figure
hold on
colormap(jet); % Set colormap
clim([min([GridProfile.Values],[],'all'), max([GridProfile.Values],[],'all')]); % Adjust color scaling
colorbar; % Show color scale
for i=1:length(GridProfile)
        
    scatter3(GridProfile(i).Lons, GridProfile(i).Lats, GridProfile(i).Values, 50, GridProfile(i).Values, 'filled');

    distances=[distances,GridProfile(i).Distance];
    values=[values,median(GridProfile(i).Values)];

end
colorbar

%%

figure
plot(distances,values)

