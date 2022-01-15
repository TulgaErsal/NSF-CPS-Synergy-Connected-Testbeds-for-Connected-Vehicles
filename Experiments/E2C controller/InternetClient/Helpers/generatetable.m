function [ X_points ] = generatetable( X_data, tq, spd, amount )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % X_points = zeros(length(tq),length(spd));
    % Tq and spd are meshgrids, change the former command to:[07182017]
    X_points = 0*tq;
    i = 1;
    j = 1;
    k = 1;
    while j <= length(amount)
        while i <= amount(j)
            X_points(i,j) = X_data(k);
            i = i+1;
            k = k+1;
        end
        while i > amount(j) && i <= max(amount)
            X_points(i,j) = X_data(k-1);
            i = i+1;
        end
        j = j+1;
        i = 1;
    end

end

