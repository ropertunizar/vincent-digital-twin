   
    %% 1) LOAD ROSBAG
    
    fprintf(   '\n------------------------ Importing ROSBAG ------------------------------');
    
    topic_to_read = ["/mavros/local_position/pose", "X_bag_toplot";
                    "/mavros/local_position/velocity_local", "V_bag_toplot";
                    "/mavros/setpoint_raw/target_local", "Target_local_toplot",
                    "/started_publishing_vel", "started_publishing_vel"];
    
        % importing rosbag and plotting 2D projection and  3D traj
        % will plot the simulation = plot_sim_number

    % LOAD BAG AND PLOT 2D SIM and graphs
    load_rosbag_aferSIM

        %% 2) OBTAIN METRICS
   
    fprintf('\n\n------------------------ Obtaining METRICS ------------------------------');
    
    obtain_traject_metrics % main script to calculate and plot metrics
    %CalcFrecht_sim_real_metrics
         %fprintf("\n--- Sim duration:= %.4f  ---\n", duration_sim);
    
    %% CREATE FOLDER AND SAVE DATA FROM INDIVIDUAL SIM
    
    if save_indiv_simulations == true
        fprintf('\n\n------------------------ saving INDIV SIM ------------------------------');
        path_indiv_sims_folder_simnumber = path_indiv_sims_folder + "/sim" + sim_counter;
        mkdir(path_indiv_sims_folder_simnumber);
    
        path_indiv_sim_pos = path_indiv_sims_folder_simnumber + "/X_bag_toplot_3D.txt";
        path_indiv_sim_vel = path_indiv_sims_folder_simnumber + "/V_bag_toplot_3D.txt";
        path_indiv_sim_acc = path_indiv_sims_folder_simnumber + "/ACC_bag_toplot_3D.txt";


    
        writematrix(X_bag_toplot_3D, path_indiv_sim_pos);
        writematrix (V_bag_toplot_3D, path_indiv_sim_vel);
        writematrix (ACC_bag_toplot_3D, path_indiv_sim_acc);
    end


