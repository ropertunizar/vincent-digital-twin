    

%3) RAW

topic_raw_setpoint = [ns '/mavros/setpoint_raw/local'];  % 20261014 namespaced
msg_type_raw_setpoint = 'mavros_msgs/PositionTarget';

[pub_raw, msg_raw] = rospublisher(topic_raw_setpoint, msg_type_raw_setpoint, 'DataFormat', 'struct');



%%
msg_raw.Header.Stamp = rostime('now', 'DataFormat', 'struct'); 
msg_raw.CoordinateFrame = uint8(1);

switch message_mask  
        % https://docs.ros.org/en/api/mavros_msgs/html/msg/PositionTarget.html
        % ignore flags         
        % [2048 1024 512 256]  [128 64 32 16]  [8 4 2 1]
        % [IGNORE_YAW_RATE  IGNORE_YAW  FORCE  IGNORE_AFZ]  [IGNORE_AFY IGNORE_AFX IGNORE_VZ IGNORE_VY]   [IGNORE_VX IGNORE_PZ IGNORE_PY IGNORE_PX]

    case 1
        msg_raw.TypeMask = uint16(3576); % only pos (IN BINARY 0000 1101 1111 1000)
                                                            
        fprintf("      mask for position only")
    case 2
        msg_raw.TypeMask = uint16(3527); % only vel (IN BINARY 0000 1101 1100 0111) 0b1101 1100 0111
        fprintf("      mask for velocity only")
    case 3
        msg_raw.TypeMask = uint16(3520); % pos & vel (IN BINARY 0000 1101 1100 0000)
        fprintf("      mask for position and velocity")
    case 4 
        msg_raw.TypeMask = uint16(3072); % pos & vel & acc (IN BINARY 0000 1100 0000 0000)
        fprintf("      mask for position , velocity and accel")
        
    otherwise
        fprintf("    --> wrong mask!!!")
        return
end





% DEBUGGING 
%switch sim_counter
%    case 1
%        msg_raw.TypeMask = uint16(3576); % onle pos
%        fprintf ('\nusing positions only');
%    case 5
 %       msg_raw.TypeMask = uint16(3527); % only vel 
 %       fprintf ('\nusing velocities only');
%    case 2
%        msg_raw.TypeMask = uint16(3520); % pos & vel 
%        fprintf ('\nusing positions and velocities');
%end

%msg_raw.TypeMask = uint16(3520); %only pos y vel =3520 works; only vel =3527 ; only pos =3576
% WARN  [mc_pos_control] invalid setpoints WARN  [mc_pos_control] Failsafe: stop and wait


msg_raw.Header.FrameId = 'map';
%msg_raw.CoordinateFrame=1;

%dummy_pos_target_msg = rosmessage('mavros_msgs/PositionTarget', 'DataFormat', 'struct');
%local_ned_frame_value = dummy_pos_target_msg.CoordinateFrameInfo.FRAME_LOCAL_NED; % <-- Esto puede variar si MAVROS cambia las constantes







% initialize
rate2 = rosrate(calc_rate*rate_multiplier);
rate2.OverrunAction = 'drop';
%reset(rate2);


% Print STARTING TIME
format longG
t1 = now;
d1 = datetime(t1,'ConvertFrom','datenum');

fprintf('\n\n   -> STARTING RAW PUBLISHING\n');
fprintf('      Starting time = %s\n', d1);



% PUBLISHING VELOCITIES
i=1;
tic

counter_timestamp_msg = 30; %how many loops to send the timestamp message
[pub_start, msg_start] = rospublisher('/started_publishing_vel','std_msgs/Header');
%reset(rate2);

%waitfor(rate2);
starting_ros_time_sim = rostime("now");

time_start = rostime("now");
%starting_ros_time_sim = time_start;
timer_send_traj = time_start + Ti_topublish(end);

