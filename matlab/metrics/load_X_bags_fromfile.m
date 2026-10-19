%% after running simulation PX4 SITL
%run after main to display both trajectories on same fig

%clc




 %% REAL TRAJECTORY GOPRO CAM
color_real = 'yellow';
camera_selection = 1;

gopro_cam = true;

camera_configs; 

P_matrix_real= P_matrix;
real_file = common_path + real_test_path + real_folder_name + real_file_name;

 X_real_toplot_3D= readmatrix(real_file);
 
 t_real_toplot=X_real_toplot_3D(4,:);
 X_real_toplot_3D=X_real_toplot_3D(1:3,:);
 X_real_toplot_3D = [X_real_toplot_3D(1,:); X_real_toplot_3D(2,:); X_real_toplot_3D(3,:); ones(1,length(X_real_toplot_3D))];
 
 fprintf(   '\n--- projecting into camera ---\n');
 x_real_toplot_hom = project_trajectory(P_matrix_real, X_real_toplot_3D); 


 %% SIM TRAJECTORY  1080 16:9 CAM
color_sim = 'blue';

camera_selection=0;
gopro_cam = false;

camera_configs; 

P_matrix_sim = P_matrix;

sim_file = common_path + sim_test_path + sim_folder_name + sim_file_name;

 X_sim_toplot_3D= readmatrix(sim_file);
 t_sim_toplot=X_sim_toplot_3D(4,:);

 X_sim_toplot_3D=X_sim_toplot_3D(1:3,:);
 X_sim_toplot_3D = [X_sim_toplot_3D(1,:); X_sim_toplot_3D(2,:); X_sim_toplot_3D(3,:); ones(1,length(X_sim_toplot_3D))];

% project traject SIM into camera
fprintf(   '\n--- projecting into camera ---\n');
x_sim_toplot_hom = project_trajectory(P_matrix_sim,X_sim_toplot_3D); 

%% PLOTTING
if plot_sim_number == sim_counter

    fprintf(   '\n--- Plotting individual sim ---\n');


        
    % PLOT 2D DESIRED DRAWING
     fprintf(' drawing_mode = Nikolaus \n');
        sequence_nikolaus = [1, 2, 3, 4, 2, 5, 4, 1, 5]; %v1
        %sequence_nikolaus = [1, 2, 3, 4, 5, 1, 4, 2, 5]; %v2
    
        num_wp_to_plot = 5; % to load (5 full house)
        
        seq_length = nikolaus_seq_length; % in configs  Nikolaus sequence lenght (9 full house)
        fprintf(' seq_length = %d \n\n', seq_length);
        
        
        num_wp_to_travel = seq_length;


            load_wp_niko %LOAD WP NIKO

        seq_to_travel = sequence_nikolaus(1:seq_length); %wp numbers of the travel sequence

        
        wp_uv = wp_Niko;  %variable with desired drawing
        num_wp = num_wp_to_travel;
        %seq_to_plot = seq_to_travel; 
        seq_to_plot=(1:1:length(wp_uv));


uv_desired = wp_uv; % variable with desired drawing

create_labels % for numbering the 2d points (in utils)


if plot_2D_camera_view  == true

    % create camera view (gray image)
    fprintf(' --- creating 2D camera view... \n');
        create_camera_view;

    % plot 2d Points on camera view
    fprintf(' --- plotting 2D points on camera view... \n');
        figure2 = plot_2D_points_onCameraView(wp_uv, label, plot_labels_2D_bool, colorplot_uv, sizemarker_uv, "wps");   % PLOT PROJECTED x_hom points on the camera

    % plot lines joining wp's
    plot_joined_wp_bool=false;
    if plot_joined_wp_bool == true

        fprintf(' --- plotting 2D joining lines ... \n');
            plot_2D_lines_onCameraView; 

    end

    axis([0 sensor(1) 0 sensor(2)]) % to recenter the image to only the size of the sensor


        %aa_load_2D_wp_and_plot
    
    % PLOT 2D TRAJECTORY SIM


            display_name = "Trajectory SIM executed";
        p1 = plot_project_2D_trajectory_points(x_sim_toplot_hom, color_sim, sensor, display_name); % plot 2D projected onto camera
        

        display_name_2 = "Trajectory REAL executed";
        p2 = plot_project_2D_trajectory_points(x_real_toplot_hom, color_real, sensor, display_name_2); % plot 2D projected onto camera
end           

        % 
        % 
        %                      %project calculated traj again
        %             exist_q = exist("q");
        %             if exist_q == 0
        % 
        %             % load q 
        %             path_to_q = path_actual_test_folder + export_prefix + "q.txt";
        %             q = readmatrix(path_to_q);
        % 
        %             % load qd 
        %             path_to_qd = path_actual_test_folder + export_prefix + "qd.txt";
        %             qd = readmatrix(path_to_qd);
        % 
        %             % load qdd 
        %             path_to_qdd = path_actual_test_folder + export_prefix + "qdd.txt";
        %             qdd = readmatrix(path_to_qdd);
        % 
        %             % load tvec 
        %             path_to_tvec = path_actual_test_folder + export_prefix + "tvec.txt";
        %             tvec = readmatrix(path_to_tvec);
        %             tpts_init=tvec(1:samples*splitter:end); %careful with spliter
        % 
        % 
        %             % drawing 3D WP's
        %             path_to_totalwps = path_actual_test_folder + drawing_prefix + "drawing_3D_WPs.txt";
        %             initial_wpts_loaded = readmatrix(path_to_totalwps);
        %             total_waypoints_init = length (initial_wpts_loaded);
        % 
        %             Wpts_init = initial_wpts_loaded;
        % 
        %             % drawing 3d WP's split
        %             path_to_totalwps_split = path_actual_test_folder + export_prefix + "export_3D_" + file_name_mode+ ".txt";
        %             initial_wpts_split_loaded = readmatrix(path_to_totalwps_split);
        %             total_waypoints_split = length (initial_wpts_split_loaded);
        %         else
        %         end
        % 
        % 
        %         if ros_pub_selector>1 %to avoid plotting if wp public
        % 
        %                      % PLOT 2D CALCULATED/PUBLISHED TRAJECTORY
        %         total_minipoints = size(q,2);
        %         X_calc_toPlot_hom = [q; ones(1,total_minipoints)];
        %         x_hom_calc = project_trajectory(P_matrix,X_calc_toPlot_hom); %
        %         %plot calculated 2d traject sin
        %         display_name = "Trajectory calculated";
        %         p2 = plot_project_2D_trajectory_points (x_hom_calc, color_traj, sensor, display_name);
        %         legend([lines_plotted(1) p2 p1], {"Desired Drawing", "Trajectory calculated", "Trajectory Executed"},'Location','southwest')
        % 
        %         end
        % 
        % 
        % 
        % 
        % % PLOT POS VEL ACC GRAPHS
        %     %Plot_posvelacc_ros
        %     Plot_posvelacc_v2
        %     %Plot_posvelaccjerksnap_v2 %CHECK 
        % 
        %     %add title
        %     title_string ="simulation number " + string(sim_counter);
        %     sgtitle(title_string);
        % 
        %     legend("Trajectory calculated", "Trajectory Executed", "wpts");
        % 
        % 
        % 
        % 
        % 



end