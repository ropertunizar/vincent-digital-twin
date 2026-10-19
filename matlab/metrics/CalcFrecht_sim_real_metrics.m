% TO OBTAIN METRICS


global traj3D_bool 
traj3D_bool = false;

 %% 1) 2D RESAMPLE PROJECTED AND DESIRED TRAJECT and obtain RSME without correspondence
 if metric_selector == 1

    fprintf(    '\n\n-----------------------------2D section-----------------------------');
    fprintf(   '    \n------------------ Resampling 2D projected curves-------------------');

    curve1_original = x_sim_toplot_hom; % px4 projected SIMULATION trajectory
    curve2_original = x_real_toplot_hom; % DESIRED projected trajectory

    %%% RESEAMPLING TRAJECTORIES
    splitter_graph=4; %for resampling
        [curve1_resampled, curve2_resampled] = resamplingTrajectories(curve1_original, curve2_original, splitter_graph);
   

    % follow the DESIRED trajectory and find closes point on SIMULATION/BAG
        search_case = 1; 
        % else other way around
        
        if search_case == 1
            curve1_search = curve1_resampled; 
            curve2_search = curve2_resampled;
        else
            curve1_search = curve2_resampled; 
            curve2_search = curve1_resampled;
        end
        
    
    %%% OBTAIN PAIRING TABLE 
        %fprintf ("\n--------------------- Starting CALC MIN DIST 2D ------------------------");
        [pairing_table, error_table_2D] = calc_mindist(curve1_search, curve2_search, max_search_radius);
        %fprintf(   '--------------------- Finishing CALC MIN DIST 2D ----------------------\n');


    % calcule errors
        square_error_2D = error_table_2D.^2;
        MSE_2D = mean(square_error_2D);
        RMSE_2D = sqrt(MSE_2D);
        max_error_2D = max(error_table_2D);
        min_error_2D = min(error_table_2D);
    
    
        fprintf("\n------ 2D METRICS (with correspondence; (max_search_radius = %i)) ------\n", max_search_radius);
        fprintf("max error = %.4f px \n", max_error_2D);
        fprintf("min error = %.4f px\n", min_error_2D);
        fprintf("RMSE = %.4f px\n", RMSE_2D);
  
    

    % plot 2D comparison
        if plot_sim_number == sim_counter
             fprintf ("\n\n----------------- Plotting PROJECTED 2D COMPARISON ----------------------\n");
             plot_mindist_2Dresults
        end
end




%% STORE METRICS

% vectors with results of simulation 
store_metrics

%%
fprintf('\n----------------------- METRICS SIMULATION #%i Obtained --------------------\n',sim_counter);
fprintf(  '----------------------------------------------------------------------------\n');