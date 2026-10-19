
%% LOAD results from file and PUBLISH VEL's

if bool_use_last_values == false %to use the last stored values

    %clearvars -except   load_folder_name load_file_name path_load_file_for_pub path_tests_folder waittime_selector altitude
 
    %load_path="/home/jdeese/Desktop/otherDroneStuff/01_MATLAB/tests/";
    export_prefix = "02_export/";
    %load_file_name_core = "export_vel_to_publish_wppicker_manual_v1"; 

    load_file_name =  path_load_file_for_pub;

    % read initial position
    path_initial_position = path_tests_folder + load_folder_name +"/" + export_prefix + "initial_position.txt";
    initial_position=readmatrix(path_initial_position);

    path_load_vel_for_pub = path_load_file_for_pub;
    
else
    
 

    exist_value = exist ('load_folder_name');
    if exist_value ==1
         load_folder_name = date_today_str;
         path_load_vel_for_pub = path_vel_for_pub;
    else
         % load_file_name =  file_name_vel_for_pub ;
         % load_file_name_core = file_name_vel_for_pub_core;   


         load_folder_name = date_today_str;
         path_load_vel_for_pub = path_vel_for_pub;
    end

   

end

%print loading info
fprintf("Test: %s", load_folder_name);
fprintf("\nLoading file: %s \n", path_load_vel_for_pub);

%LOAD DATA
Vel_pub = readmatrix(path_load_vel_for_pub);




%% to publish velocities stored in vx_topublish, vy_topublish, vz_topublish
% take the RESULTS from the TRAJECTORY GENERATOR and publish them
vx_topublish = Vel_pub(2,:);
vy_topublish = -Vel_pub(1,:);
vz_topublish = Vel_pub(3,:);
Ti_topublish = Vel_pub(4,:);

%%
total_flighttime = Vel_pub(4,end);
fprintf("\nTotal flight time:= %i seconds", total_flighttime);

% to check if use the Ti_toplot interval or calc_waittime as rate for pub
if waittime_selector > 1
    fprintf("\nusing Ti_toplot to calc variable rate\n");
else
    calc_waittime= total_flighttime / (length(Ti_topublish)-1) ;
    calc_rate = 1 / calc_waittime;
    fprintf("\nusing Total flight to calc_rate = %i HZ\n", calc_rate);
end