%RESAMPLING TRAJECTORRIES
    function [curve1_resampled, curve2_resampled] = resamplingTrajectories(curve1, curve2 ,splitter )
    
    
    % resampling
    %fprintf("\n Number of samples on GT : %d",  length(curve1) );
    %fprintf("\n Number of samples on Executed trajectory : %d",  length(curve2) );
    %select the max value
    if length(curve1) > length (curve2)
        resampling_size = length(curve1); %length(x_hom);
    else
        resampling_size = length(curve2); %length(x_hom);
    end
    
    resampling_size=resampling_size * splitter; % to match without splitter
    
    %fprintf("\n Number of samples to resample by arc distance : %d",  resampling_size);
    
    % 1) traject sim  (CURVE1)
    curve1_variable = [curve1(1,:); curve1(2,:)]' ;

       if resampling_size  ~=  length(curve1)
               
            curve1_resampled = resample_by_arc_length(curve1_variable, resampling_size);
    
       else
            curve1_resampled = curve1_variable;
       end


    % 2) Desired  (CURVE2)
    curve2_variable = [curve2(1,:); curve2(2,:)]';%curve2'; 

           if resampling_size  ~=  length(curve2)
               
            curve2_resampled = resample_by_arc_length(curve2_variable, resampling_size);
    
       else
            curve2_resampled = curve2_variable;
       end
     
    
    fprintf( '\n---- CALC ERRORS (without correspondence) ----');
    % calc RMSE
    RMSE = calc_RMSE(curve1_resampled, curve2_resampled);
    fprintf("\n\nRMSE: %.3f px on X", RMSE(1));
    fprintf("\nRMSE: %.3f px on Y", RMSE(2));
   
    
    
    
    % PLOTTING
    plotting_bool = false;

    if plotting_bool == true
        fprintf( '\n--- PLOTTING RESULTS ---\n');
    
        error_plot_interval = 10 ;
        
        %create camera view with desired wp's
        create_camera_view; % create camera view (gray image)
        plot_2D_points_onCameraView   % PLOT PROJECTED x_hom points on the camera
        plot_joined_wp = false; % to plot green joined wp's
        plot_2D_lines_onCameraView
        hold on;
        
    
        plot_traj_with_RMSE_errors(curve1_resampled, curve1_resampled, error_plot_interval);
    end
    
    
    %fprintf( '\n------------------------ FINISHIHG RESAMPLING SCRIPT --------------------------------\n');
end
