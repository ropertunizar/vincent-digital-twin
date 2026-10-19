    %elapsed_time_array(1,sim_counter) = seconds(total_elapsed_time);
    elapsed_time_array(1,run_counter) = starting_ros_time_sim.Sec;
    elapsed_time_array(2,run_counter) = starting_ros_time_sim.Nsec;

    elapsed_time_array(3,run_counter) = finisishing_ros_time_sim.Sec;
    elapsed_time_array(4,run_counter) = finisishing_ros_time_sim.Nsec;

    elapsed_time_array(5,run_counter) = seconds(elapsed_time);
