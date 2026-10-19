%% VINCENT VAN DRONE - TRAJECTORY PUBLISHING - 

% -------------------------------------------------------------------------
% CODE EXPLANATION:

% script to execute a previously calculated trajectory (possibility to 
% excute multiple times, and various publishing methods) in:
%     a) simulation environment (ROS1 PX4_SITL, GAZEBO CLASSIC, QGROUNDCONTROL, RVIZ)
%     b) real drone platform 

% it inputs the calculated trajectory (q.txt, qd.txt, qdd.txt, tvec.txt) and user configs (sim/real, total_runs, publishing methods... )

% it outputs in the same experiment folder as the trajectory generated 
        % ROSBAG containing all the runs
        % TXT file with the initial and final times and duration of the run 
        % Log and TXT (with the multirun settings and terminal prints)


% -------------------------------------------------------------------------
% CODE STRUCTURE:

% 00) CONFIGS (Sim/Real, total_runs, publishing methods...)

% 01) MULTIRUNS
    % aa) - SETUP ENVIRONMENT ROS
    % bb) - TAKE-OFF DRONE 
    % cc) - RUN EXECUTION LOOP 
    	% STEP 0) ROSBAG RECORD (previous to the loop)
	    % STEP 1) FLY TO INITIAL POSITION
        % STEP 2) HOVER AT CURRENT STARTING POSITION
        % STEP 3) START PUBLISHING !!!
        % STEP 4) HOVER AT CURRENT FINISHING POSITION
    % dd) - LANDING SEQUUENCE (FOR REAL DRONE)

% 02) SAVING AND EXITING



%% 00) CONFIGS

% REPORT GENERATION
    clc % clear command window
    diary 02_traj_exec_report.txt % Start recording to a file 

% SIM OR REAL
    simulation = false; % true FOR PX4 SITL,  false FOR REAL VINCENT
    rate_multiplier = 1 ; % ADDED 20251215 TO INCREASE THE RATE OF PUBLISHING

% NUMBER OF RUNS
    total_runs = 1;

% PUBLISHING MODE  %%%%%%% -> %IMPORTANT!
    ros_pub_selector = 3;       % 1 = Wp's , 2 = Velocities ; 3 = raw (SELECT mask)
    message_mask = 3;           % 1 = pos, 2 = vel, 3 = pos+vel 4 = Pos+Vel+acc  


    
    CONFIGS_MULTIRUN_ROS
   


%% 01) START MULTIRUNS

    fprintf("------------------------------------------\n" );
    fprintf("----------- STARTING MULTIRUNS  ----------\n" );


    t1 = now; 
    time_now = datetime(t1,'ConvertFrom','datenum');
    fprintf('\n\n TIME = %s\n', time_now);
    
    if simulation==true
        fprintf("\n-------- SIMULATION ENVIRONMENT  ---------\n" );
        else
        fprintf("\n--------- REAL DRONE ENVIRONMENT  --------\n" );
    end




    %% aa) SETUP ENVIROMENT ROS
    
    fprintf('\n-------- 1) SETUP ROS ENV-------- \n\n');
    
    
    % 1) SETUP ENVIROMENT ROS VARIABLES 
        set_env_ros_sim
    
    % 2) PREPARE DATA FOR PUBLISHING
        prepare_data_for_pub
    
    
    
    % 3) START ROS NODE
    fprintf(   '\n-------- 2) STARTING ROS NODE-------- \n\n');
    node_name='/matlab_node_Vincent_multiSIM';
    rosinit ('NodeName',node_name);
    
    
    % 4) Initial setup px4 subs/pubs
    fprintf('\n--------3) INITIAL PX4 SETUP -------- \n\n');
        initial_setup_px4sitl



    %% bb) TAKE-OFF DRONE (x_take_off,y_take_off, z_take_off)
    fprintf('\n--------4) TAKE-OFF SEQUENCE -------- \n\n');

        takeoff


    %% cc) RUN EXECUTION LOOP

    elapsed_time_array = zeros(5,total_runs); % 5 time metrics to store executions 

        % (1,:) starting time (Sec)
        % (2,:) starting time (NSec)
        % (3,:) finishing time (Sec)
        % (4,:) finishing time (NSec)
        % (5,:) elapsed time

    % STEP 0) ROSBAG RECORDING

    % to match OPTITRACK REF SYSTEM (Y, -X, Z)
    initial_position_run = [initial_position(2), -initial_position(1), initial_position(3)];
      
    %% 20260622 para offset en spawn

            
        % 20261014: offset from config (spawn_offset), not from TF map->odom (no such TF in the twin setup)
        % 20261014b: for the SITL twin, read the spawn that spawn_sim_from_real.py computed from the real drone
        if strcmp(ns, '/sim')
            try
                % rosparam returns ROS lists as cell arrays -> convert to numeric row vectors
                spawn_offset = rosparam('get', '/sim/spawn_offset'); if iscell(spawn_offset), spawn_offset = cell2mat(spawn_offset); end
                traj_offset  = rosparam('get', '/sim/traj_offset');  if iscell(traj_offset),  traj_offset  = cell2mat(traj_offset);  end
                spawn_offset = double(spawn_offset(:)'); traj_offset = double(traj_offset(:)');

                % published setpoint = trajectory + traj_offset - spawn (SITL local frame starts at its spawn)
                spawn_offset = spawn_offset - traj_offset;
                fprintf('SITL: spawn [%.2f %.2f], trajectory shifted by [%.2f %.2f]\n', spawn_offset(1)+traj_offset(1), spawn_offset(2)+traj_offset(2), traj_offset(1), traj_offset(2));
            
            catch ex
                warning('Could not use /sim/spawn_offset (%s).', ex.message);
                error('Stopping: the SITL offset is unknown.');
            end
        end
        spawn_offset_x = spawn_offset(1);
        spawn_offset_y = spawn_offset(2);
        spawn_offset_z = spawn_offset(3);
        fprintf('Target %s, vision-origin offset: X=%.2f, Y=%.2f, Z=%.2f\n', ns, spawn_offset_x, spawn_offset_y, spawn_offset_z);


    % 20260622 FIN para offset en spawn
