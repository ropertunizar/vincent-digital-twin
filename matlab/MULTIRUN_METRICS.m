%% VINCENT VAN DRONE - TRAJECTORY EXECUTION METRICS - 

% -------------------------------------------------------------------------
% CODE EXPLANATION:

% script to calculate the metrics of the previously executed trajectory 

% it inputs the rosbag and calculated trajectory  and user configs 

% it outputs in the same experiment folder as the trajectory generated 
        % Figures and TXT of the calculated metrics
        % TXT (with the terminal prints)


% -------------------------------------------------------------------------
% CODE STRUCTURE:
    
    % 00) CONFIGS (Sim/Real, total_runs, publishing methods...)
    
    % 01) MULTIRUN METRICS (MAIN LOOP)
    
    % 02) PLOT, SAVE METRICS & EXIT



%% 00) CONFIGS
% REPORT GENERATION

    clc % clear command window
    close all;

    diary 03_metrics_report.txt % Start recording to a file 


% USER CONFIGS

        CONFIGS_MULTIRUN_METRICS




%% 01) OBTAIN THE METRICS FOR THE EXECUTED RUNS

    fprintf('-------------------------------------------------------------------------\n');
    fprintf('------------------------ MULTIRUN METRICS -------------------------------\n');

    t1 = now; 
    time_now = datetime(t1,'ConvertFrom','datenum');
    fprintf('\n\n TIME = %s\n', time_now);


% LOOP FOR total_simulations_to_process

    for sim_counter = 1:total_simulations_to_process
    
        fprintf('\n-------------------------------------------------------------------------\n');
        fprintf("\n                      -    -- SIMULATION #%i  ---                 \n", sim_counter);
            
            if bool_compare_sim_real==false
                sim_analysis
            else 
                sim_analysis_v2_temp
            end 
           

                % 1) loads bag and plots trajectories
                % 2) obtain strajectory metrics
                    % a) 2D RESAMPLE AND CALC 2D DIST WITH METRICS
                    % b) 3D RESAMPLE AND CALC 3D DIST WITH METRICS
                    % c) 3D vel errors
                % 3) saves indiv sim data
    
            

    end


%% 02) PLOT STATISTICS METRICS AND SAVE METRICS AND FIGURES AND EXIT

    plot_mean_box
    saving_metrics % saving metrics txt
    saving_figures % saving figures


% FINISH MULTISIM_METRICS
    
    t1 = now; 
    time_now = datetime(t1,'ConvertFrom','datenum');
    fprintf('\n\n TIME = %s\n', time_now);
    
    fprintf('\n------------------------ Exiting MULTISIM METRICS -------------------------\n');
    fprintf('  ---------------------------------------------------------------------------\n');

% EXIT REPORT
    % Stop recording and move file
    diary off
    movefile("03_metrics_report.txt", path_log)