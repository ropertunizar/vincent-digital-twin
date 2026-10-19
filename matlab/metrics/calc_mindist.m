% calc min distance from each point in the sim trajectory to the gt
%clc;
function [pairing_table,error_table] = calc_mindist(curve1, curve2, max_search_radius)
global traj3D_bool    % to calculate 3D distance, else 2D
    

    
    %max_search_radius = 30; %max amount of samples to look for forwards and backwards
    %plot_interval = 1; % interval to lighten the PC's work
    fprintf ("\nmax_search_radius = %i\n", max_search_radius);

    
         %for debugging
    calc_initial = true ;
    calc_middle = true;
    calc_final = true; 
    total_points = 0; %for plotting
    
    if calc_initial == true
        total_points = total_points + max_search_radius;
    end
    if calc_middle == true
        total_points = total_points + length (curve1) - 2*max_search_radius ; 
    end
    if calc_final == true
        total_points = total_points + max_search_radius;
    end
    %fprintf("total points to plot = %i\n", total_points);
   
    
    
    
    % function to create pairing_table and error_table
    [pairing_table, error_table] = findmindistance_table (curve1, curve2, ...
        max_search_radius, calc_initial, calc_middle, calc_final);
    
   


    
   
end