%%
    % START ROSBAG_RECORD
    [recorderNode, bagFile] = rosbag_record(targetFolder,topics);
    activeFile = [bagFile, '.active'];


    % --- check ROSBAG ---
    if ~isempty(recorderNode)
        disp(['Recording to: ', bagFile]);
        
        
            % --- LOOP TOTAL_RUNS  ---
            for run_counter=1:total_runs
            
                fprintf("--------------------------------------------\n" );
                fprintf("-----------STARTING RUN NUMBER %i ----------- \n", run_counter );
            

                
                % STEP 1) Fly to initial position    
                Goal.Pose.Position.X = initial_position_run(1)-spawn_offset_x;
                Goal.Pose.Position.Y = initial_position_run(2)-spawn_offset_y;
                Goal.Pose.Position.Z = initial_position_run(3)-spawn_offset_z;

                Goal.Header.FrameId = char('map');
               
                    fly_to_position 
            
                % STEP 2) Hover at current position
                    hover
            
                % STEP 3) START PUBLISHING
                fprintf(   '********* TRAJECTORY ROS PUBLISHER  *********\n');
    
                    RUNS_ROS_Publisher
    
                fprintf(   '***** EXITING TRAJECTORY ROS PUBLISHER  *****\n\n');
                
                 
                % store times
                    store_times
            
                % STEP 4) Hover at current position
                waittime_finish_hover = 3;
                    hover
                   
                fprintf("---------- FINISHING RUN NUMBER %i ----------\n", run_counter );
                fprintf("---------------------------------------------\n" );
                
    
                %testing_things
                %to save elapsed times 
                %move back to starting position
                %fly_to_position(initial_position_run)
    
            end %END LOOP
        
        % 2. Stop the recording safely using rosnode kill
        fprintf('Stopping node /%s ...\n', recorderNode);
        
        stopCmd = sprintf('rosnode kill /%s', recorderNode);
        system(stopCmd);
        
        % --- THE FIX: WAIT LOOP ---
        disp('Waiting for rosbag to finish writing...');
        
        % Wait while the .active file still exists
        maxRetries = 20; % Timeout after ~20 seconds
        count = 0;
        
        while exist(activeFile, 'file') && count < maxRetries
            pause(1); % Wait 1 second
            count = count + 1;
            fprintf('.'); 
        end
    
        fprintf('\n');
    
    
        % Final Check
        if exist(bagFile, 'file') && ~exist(activeFile, 'file')
            disp('SUCCESS: Bag file saved and closed correctly.');
        else
            disp('WARNING: File might still be active or process got stuck.');
            % Force kill if still stuck (optional safety net)
            system(sprintf('pkill -f %s', recorderNode));
        end
    
    
    end

    %% dd) LANDING SEQUUENCE FOR REAL DRONE
    
    if simulation == false  % if real drone
    
        fprintf(   '\n --> LANDING SEQ\n\n');
            land % land at current position
    
    end

%% 02) SAVING AND EXITING

% SAVING elapsed_time_array
    fprintf("\n---------------------------------------------\n" );
    fprintf(   ' --> Saving elapsed times\n');
        writematrix (elapsed_time_array, path_elapsed_time_array); 


    fprintf("\n----- EXITING MULTIRUN. TOTAL RUNS = %i. ----", run_counter );
    fprintf("\n--------------------------------------------\n " );
    
% SAVING LOG with all the configs from the sim
    if save_log_bool == true
        fprintf(" --> Saving log ... \n");
        save_traj_exec_log
    end
    
    t1 = now; 
    time_now = datetime(t1,'ConvertFrom','datenum');
    fprintf('\n\n TIME = %s\n', time_now);
    
% EXIT REPORT  
    diary off  % Stop recording and move file
    movefile("02_traj_exec_report.txt", path_log)