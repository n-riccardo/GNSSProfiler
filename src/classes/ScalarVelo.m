classdef ScalarVelo
    
    properties
        Name (1,1) string = ""         
        LonScalarF (:,1) double = [];
        LatScalarF (:,1) double = [];
        GridVe (:,:) double = [];
        GridVn (:,:) double = [];
        GridVu (:,:) double = [];
        Path (1,1) string = "" 
        Selected (1,1) logical = true
        Color (1,1) string = "#000000"
    end
    
    methods
        function obj = ScalarVelo(name, lonScalarF, latScalarF, gridVe, gridVn, ...
                gridVu, path, selected, color)

            arguments
                name (1,1) string = ""
                lonScalarF (:,1) double = [];
                latScalarF (:,1) double = [];
                gridVe (:,:) double = [];
                gridVn (:,:) double = [];
                gridVu (:,:) double = [];
                path (1,1) string = ""
                selected (1,1) logical = true
                color (1,1) string = "#000000"
            end

            obj.Name = name;
            obj.LonScalarF = lonScalarF;
            obj.LatScalarF = latScalarF;
            obj.GridVe = gridVe;
            obj.GridVn = gridVn;
            obj.GridVu = gridVu;
            obj.Path = path;
            obj.Selected = selected;
            obj.Color = color;
        end
    end
end

