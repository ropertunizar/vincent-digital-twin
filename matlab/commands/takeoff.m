%% TAKE OFF SEQUENCE


% Set the desired height of PX4 
poseMsg.Pose.Position.X = x_take_off;
poseMsg.Pose.Position.Y = y_take_off;
poseMsg.Pose.Position.Z = z_take_off;
poseMsg.Header.FrameId = char('map');

fprintf(' --> Taking off to Position X=%.2f, Y=%.2f, Z=%.2f \n',poseMsg.Pose.Position.X, poseMsg.Pose.Position.Y, poseMsg.Pose.Position.Z );

numSteps = 20; %IDK
for num=1:numSteps
    send(posePub,poseMsg);
    waitfor(r);
end



%exampleHelperUAVTakeOff(stateSub, setModeCli, armingCli, srvReqTimeout)


%% CONTROL LOOP
% waittime_finish_takeoff = 20;
counter_waiting_max = r.DesiredRate * waittime_finish_takeoff; 

counter_waiting = 1;
holding_position_counter = 0 ;

fprintf(' --> UAVTakeOff HELPER \n');
while (1)
    
    % update current time to calculate time elapsed since last service request
    if auto_arm
        exampleHelperUAVTakeOff(stateSub, setModeCli, armingCli, 5.0);
    end
    %exampleHelperUAVTakeOff(stateSub, setModeCli, armingCli, 5.0);
    
    %poseMsg.Pose.Position.X = 0;
    %poseMsg.Pose.Position.Y = 0;

  
    if ~isempty(landNowSub.LatestMessage) && landNowSub.LatestMesage.Data
        % Landing message received
        break;
    end    
    send(posePub,poseMsg);
    waitfor(r);

    %calculate current distance to Goal
    Current_pose = currPosSub.LatestMessage;
    distance3d = calc_3D_distance (Current_pose, poseMsg);
    %fprintf(   '\n-------- Distance to Goal = %.4f -------- \n', distance3d);


    % to exit after take off seq is finished
    counter_waiting = counter_waiting +1 ;
    if counter_waiting >= counter_waiting_max
        fprintf(   ' --> Exiting TAKE OFF SEQ (for counter_waiting_max) \n\n');
        break
    end
    
    % to exit after goal reached for holding_position_counter_max times
    if distance3d <= distance_goal_reached
        holding_position_counter = holding_position_counter +1;
        %fprintf(   '\n-------- Goal reached -------- \n');
        if holding_position_counter >= holding_position_counter_max
                    fprintf(' --> Exiting TAKE OFF SEQ\n\n');
                    break
        end

    end


end

