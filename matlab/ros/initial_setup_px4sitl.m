%% Initialize and setup sequence



    % SUBSCRIBER to the Current Pose
    if simulation == true
        currPosSub = rossubscriber([ns '/mavros/local_position/pose'],"geometry_msgs/PoseStamped","DataFormat","struct");
        else
         currPosSub = rossubscriber("/optitrack/pose","geometry_msgs/PoseStamped","DataFormat","struct");
    end

    % SUBSCRIBER to the the PX4 state
    stateSub = rossubscriber([ns '/mavros/state'],"mavros_msgs/State","DataFormat","struct");
    % SUBSCRIBER to landing message
    landNowSub = rossubscriber("/land_message","std_msgs/Bool","DataFormat","struct");

    % Create a "SetMode" SERVICE CLIENT
    setModeCli = rossvcclient([ns '/mavros/set_mode'],"mavros_msgs/SetMode","DataFormat","struct");
    % Create a "Arm" command SERVICE CLIENT
    armingCli = rossvcclient([ns '/mavros/cmd/arming'],"mavros_msgs/CommandBool","DataFormat","struct");
    
    
    % Create a PUBLISHER for PX4 position command
    posePub = rospublisher([ns '/mavros/setpoint_position/local'],"geometry_msgs/PoseStamped","DataFormat","struct");
    
    % Create a Pose MESSAGE
    poseMsg = rosmessage(posePub);
    Goal = rosmessage(posePub);

    
    % TO READ INITIAL POSITION FOR TAKE-OFF
    if enable_intial_position_reader == true
        fprintf(' --> reading initial position for take-off ----- \n');

        initial_takeoff_pose = currPosSub.LatestMessage;
        x_take_off = initial_takeoff_pose.Pose.Position.X;
        y_take_off = initial_takeoff_pose.Pose.Position.Y;
    end



%% Define rate of publishing and prime the takeoff sequence with position messages
% Publish the messages at 20 Hz

pause(1); % TODO fix random problem here
r = rosrate(20);

% Wait for a successful PX4 SITL connection
while ( isempty(stateSub.LatestMessage) || ~stateSub.LatestMessage.Connected )
    fprintf(   '\n--------waiting for Px4 Connection-------- \n');
    waitfor(r);
end


