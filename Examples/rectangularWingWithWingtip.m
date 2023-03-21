% model = baff.model.Model;
% model.Name = 'DemoWing';
clear all

FoldAngle = 45; % wingtip fold angle in degrees
FlareAngle = 45; % wingtip fold angle in degrees

BarThickness = 4e-3;
BarWidth = 25e-3;
WingChord = 0.12;
BarChordwisePos = 0.25;
L = 1;
eta_hinge = 0.8;
eta_beam = 0.76;
% Make Aero Bar
mainBeam = baff.model.Wing.UniformWing(L*eta_beam,BarThickness,BarWidth...
    ,baff.model.Material.Stainless400,WingChord,BarChordwisePos,...
    "etaAeroMax",eta_hinge/eta_beam,"NAeroStations",10);
mainBeam.Name = 'Wing 1';

% Add Masses
xs = [-21,-21,-21,-21,-21,-17]*1e-3 + (BarChordwisePos-0.25)*WingChord;
ys = [100,240,380,520,660,767]*1e-3;
mass = [ones(1,5)*0.075,0.056];
inertias = [ones(1,5)*82,26;ones(1,5)*73,32;ones(1,5)*151,56]*1e-6;
% load('Wing2ndMass.mat')
for i = 1:length(xs)
    tmp_mass = baff.model.Mass(mass(i));
    tmp_mass.eta = ys(i)/(L*eta_hinge);
    tmp_mass.Offset(1) = xs(i);
    tmp_mass.Name = sprintf('tmp_mass_%.0f',i);
    tmp_mass.InertiaTensor = diag(inertias(:,i)');
    tmp_mass.mass= mass(i);
    mainBeam.add(tmp_mass);
end
% create hinge
hinge = baff.model.Hinge();
hinge.HingeVector = baff.util.rotz(FlareAngle)*[1;0;0];
hinge.Rotation = -FoldAngle;
hinge.isLocked = 0;
hinge.eta = 1;
hinge.Offset = [(BarChordwisePos-0.5)*WingChord L*(eta_hinge-eta_beam) 0];
hinge.Name = 'SAH';
mainBeam.add(hinge);

% add wingtip
wingtip = baff.model.Wing.UniformWing(0.2,4e-3,30e-3,baff.model.Material.Stiff,WingChord,0.5,NStations=4);
wingtip.eta = 1;
wingtip.Name = 'Wingtip';
hinge.add(wingtip);

%add wingtip mass
tmp_mass = baff.model.Mass(0.167);
tmp_mass.Offset = [-WingChord/4-0.022,0.087,0];
tmp_mass.Name = 'wingtip_mass';
tmp_mass.InertiaTensor = diag([942,122,1057])*1e-6;
wingtip.add(tmp_mass);

% Add Constraint
con = baff.model.Constraint("ComponentNums",123456,"eta",0,"Name","Root Connection");
con.add(mainBeam);

%draw
f = figure(1);
clf;
hold on
con.draw();
ax = gca;
ax.Clipping = false;
ax.ZAxis.Direction = "reverse";
axis equal

delete test.h5
baff.model.Model.GenTempHdf5('test.h5');
tic;
model = baff.model.Model;
model.AddElement(con);
model.UpdateIdx();
model.ToBaff('test.h5');
toc;

tic;
model2 = baff.model.Model.FromBaff('test.h5');
toc;

%draw
f = figure(2);
clf;
hold on
model2.draw();
ax = gca;
ax.Clipping = false;
ax.ZAxis.Direction = "reverse";
axis equal