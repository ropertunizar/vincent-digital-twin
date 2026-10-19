
%USER CONFIGS FOR MULTIRUN_METRICS

load_bag_name = bagFile; % or change manualy below
bool_use_last_values = false; % if false, check configs_multisim_metrics for setup 
plot_sim_number = 1; %if we want to plot a certain simulation of the whole bag; if none, 0
total_simulations_to_process = total_runs; %to process a certain number of simulations max: total_runs
%total_simulations_to_process = 1; %to process only the first

    
bool_compare_sim_real = true; %20260706 added for comparing projected sim and real   

common_path = "/home/jdeese/Desktop/otherDroneStuff/01_MATLAB/00_VINCENT_VAN_DRONE/99_export/00_tests/";

sim_test_path = "old/v1/01_rest/";
sim_folder_name="20250623-201606_niko_sim_qp_5runs_higherP/";
sim_file_name="03_rosbag/indiv_sims/sim3/X_bag_toplot_3D.txt";

real_test_path ="old/v1/00_tfm/";
real_folder_name="20250623-135275_niko_gopro_qp_3runs_best/";
real_file_name="03_rosbag/indiv_sims/sim3/X_bag_toplot_3D.txt";




%  Plot and save simulations
save_indiv_simulations = true; % to store indiv simulations for laters
plot_div = degree + 2;




    CONFIGS_VINCENT; %needed for extra variables

    % to load last used values or a specific folder
    if bool_use_last_values == true

       
       load_test_folder_name = load_folder_name;
       path_actual_test_folder = path_tests_folder + load_folder_name ;
        

    
    else %TO SELECT MANUALLY
        
        
        

        load_folder_name = "20260706-172975" ; %"20250624-091096_Niko_Gopro4:3_wp_3runs";       %% CHANGE HERE
        path_actual_test_folder = path_tests_folder + load_folder_name + "/";
        
        color_traj = [1 0.5 0]; % ORANGE
        plot_splitted = false;
        

        %SET UP DEPENDING ON THE SIM
        %total_runs=1;

        drawing_mode = 1;                  %% CHANGE DRAWING MODE HERE
            % 1 = Nikolaus; 
            % 2 = Illustrator; 
            % 3 = load previous;
            % 4 = Manual; 
            % 5 = star;
            % 6 = lines;
            % 7 = circle;
            % 99 = niko 3d

        drawing_configs

        optitrack_cam = false;       %% CHANGE CAMERA HERE
        optitrack_cam_num = 1;
        gopro_cam = true; % to gopro cam settings 

        camera_configs


    end


% CONFIG calc_mindist 
    max_search_radius = 100; %max amount of samples to look for forwards and backwards
    plot_interval = 1; % interval to lighten the PC's work
    metric_selector = 1; %set to 0 to avoid calculating metrics
    total_metrics = 7 ; %to draw boxes later
    metrics_stored = zeros(total_metrics,total_runs);


% create folder to save indiv sims
    if save_indiv_simulations == true
   
       path_indiv_sims_folder = path_actual_test_folder + rosbag_prefix+ "indiv_sims";
        mkdir(path_indiv_sims_folder);
    
    end


%%


plot_sim_metrics = true; % for plotting graphs
plot_div = 5; % to plot pos, vel , acc






