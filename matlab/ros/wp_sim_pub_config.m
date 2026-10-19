
if bool_use_last_values == false %to use the last stored values
    fprintf("NOT USING LAST VALUES!!!");

    %%%CAREFUL HERE
    %clearvars -except  load_folder_name file_name dist_threshold_fast dist_threshold_slow dist_between_goals_threshold print_speed_selection

    %file_name_wp_for_pub_core = "export_wp_to_publish_"+ file_name+ ".txt"; 
    load_path="/home/jdeese/Desktop/otherDroneStuff/01_MATLAB/tests/";
    export_prefix = "02_export/";
    %load_file_name_core = "export_wp_to_publish_wppicker_manual_v1"; 

    %load_file_name =  load_path + load_folder_name + export_prefix  + load_file_name_core;



    % read initial position
    path_initial_position = path_tests_folder + load_folder_name +"/" + export_prefix + "initial_position.txt";
    initial_position=readmatrix(path_initial_position);

else

    %to review
    exist_value = exist ('load_folder_name');
    if exist_value == 1

        %oad_path="/home/jdeese/Desktop/otherDroneStuff/01_MATLAB/tests/";
        %export_prefix = "/02_export/";
        %load_file_name_core = "export_wp_to_publish_"; 
        if pid_folder==true
            path_load_file_for_pub = path_load_wp_for_pub;
        else
            %load_file_name =  path_tests_folder + load_folder_name + export_prefix  + load_file_name_core + file_name + ".txt";
             load_folder_name = date_today_str;
             path_load_wp_for_pub = path_wp_for_pub;
        end

         
    else
         %load_file_name =  file_name_wp_for_pub ;
         %load_file_name_core = file_name_wp_for_pub_core;
         load_folder_name = date_today_str;
         path_load_wp_for_pub = path_wp_for_pub;
    end
    %load_folder_name = date_today_str;

end

% print loading info
fprintf(" Test: %s", load_folder_name);

fprintf("\n Loading file: %s \n \n", path_load_file_for_pub);
%fprintf("\n Loading file: %s \n \n", filename_wp_for_pub_core);

% LOAD DATA
WP_pub = readmatrix(path_load_file_for_pub);


%% change Reference syst matlab-Ros
% convert coordinates to publish
WPx_topublish = WP_pub(2,:);
WPy_topublish = -WP_pub(1,:);
WPz_topublish = WP_pub(3,:);
WP_topublish = [WPx_topublish; WPy_topublish; WPz_topublish];

%%
total_WP_toPub = length(WP_topublish); % how many wp's to publish