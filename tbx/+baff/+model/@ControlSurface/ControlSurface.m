classdef ControlSurface
    properties
        Name string = ""    % Name
        Etas (2,1) double = [0;1];       % start and end eta along the wing
        pChord (2,1) double = [0.1;0.1]; % Percentage of chord that is control surface at either end
    end
    methods (Static)
        obj = FromBaff(filepath,loc);
        TemplateHdf5(filepath,loc);
    end
    
    methods
        function obj = ControlSurface(name,etas,pChords)
            arguments
                name string
                etas (2,1) double
                pChords (2,1) double
            end
            obj.Name = name;
            obj.Etas = etas;
            obj.pChord = pChords;
        end
        function draw(obj,Parent,opts)
            arguments
                obj
                Parent baff.model.Wing
                opts.Origin (3,1) double = [0,0,0];
                opts.A (3,3) double = eye(3);
            end
            for i = 1:length(obj)
                beamLoc = [Parent.Stations.GetPos(obj(i).Etas(1)),Parent.Stations.GetPos(obj(i).Etas(2))];
                aeroLoc = [Parent.AeroStations.GetPos(obj(i).Etas(1),[1-obj(i).pChord(1),1]),...
                    Parent.AeroStations.GetPos(obj(i).Etas(2),[1,1-obj(i).pChord(2)])];
                points = beamLoc(:,[1,1,2,2]).*Parent.EtaLength + aeroLoc;
                points = repmat(opts.Origin,1,4) + opts.A*points;
                patch(points(1,:)',points(2,:)',points(3,:)',[1 1 1],'FaceAlpha',.5);
            end
        end
    end
end

