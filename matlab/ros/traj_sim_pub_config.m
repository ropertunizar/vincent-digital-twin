
%% LOAD results from file and PUBLISH VEL's
filename_q_for_pub_core = "q.txt";
filename_qd_for_pub_core = "qd.txt";
filename_qdd_for_pub_core = "qdd.txt";
filename_initial_position = 'initial_position.txt';
filename_tvec_for_pub_core = "tvec.txt";

filename_q_for_pub = path_actual_test_folder + export_prefix + filename_q_for_pub_core;
filename_qd_for_pub = path_actual_test_folder + export_prefix + filename_qd_for_pub_core;
filename_qdd_for_pub = path_actual_test_folder + export_prefix + filename_qdd_for_pub_core;
filename_initial_position = path_actual_test_folder + export_prefix + filename_initial_position;

filename_tvec_for_pub = path_actual_test_folder + export_prefix + filename_tvec_for_pub_core;


%print loading info
fprintf("Test folder: %s", load_folder_name);
fprintf("\n Loading q file: %s", filename_q_for_pub_core);
fprintf("\n Loading qd file: %s", filename_qd_for_pub_core);
fprintf("\n Loading qdd file: %s", filename_qdd_for_pub_core);
fprintf("\n Loading initial position: %s", filename_initial_position);

%LOAD DATA
q_pub = readmatrix(filename_q_for_pub);
qd_pub = readmatrix(filename_qd_for_pub);
qdd_pub = readmatrix(filename_qdd_for_pub);
initial_position = readmatrix(filename_initial_position);

tvec_pub = readmatrix(filename_tvec_for_pub);


%% to publish velocities stored in vx_topublish, vy_topublish, vz_topublish
% take the RESULTS from the TRAJECTORY GENERATOR and publish them

% POSITION
x_topublish = q_pub(2,:);
y_topublish = -q_pub(1,:);
z_topublish = q_pub(3,:);

% VELOCITY
vx_topublish = qd_pub(2,:);
vy_topublish = -qd_pub(1,:);
vz_topublish = qd_pub(3,:);

% ACCELERATION
ax_topublish = qdd_pub(2,:);
ay_topublish = -qdd_pub(1,:);
az_topublish = qdd_pub(3,:);

% TIME VECTOR
Ti_topublish = tvec_pub;

%%

total_flighttime = Ti_topublish(end);
fprintf("\nTotal flight time:= %i seconds", total_flighttime);

% to check if use the Ti_toplot interval or calc_waittime as rate for pub
if waittime_selector > 1

    fprintf("\nusing Ti_toplot to calc variable rate\n");

else

    calc_waittime= total_flighttime / (length(Ti_topublish)-1) ;
    calc_rate = 1 / calc_waittime;
    fprintf("\nusing Total flight to calc_rate = %i HZ", calc_rate);
    fprintf("\nusing rate_multiplier = %i \n", rate_multiplier);
    
end