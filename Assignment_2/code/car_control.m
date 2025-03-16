clear; clc;close all;


%% Initial Parameters
initial_pos = [4.1 0.3];

initial_thetas = [0 -45 -90];
% initial_thetas = linspace(-180, 180,10);
car.desired_pos = [10 3.2];
car.pos = initial_pos;

car.speed = 0.05;

%% Main event loop

% Initial Fuzzy Controller, only the Fuzzy Rules have been tuned.
car.fis = readfis('CarControllerInitial');
prepare_plot(car, initial_pos, "Initial Controller")
cumerror = 0;
final_pos = zeros(length(initial_thetas),2);
for i = 1:length(initial_thetas)
    trajectory = simulate(car, initial_thetas(i), i);
    final_pos(i,:) = trajectory(end,:);
    cumerror = cumerror + abs(final_pos(i,2) - car.desired_pos(2));

    p = plot(final_pos(i,1), final_pos(i,2), 'xr', 'LineWidth', 0.2);
    p.Annotation.LegendInformation.IconDisplayStyle  = 'off';
    % fprintf("Target Delta: %4.3f \n", final_pos(i,2) - car.desired_pos(2) );

end

exportgraphics(gcf, "../images/initial_fis_ALL.png", 'Resolution',300);
plotMFs(car.fis, 'InitialMFs');
std_Initial = std(final_pos)*1000;
fprintf("Initial MFs: Average y Cumulative Error (mm) is: %4.3f , Standard Deviation: %4.3f \n" ...
    , cumerror*1000 / length(initial_thetas) , std_Initial(2));


% Final Fuzzy Contoller, MFs have been tuned.
hold off;
car.fis = readfis('CarControllerMFsAltered');
prepare_plot(car, initial_pos, 'Final Controller (Tuned MFs)')
cumerror = 0;
final_pos = zeros(length(initial_thetas),2);
for i = 1:length(initial_thetas)
    trajectory = simulate(car, initial_thetas(i), i);
    final_pos(i,:) = trajectory(end,:);
    cumerror = cumerror + abs(final_pos(i,2) - car.desired_pos(2));

    p = plot(final_pos(i,1), final_pos(i,2), 'xr', 'LineWidth', 0.2);
    p.Annotation.LegendInformation.IconDisplayStyle  = 'off';
    % fprintf("Target Delta:                                 %4.3f \n", final_pos(i,2) - car.desired_pos(2) );

end

exportgraphics(gcf, "../images/Tuned_fis_ALL.png", 'Resolution',300);
plotMFs(car.fis, 'FinalMFs');
std_AlteredMFs = std(final_pos)*1000;
fprintf("Tuned MFs: Average y Cumulative Error (mm) is: %4.3f , Standard Deviation: %4.3f \n" ...
    , cumerror*1000 / length(initial_thetas) , std_AlteredMFs(2));

