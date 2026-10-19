
%% LOOP GOAL NAVIGATION 


% Publishers
%[pub_goal_pose, goal_pose] = rospublisher('/cmd_pose_2_drone','geometry_msgs/PoseStamped'); %FOR CASPAR'S NODE
[pub_goal_pose, goal_pose] = rospublisher('/mavros/setpoint_position/local','geometry_msgs/PoseStamped');
% Subscibers 
local_pos_sub = rossubscriber('/mavros/local_position/pose'); %to receive the current position

% publisher for knowing when the publishing started and finished
[pub_start,msg_start] = rospublisher('/started_publishing_vel','std_msgs/Header');

%send 0
% msg_sim_on_bool.Stamp.Sec=0;
% msg_sim_on_bool.Stamp.Nsec=0;
% send(pub_sim_on_bool,msg_sim_on_bool) 




% First navigate to INITIAL POSITION
i=1;
goal_pose.Pose.Position.X= WPx_topublish(i);
goal_pose.Pose.Position.Y= WPy_topublish(i);
goal_pose.Pose.Position.Z= WPz_topublish(i);
% next goal
goal_pose_next.Pose.Position.X= WPx_topublish(i+1);
goal_pose_next.Pose.Position.Y= WPy_topublish(i+1);
goal_pose_next.Pose.Position.Z= WPz_topublish(i+1);

% CALCULATE DISTANCE BETWEEN GOALS (FROM i TO i+1)
dist_between_goals = calc_dist(goal_pose, goal_pose_next);

drone_finished = false; % flag until it's not in position


t1 = now;
starting_time = datetime(t1,'ConvertFrom','datenum');
fprintf( '----> STARTING WP PUBLISH ');
fprintf('\n Starting time = %s \n', starting_time);




starting_ros_time_sim = rostime("now");
time_start = starting_ros_time_sim;

counter_timestamp_msg = 30;
i=1;


% repeat until list finished
while drone_finished == false

    % SEND GOAL
    send(pub_goal_pose,goal_pose);


   %send boolean to know the publishing starts
   if i < counter_timestamp_msg
    msg_start.Stamp = time_start;
    send(pub_start,msg_start)
   else
       %SET TO ZERO
       msg_start.Stamp.Sec=0;
       msg_start.Stamp.Nsec=0;
       send(pub_start,msg_start) 
   end



    % CALC DISTANCE TO GOAL
    local_pose_now = receive(local_pos_sub); % receive current pose
    dist_to_goal_current = calc_dist(goal_pose,local_pose_now); % calculate distance to goal

    
    %fprintf("\n---Distance to goal: %.2f\n",dist_to_goal);

    % CHECK DISTANCE FROM i TO i+1 GOAL
    % select which dist_threshold to use (Fast or slow)

    if dist_between_goals > dist_between_goals_threshold
        dist_threshold_skip_wp = dist_threshold_fast; % select FAST gap
            if print_speed_selection == true
            fprintf( '\n--Selecting FAST');
            end
        

    else
        dist_threshold_skip_wp = dist_threshold_slow; % select SLOW gap
            if print_speed_selection == true
            fprintf( '\n--Selecting SLOW');
            end
    end
    

    if dist_to_goal_current <= dist_threshold_skip_wp % we are in the skip region
        
        %fprintf("\n---Drone reached goal= %i\n",i);

        % if next goal is out of range of total_WP_toPub, exit while loop
        if i > total_WP_toPub
            %fprintf("\n---Drone finished last goal= %i\n",i);
            drone_finished=true; % exit the loop
        end
               
        % next i
        i = i+1;

        % Select following goal
        if i <= total_WP_toPub
            goal_pose.Pose.Position.X= WPx_topublish(i);
            goal_pose.Pose.Position.Y= WPy_topublish(i);
            goal_pose.Pose.Position.Z= WPz_topublish(i);
        else
            drone_finished= true;
        end


        % and check the i+1 goal to calculate dist_between_goals
        if i < total_WP_toPub
            
            goal_pose_next.Pose.Position.X= WPx_topublish(i+1);
            goal_pose_next.Pose.Position.Y= WPy_topublish(i+1);
            goal_pose_next.Pose.Position.Z= WPz_topublish(i+1);
            %check distance between i and i+1 goal
            dist_between_goals = calc_dist(goal_pose, goal_pose_next);
            
        else
           dist_between_goals = dist_to_goal_current;
        end


    end
    
end




finisishing_ros_time_sim = rostime("now");

% send time to know the publishing ended
time_end = finisishing_ros_time_sim;
finisishing_ros_time_sim = time_end; 

%calc_waittime= total_flighttime / (length(Ti_topublish)-1) ;
calc_waittime = 25;
    rate2 = 1 / calc_waittime;
    %fprintf("\nusing Total flight to calc_rate = %i HZ\n", calc_rate);

for i=1:counter_timestamp_msg
    msg_start.Stamp=time_end;
    send(pub_start,msg_start)
    waitfor(rate2);
end


t2 = now;

finish_time = datetime(t2,'ConvertFrom','datenum');
fprintf( '\n----> FINISHING WP PUBLISH ');
fprintf('\n Finishing time = %s \n', finish_time);



% elapsed_time = finish_time-starting_time;
% total_elapsed_time.Format = 'mm:ss.SSS';
% fprintf('\nTOTAL ELAPSED TIME = %s\n\n', total_elapsed_time);


% Print ELAPSED TIME
total_elapsed_time = finish_time-starting_time;
elapsed_time = total_elapsed_time; %finish_time-starting_time;

total_elapsed_time.Format = 'mm:ss.SSS';
fprintf('\nTOTAL ELAPSED TIME = %s\n\n', total_elapsed_time);


% shutdown ros node
%rosshutdown