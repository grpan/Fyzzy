function [dH,dV] = sense(pos )
%SENSE - Use the car's sensors
%   Calculate the car's sensors from the car's position vector
    
    x = pos(1);
    y = pos(2);

    if x<=5
        dV = y;
    elseif x<=6
        dV = y-1;
    elseif x<= 7
        dV = y-2;
    else
        dV = y-3;
    end
    
    if y<=1
        dH = 5-x;
    elseif y<= 2
        dH = 6-x;
    elseif y<= 3
        dH = 7-x;
    else
        dH = 1;
    end
    
    if dH>1;
        dH = 1;
    end
    if dV>1;
        dV=1;
    end

end