
% sim_counter
total_metrics_stored = 9;

metrics_stored(1,sim_counter) = duration_sim;  %Seconds of the sim

metrics_stored(2,sim_counter) = max_error_2D;
metrics_stored(3,sim_counter) = RMSE_2D;

metrics_stored(4,sim_counter) = max_error_3D;
metrics_stored(5,sim_counter) = RMSE_3D;

metrics_stored(6,sim_counter) = max_search_radius;

metrics_stored(7, sim_counter) = RMSE_3D_vel_x;
metrics_stored(8, sim_counter) = RMSE_3D_vel_y;
metrics_stored(9, sim_counter) = RMSE_3D_vel_z;

labels_metrics = [ 'sec', "px", "px", "m", "m" , "samples", "m/s", "m/s", "m/s"];
titles_metrics = [ 'Sim Duration', "max error 2D", "RMSE 2D", "max error 3D", "RMSE 3D", "search radius", "RMSE 3D VEL X", "RMSE 3D VEL Y" , "RMSE 3D VEL Z"  ];


