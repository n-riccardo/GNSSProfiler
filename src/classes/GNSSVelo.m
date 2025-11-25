classdef GNSSVelo

    properties
        Name (1,1) string = ""         
        Data table = table()              
        Path (1,1) string = "" 
        Selected (1,1) logical = true
        Colors (1,2) string = ["#000000","#8F8F8F"]
    end

    methods
        function obj = GNSSVelo(name, data, path, selected, colors)

            arguments
                name (1,1) string = ""
                data table = table() 
                path (1,1) string = ""
                selected (1,1) logical = true
                colors (1,2) string = ["#000000","#8F8F8F"]
            end

            obj.Name = name;
            obj.Data = data;
            obj.Path = path;
            obj.Selected = selected;
            obj.Colors = colors;
        end
    end

end