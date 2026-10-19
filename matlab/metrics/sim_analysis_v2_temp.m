   
    %% 1) LOAD ROSBAG
    
    fprintf(   '\n------------------------ Loading X_BAGS.txt ------------------------------');
    

    load_X_bags_fromfile

        %% 2) OBTAIN METRICS
   
    fprintf('\n\n------------------------ Obtaining METRICS ------------------------------');
    
    %obtain_traject_metrics % main script to calculate and plot metrics
    CalcFrecht_sim_real_metrics
         %fprintf("\n--- Sim duration:= %.4f  ---\n", duration_sim);
    

