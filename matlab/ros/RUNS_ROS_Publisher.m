%% RUNS ROS PUBLISHER   

% Plot loaded picture

create_folder = false; % leave as false to not create folder when loading configs
plot_2D_cam_view_with_loaded_wp_bool = false; % PLOT loaded 2D image?

if plot_2D_cam_view_with_loaded_wp_bool == true
    fprintf( '\n-> Plotting loaded drawing \n');
    plot_2D_cam_view_with_loaded_wp
end

%% SELECT PUBLISHER


switch ros_pub_selector

    case 1
    fprintf('     MODE = WP PUBLISHER \n');
    % config for WP
    % distance between goals i and i+1
    dist_threshold_fast = 0.05;  % for bigger gaps less accurate
    dist_threshold_slow = 0.03;  %for slow parts
    dist_between_goals_threshold = 0.1; % min size gap for fast
    print_speed_selection = false; %to plot in wp publish the threshold distance (FAST/SLOW)

        RUNS_ROS_WP_Publisher

    case 2
    fprintf('      MODE = VEL PUBLISHER \n');

        RUNS_ROS_Vel_Publisher

    case 3 
    fprintf('      MODE = RAW PUBLISHER \n');
    
        RUNS_ROS_Raw_Publisher

end


