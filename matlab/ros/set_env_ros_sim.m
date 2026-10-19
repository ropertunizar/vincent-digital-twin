
% environment variables
% 20261014: ROS master runs on the laptop for both SITL and real (twin setup)
    setenv ('ROS_MASTER_URI' , 'http://192.168.0.108:11311')
    setenv ('ROS_IP', '192.168.0.108')
    setenv ('ROS_HOSTNAME' , '192.168.0.108') 
    

%fprintf(   '\n--------SHUTTING DOWN ROS NODE-------- \n');
rosshutdown % Shutdown ros node and start a new one


