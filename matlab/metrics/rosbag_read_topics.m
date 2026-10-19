%% to read the topics taking into account the simulation duration

% load bag
%rosbag_file = path_actual_test_folder + rosbag_prefix + load_bag_name + file_suffix;
rosbag_file = path_actual_test_folder + rosbag_prefix + load_bag_name ;
bagreader= rosbagreader(rosbag_file);

% Whole bag starting and ending stamps
starting_stamp_reader = bagreader.StartTime; % obtain the stamp of bag reader at the start
ending_stamp_reader = bagreader.EndTime;

%% comm offset
communication_offset= 0.667; %calculated with plotjuggler
fprintf("communication_offset = %.3f sec\n\n", communication_offset);

%%
% use the TXT FILE TO KNOW WHERE and HOW EACH BAG IS DIVIDED INTO INDIV SIMS

% Read elapsed_time_array txt file with times

elapsed_time_array_filename = path_actual_test_folder + rosbag_prefix + "elapsed_time_array.txt";
elapsed_time_array = readmatrix(elapsed_time_array_filename);


% Individual sims 
% starting-ending times and duration
starting_stamp_bag_sim = ( elapsed_time_array(1,sim_counter) + elapsed_time_array(2,sim_counter)/1e9 +communication_offset) ; 
ending_stamp_bag_sim = ( elapsed_time_array(3,sim_counter) + elapsed_time_array(4,sim_counter)/1e9 + communication_offset); 
duration_sim = ending_stamp_bag_sim - starting_stamp_bag_sim;


% Calculate offset for simluation
starting_stamp_offset_sim = starting_stamp_bag_sim - starting_stamp_reader; % offset to remove excess at the start of .bag
ending_stam_offset_sim =  ending_stamp_reader - ending_stamp_bag_sim ; % offset to remove excess at the end of .bag
fprintf("starting_stamp_offset_sim = %.3f\n", starting_stamp_offset_sim);
fprintf("ending_stam_offset_sim = %.3f\n", ending_stam_offset_sim);
fprintf('total duration of sim =  %.3f\n', duration_sim);

% Time interval to create subsets
Time_sim = [(starting_stamp_reader + starting_stamp_offset_sim) (bagreader.EndTime - ending_stam_offset_sim) ];

% topics
Topics = topic_to_read(:,1);

%% CREATING VARIABLES FOR METRIC CALCULATION
% 1) "/mavros/local_position/pose"

%subset starting-ending times
bagreader_start_finish_position = select(bagreader,...
    Time=Time_sim,...
    Topic=Topics(1));


% read messages
bag_msgs_position = readMessages(bagreader_start_finish_position);
% create a struct
bag_msgStructs_position = readMessages(bagreader_start_finish_position,'DataFormat','struct');

% extract X Y Z
X_bag = cellfun(@(m) double(m.Pose.Position.X),bag_msgStructs_position)';
Y_bag = cellfun(@(m) double(m.Pose.Position.Y),bag_msgStructs_position)';
Z_bag = cellfun(@(m) double(m.Pose.Position.Z),bag_msgStructs_position)';
Time_pos = cellfun(@(m) rostime(m.Header.Stamp.Sec, m.Header.Stamp.Nsec),bag_msgStructs_position)';
starting_T= Time_pos(1);
Time_pos_clear=zeros(1,length(Time_pos));
for i=1:length(Time_pos)
    Time_pos_duration(i) = (Time_pos(i) -starting_T);
    Time_pos_clear(i) = seconds(Time_pos_duration(i));
end

%switch coordinate system
offset_loc = [0, 0, 0]; % X, Y , Z in RVIZ drone_starting_point

%change orientation to match simulation 
X_bag_toplot = -Y_bag + offset_loc(1,1);
Y_bag_toplot = X_bag+ offset_loc(1,2);
Z_bag_toplot = Z_bag + offset_loc(1,3);

% 3D Position in homogeneous coordinates
X_bag_toplot_hom = [X_bag_toplot; Y_bag_toplot; Z_bag_toplot;ones(1,length(X_bag_toplot))];
% 3D Position with time vector
X_bag_toplot_3D = [X_bag_toplot; Y_bag_toplot; Z_bag_toplot; Time_pos_clear];


% -------------------------------------------
% 2) "/mavros/local_position/velocity_local"

%subset starting-ending times
bagreader_start_finish_vel= select(bagreader,...
    Time=Time_sim,...
    Topic=Topics(2));


% read messages
bag_msgs_vel = readMessages(bagreader_start_finish_vel);
% create a struct
bag_msgStructs_vel = readMessages(bagreader_start_finish_vel,'DataFormat','struct');

% extract VX VY VZ
VX_bag = cellfun(@(m) double(m.Twist.Linear.X),bag_msgStructs_vel)';
VY_bag = cellfun(@(m) double(m.Twist.Linear.Y),bag_msgStructs_vel)';
VZ_bag = cellfun(@(m) double(m.Twist.Linear.Z),bag_msgStructs_vel)';
Time_vel = cellfun(@(m) rostime(m.Header.Stamp.Sec, m.Header.Stamp.Nsec),bag_msgStructs_vel)';
starting_T= Time_vel(1);
Time_vel_clear=zeros(1,length(Time_vel));
for i=1:length(Time_vel)
    Time_vel_duration(i) = (Time_vel(i) -starting_T);
    Time_vel_clear(i) = seconds(Time_vel_duration(i));
end


VX_bag_toplot = -VY_bag ;
VY_bag_toplot = VX_bag;
VZ_bag_toplot = VZ_bag;
% 3D VELOCITY with time vector
V_bag_toplot_3D = [VX_bag_toplot; VY_bag_toplot; VZ_bag_toplot;Time_vel_clear;];



% -------------------------------------------
% 3) "/mavros/setpoint_raw/target_local"

%subset starting-ending times
bagreader_start_finish_target= select(bagreader,...
    Time=Time_sim,...
    Topic=Topics(3));

% read messages
bag_msgs_target = readMessages(bagreader_start_finish_target);
% create a struct
bag_msgStructs_target = readMessages(bagreader_start_finish_target,'DataFormat','struct');

% extract VX VY VZ
ACCX_bag = cellfun(@(m) double(m.AccelerationOrForce.X),bag_msgStructs_target)';
ACCY_bag = cellfun(@(m) double(m.AccelerationOrForce.Y),bag_msgStructs_target)';
ACCZ_bag = cellfun(@(m) double(m.AccelerationOrForce.Z),bag_msgStructs_target)';
Time_target = cellfun(@(m) rostime(m.Header.Stamp.Sec, m.Header.Stamp.Nsec),bag_msgStructs_target)';
starting_T= Time_target(1);
Time_target_clear=zeros(1,length(Time_target));
for i=1:length(Time_target)
    Time_target_duration(i) = (Time_target(i) -starting_T);
    Time_target_clear(i) = seconds(Time_target_duration(i));
end

ACCX_bag_toplot = -ACCY_bag ;
ACCY_bag_toplot = ACCX_bag;
ACCZ_bag_toplot = ACCZ_bag;
% 3D ACC with time vector
ACC_bag_toplot_3D = [ACCX_bag_toplot; ACCY_bag_toplot; ACCZ_bag_toplot;Time_target_clear;];


%%
fprintf(   '\n--- ROSBAG imported! ---\n');