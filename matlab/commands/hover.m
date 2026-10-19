% Hover at latest position
poseMsg = currPosSub.LatestMessage;

%or hover at goal
%poseMsg = Goal;

%poseMsg.Pose.Position = currPosSub.Pose.Position;

fprintf( ' --> HOVERING SEQ\n');



%% Control loop

counter_hover_max = r.DesiredRate * waittime_finish_hover; 

counter_waiting = 1;
while (1)

    send(posePub,poseMsg);

    waitfor(r);

    % to exit after take off seq is finished
    counter_waiting = counter_waiting +1 ;
    if counter_waiting >= counter_hover_max
        %fprintf(   ' --> EXITING HOVERING SEQ \n\n');
        break
    end


end