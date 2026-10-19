function RMSE = calc_RMSE_3D(traject_sim_resampled, desired_resampled)

    error = (traject_sim_resampled - desired_resampled);
    square_error = error.^2;
    
    MSE = mean(square_error);
    RMSE = sqrt(MSE);
    
    max_error_x = max(sqrt(square_error(:,1)));
    max_error_y = max(sqrt(square_error(:,2)));
    max_error_z = max(sqrt(square_error(:,3)));

    min_error_x = min(sqrt(square_error(:,1)));
    min_error_y = min(sqrt(square_error(:,2)));
    min_error_z = min(sqrt(square_error(:,3)));

    fprintf("\nmax_error_X = %.2f m", max_error_x);
    fprintf("\nmax_error_Y = %.2f m", max_error_y);
    fprintf("\nmax_error_Z = %.2f m", max_error_z);

    fprintf("\nmin_error_X = %.2f m", min_error_x);
    fprintf("\nmin_error_Y = %.2f m", min_error_y);
    fprintf("\nmin_error_Z = %.2f m", min_error_z);

end
