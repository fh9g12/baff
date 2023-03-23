classdef (Abstract) Base < matlab.mixin.Heterogeneous
    
    properties
        Eta (1,1) double;
        EtaDir (3,1) double = [0;1;0];
    end
    
    methods
        function out = plus(obj,delta_eta)
            for i = 1:length(delta_eta)
                out(i) = obj;
                out(i).Eta = out(i).Eta + delta_eta(i);
            end
        end
        function X = GetPos(obj,eta)
            % check we have an array of sorted stations
            etas = [obj.Eta];
            if ~issorted(etas)
                error('array of stations must be sorted in assending order (of eta)')
            end
            %deal with single length or a neagtive eta
            if length(etas)==1 || eta<=etas(1)
                X = obj(1).EtaDir*(eta-etas(1));
                return
            end
            %deal with all other cases
            idx = etas<eta;
            dirs = [obj(idx).EtaDir];
            etas = [etas(idx),eta];
            delta = repmat(etas(2:end)-etas(1:end-1),3,1).*dirs;
            X = sum(delta,2);
        end
    end
    methods (Abstract)
        stations = interpolate(obj,etas);
    end
end