q = q_pub; 
for i = 1:length(q)

    %% 20260622 para offset en spawn
    msg_raw_map.Position.X = x_topublish(i); %ADDED MAP
    msg_raw_map.Position.Y = y_topublish(i);
    msg_raw_map.Position.Z = z_topublish(i);
    
    msg_raw.Velocity.X = vx_topublish(i);
    msg_raw.Velocity.Y = vy_topublish(i);
    msg_raw.Velocity.Z = vz_topublish(i);

    msg_raw.AccelerationOrForce.X = ax_topublish(i);
    msg_raw.AccelerationOrForce.Y = ay_topublish(i);
    msg_raw.AccelerationOrForce.Z = az_topublish(i);


    if message_mask == 1 || message_mask == 3 || message_mask == 4
        msg_raw.Position.X = msg_raw_map.Position.X - spawn_offset_x;
        msg_raw.Position.Y = msg_raw_map.Position.Y - spawn_offset_y;
        msg_raw.Position.Z = msg_raw_map.Position.Z - spawn_offset_z;
    end
    
    % Si tu máscara incluye VELOCIDAD o ACELERACIÓN, se pasan tal cual. 
    % (Los vectores de velocidad/aceleración son relativos y no les afecta el offset espacial)
    if message_mask == 2 || message_mask == 3 || message_mask == 4
        % msg_raw.Velocity.X = target_map_vx;
        % msg_raw.AccelerationOrForce.X = target_map_ax;
        % ... (etc)
    end
    % 20260622 FIN para offset en spawn


    msg_raw.Header.Stamp = rostime('now', 'DataFormat', 'struct');

    
    if i < counter_timestamp_msg
    msg_start.Stamp = time_start;
    send(pub_start,msg_start)
    else
       %SET TO ZERO
       msg_start.Stamp.Sec=0;
       msg_start.Stamp.Nsec=0;
       send(pub_start,msg_start) 
    end
    
    %debug
    % disp(['DEBUG Punto ', num2str(i), ' Pos: ', num2str(msg_raw.Position.X), ', ', num2str(msg_raw.Position.Y), ', ', num2str(msg_raw.Position.Z)]);
    % disp(['DEBUG Punto ', num2str(i), ' Vel: ', num2str(msg_raw.Velocity.X), ', ', num2str(msg_raw.Velocity.Y), ', ', num2str(msg_raw.Velocity.Z)]);
    % % ... (Añade para Acceleration si la usas) ...
    % 
    % % Verifica si hay NaN o Inf en los valores que estás enviando:
    % if any(isnan([msg_raw.Position.X, msg_raw.Position.Y, msg_raw.Position.Z])) || ...
    %    any(isinf([msg_raw.Position.X, msg_raw.Position.Y, msg_raw.Position.Z])) || ...
    %    any(isnan([msg_raw.Velocity.X, msg_raw.Velocity.Y, msg_raw.Velocity.Z])) || ...
    %    any(isinf([msg_raw.Velocity.X, msg_raw.Velocity.Y, msg_raw.Velocity.Z]))
    %    error('¡Setpoints contienen NaN o Inf!'); % Detén la ejecución si encuentras valores inválidos
    % end

    send(pub_raw, msg_raw);
    waitfor(rate2);
end



% send time to know the publishing ended
    time_end = rostime("now");
    finisishing_ros_time_sim = time_end; 
    for i=1:counter_timestamp_msg
        msg_start.Stamp=time_end;
        send(pub_start,msg_start)
        waitfor(rate2);
    end



% Print FINISHING TIME
    t2 = now;
    d2 = datetime(t2,'ConvertFrom','datenum');
    fprintf('\n   -> FINISHING RAW PUBLISHING\n');
    fprintf('      Finishing time = %s\n', d2);


% Print ELAPSED TIME
    total_elapsed_time = d2-d1;
    elapsed_time = total_elapsed_time; %finish_time-starting_time;
    total_elapsed_time.Format = 'mm:ss.SSS';
    fprintf('\n      TOTAL ELAPSED TIME = %s\n\n', total_elapsed_time);


