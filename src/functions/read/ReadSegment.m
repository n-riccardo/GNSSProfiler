function FaultsLonLat = ReadSegment(fileName)
% ReadSegmentStruct.m from Blocks

% Declare variables
nHeaderLines = 13;
nFieldLines  = 13;

% Read in the whole segment file as a cell
contentsSegmentFile = textread(fileName, '%s', 'delimiter', '\n', 'whitespace', '');

% Get rid of the descriptive header
contentsSegmentFile(1 : nHeaderLines) = [];

% Assign the remaining data to structs
%Segment.name = char(deal(contentsSegmentFile(1 : nFieldLines : end)));

endPointCoordinates = str2num_fast(contentsSegmentFile(2 : nFieldLines :end), 4);

lon_start=endPointCoordinates(:, 1);
lat_start=endPointCoordinates(:, 2);
lon_end=endPointCoordinates(:, 3);
lat_end=endPointCoordinates(:, 4);

for i=1:length(lon_start)
    if(lon_start(i)>180)
        lon_start(i)=lon_start(i)-360;
    end
    if(lon_end(i)>180)
        lon_end(i)=lon_end(i)-360;
    end
end

[Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2] = deal(lon_start, lat_start, lon_end, lat_end);

nSegments=length(Segment.lon1);

LonLat=zeros(3*nSegments,2);

j=1;
for i=1:3:(3*length(Segment.lon1))
    LonLat(i,:)=[Segment.lon1(j), Segment.lat1(j)];
    LonLat(i+1,:)=[Segment.lon2(j), Segment.lat2(j)];
    LonLat(i+2,:)=[NaN, NaN];
    j=j+1;
end


FaultsLonLat=LonLat;

end

