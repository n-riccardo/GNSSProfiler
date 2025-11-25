classdef GFaults

    properties
        Name (1,1) string = ""         
        Data (:,:) double = []; %NaN Separated              
        Depth (:,1) double = []; %NaN Separated
        Path (1,1) string = ""
        Selected (1,1) logical = true
        Color (1,1) string = "#000000"
    end

    methods
        function obj = GFaults(name, data, depth, path, selected, color)

            arguments
                name (1,1) string = ""
                data (:,:) double = [];
                depth (:,1) double = [];
                path (1,1) string = ""
                selected (1,1) logical = true
                color (1,1) string = "#000000"
            end

            obj.Name = name;
            obj.Data = data;
            obj.Depth = depth;
            obj.Path = path;
            obj.Selected = selected;
            obj.Color = color;
        end
    end

end