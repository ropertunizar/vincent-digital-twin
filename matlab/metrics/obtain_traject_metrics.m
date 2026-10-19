% TO OBTAIN METRICS


global traj3D_bool 
traj3D_bool = false;

 %% 1) 2D RESAMPLE PROJECTED AND DESIRED TRAJECT and obtain RSME without correspondence
 if metric_selector == 1

    fprintf(    '\n\n-----------------------------2D section-----------------------------');
    fprintf(   '    \n------------------ Resampling 2D projected curves-------------------');

    curve1_original = x_sim_toplot_hom; % px4 projected SIMULATION trajectory
    curve2_original = uv_desired; % DESIRED projected trajectory

    %%% RESEAMPLING TRAJECTORIES
    splitter_graph=4; %for resampling
        [curve1_resampled, curve2_resampled] = resamplingTrajectories(curve1_original, curve2_original, splitter_graph);
   

    % follow the DESIRED trajectory and find closes point on SIMULATION/BAG
        search_case = 2; 
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


%% 2) 3D RESAMPLE and METRICS

    %plot subgraphs resampled
    % plot XYZ min dist
    %plot_posvelacc_ros_minDist

        % 1) RESAMPLE 3D
            
            fprintf(    '\n----------------------------- 3D section-----------------------------');
            fprintf(   '\n------------------------ Resampling 3D curves------------------------------');
        
                % IMPORTANT order
                curve1_original_3D = X_bag_toplot_3D(1:3,:); % px4 3D sim trajectory
                curve2_original_3D = q(1:3,:); % desired 3D trajectory
                %curve2_original_3D = Wpts_init(1:3,:); % desired 3D trajectory
                
                % curve1_original_3D =  Wpts_init(1:3,:); % desired 3D trajectory
                % curve2_original_3D =X_bag_toplot_3D(1:3,:); % px4 3D sim trajectory
            
            
                %%% RESAMPLE
                [curve1_resampled_3D, curve2_resampled_3D] = resampling3DTrajectories(curve1_original_3D, curve2_original_3D);
        





        %2) CALC MIN DIST
            
            %fprintf( '\n----------------------------------------------------------------------');
            %fprintf( '\n--------------------- Starting CALC MIN DIST 3D ----------------------');

        
            % follow the DESIRED trajectory and find closes point on SIMULATION/BAG
                search_case =1; 
                % else other way around
                
                if search_case == 1
                    curve1_search_3D = curve1_resampled_3D; 
                    curve2_search_3D = curve2_resampled_3D;
                else
                    curve1_search_3D = curve2_resampled_3D; 
                    curve2_search_3D = curve1_resampled_3D;
                end


                traj3D_bool = true;
        
                [pairing_table_3D, error_table_3D ] = calc_mindist(curve1_search_3D ,curve2_search_3D ,max_search_radius);
            %fprintf(   '--------------------- Finishing CALC MIN DIST 3D ------------------------\n');
                
                
                % calcule errors
                    square_error_3D = error_table_3D.^2;
                    MSE_3D = mean(square_error_3D);
                    RMSE_3D = sqrt(MSE_3D);
                    max_error_3D = max(error_table_3D);
                    min_error_3D = min(error_table_3D);
                
                
                    fprintf("\n------ 3D METRICS (with correspondence; (max_search_radius = %i) ------\n", max_search_radius);
                    fprintf("max error = %.4f m \n", max_error_3D);
                    fprintf("min error = %.4f m \n", min_error_3D);
                    fprintf("RMSE = %.4f m \n", RMSE_3D);
          
        
            
        %3) PLOTTING 3D RESULTS
        
            if plot_sim_number == sim_counter %plot selected sim run
                 
                total_points = length(curve1_resampled_3D);
        
                figure_number= 8; % 3D comparision with frechet sim-traj vs desired 3D lines

                plot_traj_3D_with_pairing_table(curve1_resampled_3D, curve2_resampled_3D, ...
                    plot_interval, pairing_table_3D, total_points,figure_number,search_case);
                    
            end

%% CALCULATE 3D VEL ERROR

% 1) resample 3D vels

fprintf('   \n------------------- Calculating 3DVel Errors ------------------------');

calculate_3Dvel_errors  % (V_bag_toplot_3D vs qd)
    
    if plot_sim_number == sim_counter

            % PLOT ERRORS
            figure(6);hold on;

            title_string ="velocity errors run #" + string(sim_counter);
            sgtitle(title_string);
            linewidth_3Dvel = 3;

            plot_interval_3Dvel = 10; % to not plot the whole thing

            % X coordinate
                subplot(3,1,1);
                color_vel_x 
                hold on;
            % Y coordinate
                subplot(3,1,2);
                color_vel_y
                hold on;
            % Z coordinate
                subplot(3,1,3);
                color_vel_z
                hold on;
    end

    fprintf("\n------ 3D Vel METRICS -------\n");
    fprintf("RMSE_3D_vel_x = %.4f m/s \n", RMSE_3D_vel_x);
    fprintf("RMSE_3D_vel_y = %.4f m/s \n", RMSE_3D_vel_y);
    fprintf("RMSE_3D_vel_z = %.4f m/s \n", RMSE_3D_vel_z);

%% STORE METRICS

% vectors with results of simulation 
store_metrics

%%
fprintf('\n----------------------- METRICS SIMULATION #%i Obtained --------------------\n',sim_counter);
fprintf(  '----------------------------------------------------------------------------\n');