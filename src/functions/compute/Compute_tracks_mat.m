function container=Compute_tracks_mat(w,start_end_points,Npoints_GMT,output_folder,id)
%%Compute both track and rectangle for a profile.
%It works with rhumb lines. Pass output_folder="", if you do not want output files.
%%Additional notes:
%Compute_tracks_mat is a adaption of compute_tracks.m to be used within MATLAB
%Last check on 24/01/25
%%Author: Riccardo Nucci (riccardo.nucci4@unibo.it)

%reference Sphere
reference_earth = referenceEllipsoid('earth'); %WGS84
reference_earth.LengthUnit = 'kilometer';

lon_start=start_end_points(1);
lat_start=start_end_points(2);
lon_end=start_end_points(3);
lat_end=start_end_points(4);

A=[lat_start,lon_start];
B=[lat_end,lon_end];

total_distance=distance('rh',[A(1),A(2)],[B(1),B(2)],reference_earth); %km
[lat_track,lon_track] = track2('rh',A(1),A(2),B(1),B(2),reference_earth,'degrees',Npoints_GMT);
distances_from_A=distance('rh',[A(1),A(2)],[lat_track,lon_track],reference_earth);
azimuth_= azimuth("rh",A(1),A(2),B(1),B(2),reference_earth,"degrees"); %default is w.r.t. north and positive clochwise

%let's define C and D orthogonal to the path
%these are the angles for lines orthogonal to the paths
% [C(1),C(2)]=track1('rh',A(1),A(2),azimuth_-90, w,reference_earth,'degrees',1);
%in the function: azimuth is w.r.t. north and positive clockwise
% [D(1),D(2)]=track1('rh',B(1),B(2),azimuth_-90, w,reference_earth,'degrees',1);

%[E(1),E(2)]=track1('rh',B(1),B(2),azimuth_+90, w,reference_earth,'degrees',1);
%[F(1),F(2)]=track1('rh',A(1),A(2),azimuth_+90, w,reference_earth,'degrees',1);

% Revised version (07/10/2024):

lat_rect=[];
lon_rect=[];

lat_rect=[lat_rect;A(1)];
lon_rect=[lon_rect;A(2)];

for i=1:Npoints_GMT

    lat_temp=lat_track(i);
    lon_temp=lon_track(i);

    [lat_rect_temp,lon_rect_temp]=track1('rh',lat_temp,lon_temp,azimuth_-90, w,reference_earth,'degrees',1);
    %[lat_rect_temp2,lon_rect_temp2]=track1('rh',A(1),A(2),azimuth_+90, w,reference_earth,'degrees',1);

    lon_rect=[lon_rect;lon_rect_temp];
    lat_rect=[lat_rect;lat_rect_temp];

end

lat_rect=[lat_rect;B(1)];
lon_rect=[lon_rect;B(2)];

for i=1:Npoints_GMT

    lat_temp=lat_track(Npoints_GMT-i+1);
    lon_temp=lon_track(Npoints_GMT-i+1);

    [lat_rect_temp,lon_rect_temp]=track1('rh',lat_temp,lon_temp,azimuth_+90, w,reference_earth,'degrees',1);

    lon_rect=[lon_rect;lon_rect_temp];
    lat_rect=[lat_rect;lat_rect_temp];

end

lat_rect=[lat_rect;A(1)];
lon_rect=[lon_rect;A(2)];

%%

container.total_distance=total_distance;
container.lat_track=lat_track;
container.lon_track=lon_track;
container.azimuth=azimuth_;
container.lat_rect=lat_rect;
container.lon_rect=lon_rect;

T1=table(distances_from_A, lon_track,lat_track);
T1.Properties.VariableNames = {'Dist (km)','LonTrk', 'LatTrk'};
if(~isnan(output_folder))
    writetable(T1,output_folder+"/track_GMT"+string(w*2)+id+".txt");
end

T2=table(total_distance,azimuth_,w*2);
T2.Properties.VariableNames = {'TotalTrkDist (km)', 'Azimuth (deg)', 'Width (km)'};
if(~isnan(output_folder))
    writetable(T2,output_folder+"/info_GMT"+string(w*2)+id+".txt");
end

T3=table(lon_rect,lat_rect);
T3.Properties.VariableNames = {'LonRect', 'LatRect'};
if(~isnan(output_folder))
    writetable(T3,output_folder+"/rect_GMT"+string(w*2)+id+".txt");
end


end

