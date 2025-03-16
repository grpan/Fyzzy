clear
clc


%% Analog Linear PID.

Kp = 200/150; mu = 19; Ki=Kp*mu;
Omega = tf(18.69, [1 12.064]);
PI = tf([Kp Ki], [1 0]);
Hk = minreal((Omega * PI ) / (1 + Omega * PI));
step_analog = stepinfo(Hk);

%% Initial Fuzzy-PI

a = 1 / mu; Ke=1; Kd = a*Ke; K1 =  Kp / (a*Ke);
mdl = "control_simu";load_system("simulink/control_simu");
print('-scontrol_simu', '-dpng', '-r200', '../images/control_simu_main');
print('-scontrol_simu/Fuzzy PI Controller', '-dpng', '-r200', '../images/control_simu_Fuzzy_PI_Controller');
simIn1 = Simulink.SimulationInput(mdl);
simIn1 = setBlockParameter(simIn1,"control_simu/Signal Editor", "ActiveScenario", "Step");
simIn1 = setModelParameter(simIn1, "StartTime", "-0.05", "StopTime", "0.5", ...
    "SolverType", "Variable-step", "MaxStep","0.001");%, "UserString", "Initial");
simIn1.UserString = "Initial ";
simout1 = sim(simIn1);

%% Final Fuzzy-PI
a_t = a * 0.4 ; Ke_t=Ke * 1.5; Kd_t = a_t*Ke_t; K1_t = 3.4*K1; % tuned parameters
simIn2 = Simulink.SimulationInput(mdl);
simIn2 = setBlockParameter(simIn2,"control_simu/Signal Editor", "ActiveScenario", "Step");
simIn2 = setModelParameter(simIn2, "StartTime", "-0.05", "StopTime", "0.5", ...
    "SolverType", "Variable-step", "MaxStep","0.001");%, "UserString", "Final");
simIn2.UserString = "Final ";
simIn2 = setVariable(simIn2, 'a',a_t);
simIn2 = setVariable(simIn2, 'Ke', Ke_t);
simIn2 = setVariable(simIn2, 'Kd', Kd_t);
simIn2 = setVariable(simIn2, 'K1', K1_t);
simout2 = sim(simIn2);


step_init = stepinfo(simout1.logsout{1}.Values.Data, simout1.logsout{1}.Values.Time, 150, 0);
step_final= stepinfo(simout2.logsout{1}.Values.Data, simout2.logsout{1}.Values.Time, 150, 0);

fprintf("Analog PI: RiseTime: %4.2f ms, Overshoot: %4.2f%%, Settling: %4.2fms\n", [step_analog.RiseTime*1000 step_analog.Overshoot step_analog.SettlingTime*1000]);
fprintf('Rise-Time Before tuning:     %6.2f ms. after: %6.2f ms.\n',[step_init.RiseTime*1000 step_final.RiseTime*1000]);
fprintf('Overshoot Before tuning:       %6.2f%%. after:   %6.2f%%.\n',[step_init.Overshoot step_final.Overshoot]);
fprintf('Settling time Before tuning: %6.2f ms. after: %6.2f ms.\n',[step_init.SettlingTime*1000 step_final.SettlingTime*1000]);
createfigure("Initial Tuning", ["Initial " "Final " "Step"],[simout1.logsout{1}, simout2.logsout{1}, simout2.logsout{2}]);


%% Scenario 1
simIn1 = setBlockParameter(simIn1,"control_simu/Signal Editor", "ActiveScenario", "Scenario1");
simIn1 = setModelParameter(simIn1, "StartTime", "0", "StopTime", "30");
simIn1.UserString = "Scenario 1 ";
simout1 = sim(simIn1);

simIn2 = setBlockParameter(simIn2,"control_simu/Signal Editor", "ActiveScenario", "Scenario1");
simIn2 = setModelParameter(simIn2, "StartTime", "0", "StopTime", "30");
simIn2.UserString = "Scenario 1 ";
simout2 = sim(simIn2);
createfigure("Scenario 1", ["initial" "Final " "Linear" "Pulse"],[simout1.logsout{1}, simout2.logsout{1}, simout2.logsout{2}, simout2.logsout{3}], [[10-0.02 10+0.25]; [20-0.02 20+0.25]]);

% Perform Parameter sweep
sf = [0.5 1.0 2];
Ke_vals = Ke*sf; a_vals = a* sf; Kd_vals=a_vals*Ke; K1_vals = K1*sf;
simIn = createArray(1,9, FillValue=Simulink.SimulationInput(mdl));
simIn = setBlockParameter(simIn,"control_simu/Signal Editor", "ActiveScenario", "Step");
simIn = setModelParameter(simIn, "StartTime", "-0.05", "StopTime", "0.3", ...
    "SolverType", "Variable-step", "MaxStep","0.0005");%, "UserString", "Final");
for i = 1:length(Ke_vals)
    simIn(i).UserString = "Sweep";
    simIn(i) = setVariable(simIn(i),'Ke',Ke_vals(i));%,'Workspace','control_simu')
