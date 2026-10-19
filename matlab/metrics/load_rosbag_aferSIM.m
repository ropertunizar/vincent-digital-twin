%% after running simulation PX4 SITL
%run after main to display both trajectories on same fig

%clc

%% configs
color_sim = 'yellow';

%load_folder_name= "20250503-101153_robsag";
%load_bag_name = "2025-05-03-10-14-49";

%load_bag_path = path_actual_test_folder;
%load_prefix = "03_rosbag/";
%file_suffix = ".bag";



%% read topics
fprintf(   '\n--- reading ROSBAG ---\n');
rosbag_read_topics


%% PLOTTING IF NEEDED


% project traject SIM into camera
fprintf(   '\n--- projecting into camera ---\n');
x_sim_toplot_hom = project_trajectory(P_matrix,X_bag_toplot_hom); 

if plot_sim_number == sim_counter

    fprintf(   '\n--- Plotting individual sim ---\n');

    % PLOT 3D TRAJECT SIM PX4
        plot_3D_traj(X_bag_toplot, Y_bag_toplot, Z_bag_toplot, color_sim, 100); % plot 3D trajectory
        figure_3D = figure(3);
        legend({'Trajectory executed'},'Location','southwest')
        hold off;
        %add title
        title_string ="Trajectory run #" + string(sim_counter);
        title(title_string);

        
    % PLOT 2D DESIRED DRAWING
        aa_load_2D_wp_and_plot
    
    % PLOT 2D TRAJECTORY SIM
        display_name = "Trajectory executed";
        p1 = plot_project_2D_trajectory_points(x_sim_toplot_hom, color_sim, sensor, display_name); % plot 2D projected onto camera
        
            
    
                             %project calculated traj again
                    exist_q = exist("q");
                    if exist_q == 0
                   
                    % load q 
                    path_to_q = path_actual_test_folder + export_prefix + "q.txt";
                    q = readmatrix(path_to_q);
            
                    % load qd 
                    path_to_qd = path_actual_test_folder + export_prefix + "qd.txt";
                    qd = readmatrix(path_to_qd);
                    
                    % load qdd 
                    path_to_qdd = path_actual_test_folder + export_prefix + "qdd.txt";
                    qdd = readmatrix(path_to_qdd);
            
                    % load tvec 
                    path_to_tvec = path_actual_test_folder + export_prefix + "tvec.txt";
                    tvec = readmatrix(path_to_tvec);
                    tpts_init=tvec(1:samples*splitter:end); %careful with spliter
                    
            
                    % drawing 3D WP's
                    path_to_totalwps = path_actual_test_folder + drawing_prefix + "drawing_3D_WPs.txt";
                    initial_wpts_loaded = readmatrix(path_to_totalwps);
                    total_waypoints_init = length (initial_wpts_loaded);
        
                    Wpts_init = initial_wpts_loaded;
            
                    % drawing 3d WP's split
                    path_to_totalwps_split = path_actual_test_folder + export_prefix + "export_3D_" + file_name_mode+ ".txt";
                    initial_wpts_split_loaded = readmatrix(path_to_totalwps_split);
                    total_waypoints_split = length (initial_wpts_split_loaded);
                else
                end


                if ros_pub_selector>1 %to avoid plotting if wp public

                             % PLOT 2D CALCULATED/PUBLISHED TRAJECTORY
                total_minipoints = size(q,2);
                X_calc_toPlot_hom = [q; ones(1,total_minipoints)];
                x_hom_calc = project_trajectory(P_matrix,X_calc_toPlot_hom); %
                %plot calculated 2d traject sin
                display_name = "Trajectory calculated";
                p2 = plot_project_2D_trajectory_points (x_hom_calc, color_traj, sensor, display_name);
                legend([lines_plotted(1) p2 p1], {"Desired Drawing", "Trajectory calculated", "Trajectory Executed"},'Location','southwest')
                
                end


    
    
        % PLOT POS VEL ACC GRAPHS
            %Plot_posvelacc_ros
            Plot_posvelacc_v2
            %Plot_posvelaccjerksnap_v2 %CHECK 

            %add title
            title_string ="simulation number " + string(sim_counter);
            sgtitle(title_string);
    
            legend("Trajectory calculated", "Trajectory Executed", "wpts");
        
            

       
   



end