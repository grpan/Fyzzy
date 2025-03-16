function trajectory = simulate(car, theta, idx)
%SIMULATE - Simulate and Plot
%   Simulate the car's trajectory and plot
    

path = zeros(300, 2);
i = 0;
car.theta = theta;
h = animatedline('SeriesIndex', idx, 'LineWidth', 0.4 , 'DisplayName', string(theta) + '°');


%% Main event loop
while(true)

    i = i + 1;
    path(i, :) = car.pos;
    addpoints(h , path(i,1), path(i,2) );
    drawnow
    if i==300
        break;
    end


    
    [dH, dV] = sense(car.pos);

    % DeltaTheta = 0.4;
    DeltaTheta = evalfis(car.fis, [dV, dH,car.theta]);
    % DeltaTheta = evalfis(car.fis, [car.theta, dV, dH]); % For experimental


    car.theta = car.theta + DeltaTheta;
    car.pos = car.pos + car.speed * [cosd(car.theta) sind(car.theta)];


    if car.pos(1) > car.desired_pos(1)
        trajectory = [path(1:i,1) path(1:i,2)];
        break;
    end
    if car.pos(2) > car.desired_pos(2) + 2
        break;
    end



    
end


end