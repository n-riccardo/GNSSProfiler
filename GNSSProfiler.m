classdef GNSSProfiler < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        QuickGNSSProfilePlotterUIFigure  matlab.ui.Figure
        FileMenu                      matlab.ui.container.Menu
        FaultsMenu                    matlab.ui.container.Menu
        LoadMenu                      matlab.ui.container.Menu
        ColorMenu                     matlab.ui.container.Menu
        VelocityfieldsMenu            matlab.ui.container.Menu
        LoadMenu_2                    matlab.ui.container.Menu
        GNSSMenu                      matlab.ui.container.Menu
        NetCDFMenu                    matlab.ui.container.Menu
        ColorMenu_2                   matlab.ui.container.Menu
        ColorGNSS                     matlab.ui.container.Menu
        ColorScalarSelected           matlab.ui.container.Menu
        ClearMenu_2                   matlab.ui.container.Menu
        SelectedGNSSMenu              matlab.ui.container.Menu
        SelectedNetCDFMenu            matlab.ui.container.Menu
        OptionsMenu                   matlab.ui.container.Menu
        BasemapsneedInternetconnMenu  matlab.ui.container.Menu
        BasemapMenu                   matlab.ui.container.Menu
        TopographicMenu               matlab.ui.container.Menu
        ColorterrainMenu              matlab.ui.container.Menu
        NoneMenu                      matlab.ui.container.Menu
        InfoMenu                      matlab.ui.container.Menu
        ContactsMenu                  matlab.ui.container.Menu
        RiccardoNucciMenu             matlab.ui.container.Menu
        ProfileinfoPanel              matlab.ui.container.Panel
        LabelAzimuth                  matlab.ui.control.Label
        LabelNVelo                    matlab.ui.control.Label
        LabelLength                   matlab.ui.control.Label
        LabelWidth                    matlab.ui.control.Label
        AzimuthdegLabel               matlab.ui.control.Label
        NumberofvelocitiesLabel       matlab.ui.control.Label
        LengthkmLabel                 matlab.ui.control.Label
        WidthkmLabel                  matlab.ui.control.Label
        SetButton                     matlab.ui.control.Button
        MaxYProfile                   matlab.ui.control.NumericEditField
        MinYProfile                   matlab.ui.control.NumericEditField
        PlotvelolimitsminmaxmmyrEditFieldLabel  matlab.ui.control.Label
        SaveMapforGMTButton           matlab.ui.control.Button
        Lamp                          matlab.ui.control.Lamp
        SaveDataButton                matlab.ui.control.Button
        PlotLegendButton              matlab.ui.control.Button
        LegendmmyrLabel               matlab.ui.control.Label
        EditField_3                   matlab.ui.control.NumericEditField
        MouseLatEditFieldLabel_2      matlab.ui.control.Label
        ScaleMinus                    matlab.ui.control.Button
        ScalePlus                     matlab.ui.control.Button
        MouseLatEditField             matlab.ui.control.NumericEditField
        MouseLatEditFieldLabel        matlab.ui.control.Label
        MouseLonEditField             matlab.ui.control.NumericEditField
        MouseLonEditFieldLabel        matlab.ui.control.Label
        MapinMercatorProjectionPanel  matlab.ui.container.Panel
        StatusbarLabel                matlab.ui.control.Label
        ProfileEditPanel              matlab.ui.container.Panel
        DropDown                      matlab.ui.control.DropDown
        PickpointsSwitch_2            matlab.ui.control.Switch
        InsertvaluesmanuallyLabel     matlab.ui.control.Label
        PickpointsLabel               matlab.ui.control.Label
        ProfilewidthkmLabel           matlab.ui.control.Label
        PickpointsSwitchLabel_2       matlab.ui.control.Label
        Switch                        matlab.ui.control.Switch
        EditFieldEPLat                matlab.ui.control.NumericEditField
        EditFieldEPLon                matlab.ui.control.NumericEditField
        EndPointlonlatLabel           matlab.ui.control.Label
        EditFieldSPLat                matlab.ui.control.NumericEditField
        EditFieldSPLon                matlab.ui.control.NumericEditField
        StartPointlonlatLabel         matlab.ui.control.Label
        PickpointsSwitch              matlab.ui.control.Switch
        PlotButton                    matlab.ui.control.Button
        ProfilewidthkmEditField       matlab.ui.control.NumericEditField
        EditField_2                   matlab.ui.control.EditField
        ProfilePanel                  matlab.ui.container.Panel
        UIAxes                        matlab.ui.control.UIAxes
        LoadedDataPanel               matlab.ui.container.Panel
        StationNamesCheckBox          matlab.ui.control.CheckBox
        FaultList                     matlab.ui.control.Table
        ScalarVeloList                matlab.ui.control.Table
        GNSSVeloList                  matlab.ui.control.Table
    end


    properties (Access = private)

        GNSSProfilerName = "Quick GNSS Profile Plotter, v. 1.0.0"

        % Mouse options:
        clickCount (1,1) double {mustBeInteger,mustBeLessThanOrEqual(clickCount,2),mustBeGreaterThanOrEqual(clickCount,0)} = 0;

        % Profile options:
        linePoints (2,2) double = nan(2,2);
        profileWidth (1,1) double {mustBePositive} = 50; 
        profileComponent (1,1) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(profileComponent,3)} = 1; % 1= velo parallel, 2 = velo orth, 3 = vertical
        SamplingOnTrackGrid=1000;
        NSamplingGrid=100;

        % Values relative to profile already plotted and not modified until the next plot:
        linePointsInPlot (2,2) double = nan(2,2);
        profileWidthInPlot (1,1) double {mustBePositive} = 1;  

        % Geoplot:
        MapAxes matlab.graphics.axis.GeographicAxes  % Axes for geoplotting
        Range (4,1) double = [30,45,-10,40]
        scale (1,1) double = 0.003 % Scale for quiver plot
        legendValue (1,1) double = 3
        geopoly

        % Cartesian Plot:
        Ylimits (2,1) double = [0,1];

        % GNSS velocity data:
        GNSSVelocities GNSSVeloManager = GNSSVeloManager()
        ResultTables

        % Scalar velocity data:
        ScalarVelocities ScalarVeloManager = ScalarVeloManager()
        ResultGrids

        % Faults:
        GFaultsDats GFaultsManager = GFaultsManager()

        trackInfo

        % Options for scalar velocity fields:
        PercentileDown=5;
        PercentileUp=95;

    end

    methods (Access = public)

        function showStatus(app, strD, varargin)
            if isscalar(varargin)
                iserror = varargin{1};
            else
                iserror = false;
            end

            if iserror
                app.EditField_2.BackgroundColor = "#fc5656";
            else
                app.EditField_2.BackgroundColor = "#87d4f5";
            end

            app.EditField_2.Value = strD;
        end
    end

    methods (Access = private)

        %%%%%%%%%%%%%%%%%%%%%%
        %      Plotters      %
        %%%%%%%%%%%%%%%%%%%%%%

        function PlotVelocity(app)
            delete(findall(app.MapAxes, 'Tag', 'GNSSVeloField'))
            delete(findall(app.MapAxes, 'Tag', 'ScalarSquare'))
            delete(findall(app.MapAxes, 'Tag', 'Faults'))
            delete(findall(app.MapAxes, 'Tag', 'GNSSVeloNames'))
            if(~isempty(app.GNSSVelocities))
                for i=1:numel(app.GNSSVelocities.Fields)
                    if(app.GNSSVelocities.Fields(i).Selected)
                        velocityTable=app.GNSSVelocities.Fields(i).Data;
                        lon=velocityTable.lon;
                        lat=velocityTable.lat;
                        ve=velocityTable.ve;
                        vn=velocityTable.vn;
                        se=velocityTable.se;
                        sn=velocityTable.sn;
                        QuiverGeoPlotError(lon, lat, ve, vn, se, sn, zeros(1,length(lon)),...
                            app.scale,'Axes',app.MapAxes,'Tag',"GNSSVeloField",...
                            'Color', char(app.GNSSVelocities.Fields(i).Colors(1)),...
                            'ColorEllipse', char(app.GNSSVelocities.Fields(i).Colors(2)))
                        PlotLegend(app)
                    end
                end
            end     
            if(app.StationNamesCheckBox.Value)
                if(~isempty(app.GNSSVelocities))
                    for i=1:numel(app.GNSSVelocities.Fields)
                        if(app.GNSSVelocities.Fields(i).Selected)
                            velocityTable=app.GNSSVelocities.Fields(i).Data;
                            lon=velocityTable.lon;
                            lat=velocityTable.lat;
                            name=velocityTable.name;
                            GeoPlotNames(lon,lat,name,'Axes',app.MapAxes,'Tag',"GNSSVeloNames",...
                            'Color', char(app.GNSSVelocities.Fields(i).Colors(1)))
                        end
                    end
                end
            end
            if(~isempty(app.ScalarVelocities))
                for i=1:numel(app.ScalarVelocities.Fields)
                    if(app.ScalarVelocities.Fields(i).Selected)
                        LonMax=max(app.ScalarVelocities.Fields(i).LonScalarF,[],'all');
                        LonMin=min(app.ScalarVelocities.Fields(i).LonScalarF,[],'all');
                        LatMax=max(app.ScalarVelocities.Fields(i).LatScalarF,[],'all');
                        LatMin=min(app.ScalarVelocities.Fields(i).LatScalarF,[],'all');
                        geoplot(app.MapAxes,[LatMin,LatMin,LatMax,LatMax,LatMin],...
                            [LonMin,LonMax,LonMax,LonMin,LonMin],'LineWidth',1,'Color', ...
                            app.ScalarVelocities.Fields(i).Color,'Tag','ScalarSquare')
                    end
                end
            end
            if(~isempty(app.GFaultsDats))
                for i=1:numel(app.GFaultsDats.Fields)
                    if(app.GFaultsDats.Fields(i).Selected)
                        geoplot(app.MapAxes,app.GFaultsDats.Fields(i).Data(:,2),...
                            app.GFaultsDats.Fields(i).Data(:,1),'LineWidth',1,'Color',...
                            app.GFaultsDats.Fields(i).Color,'Tag','Faults')
                    end
                end
            end
        end

        function PlotGNSSNames(app)

            
        end

        function PlotProfile(app)

            delete(findall(app.UIAxes, 'Tag', 'ProfilePlot'));
            hold(app.UIAxes, 'on');
            if(~isempty(app.ScalarVelocities.Fields))
                for i=1:numel(app.ScalarVelocities.Fields)
                    if((~isempty(app.ResultGrids{i,1})) || (~isempty(app.ResultGrids{i,2})) || (~isempty(app.ResultGrids{i,3})))
                        myColorChar=char(app.ScalarVelocities.Fields(i).Color);
                        myColorCharLight=lightenHex(myColorChar, 1.5);
                        if(app.profileComponent==1)
                            PlotProfileGrid(app.ResultGrids{i,1},app.PercentileDown,app.PercentileUp,'Axes',app.UIAxes,'Tag',"ProfilePlot", ...
                                'Color',myColorChar,'ShadingColor',myColorCharLight)
                        elseif(app.profileComponent==2)
                            PlotProfileGrid(app.ResultGrids{i,2},app.PercentileDown,app.PercentileUp,'Axes',app.UIAxes,'Tag',"ProfilePlot", ...
                                'Color',myColorChar,'ShadingColor',myColorCharLight)
                        elseif(app.profileComponent==3)
                            PlotProfileGrid(app.ResultGrids{i,3},app.PercentileDown,app.PercentileUp,'Axes',app.UIAxes,'Tag',"ProfilePlot", ...
                                'Color',myColorChar,'ShadingColor',myColorCharLight)
                        end
                    end
                end
            end

            if(~isempty(app.GNSSVelocities.Fields))
                for i=1:numel(app.GNSSVelocities.Fields)
                    if(~isempty(app.ResultTables{i}))
                        if(app.profileComponent==1)
                            ProfilePlot(app.ResultTables{i}.Distances_km, app.ResultTables{i}.Vpara, app.ResultTables{i}.Spara, 'Axes',app.UIAxes,'Tag',"ProfilePlot",'Color',char(app.GNSSVelocities.Fields(i).Colors(1)))
                        elseif(app.profileComponent==2)
                            ProfilePlot(app.ResultTables{i}.Distances_km, app.ResultTables{i}.Vorth, app.ResultTables{i}.Sorth, 'Axes',app.UIAxes,'Tag',"ProfilePlot",'Color',char(app.GNSSVelocities.Fields(i).Colors(1)))
                        elseif(app.profileComponent==3)
                            ProfilePlot(app.ResultTables{i}.Distances_km, app.ResultTables{i}.Vu, app.ResultTables{i}.Su, 'Axes',app.UIAxes,'Tag',"ProfilePlot",'Color',char(app.GNSSVelocities.Fields(i).Colors(1)))
                        end
                    end
                end
            end
            hold(app.UIAxes, 'off');

            app.linePointsInPlot=app.linePoints;
            app.profileWidthInPlot=app.profileWidth;

            showStatus(app,"Profile plotted!")
        end

        function PlotLegend(app)
            delete(findall(app.MapAxes, 'Tag', 'ScaleVector'));
            latLim=app.MapAxes.LatitudeLimits;
            lonLim=app.MapAxes.LongitudeLimits;
            latPos = latLim(1) + 0.1 * diff(latLim);   % slightly up
            lonPos = lonLim(2) - 0.2 * diff(lonLim);   % slighty left
            QuiverGeoPlotError(lonPos, latPos, app.legendValue, 0, 0, 0, 0,...
                app.scale,'Axes',app.MapAxes,'Color','green','Tag',"ScaleVector")
            text(app.MapAxes,latPos, lonPos,string(app.legendValue)+ "mm/yr", 'Tag', 'ScaleVector', ...
                'HorizontalAlignment', 'right', 'FontSize', 10, 'Color', 'k');
        end

        %%%%%%%%%%%%%%%%%%%%%%
        %  Cursor Functions  %
        %%%%%%%%%%%%%%%%%%%%%%

        function [lonPos,latPos]=UpdateGeoCursor(app)

            app.Range=[(app.MapAxes.LatitudeLimits)';(app.MapAxes.LongitudeLimits)'];
            my_range=app.Range;
            cursorPos = app.MapAxes.CurrentPoint;
            latPos=cursorPos(1,1);
            lonPos=cursorPos(1,2);

            if(latPos<=my_range(2) && latPos >=my_range(1) &&...
                    lonPos<=my_range(4) && lonPos >=my_range(3))
                app.MouseLatEditField.Value = latPos;
                app.MouseLonEditField.Value = lonPos;
            else
                lonPos=NaN;
                latPos=NaN;
            end
        end

        function [lonPos,latPos]=UpdateGeoCursorPoly(app)

            app.Range=[(app.MapAxes.LatitudeLimits)';(app.MapAxes.LongitudeLimits)'];
            my_range=app.Range;
            cursorPos = app.MapAxes.CurrentPoint;
            latPos=cursorPos(1,1);
            lonPos=cursorPos(1,2);
            inside=isinterior(app.geopoly,geopointshape(latPos,lonPos));

            h = findobj(app.UIAxes, 'Type', 'ConstantLine', 'Tag', 'DistanceLine');

            if ~isempty(h)
                delete(h);
            end

            delete(findall(app.UIAxes, 'Tag', 'DistanceText'));

            if(latPos<=my_range(2) && latPos >=my_range(1) &&...
                    lonPos<=my_range(4) && lonPos >=my_range(3) && inside)
                app.MouseLatEditField.Value = latPos;
                app.MouseLonEditField.Value = lonPos;

                distance_=DistanceFromStart(app,lonPos,latPos);

                xline(app.UIAxes,distance_,'Color','blue','Tag','DistanceLine')
                yLimits = app.UIAxes.YLim;  
                yPos = yLimits(2);       

                text(app.UIAxes, distance_, yPos, sprintf('%.2f', distance_), ...
                    'VerticalAlignment', 'top', ...
                    'HorizontalAlignment', 'left', ...
                    'Color', 'blue', ...
                    'FontSize', 12, ...
                    'Tag', 'DistanceText');

            else
                lonPos=NaN;
                latPos=NaN;
            end
        end

        function GetGeoCursor(app)
            [lonPos,latPos]=UpdateGeoCursor(app);
            if((~isnan(lonPos)) && (~isnan(latPos)))
                if(app.clickCount==0)
                    showStatus(app,"First point selected: lon "+string(lonPos)+" lat "+string(latPos))
                    app.linePoints(1,:)=[latPos,lonPos];
                    geoplot(app.MapAxes,latPos,lonPos,...
                        'ro', 'MarkerSize', 5, 'LineWidth', 2, 'Tag','ProfileTempPointStart')
                    UpdateLinePoints(app)
                    app.clickCount=1;
                elseif(app.clickCount==1)
                    showStatus(app,"Second point selected: lon "+string(lonPos)+" lat "+string(latPos))
                    app.linePoints(2,:)=[latPos,lonPos];
                    UpdateLinePoints(app)
                    geoplot(app.MapAxes,latPos,lonPos,...
                        'ro', 'MarkerSize', 5, 'LineWidth', 2, 'Tag','ProfileTempPointEnd')
                    geoplot(app.MapAxes,app.linePoints(:,1),app.linePoints(:,2),...
                        'LineStyle','--','LineWidth',2,'Color','#ffaa00','Tag','ProfileTempLine')
                    UpdateLinePoints(app)
                    app.clickCount=2;
                elseif(app.clickCount==2)
                    app.linePoints=app.linePoints.*NaN;
                    delete([findall(app.MapAxes, 'Tag', 'ProfileTempLine'),...
                        findall(app.MapAxes, 'Tag', 'ProfileTempPointStart'),...
                        findall(app.MapAxes, 'Tag', 'ProfileTempPointEnd')]);
                    UpdateLinePoints(app)
                    app.clickCount=0;
                end
            end
        end

        function UpdateLinePoints(app)

            if(isnan(app.linePoints(1,1)))
                app.EditFieldSPLat.Value=[];
            else
                app.EditFieldSPLat.Value=app.linePoints(1,1);
            end

            if(isnan(app.linePoints(1,2)))
                app.EditFieldSPLon.Value=[];
            else
                app.EditFieldSPLon.Value=app.linePoints(1,2);
            end

            if(isnan(app.linePoints(2,1)))
                app.EditFieldEPLat.Value=[];
            else
                app.EditFieldEPLat.Value=app.linePoints(2,1);
            end

            if(isnan(app.linePoints(2,2)))
                app.EditFieldEPLon.Value=[];
            else
                app.EditFieldEPLon.Value=app.linePoints(2,2);
            end
        end

        function InitPick(app)
            app.clickCount=0;
            app.linePoints=app.linePoints.*NaN;
            UpdateLinePoints(app)
            delete(findall(app.MapAxes, 'Tag', 'ProfileTempLine'))
            delete(findall(app.MapAxes, 'Tag', 'ProfileTempPointStart'))
            delete(findall(app.MapAxes, 'Tag', 'ProfileTempPointEnd'))
            delete(findall(app.MapAxes, 'Tag', 'ProfilePolygon'));
        end


        function displayTrackInfo(app,trackInfo)

            app.LabelWidth.Text=string(trackInfo.width);
            app.LabelLength.Text=string(trackInfo.total_distance);
            nVelsString="";
            for i=1:numel(app.GNSSVelocities.Fields)
                if(i==numel(app.GNSSVelocities.Fields))
                    nVelsString=nVelsString+string(trackInfo.nVels(i));
                else
                    nVelsString=nVelsString+string(trackInfo.nVels(i))+", ";
                end
            end
            app.LabelNVelo.Text=nVelsString;
            app.LabelAzimuth.Text=string(trackInfo.azimuth);

        end

        function distance_=DistanceFromStart(app,lon,lat)

            reference_earth = referenceEllipsoid('earth');
            reference_earth.LengthUnit = 'kilometer';
            start_end_points=[app.linePoints(1,2),app.linePoints(1,1),app.linePoints(2,2),app.linePoints(2,1)];

            [int_lat, int_lon] = rhxrh(lat, lon, app.trackInfo.azimuth, start_end_points(2), start_end_points(1), app.trackInfo.azimuth - 90);

            % Compute distance from station to profile center
            distance_ = distance('rh', [int_lat, int_lon], [lat, lon], reference_earth);

        end

        function UpdateGNSSVeloList(app) % Update the whole list on the basis of the GNSSVelocities object (names can be changed if equals)
            newT = table([],logical([]));
            newT.Properties.VariableNames=app.GNSSVeloList.ColumnName;
            for i=1:numel(app.GNSSVelocities.Fields)
                newRow = table(app.GNSSVelocities.Fields(i).Name,logical(app.GNSSVelocities.Fields(i).Selected),...
                    'VariableNames',app.GNSSVeloList.ColumnName);
                newT = [newT;newRow];
            end
            disp(newT)
            app.GNSSVeloList.Data = newT;
        end

        function UpdateScalarVeloList(app)
            newT = table([],logical([]));
            newT.Properties.VariableNames=app.ScalarVeloList.ColumnName;
            for i=1:numel(app.ScalarVelocities.Fields)
                newRow = table(app.ScalarVelocities.Fields(i).Name,logical(app.ScalarVelocities.Fields(i).Selected),...
                    'VariableNames',app.ScalarVeloList.ColumnName);
                newT = [newT;newRow];
            end
            disp(newT)
            app.ScalarVeloList.Data = newT;
        end

        function UpdateFaultList(app)
            newT = table([],logical([]));
            newT.Properties.VariableNames=app.FaultList.ColumnName;
            for i=1:numel(app.GFaultsDats.Fields)
                newRow = table(app.GFaultsDats.Fields(i).Name,logical(app.GFaultsDats.Fields(i).Selected),...
                    'VariableNames',app.FaultList.ColumnName);
                newT = [newT;newRow];
            end
            disp(newT)
            app.FaultList.Data = newT;
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            showStatus(app,"Welcome to "+app.GNSSProfilerName)

            load WorldCoastline.mat lon lat

            app.MapAxes = geoaxes(app.MapinMercatorProjectionPanel, ...
                'Basemap', 'none'); % oppure regola le dimensioni come vuoi

            hold(app.MapAxes, 'on');
            geoplot(app.MapAxes,lat,lon,'LineWidth',1,'Color','black')
            geolimits(app.MapAxes,app.Range(1:2)',app.Range(3:4)')

        end

        % Value changed function: PickpointsSwitch
        function PickpointsSwitchValueChanged(app, event)
            value = app.PickpointsSwitch.Value;
            if(value=="On")
                InitPick(app)
                app.PlotButton.Enable="off";
                app.Lamp.Color="green";
                showStatus(app,"Select two points on the Map")
                app.QuickGNSSProfilePlotterUIFigure.WindowButtonMotionFcn = @(src, event) UpdateGeoCursor(app);
                app.QuickGNSSProfilePlotterUIFigure.WindowButtonDownFcn = @(src, event) GetGeoCursor(app);
            else
                app.Lamp.Color="red";
                app.PlotButton.Enable="on";
                showStatus(app,"Selector switched off")
                app.MouseLatEditField.Value = [];
                app.MouseLonEditField.Value = [];
                if(app.clickCount~=2)
                    InitPick(app)
                end
                app.QuickGNSSProfilePlotterUIFigure.WindowButtonMotionFcn=[];
                app.QuickGNSSProfilePlotterUIFigure.WindowButtonDownFcn = [];
            end
        end

        % Value changed function: ProfilewidthkmEditField
        function ProfilewidthkmEditFieldValueChanged(app, event)
            try
                value = app.ProfilewidthkmEditField.Value;
                app.profileWidth=value;
                showStatus(app,"Width of profile set to: "+value+" km")
            catch
                showStatus(app,"Mmh...the width of the profile doesn't seem a positive double",true)
                app.ProfilewidthkmEditField.Value=app.profileWidth;
            end

        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %      Computing profiles      %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            isthereNaNValueInPoints=false;
            for i=1:2
                for j=1:2
                    isthereNaNValueInPoints=isthereNaNValueInPoints | isnan(app.linePoints(i,j));
                end
            end

            if((~isthereNaNValueInPoints) && ( (~isempty(app.GNSSVelocities.Fields)) || (~isempty(app.ScalarVelocities.Fields)) ))
                delete(findall(app.MapAxes, 'Tag', 'ProfilePolygon'));
                showStatus(app,"Plotting profile...")

                width=app.profileWidth;
                start_end_points=[app.linePoints(1,2),app.linePoints(1,1),app.linePoints(2,2),app.linePoints(2,1)];
                trackInfo_ = Compute_tracks_mat(width/2, start_end_points, 100, NaN, "");
                azimuth_ = trackInfo_.azimuth;
                total_distance=trackInfo_.total_distance;
                trackInfo_.width=width;
                trackInfo_.nVels=zeros(1,numel(app.GNSSVelocities.Fields));
                
                %    - Long (Longitude) - Lat (Latitude) 
                %    - E_Rate (Velocity in East direction)  - N_Rate (Velocity in North direction)  - U_Rate (Velocity in Up direction) 
                %    - x__E (Uncertainty in East direction) - x__N (Uncertainty in North direction) - x__U (Uncertainty in Up direction)
                ResultTables_ = cell(numel(app.GNSSVelocities.Fields),1);
                if(~isempty(app.GNSSVelocities.Fields))
                    for i=1:numel(app.GNSSVelocities.Fields)
                        if(app.GNSSVelocities.Fields(i).Selected)
                            veloTableComp=app.GNSSVelocities.Fields(i).Data;
                            veloTableComp=veloTableComp(:,1:8);
                            veloTableComp.Properties.VariableNames= {'Long', 'Lat', 'E_Rate', 'N_Rate', 'U_Rate', 'x__E', 'x__N', 'x__U'};
                            [ResultTable, ~, ~, app.geopoly]=ComputeGNSSProfile(veloTableComp,width/2,start_end_points);
                            
                            trackInfo_.nVels(i)=numel(ResultTable.Distances_km);
                            ResultTables_{i}=ResultTable;
                        else
                            trackInfo_.nVels(i)=0;
                            ResultTables_{i}=table();
                        end
                    end
                end

                app.ResultTables=ResultTables_;

                app.trackInfo=trackInfo_;
                displayTrackInfo(app,trackInfo_)

                ResultGrids_ = cell(numel(app.ScalarVelocities.Fields),3);  

                if(~isempty(app.ScalarVelocities.Fields))
                    for i=1:numel(app.ScalarVelocities.Fields)
                        if(app.ScalarVelocities.Fields(i).Selected)

                            GridVParallel = app.ScalarVelocities.Fields(i).GridVe * sind(azimuth_) + app.ScalarVelocities.Fields(i).GridVn * cosd(azimuth_);
                            GridVOrthogonal = app.ScalarVelocities.Fields(i).GridVe * cosd(azimuth_) - app.ScalarVelocities.Fields(i).GridVn * sind(azimuth_);
                            GridVUp = app.ScalarVelocities.Fields(i).GridVu;

                            grid_dataParallel.Long=app.ScalarVelocities.Fields(i).LonScalarF;
                            grid_dataParallel.Lat=app.ScalarVelocities.Fields(i).LatScalarF;
                            grid_dataParallel.Val=GridVParallel;
                            grid_dataOrthogonal.Long=app.ScalarVelocities.Fields(i).LonScalarF;
                            grid_dataOrthogonal.Lat=app.ScalarVelocities.Fields(i).LatScalarF;
                            grid_dataOrthogonal.Val=GridVOrthogonal;
                            grid_dataUp.Long=app.ScalarVelocities.Fields(i).LonScalarF;
                            grid_dataUp.Lat=app.ScalarVelocities.Fields(i).LatScalarF;
                            grid_dataUp.Val=GridVUp;

                            [GridProfileParallel, ~, ~, ~] = ComputeProfilesFromGrid(grid_dataParallel, width/2, start_end_points,'SamplingDistOnTrack',total_distance/app.SamplingOnTrackGrid,'NSamplingCrossTrack',app.NSamplingGrid);
                            [GridProfileOrthogonal, ~, ~, app.geopoly] = ComputeProfilesFromGrid(grid_dataOrthogonal, width/2, start_end_points,'SamplingDistOnTrack',total_distance/app.SamplingOnTrackGrid,'NSamplingCrossTrack',app.NSamplingGrid);
                            [GridProfileUp, ~, ~, app.geopoly] = ComputeProfilesFromGrid(grid_dataUp, width/2, start_end_points,'SamplingDistOnTrack',total_distance/app.SamplingOnTrackGrid,'NSamplingCrossTrack',app.NSamplingGrid);

                            ResultGrids_{i,1}=GridProfileParallel;
                            ResultGrids_{i,2}=GridProfileOrthogonal;
                            ResultGrids_{i,3}=GridProfileUp;
                        else
                            ResultGrids_{i,1}=[];
                            ResultGrids_{i,2}=[];
                            ResultGrids_{i,3}=[];
                        end
                    end
                end

                app.ResultGrids=ResultGrids_;
                geoplot(app.MapAxes,app.geopoly,'Tag','ProfilePolygon')

                PlotProfile(app)

            else
                showStatus(app,"Error while plotting your profile: maybe you didn't pick any points? Or maybe you didn't load a legit velocity dataset?",true)
            end

        end

        % Button pushed function: ScalePlus
        function ScalePlusButtonPushed(app, event)
            app.scale=app.scale*1.1;
            %delete(findall(app.MapAxes, 'Tag', 'GNSSVeloField'))
            PlotVelocity(app)
            showStatus(app,"Velocity scale increased by 10%")
        end

        % Button pushed function: ScaleMinus
        function ScaleMinusButtonPushed(app, event)
            app.scale=app.scale*0.9;
            %delete(findall(app.MapAxes, 'Tag', 'GNSSVeloField'))
            PlotVelocity(app)
            showStatus(app,"Velocity scale decreased by 10%")
        end

        % Button pushed function: PlotLegendButton
        function PlotLegendButtonPushed(app, event)
            PlotLegend(app)
        end

        % Value changed function: EditField_3
        function EditField_3ValueChanged(app, event)
            value = app.EditField_3.Value;
            app.legendValue=value;
        end

        % Menu selected function: LoadMenu
        function LoadMenuSelected(app, event)

            showStatus(app, "Please, select a file with lon-lat format")

            ff = fixfocus;
            [file,location] = uigetfile('*');
            delete(ff);

            if isequal(file,0)
                showStatus(app,"No fault database loaded")
            else
                fullFileName = fullfile(location, file);
                showStatus(app,"User selected "+ string(fullFileName))
                try
                    fullFileName=string(fullFileName);
                    [Name,FaultsLonLat]= ReadFaultsFile(fullFileName);
                    GFaultsDat=GFaults(Name,FaultsLonLat,[],fullFileName,true);
                    app.GFaultsDats.addField(GFaultsDat);
                    UpdateFaultList(app)
                    PlotVelocity(app)
                    showStatus(app,"Faults successfully loaded")
                catch ME
                    % Mostra un messaggio di errore nell’interfaccia
                    showStatus(app, "Error while trying to load and plot faults (maybe incorrect format?). Details: " + ME.message, true);
                end
            end
        end

        % Value changed function: Switch
        function SwitchValueChanged(app, event)
            value = app.Switch.Value;
            if(value=="On")
                h = findobj(app.MapAxes, 'Tag', 'ProfilePolygon');

                if ~isempty(h) && isvalid(h) && app.PickpointsSwitch.Value=="Off"

                    showStatus(app,'You can indicate a point within the polygon');

                    app.QuickGNSSProfilePlotterUIFigure.WindowButtonMotionFcn = @(src, event) UpdateGeoCursorPoly(app);
                else
                    app.QuickGNSSProfilePlotterUIFigure.WindowButtonMotionFcn=[];
                    app.Switch.Value="Off";

                    showStatus(app,'The polygon does not exist (maybe you have to plot a profile first?)',true);
                end
            else
                app.QuickGNSSProfilePlotterUIFigure.WindowButtonMotionFcn=[];
                app.Switch.Value="Off";


            end
        end

        % Button pushed function: SaveDataButton
        function SaveDataButtonPushed(app, event)

            eb = findall(app.UIAxes, 'Type', 'ErrorBar');

            if isempty(eb)
                showStatus(app, "No plot found", true);
                return;
            end
            
            ff=fixfocus;
            [file, path] = uiputfile('*.txt', 'Save as');
            delete(ff);

            if isequal(file, 0)
                return; 
            end

            fullFileName = fullfile(path, file);

            fid = fopen(fullFileName, 'w');
            if fid == -1
                showStatus(app, "Cannot open file", true);
                return;
            end

            start_end_points=[app.linePointsInPlot(1,2),app.linePointsInPlot(1,1),app.linePointsInPlot(2,2),app.linePointsInPlot(2,1)];

            fprintf(fid, '*\tPlot Info\n');
            fprintf(fid, 'LonStart:\t%f\n', start_end_points(1));
            fprintf(fid, 'LatStart:\t%f\n', start_end_points(2));
            fprintf(fid, 'LonEnd:\t%f\n', start_end_points(3));
            fprintf(fid, 'LatEnd:\t%f\n', start_end_points(4));
            fprintf(fid, 'Profile_Width_km:\t%f\n', app.profileWidthInPlot);
            fprintf(fid, '*\tPlot data\n');
            fprintf(fid, 'Distance_km\tVelo_mmyr\tSigmaVelo_mmyr\n');
            
            for k = 1:length(eb)
                x     = eb(k).XData;
                y     = eb(k).YData;
                sigma = eb(k).YNegativeDelta;  % or YPositiveDelta 

                [x_sorted, idx] = sort(x);
                y_sorted     = y(idx);
                sigma_sorted = sigma(idx);

                for i = 1:length(x_sorted)
                    fprintf(fid, '%f\t%f\t%f\n', x_sorted(i), y_sorted(i), sigma_sorted(i));
                end

                if k < length(eb)
                    fprintf(fid, '\n');
                end
            end

            fclose(fid);
            showStatus(app, 'Data succesfully saved!');



        end

        % Callback function
        function ClearMenuSelected(app, event)
            h = findall(app.MapAxes, 'Tag', 'Faults');
            if ~isempty(h)
                delete(h);
            end
            h = findall(app.MapAxes, 'Tag', 'oldFaults');
            if ~isempty(h)
                delete(h);
            end
            app.ClearMenu.Enable ="off";
            app.ColorMenu.Enable = "off";
        end

        % Menu selected function: ColorMenu
        function ColorMenuSelected(app, event)
            ff = fixfocus;
            newColor = uisetcolor;
            newHex = string(sprintf('#%02X%02X%02X', round(newColor(1)*255), round(newColor(2)*255), round(newColor(3)*255)));
            delete(ff);
            disp(newHex)
            if length(newColor) == 3
                for i=1:numel(app.GFaultsDats.Fields)
                    if(app.GFaultsDats.Fields(i).Selected)
                        app.GFaultsDats.Fields(i).Color=newHex;
                        PlotVelocity(app)
                    end
                end
            end
        end

        % Value changed function: PickpointsSwitch_2
        function PickpointsSwitch_2ValueChanged(app, event)
            value = app.PickpointsSwitch_2.Value;
            if(value=="On")
                app.PlotButton.Enable="off";
                app.EditFieldSPLon.Editable="on";
                app.EditFieldSPLat.Editable="on";
                app.EditFieldEPLon.Editable="on";
                app.EditFieldEPLat.Editable="on";
                delete([findall(app.MapAxes, 'Tag', 'ProfileTempLine'),...
                    findall(app.MapAxes, 'Tag', 'ProfileTempPointStart'),...
                    findall(app.MapAxes, 'Tag', 'ProfileTempPointEnd'),...
                    findall(app.MapAxes, 'Tag', 'ProfilePolygon')]);
            end
            if(value=="Off")
                app.PlotButton.Enable="on";
                app.EditFieldSPLon.Editable="off";
                app.EditFieldSPLat.Editable="off";
                app.EditFieldEPLon.Editable="off";
                app.EditFieldEPLat.Editable="off";

                if(all(~isnan(app.linePoints), 'all'))
                geoplot(app.MapAxes,app.linePoints(1,1),app.linePoints(1,2),...
                    'ro', 'MarkerSize', 5, 'LineWidth', 2, 'Tag','ProfileTempPointStart')
                geoplot(app.MapAxes,app.linePoints(2,1),app.linePoints(2,2),...
                    'ro', 'MarkerSize', 5, 'LineWidth', 2, 'Tag','ProfileTempPointEnd')
                geoplot(app.MapAxes,app.linePoints(:,1),app.linePoints(:,2),...
                        'LineStyle','--','LineWidth',2,'Color','#ffaa00','Tag','ProfileTempLine')
                end
                
            end
        end

        % Value changed function: EditFieldSPLon
        function EditFieldSPLonValueChanged(app, event)
            value = app.EditFieldSPLon.Value;
            try
                app.linePoints(1,2)=value;
            catch ME
                app.showStatus("Error while updating start-end points. Detaills: "+ME.message,true)
            end
        end

        % Value changed function: EditFieldSPLat
        function EditFieldSPLatValueChanged(app, event)
            value = app.EditFieldSPLat.Value;
            try
                app.linePoints(1,1)=value;
            catch ME
                app.showStatus("Error while updating start-end points. Detaills: "+ME.message,true)
            end
        end

        % Value changed function: EditFieldEPLon
        function EditFieldEPLonValueChanged(app, event)
            value = app.EditFieldEPLon.Value;
            try
                app.linePoints(2,2)=value;
            catch ME
                app.showStatus("Error while updating start-end points. Detaills: "+ME.message,true)
            end
        end

        % Value changed function: EditFieldEPLat
        function EditFieldEPLatValueChanged(app, event)
            value = app.EditFieldEPLat.Value;
            try
                app.linePoints(2,1)=value;
            catch ME
                app.showStatus("Error while updating start-end points. Detaills: "+ME.message,true)
            end
        end

        % Callback function
        function PickpointsSwitch_3ValueChanged(app, event)
            value = app.PickpointsSwitch_3.Value;
            if(value=="On")
                app.parallelOrOrth=false;
            elseif(value=="Off")
                app.parallelOrOrth=true;
            end
        end

        % Value changed function: DropDown
        function DropDownValueChanged(app, event)
            value = app.DropDown.Value;
            if(value=="V. Para.")
                app.profileComponent=1;
                app.UIAxes.Title.String = 'Velocity Parallel';
            end
            if(value=="V. Orth.")
                app.profileComponent=2;
                app.UIAxes.Title.String = 'Velocity Orthogonal';
            end
            if(value=="V. Vertical")
                app.profileComponent=3;
                app.UIAxes.Title.String = 'Vertical Velocity';
            end
        end

        % Menu selected function: NetCDFMenu
        function LoadNetCDFMenuSelected(app, event)
            showStatus(app, "Please, select a NetCDF file")

            ff = fixfocus;
            [file,location] = uigetfile('*');
            delete(ff);

            if isequal(file,0)
                showStatus(app,"No scalar field loaded")
            else
                fullFileName = fullfile(location, file);
                showStatus(app,"User selected "+ string(fullFileName))
                %try
                    [Name,lonScalarF,latScalarF,gridVe,gridVn,gridVu]=ReadNetCDFFile(fullFileName);
                    ScalarVelocity=ScalarVelo(Name, lonScalarF, latScalarF, gridVe, gridVn, ...
                                gridVu, string(fullFileName));
                    app.ScalarVelocities.addField(ScalarVelocity)
                    UpdateScalarVeloList(app)
                    PlotVelocity(app)
                    showStatus(app,"Scalar Field successfully loaded")
                %catch ME
                    %showStatus(app, "Error while trying to load and plot scalar field (maybe incorrect format?). Details: " + ME.message, true);
                %end
            end
        end

        % Callback function
        function ClearScalarFieldsMenuSelected(app, event)
            h = findall(app.MapAxes, 'Tag', 'ScalarSquare');
            if ~isempty(h)
                delete(h);
            end
            app.LonScalarF = [];
            app.LatScalarF = [];
            app.GridVe = [];
            app.GridVn = [];
            app.GridVu = [];
            app.ClearScalarFieldsMenu.Enable = 'off';
        end

        % Callback function
        function PlotScalarFieldsMenuSelected(app, event)

        end

        % Button pushed function: SaveMapforGMTButton
        function SaveMapforGMTButtonPushed(app, event)
            
            showStatus(app, "Not implemented yet")

            %lon=app.velocityTable.lon;
            %lat=app.velocityTable.lat;
            %ve=app.velocityTable.ve;
            %vn=app.velocityTable.vn;
            %se=app.velocityTable.se;
            %sn=app.velocityTable.sn;


        end

        % Menu selected function: GNSSMenu
        function LoadGNSSveloMenuSelected(app, event)
            
            showStatus(app, "Please, select a file. Std format is lon, lat, ve, vn, vu, se, sn, su, name (and 1 line of header)")

            ff = fixfocus;
            [file,location] = uigetfile({'*.sta;*.sta.data;*.dat;*.txt'});
            delete(ff);

            if isequal(file,0)
                showStatus(app,"No velocity loaded")
            else
                fullFileName = string(fullfile(location, file));
                try
                    %delete(findall(app.MapAxes, 'Tag', 'GNSSVeloField'))
                    [Name,TableVelo]=ReadGNSSVelo(fullFileName);
                    disp(Name)
                    GNSSVelocity=GNSSVelo(Name,TableVelo,fullFileName,true);
                    disp(app.GNSSVelocities.Fields)
                    app.GNSSVelocities.addField(GNSSVelocity);
                    UpdateGNSSVeloList(app)
                    PlotVelocity(app)
                    showStatus(app,"Velocity field successfully loaded")
                catch ME
                    showStatus(app, "Error while trying to load and plot the velocity (maybe incorrect format?). Details: " + ME.message, true);
                end
            end

        end

        % Menu selected function: RiccardoNucciMenu
        function ContactsMenuSelected(app, event)

        email = 'riccardo.nucci4@unibo.it';
        subject = 'Support on GNSSProfiler';
        mailtoLink = sprintf('mailto:%s?subject=%s', email, subject);
        web(mailtoLink, '-browser');
        
        end

        % Value changed function: MinYProfile
        function SetMinYProfile(app, event)

            app.Ylimits(1)=app.MinYProfile.Value;

        end

        % Value changed function: MaxYProfile
        function SetMaxYProfile(app, event)

            app.Ylimits(2)=app.MaxYProfile.Value;

        end

        % Button pushed function: SetButton
        function SetMinMaxProfile(app, event)
            
            try
                app.UIAxes.YLim = app.Ylimits;
                showStatus(app,"Y-Limits on profile changed")
            catch ME
                showStatus(app,"Error while setting Y-limits on profile. Details: "+ ME.message,true)
            end

        end

        % Cell edit callback: GNSSVeloList
        function GNSSVeloListCellEdit(app, event)
            row = event.Indices(1);
            selected = event.NewData;
            name=string(app.GNSSVeloList.Data(row,1).(1));
            app.GNSSVelocities.changeSelectionByName(name,selected);
            PlotVelocity(app)
        end

        % Menu selected function: BasemapMenu, ColorterrainMenu, NoneMenu, 
        % ...and 1 other component
        function BasemapMenuSelected(app, event)
            src = event.Source;
            switch src.Text
                case 'Topographic'
                    geobasemap(app.MapAxes,'topographic')
                case 'Colorterrain'
                    geobasemap(app.MapAxes,'colorterrain')
                case 'Satellite'
                    geobasemap(app.MapAxes,'satellite');
                case 'None'
                    geobasemap(app.MapAxes,'none');
            end
            
        end

        % Menu selected function: ColorGNSS
        function ColorGNSSSelected(app, event)
            ff = fixfocus;
            newColor = uisetcolor;
            newHex = string(sprintf('#%02X%02X%02X', round(newColor(1)*255), round(newColor(2)*255), round(newColor(3)*255)));
            delete(ff);
            disp(newHex)
            if length(newColor) == 3
                for i=1:numel(app.GNSSVelocities.Fields)
                    if(app.GNSSVelocities.Fields(i).Selected)
                        app.GNSSVelocities.Fields(i).Colors(1)=newHex;
                        PlotVelocity(app)
                    end
                end
            end
        end

        % Cell edit callback: ScalarVeloList
        function ScalarVeloListCellEdit(app, event)
            row = event.Indices(1);
            selected = event.NewData;
            name=string(app.ScalarVeloList.Data(row,1).(1));
            app.ScalarVelocities.changeSelectionByName(name,selected);
            PlotVelocity(app)
        end

        % Menu selected function: ColorScalarSelected
        function ColorScalarSelectedSelected(app, event)
            ff = fixfocus;
            newColor = uisetcolor;
            newHex = string(sprintf('#%02X%02X%02X', round(newColor(1)*255), round(newColor(2)*255), round(newColor(3)*255)));
            delete(ff);
            disp(newHex)
            if length(newColor) == 3
                for i=1:numel(app.ScalarVelocities.Fields)
                    if(app.ScalarVelocities.Fields(i).Selected)
                        app.ScalarVelocities.Fields(i).Color=newHex;
                        PlotVelocity(app)
                    end
                end
            end
        end

        % Cell edit callback: FaultList
        function FaultListCellEdit(app, event)
            row = event.Indices(1);
            selected = event.NewData;
            name=string(app.FaultList.Data(row,1).(1));
            app.GFaultsDats.changeSelectionByName(name,selected);
            PlotVelocity(app)
        end

        % Menu selected function: SelectedGNSSMenu
        function SelectedGNSSMenuSelected(app, event)
            
        end

        % Value changed function: StationNamesCheckBox
        function StationNamesCheckBoxValueChanged(app, event)
            %value = app.StationNamesCheckBox.Value;
            PlotVelocity(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create QuickGNSSProfilePlotterUIFigure and hide until all components are created
            app.QuickGNSSProfilePlotterUIFigure = uifigure('Visible', 'off');
            app.QuickGNSSProfilePlotterUIFigure.Color = [0.9686 0.9686 0.9686];
            app.QuickGNSSProfilePlotterUIFigure.Position = [100 100 1471 802];
            app.QuickGNSSProfilePlotterUIFigure.Name = 'Quick GNSS Profile Plotter';
            app.QuickGNSSProfilePlotterUIFigure.Scrollable = 'on';

            % Create FileMenu
            app.FileMenu = uimenu(app.QuickGNSSProfilePlotterUIFigure);
            app.FileMenu.Text = 'File';

            % Create FaultsMenu
            app.FaultsMenu = uimenu(app.FileMenu);
            app.FaultsMenu.Text = 'Faults';

            % Create LoadMenu
            app.LoadMenu = uimenu(app.FaultsMenu);
            app.LoadMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadMenuSelected, true);
            app.LoadMenu.Text = 'Load';

            % Create ColorMenu
            app.ColorMenu = uimenu(app.FaultsMenu);
            app.ColorMenu.MenuSelectedFcn = createCallbackFcn(app, @ColorMenuSelected, true);
            app.ColorMenu.Text = 'Color';

            % Create VelocityfieldsMenu
            app.VelocityfieldsMenu = uimenu(app.FileMenu);
            app.VelocityfieldsMenu.Text = 'Velocity fields';

            % Create LoadMenu_2
            app.LoadMenu_2 = uimenu(app.VelocityfieldsMenu);
            app.LoadMenu_2.Text = 'Load';

            % Create GNSSMenu
            app.GNSSMenu = uimenu(app.LoadMenu_2);
            app.GNSSMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadGNSSveloMenuSelected, true);
            app.GNSSMenu.Text = 'GNSS';

            % Create NetCDFMenu
            app.NetCDFMenu = uimenu(app.LoadMenu_2);
            app.NetCDFMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadNetCDFMenuSelected, true);
            app.NetCDFMenu.Text = 'NetCDF';

            % Create ColorMenu_2
            app.ColorMenu_2 = uimenu(app.VelocityfieldsMenu);
            app.ColorMenu_2.Text = 'Color';

            % Create ColorGNSS
            app.ColorGNSS = uimenu(app.ColorMenu_2);
            app.ColorGNSS.MenuSelectedFcn = createCallbackFcn(app, @ColorGNSSSelected, true);
            app.ColorGNSS.Text = 'Selected GNSS';

            % Create ColorScalarSelected
            app.ColorScalarSelected = uimenu(app.ColorMenu_2);
            app.ColorScalarSelected.MenuSelectedFcn = createCallbackFcn(app, @ColorScalarSelectedSelected, true);
            app.ColorScalarSelected.Text = 'Selected NetCDF';

            % Create ClearMenu_2
            app.ClearMenu_2 = uimenu(app.VelocityfieldsMenu);
            app.ClearMenu_2.Text = 'Clear';

            % Create SelectedGNSSMenu
            app.SelectedGNSSMenu = uimenu(app.ClearMenu_2);
            app.SelectedGNSSMenu.MenuSelectedFcn = createCallbackFcn(app, @SelectedGNSSMenuSelected, true);
            app.SelectedGNSSMenu.Text = 'Selected GNSS';

            % Create SelectedNetCDFMenu
            app.SelectedNetCDFMenu = uimenu(app.ClearMenu_2);
            app.SelectedNetCDFMenu.Text = 'Selected NetCDF';

            % Create OptionsMenu
            app.OptionsMenu = uimenu(app.FileMenu);
            app.OptionsMenu.Text = 'Options';

            % Create BasemapsneedInternetconnMenu
            app.BasemapsneedInternetconnMenu = uimenu(app.OptionsMenu);
            app.BasemapsneedInternetconnMenu.Text = 'Basemaps (need Internet conn.)';

            % Create BasemapMenu
            app.BasemapMenu = uimenu(app.BasemapsneedInternetconnMenu);
            app.BasemapMenu.MenuSelectedFcn = createCallbackFcn(app, @BasemapMenuSelected, true);
            app.BasemapMenu.Text = 'Satellite';

            % Create TopographicMenu
            app.TopographicMenu = uimenu(app.BasemapsneedInternetconnMenu);
            app.TopographicMenu.MenuSelectedFcn = createCallbackFcn(app, @BasemapMenuSelected, true);
            app.TopographicMenu.Text = 'Topographic';

            % Create ColorterrainMenu
            app.ColorterrainMenu = uimenu(app.BasemapsneedInternetconnMenu);
            app.ColorterrainMenu.MenuSelectedFcn = createCallbackFcn(app, @BasemapMenuSelected, true);
            app.ColorterrainMenu.Text = 'Colorterrain';

            % Create NoneMenu
            app.NoneMenu = uimenu(app.BasemapsneedInternetconnMenu);
            app.NoneMenu.MenuSelectedFcn = createCallbackFcn(app, @BasemapMenuSelected, true);
            app.NoneMenu.Text = 'None';

            % Create InfoMenu
            app.InfoMenu = uimenu(app.QuickGNSSProfilePlotterUIFigure);
            app.InfoMenu.Text = 'Info';

            % Create ContactsMenu
            app.ContactsMenu = uimenu(app.InfoMenu);
            app.ContactsMenu.Text = 'Contacts';

            % Create RiccardoNucciMenu
            app.RiccardoNucciMenu = uimenu(app.ContactsMenu);
            app.RiccardoNucciMenu.MenuSelectedFcn = createCallbackFcn(app, @ContactsMenuSelected, true);
            app.RiccardoNucciMenu.Text = 'Riccardo Nucci';

            % Create LoadedDataPanel
            app.LoadedDataPanel = uipanel(app.QuickGNSSProfilePlotterUIFigure);
            app.LoadedDataPanel.BorderColor = [0 0 1];
            app.LoadedDataPanel.HighlightColor = [0 0 1];
            app.LoadedDataPanel.Title = 'Loaded Data';
            app.LoadedDataPanel.Position = [398 23 302 331];

            % Create GNSSVeloList
            app.GNSSVeloList = uitable(app.LoadedDataPanel);
            app.GNSSVeloList.ColumnName = {'GNSS v. name'; 'Selected'};
            app.GNSSVeloList.RowName = {};
            app.GNSSVeloList.SelectionType = 'row';
            app.GNSSVeloList.ColumnEditable = [false true];
            app.GNSSVeloList.CellEditCallback = createCallbackFcn(app, @GNSSVeloListCellEdit, true);
            app.GNSSVeloList.Position = [9 223 286 76];

            % Create ScalarVeloList
            app.ScalarVeloList = uitable(app.LoadedDataPanel);
            app.ScalarVeloList.ColumnName = {'Scalar v. name'; 'Selected'};
            app.ScalarVeloList.RowName = {};
            app.ScalarVeloList.SelectionType = 'row';
            app.ScalarVeloList.ColumnEditable = [false true];
            app.ScalarVeloList.CellEditCallback = createCallbackFcn(app, @ScalarVeloListCellEdit, true);
            app.ScalarVeloList.Position = [9 114 286 76];

            % Create FaultList
            app.FaultList = uitable(app.LoadedDataPanel);
            app.FaultList.ColumnName = {'Fault data name'; 'Selected'};
            app.FaultList.RowName = {};
            app.FaultList.SelectionType = 'row';
            app.FaultList.ColumnEditable = [false true];
            app.FaultList.CellEditCallback = createCallbackFcn(app, @FaultListCellEdit, true);
            app.FaultList.Position = [9 19 286 76];

            % Create StationNamesCheckBox
            app.StationNamesCheckBox = uicheckbox(app.LoadedDataPanel);
            app.StationNamesCheckBox.ValueChangedFcn = createCallbackFcn(app, @StationNamesCheckBoxValueChanged, true);
            app.StationNamesCheckBox.Text = 'Station Names';
            app.StationNamesCheckBox.Position = [9 199 100 22];

            % Create ProfilePanel
            app.ProfilePanel = uipanel(app.QuickGNSSProfilePlotterUIFigure);
            app.ProfilePanel.BorderColor = [0 0 1];
            app.ProfilePanel.HighlightColor = [0 0 1];
            app.ProfilePanel.Title = 'Profile';
            app.ProfilePanel.Position = [29 367 680 331];

            % Create UIAxes
            app.UIAxes = uiaxes(app.ProfilePanel);
            title(app.UIAxes, 'Velocity Parallel')
            xlabel(app.UIAxes, 'Distance along track (km)')
            ylabel(app.UIAxes, 'Velocity (mm/yr)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [17 16 644 286];

            % Create EditField_2
            app.EditField_2 = uieditfield(app.QuickGNSSProfilePlotterUIFigure, 'text');
            app.EditField_2.Editable = 'off';
            app.EditField_2.FontWeight = 'bold';
            app.EditField_2.BackgroundColor = [0.5294 0.8314 0.9608];
            app.EditField_2.Position = [29 740 681 22];

            % Create ProfileEditPanel
            app.ProfileEditPanel = uipanel(app.QuickGNSSProfilePlotterUIFigure);
            app.ProfileEditPanel.BorderColor = [0 0 1];
            app.ProfileEditPanel.HighlightColor = [0 0 1];
            app.ProfileEditPanel.Title = 'Profile Edit';
            app.ProfileEditPanel.Position = [29 23 344 253];

            % Create ProfilewidthkmEditField
            app.ProfilewidthkmEditField = uieditfield(app.ProfileEditPanel, 'numeric');
            app.ProfilewidthkmEditField.ValueChangedFcn = createCallbackFcn(app, @ProfilewidthkmEditFieldValueChanged, true);
            app.ProfilewidthkmEditField.Position = [132 171 77 23];
            app.ProfilewidthkmEditField.Value = 50;

            % Create PlotButton
            app.PlotButton = uibutton(app.ProfileEditPanel, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [133 132 77 22];
            app.PlotButton.Text = 'Plot';

            % Create PickpointsSwitch
            app.PickpointsSwitch = uiswitch(app.ProfileEditPanel, 'slider');
            app.PickpointsSwitch.ValueChangedFcn = createCallbackFcn(app, @PickpointsSwitchValueChanged, true);
            app.PickpointsSwitch.Position = [35 175 32 14];

            % Create StartPointlonlatLabel
            app.StartPointlonlatLabel = uilabel(app.ProfileEditPanel);
            app.StartPointlonlatLabel.Position = [21 36 108 22];
            app.StartPointlonlatLabel.Text = 'Start Point (lon-lat):';

            % Create EditFieldSPLon
            app.EditFieldSPLon = uieditfield(app.ProfileEditPanel, 'numeric');
            app.EditFieldSPLon.ValueDisplayFormat = '%11.6g';
            app.EditFieldSPLon.AllowEmpty = 'on';
            app.EditFieldSPLon.ValueChangedFcn = createCallbackFcn(app, @EditFieldSPLonValueChanged, true);
            app.EditFieldSPLon.Editable = 'off';
            app.EditFieldSPLon.HorizontalAlignment = 'center';
            app.EditFieldSPLon.BackgroundColor = [0.902 0.902 0.902];
            app.EditFieldSPLon.Position = [21 13 69 20];
            app.EditFieldSPLon.Value = [];

            % Create EditFieldSPLat
            app.EditFieldSPLat = uieditfield(app.ProfileEditPanel, 'numeric');
            app.EditFieldSPLat.ValueDisplayFormat = '%11.6g';
            app.EditFieldSPLat.AllowEmpty = 'on';
            app.EditFieldSPLat.ValueChangedFcn = createCallbackFcn(app, @EditFieldSPLatValueChanged, true);
            app.EditFieldSPLat.Editable = 'off';
            app.EditFieldSPLat.HorizontalAlignment = 'center';
            app.EditFieldSPLat.BackgroundColor = [0.902 0.902 0.902];
            app.EditFieldSPLat.Position = [95 13 69 20];
            app.EditFieldSPLat.Value = [];

            % Create EndPointlonlatLabel
            app.EndPointlonlatLabel = uilabel(app.ProfileEditPanel);
            app.EndPointlonlatLabel.Position = [183 37 104 22];
            app.EndPointlonlatLabel.Text = 'End Point (lon-lat):';

            % Create EditFieldEPLon
            app.EditFieldEPLon = uieditfield(app.ProfileEditPanel, 'numeric');
            app.EditFieldEPLon.ValueDisplayFormat = '%11.6g';
            app.EditFieldEPLon.AllowEmpty = 'on';
            app.EditFieldEPLon.ValueChangedFcn = createCallbackFcn(app, @EditFieldEPLonValueChanged, true);
            app.EditFieldEPLon.Editable = 'off';
            app.EditFieldEPLon.HorizontalAlignment = 'center';
            app.EditFieldEPLon.BackgroundColor = [0.902 0.902 0.902];
            app.EditFieldEPLon.Position = [183 14 69 20];
            app.EditFieldEPLon.Value = [];

            % Create EditFieldEPLat
            app.EditFieldEPLat = uieditfield(app.ProfileEditPanel, 'numeric');
            app.EditFieldEPLat.ValueDisplayFormat = '%11.6g';
            app.EditFieldEPLat.AllowEmpty = 'on';
            app.EditFieldEPLat.ValueChangedFcn = createCallbackFcn(app, @EditFieldEPLatValueChanged, true);
            app.EditFieldEPLat.Editable = 'off';
            app.EditFieldEPLat.HorizontalAlignment = 'center';
            app.EditFieldEPLat.BackgroundColor = [0.902 0.902 0.902];
            app.EditFieldEPLat.Position = [257 14 69 20];
            app.EditFieldEPLat.Value = [];

            % Create Switch
            app.Switch = uiswitch(app.ProfileEditPanel, 'slider');
            app.Switch.ValueChangedFcn = createCallbackFcn(app, @SwitchValueChanged, true);
            app.Switch.Position = [37 120 34 15];

            % Create PickpointsSwitchLabel_2
            app.PickpointsSwitchLabel_2 = uilabel(app.ProfileEditPanel);
            app.PickpointsSwitchLabel_2.HorizontalAlignment = 'center';
            app.PickpointsSwitchLabel_2.Position = [18 144 70 22];
            app.PickpointsSwitchLabel_2.Text = 'DisplayLine:';

            % Create ProfilewidthkmLabel
            app.ProfilewidthkmLabel = uilabel(app.ProfileEditPanel);
            app.ProfilewidthkmLabel.HorizontalAlignment = 'right';
            app.ProfilewidthkmLabel.Position = [120 198 101 22];
            app.ProfilewidthkmLabel.Text = 'Profile width (km):';

            % Create PickpointsLabel
            app.PickpointsLabel = uilabel(app.ProfileEditPanel);
            app.PickpointsLabel.HorizontalAlignment = 'center';
            app.PickpointsLabel.Position = [18 198 66 22];
            app.PickpointsLabel.Text = 'Pick points:';

            % Create InsertvaluesmanuallyLabel
            app.InsertvaluesmanuallyLabel = uilabel(app.ProfileEditPanel);
            app.InsertvaluesmanuallyLabel.HorizontalAlignment = 'center';
            app.InsertvaluesmanuallyLabel.Position = [21 68 128 22];
            app.InsertvaluesmanuallyLabel.Text = 'Insert values manually:';

            % Create PickpointsSwitch_2
            app.PickpointsSwitch_2 = uiswitch(app.ProfileEditPanel, 'slider');
            app.PickpointsSwitch_2.ValueChangedFcn = createCallbackFcn(app, @PickpointsSwitch_2ValueChanged, true);
            app.PickpointsSwitch_2.Position = [177 72 32 14];

            % Create DropDown
            app.DropDown = uidropdown(app.ProfileEditPanel);
            app.DropDown.Items = {'V. Para.', 'V. Orth.', 'V. Vertical'};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
            app.DropDown.Position = [248 151 77 26];
            app.DropDown.Value = 'V. Para.';

            % Create StatusbarLabel
            app.StatusbarLabel = uilabel(app.QuickGNSSProfilePlotterUIFigure);
            app.StatusbarLabel.HorizontalAlignment = 'center';
            app.StatusbarLabel.FontSize = 14;
            app.StatusbarLabel.FontWeight = 'bold';
            app.StatusbarLabel.Position = [29 767 74 23];
            app.StatusbarLabel.Text = 'Status bar:';

            % Create MapinMercatorProjectionPanel
            app.MapinMercatorProjectionPanel = uipanel(app.QuickGNSSProfilePlotterUIFigure);
            app.MapinMercatorProjectionPanel.BorderColor = [0 0 1];
            app.MapinMercatorProjectionPanel.HighlightColor = [0 0 1];
            app.MapinMercatorProjectionPanel.Title = 'Map in Mercator Projection';
            app.MapinMercatorProjectionPanel.Position = [741 56 701 613];

            % Create MouseLonEditFieldLabel
            app.MouseLonEditFieldLabel = uilabel(app.QuickGNSSProfilePlotterUIFigure);
            app.MouseLonEditFieldLabel.HorizontalAlignment = 'right';
            app.MouseLonEditFieldLabel.Position = [736 740 68 22];
            app.MouseLonEditFieldLabel.Text = 'Mouse Lon:';

            % Create MouseLonEditField
            app.MouseLonEditField = uieditfield(app.QuickGNSSProfilePlotterUIFigure, 'numeric');
            app.MouseLonEditField.ValueDisplayFormat = '%11.6g';
            app.MouseLonEditField.AllowEmpty = 'on';
            app.MouseLonEditField.Editable = 'off';
            app.MouseLonEditField.BackgroundColor = [0.902 0.902 0.902];
            app.MouseLonEditField.Position = [810 741 100 22];
            app.MouseLonEditField.Value = [];

            % Create MouseLatEditFieldLabel
            app.MouseLatEditFieldLabel = uilabel(app.QuickGNSSProfilePlotterUIFigure);
            app.MouseLatEditFieldLabel.HorizontalAlignment = 'right';
            app.MouseLatEditFieldLabel.Position = [736 711 64 22];
            app.MouseLatEditFieldLabel.Text = 'Mouse Lat:';

            % Create MouseLatEditField
            app.MouseLatEditField = uieditfield(app.QuickGNSSProfilePlotterUIFigure, 'numeric');
            app.MouseLatEditField.ValueDisplayFormat = '%11.6g';
            app.MouseLatEditField.AllowEmpty = 'on';
            app.MouseLatEditField.Editable = 'off';
            app.MouseLatEditField.BackgroundColor = [0.902 0.902 0.902];
            app.MouseLatEditField.Position = [810 711 100 22];
            app.MouseLatEditField.Value = [];

            % Create ScalePlus
            app.ScalePlus = uibutton(app.QuickGNSSProfilePlotterUIFigure, 'push');
            app.ScalePlus.ButtonPushedFcn = createCallbackFcn(app, @ScalePlusButtonPushed, true);
            app.ScalePlus.Position = [1207 711 35 22];
            app.ScalePlus.Text = '+';

            % Create ScaleMinus
            app.ScaleMinus = uibutton(app.QuickGNSSProfilePlotterUIFigure, 'push');
            app.ScaleMinus.ButtonPushedFcn = createCallbackFcn(app, @ScaleMinusButtonPushed, true);
            app.ScaleMinus.Position = [1164 711 35 22];
            app.ScaleMinus.Text = '-';

            % Create MouseLatEditFieldLabel_2
            app.MouseLatEditFieldLabel_2 = uilabel(app.QuickGNSSProfilePlotterUIFigure);
            app.MouseLatEditFieldLabel_2.HorizontalAlignment = 'right';
            app.MouseLatEditFieldLabel_2.Position = [1163 736 81 22];
            app.MouseLatEditFieldLabel_2.Text = 'Velocity scale:';

            % Create EditField_3
            app.EditField_3 = uieditfield(app.QuickGNSSProfilePlotterUIFigure, 'numeric');
            app.EditField_3.ValueChangedFcn = createCallbackFcn(app, @EditField_3ValueChanged, true);
            app.EditField_3.Position = [1060 712 58 21];
            app.EditField_3.Value = 3;

            % Create LegendmmyrLabel
            app.LegendmmyrLabel = uilabel(app.QuickGNSSProfilePlotterUIFigure);
            app.LegendmmyrLabel.Position = [967 711 90 22];
            app.LegendmmyrLabel.Text = 'Legend (mm/yr)';

            % Create PlotLegendButton
            app.PlotLegendButton = uibutton(app.QuickGNSSProfilePlotterUIFigure, 'push');
            app.PlotLegendButton.ButtonPushedFcn = createCallbackFcn(app, @PlotLegendButtonPushed, true);
            app.PlotLegendButton.Position = [1010 740 78 22];
            app.PlotLegendButton.Text = 'Plot Legend';

            % Create SaveDataButton
            app.SaveDataButton = uibutton(app.QuickGNSSProfilePlotterUIFigure, 'push');
            app.SaveDataButton.ButtonPushedFcn = createCallbackFcn(app, @SaveDataButtonPushed, true);
            app.SaveDataButton.Position = [620 711 90 22];
            app.SaveDataButton.Text = 'Save Data';

            % Create Lamp
            app.Lamp = uilamp(app.QuickGNSSProfilePlotterUIFigure);
            app.Lamp.Position = [1424 651 16 16];
            app.Lamp.Color = [1 0 0];

            % Create SaveMapforGMTButton
            app.SaveMapforGMTButton = uibutton(app.QuickGNSSProfilePlotterUIFigure, 'push');
            app.SaveMapforGMTButton.ButtonPushedFcn = createCallbackFcn(app, @SaveMapforGMTButtonPushed, true);
            app.SaveMapforGMTButton.Position = [1297 711 116 22];
            app.SaveMapforGMTButton.Text = 'Save Map for GMT';

            % Create PlotvelolimitsminmaxmmyrEditFieldLabel
            app.PlotvelolimitsminmaxmmyrEditFieldLabel = uilabel(app.QuickGNSSProfilePlotterUIFigure);
            app.PlotvelolimitsminmaxmmyrEditFieldLabel.HorizontalAlignment = 'right';
            app.PlotvelolimitsminmaxmmyrEditFieldLabel.Position = [29 711 183 22];
            app.PlotvelolimitsminmaxmmyrEditFieldLabel.Text = 'Plot velo-limits (min-max, mm/yr):';

            % Create MinYProfile
            app.MinYProfile = uieditfield(app.QuickGNSSProfilePlotterUIFigure, 'numeric');
            app.MinYProfile.ValueChangedFcn = createCallbackFcn(app, @SetMinYProfile, true);
            app.MinYProfile.HorizontalAlignment = 'left';
            app.MinYProfile.Position = [227 711 53 22];

            % Create MaxYProfile
            app.MaxYProfile = uieditfield(app.QuickGNSSProfilePlotterUIFigure, 'numeric');
            app.MaxYProfile.ValueChangedFcn = createCallbackFcn(app, @SetMaxYProfile, true);
            app.MaxYProfile.HorizontalAlignment = 'left';
            app.MaxYProfile.Position = [286 711 53 22];
            app.MaxYProfile.Value = 1;

            % Create SetButton
            app.SetButton = uibutton(app.QuickGNSSProfilePlotterUIFigure, 'push');
            app.SetButton.ButtonPushedFcn = createCallbackFcn(app, @SetMinMaxProfile, true);
            app.SetButton.Position = [346 711 53 22];
            app.SetButton.Text = 'Set';

            % Create ProfileinfoPanel
            app.ProfileinfoPanel = uipanel(app.QuickGNSSProfilePlotterUIFigure);
            app.ProfileinfoPanel.BorderColor = [0 0 1];
            app.ProfileinfoPanel.HighlightColor = [0 0 1];
            app.ProfileinfoPanel.Title = 'Profile info';
            app.ProfileinfoPanel.Position = [29 285 344 69];

            % Create WidthkmLabel
            app.WidthkmLabel = uilabel(app.ProfileinfoPanel);
            app.WidthkmLabel.Position = [9 23 71 21];
            app.WidthkmLabel.Text = 'Width (km):';

            % Create LengthkmLabel
            app.LengthkmLabel = uilabel(app.ProfileinfoPanel);
            app.LengthkmLabel.Position = [190 23 72 22];
            app.LengthkmLabel.Text = 'Length (km):';

            % Create NumberofvelocitiesLabel
            app.NumberofvelocitiesLabel = uilabel(app.ProfileinfoPanel);
            app.NumberofvelocitiesLabel.Position = [9 0 117 22];
            app.NumberofvelocitiesLabel.Text = 'Number of velocities:';

            % Create AzimuthdegLabel
            app.AzimuthdegLabel = uilabel(app.ProfileinfoPanel);
            app.AzimuthdegLabel.Position = [189 1 83 22];
            app.AzimuthdegLabel.Text = 'Azimuth (deg):';

            % Create LabelWidth
            app.LabelWidth = uilabel(app.ProfileinfoPanel);
            app.LabelWidth.BackgroundColor = [1 1 1];
            app.LabelWidth.HorizontalAlignment = 'center';
            app.LabelWidth.Position = [80 25 104 17];
            app.LabelWidth.Text = '';

            % Create LabelLength
            app.LabelLength = uilabel(app.ProfileinfoPanel);
            app.LabelLength.BackgroundColor = [1 1 1];
            app.LabelLength.HorizontalAlignment = 'center';
            app.LabelLength.Position = [265 25 69 17];
            app.LabelLength.Text = '';

            % Create LabelNVelo
            app.LabelNVelo = uilabel(app.ProfileinfoPanel);
            app.LabelNVelo.BackgroundColor = [1 1 1];
            app.LabelNVelo.HorizontalAlignment = 'center';
            app.LabelNVelo.Position = [130 3 53 17];
            app.LabelNVelo.Text = '';

            % Create LabelAzimuth
            app.LabelAzimuth = uilabel(app.ProfileinfoPanel);
            app.LabelAzimuth.BackgroundColor = [1 1 1];
            app.LabelAzimuth.HorizontalAlignment = 'center';
            app.LabelAzimuth.Position = [272 4 62 17];
            app.LabelAzimuth.Text = '';

            % Show the figure after all components are created
            app.QuickGNSSProfilePlotterUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GNSSProfiler

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.QuickGNSSProfilePlotterUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.QuickGNSSProfilePlotterUIFigure)
        end
    end
end