end
for i = 1:length(a_vals)
    simIn(i+3).UserString = "Sweep";
    simIn(i+3) = setVariable(simIn(i+3),'Kd',Kd_vals(i));%,'Workspace','control_simu')
end
for i = 1:length(K1_vals)
    simIn(i+6).UserString = "Sweep";
    simIn(i+6) = setVariable(simIn(i+6),'K1',K1_vals(i));%,'Workspace','control_simu')
end
simout = sim(simIn);
createfigure("Sweep Ke", "Ke " + compose("%.1f ", Ke_vals), [simout(1).logsout{1}, simout(2).logsout{1}, simout(3).logsout{1}]);
createfigure("Sweep a", "a " + compose("%.3f ", a_vals), [simout(1+3).logsout{1}, simout(2+3).logsout{1}, simout(3+3).logsout{1}]);
createfigure("Sweep K1", "K1 " + compose("%.2f ", K1_vals), [simout(1+6).logsout{1}, simout(2+6).logsout{1}, simout(3+6).logsout{1}]);

% Plot fis (gensurf)
fis = readfis("flb.fis");
[X, Y, Z] = gensurf(fis, gensurfOptions("NumGridPoints", [9,9]));
f = figure('visible','off');
set(gcf,'units','points','position',[10,10,800,500]);
% surface(X, Y, Z);view(3);
surf(X, Y, Z);view(3);
xlabel("E");ylabel("Delta E");zlabel("Delta U");
labelHandle = get(gca,'XLabel');
labelHandle.Interpreter = 'none';
labelHandle = get(gca,'YLabel');
labelHandle.Interpreter = 'none';
labelHandle = get(gca,'ZLabel');
labelHandle.Interpreter = 'none';
xMin=min(min(X)); xMax=max(max(X));
yMin=min(min(Y)); yMax=max(max(Y));
zMin=min(min(Z)); zMax=max(max(Z));
if zMin==zMax, zMin=-inf; zMax=inf; end
axis([xMin xMax yMin yMax zMin zMax])
exportgraphics(f, "../images/" + "gensurf" + ".png");
close(f);

% Eval e is PS (0.25) and delta E is NS (-0.25)
evalfis(fis, [-0.25, 0.25]);

%% Scenario 2
simIn1 = setBlockParameter(simIn1,"control_simu/Signal Editor", "ActiveScenario", "Scenario2");
% simIn1 = setModelParameter(simIn1, "StartTime", "0", "StopTime", "30");
simIn1.UserString = "Scenario 2 ";
simout1 = sim(simIn1);

simIn2 = setBlockParameter(simIn2,"control_simu/Signal Editor", "ActiveScenario", "Scenario2");
% simIn2 = setModelParameter(simIn2, "StartTime", "0", "StopTime", "30");
simIn2.UserString = "Scenario 2 ";
simout2 = sim(simIn2);
createfigure("Scenario 2", ["Initial" "Final " "Linear" "Trapezoid"],[simout1.logsout{1}, simout2.logsout{1}, simout2.logsout{2}, simout2.logsout{3}], [[10-0.02 10+0.2]; [20-0.02 20+0.2]]);


%% Scenario 3
mdl_tl = "control_simu_disturbance";load_system("simulink/control_simu_disturbance");
print('-scontrol_simu_disturbance', '-dpng', '-r200', '../images/control_simu_disturbance');
simIn1 = Simulink.SimulationInput(mdl_tl);
simIn1 = setBlockParameter(simIn1,"control_simu_disturbance/Signal Editor", "ActiveScenario", "Step");
simIn1 = setModelParameter(simIn1, "StartTime", "0", "StopTime", "30", ...
    "SolverType", "Variable-step", "MaxStep","0.001");%, "UserString", "Final");
simIn1.UserString = "Scenario 3 ";
simout1 = sim(simIn1);

simIn2 = Simulink.SimulationInput(mdl_tl);
simIn2 = setBlockParameter(simIn2,"control_simu_disturbance/Signal Editor", "ActiveScenario", "Step");
simIn2 = setModelParameter(simIn2, "StartTime", "0", "StopTime", "30", ...
    "SolverType", "Variable-step", "MaxStep","0.001");%, "UserString", "Final");
simIn2.UserString = "Scenario 3 ";
simIn2 = setVariable(simIn2, 'a',a_t);
simIn2 = setVariable(simIn2, 'Ke', Ke_t);
simIn2 = setVariable(simIn2, 'Kd', Kd_t);
simIn2 = setVariable(simIn2, 'K1', K1_t);
simout2 = sim(simIn2);
createfigure("Scenario 3", ["Initial " "Final " "" "Step"],[simout1.logsout{3}, simout2.logsout{3}, simout2.logsout{4}, simout2.logsout{2}], [[10-0.02 10+0.2]; [20-0.02 20+0.2]]);
createfigure("Scenario 3 Disturbance", ["" "Disturbance"],[simout2.logsout{3}, simout2.logsout{1}]);
