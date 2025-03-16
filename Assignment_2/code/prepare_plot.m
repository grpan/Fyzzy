function prepare_plot(car,initial_pos, Name)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
figure;
axis equal

area( [5 5 6 6 7 7 10 10],[0 1 1 2  2 3 3 0], 'FaceColor',0.5*ones(1,3), FaceAlpha=0.5);
axis([4 11 0 5]);
set(gca,'DataAspectRatio',[1 1 1])
hold on

plot(car.desired_pos(1),car.desired_pos(2),'xr', 'LineWidth', 0.06);
plot(initial_pos(1),initial_pos(2),'+r', 'LineWidth', 0.06);

title(Name);

legend('Walled Area', 'Location','southeast');
end