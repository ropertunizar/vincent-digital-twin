
function plot_traj_with_RMSE_errors(traject_sim_resampled, desired_resampled, error_plot_interval)


%trajectoria SIM
color_traj = [0, 0.7, 0.7];
plot(traject_sim_resampled(:, 1), traject_sim_resampled(:, 2),'Color', color_traj, 'Marker','o', 'MarkerSize', 3, 'LineWidth', 2, 'DisplayName', 'Resampleada (long. arco)');
%plot(trayectoria_resampleada(:, 1), trayectoria_resampleada(:, 2), 'yo-', 'DisplayName', 'Resampleada (long. arco)');
%plot(x_hom(1,:), -x_hom(2,:), 'go-', 'DisplayName', 'GT Polinomial');  %GT Trajectory)

%Desired
color_desired = "green" ; 
plot(desired_resampled(:, 1), desired_resampled(:, 2),'Color', color_desired, 'Marker','o', 'MarkerSize', 3, 'LineWidth', 2, 'DisplayName', 'Resampleada (long. arco)');
%plot(uv_desired(1,:), uv_desired(2,:), 'go-', 'DisplayName', 'GT DESIRED'); 


%plot errors

[p1 , p2] = plot_errors(traject_sim_resampled, desired_resampled, error_plot_interval);

for i = 1:length(p1)
    plot([p1(1,i), p2(1,i)], [p1(2,i), p2(2,i)], 'k-', 'LineWidth', 2)
end

xlabel('X');
ylabel('Y');
%legend('show');
title('Resampling by arc distance');
grid on;
hold off;

end