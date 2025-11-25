classdef ScalarVeloManager < handle

    properties
        Fields (:,1) ScalarVelo = ScalarVelo.empty(0,1)
    end

    methods
        function obj = ScalarVeloManager()
            obj.Fields=ScalarVelo.empty(0,1);
        end
       
        function addField(obj, field)
            arguments
                obj
                field ScalarVelo
            end

            obj.Fields(end+1) = field;
            obj.MakeUniqueNames;

        end

        function removeByName(obj, name)
            arguments
                obj
                name (1,1) string
            end

            idx = obj.indexByName(name);
            if ~isempty(idx)
                obj.Fields(idx) = [];
            end
        end

        function field = getByName(obj, name)
            arguments
                obj
                name (1,1) string
            end

            idx = obj.indexByName(name);
            if isempty(idx)
                field = ScalarVelo.empty;
            else
                field = obj.Fields(idx);
            end
        end

        function field = changeSelectionByName(obj, name, selected)
            arguments
                obj
                name (1,1) string
                selected (1,1) logical
            end

            idx = obj.indexByName(name);
            if isempty(idx)
                field = ScalarVelo.empty;
            else
                field = obj.Fields(idx);
            end
            field.Selected=selected;
            obj.Fields(idx) = field;
        end

        function names = listNames(obj)
            names = string.empty(0,1);
            for k = 1:numel(obj.Fields)
                names(k,1) = obj.Fields(k).Name;
            end
        end
    end

    methods (Access = private)
        function idx = indexByName(obj, name)
            if isempty(obj.Fields)
                idx = [];
                return;
            end
            allNames = arrayfun(@(f) f.Name, obj.Fields);
            idx = find(allNames == name, 1, 'first');
        end

        function MakeUniqueNames(obj)
            allNames = arrayfun(@(f) f.Name, obj.Fields);
            allNames = string(allNames);
            newNames=matlab.lang.makeUniqueStrings(allNames);
            for i=1:numel(allNames)
                obj.Fields(i).Name=newNames(i);
            end
        end
    end
end
