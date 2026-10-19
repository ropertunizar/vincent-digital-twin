%RESAMPLING TRAJECTORRIES
    function [curve1_resampled, curve2_resampled] = resampling3DTrajectories(curve1, curve2)
    
    
    %% resampling
    %fprintf("\n Number of samples on GT : %d",  length(curve1) );
    %fprintf("\n Number of samples on Executed trajectory : %d",  length(curve2) );
    %select the max value
    if length(curve1) > length (curve2)
        resampling_size = length(curve1); %length(x_hom);
    else
        resampling_size = length(curve2); %length(x_hom);
    end

    
    %fprintf("\n Number of samples to resample by arc distance : %d",  resampling_size);
    
    % 1) traject sim 
    %curve1_variable = [curve1(1,:); curve1(2,:)]' ;
    curve1_variable = curve1';
    
    if resampling_size  ~=  length(curve1_variable)

        curve1_resampled = resample_by_arc_length_3D(curve1_variable, resampling_size);
        else
            curve1_resampled = curve1_variable;

    end

    
    
    % 2) Desired 
    curve2_variable = curve2'; 
    if resampling_size  ~=  length(curve2_variable)

        curve2_resampled = resample_by_arc_length_3D(curve2_variable, resampling_size);
    else 
        curve2_resampled = curve2_variable; 
    end

   
    %% calc RMSE
    fprintf( '\n---- CALC ERRORS (without correspondence) ----'); %important without correspondence
    
    RMSE = calc_RMSE_3D(curve1_resampled, curve2_resampled);
    fprintf("\n\nRMSE: %.3f m on X", RMSE(1));
    fprintf("\nRMSE: %.3f m on Y", RMSE(2));
    fprintf("\nRMSE: %.3f m on Z", RMSE(3));
    
    
    
   
  
    
    
    %fprintf( '\n------------------------ FINISHIHG RESAMPLING SCRIPT --------------------------------\n');
end
