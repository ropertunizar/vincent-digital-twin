
fprintf(   '\n --> FLYING TO POSITION \n');


%% Control loop

%counter_flyto_max = r.DesiredRate * waittime_finish_flyto; 

%distance_goal_reached = 0.05;
%holding_position_counter_max = 20; %number of times the goal has to be in distance to exit 
%to avoid oscilations
fprintf('      X=%.2f, Y=%.2f, Z=%.2f \n',Goal.Pose.Position.X, Goal.Pose.Position.Y, Goal.Pose.Position.Z );
holding_position_counter=0; %initialize

while (1)
    
    send(posePub,Goal);
    waitfor(r);

    %calculate current distance to Goal
    Current_pose = currPosSub.LatestMessage;
    distance3d = calc_3D_distance (Current_pose, Goal);
    %fprintf(   '\n-------- Distance to Goal = %.4f -------- \n', distance3d);

    % to exit after goal reached for  holding_position_counter_max times
    counter_waiting = counter_waiting +1 ;
    if distance3d <= distance_goal_reached
        holding_position_counter = holding_position_counter +1;
        %fprintf(   '\n-------- Goal reached -------- \n');
        if holding_position_counter >= holding_position_counter_max
                fprintf('      Goal reached\n\n');
                break
        end

    end


end