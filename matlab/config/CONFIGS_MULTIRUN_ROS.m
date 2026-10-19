%% CONFIGS FOR MULTIRUNS_ROS.m



    % DATA
    % IMPORTANT!!!
    bool_use_last_values = false; %to use last values (from last execution variables, paths...)


    if bool_use_last_values == false % EDIT FOLDER AND FILE TO LOAD         
   
        load_folder_name = "nikolaus";   % trajectory folder in matlab/trajectories/

        %path_tests_folder = "/home/jdeese/Desktop/otherDroneStuff/01_MATLAB/00_VINCENT_VAN_DRONE/99_export/00_tests/"; % path to save
        path_tests_folder = string(fullfile(fileparts(fileparts(mfilename("fullpath"))), "trajectories")) + "/";   % repo-relative

        path_tests_subfolder = "";

        path_tests_folder = path_tests_folder+path_tests_subfolder;

        path_actual_test_folder = path_tests_folder + load_folder_name +"/";

        %for WP or VEL PUBLISHING 
        load_file_name = "export_wp_to_publish_Nikolaus";   % !!!!IMPORTANT   %% CHANGE HERE
        %load_file_name = "export_wp_to_publish_Star"; 
        %load_file_name = "export_wp_to_publish_Lines";filename_vel_for_pub_core

        %load_file_name = "export_vel_to_publish_Nikolaus";
        %load_file_name = "export_vel_to_publish_Star";
        %load_file_name = "export_vel_to_publish_Lines";
        export_prefix = "";   % trajectory files sit directly in the trajectory folder
        save_log_bool = true;
        path_load_file_for_pub = path_tests_folder +  load_folder_name +"/" + export_prefix + load_file_name + ".txt";

    else

        load_folder_name = date_today_str + "/";

    end


    % 20261014 TARGET DRONE (namespace) AND VISION-ORIGIN OFFSET
    %   '/sim'     -> PX4 SITL twin (instance 1, sysid 2). Its vision origin is its spawn point in the Gazebo/OptiTrack world.
    %   '/vincent' -> real Vincent (NanoPi mavros). Vision origin = OptiTrack origin -> offset [0 0 0].
    ns = '/vincent';
    %spawn_offset = [4.4, -0.28, 0];   % [x y z] of the SITL spawn (sitl_vincent.launch x:= y:=). Use [0 0 0] for '/vincent'.
    spawn_offset = [0, 0, 0];
    auto_arm = true;
    

    % INITIAL COMMAND CONFIGS
    offset_initial_position = [ 0 , 0 , 0]; % to offset from traj generator
    
    % TAKE-OFF
    enable_intial_position_reader = true; % to enable topic reader for take_off

            x_take_off = 2; % default if reader not enabled
            y_take_off = -2; % default
            z_take_off = 0.9; % for take_off [m]
    
    
    waittime_finish_takeoff = 10; % seconds to consider take-off done

    % GOAL REACHED HOVER
        distance_goal_reached = 0.05; % distance in m to considered target reached
        holding_position_counter_max = 40 ; % number of times the position is reached to considered goal reached (avoid oscilations)
        waittime_finish_hover = 3; % seconds
        
    % ROS 
        waittime_selector = 0; % 0 for publishing vels at calc_waittime
    
        %wait_time_between_sim = rostime(10);
        %configs_vincent; %load configs just in case, debugging

     % ROSBAG recording
        rosbag_prefix=  "03_rosbag/";
        path_rosbag_folder = path_actual_test_folder + rosbag_prefix;
        targetFolder = path_rosbag_folder;

        path_elapsed_time_array = path_rosbag_folder+ "/elapsed_time_array.txt";

        mkdir(path_rosbag_folder);

         % 20261014 namespaced topics + ground truth (OptiTrack) + Gazebo states
         topics = [ns '/mavros/local_position/pose ' ns '/mavros/local_position/velocity_local' ...
         ' ' ns '/mavros/setpoint_raw/target_local /started_publishing_vel' ...
         ' ' ns '/mavros/setpoint_position/local ' ns '/mavros/setpoint_raw/local ' ns '/mavros/state' ...
         ' /optitrack/pose /gazebo/model_states'];