
%% setup data (V_bag_toplot_3D vs qd)

% curves original curves and times
curve1_original_3Dvel = V_bag_toplot_3D(1:3,:); % px4 3D sim velocity
t1_original_3Dvel = V_bag_toplot_3D(4,:);
size_curve1 = length(curve1_original_3Dvel);

curve2_original_3Dvel = qd(1:3,:); % published velocity
t2_original_3Dvel = tvec;
size_curve2 = length(curve2_original_3Dvel);


%export_vel_to_publish_Nikolaus
%[curve1_resampled_3Dvel, curve2_resampled_3Dvel] = resampling3DTrajectories(curve1_original_3Dvel, curve2_original_3Dvel);
%plot(t_vec_vel, curve1_resampled_3Dvel(:,3), Color = color_bag)
%plot(tvec, curve2_resampled_3Dvel(:,3)')


    if size_curve1 > size_curve2
        resampling_size = size_curve1; 
        t_resampling = t1_original_3Dvel; % vector_tiempo de referencia
        
        curve1_interp_x  =  curve1_original_3Dvel(1,:);
        curve1_interp_y  =  curve1_original_3Dvel(2,:);
        curve1_interp_z  =  curve1_original_3Dvel(3,:);

        curve2_interp_x  =  interp1(t2_original_3Dvel, curve2_original_3Dvel(1,:), t_resampling);  % function to time interpolate curves
        curve2_interp_y  =  interp1(t2_original_3Dvel, curve2_original_3Dvel(2,:), t_resampling);  % function to time interpolate curves
        curve2_interp_z  =  interp1(t2_original_3Dvel, curve2_original_3Dvel(3,:), t_resampling);  % function to time interpolate curves
        
                % IF NAN's
        curve2_interp_x(isnan(curve2_interp_x)) = 0;
        curve2_interp_y(isnan(curve2_interp_y)) = 0;
        curve2_interp_z(isnan(curve2_interp_z)) = 0;

        %velocidades_interp = interp1(T, V, T2, 'linear')

    else
        resampling_size = size_curve2;
        t_resampling = t2_original_3Dvel;% vector_tiempo de referencia

        curve1_interp_x  =  interp1(t1_original_3Dvel, curve1_original_3Dvel(1,:), t_resampling);  % function to time interpolate curves
        curve1_interp_y  =  interp1(t1_original_3Dvel, curve1_original_3Dvel(2,:), t_resampling);  % function to time interpolate curves
        curve1_interp_z  =  interp1(t1_original_3Dvel, curve1_original_3Dvel(3,:), t_resampling);  % function to time interpolate curves
        
        % IF NAN's
        curve1_interp_x(isnan(curve1_interp_x)) = 0;
        curve1_interp_y(isnan(curve1_interp_y)) = 0;
        curve1_interp_z(isnan(curve1_interp_z)) = 0;
        

        curve2_interp_x  =  curve2_original_3Dvel(1,:);
        curve2_interp_y  =  curve2_original_3Dvel(2,:);
        curve2_interp_z  =  curve2_original_3Dvel(3,:);
    end

%plot x




%plot_traj_with_RMSE_errors(curve1_resampled_3Dvel, curve2_resampled_3Dvel, error_plot_interval);

%% ERRORS
% initialize errors
error_3Dvel_x = zeros(resampling_size,1);
error_3Dvel_y = zeros(resampling_size,1);
error_3Dvel_z = zeros(resampling_size,1);

% calculate errors
for i=1:resampling_size
    error_3Dvel_x(i) = curve1_interp_x(i) - curve2_interp_x(i);
    error_3Dvel_y(i) = curve1_interp_y(i) - curve2_interp_y(i);
    error_3Dvel_z(i) = curve1_interp_z(i) - curve2_interp_z(i);

end

error_3Dvel = [error_3Dvel_x error_3Dvel_y error_3Dvel_z];
square_error_3Dvel=error_3Dvel.^2;
MSE_3Dvel = mean(square_error_3Dvel);
RMSE_3Dvel = sqrt(MSE_3Dvel);

% square_error_3D = error_table_3D.^2;
%     MSE_3D = mean(square_error_3D);
%     RMSE_3D = sqrt(MSE_3D);

RMSE_3D_vel_x = RMSE_3Dvel(1);
RMSE_3D_vel_y = RMSE_3Dvel(2);
RMSE_3D_vel_z = RMSE_3Dvel(3);
