function RMSE = calc_RMSE(traject_sim_resampled, desired_resampled)

    error = (traject_sim_resampled - desired_resampled);
    square_error = error.^2;
    
    MSE = mean(square_error);
    RMSE = sqrt(MSE);
    
    max_error_x = max(error(:,1));
    max_error_y = max(error(:,2));

    fprintf("\nmax error_x = %.2f px", max_error_x);
    fprintf("\nmax error_y = %.2f px", max_error_y);

end
