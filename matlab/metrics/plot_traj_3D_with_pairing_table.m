function plot_traj_3D_with_pairing_table(curve1_resampled_3D, curve2_resampled_3D, ...
        plot_interval, pairing_table_3D, total_points, figure_number,search_case)

figure(figure_number);

% %trajectoria SIM
% color_traj = 'yellow';
% color_desired = "green" ;

%trajectoria SIM
if search_case == 1
    color_curve1 = 'yellow';
    color_curve2 = [1 0.5 0]; %ORANGE; 

else

        color_curve1 = 'yellow';
    color_curve2 = [1 0.5 0]; %ORANGE; 
    % color_curve1 = [1 0.5 0]; %ORANGE;
    % color_curve2 = "yellow" ; 

end


%scatter3 (x , y , z, 200,color1 ,".");
plot_traj = plot3(curve1_resampled_3D(:, 1),curve1_resampled_3D(:, 2),curve1_resampled_3D(:, 3), 'Marker','o', 'Color', color_curve1, 'MarkerSize', 5, 'LineWidth', 2, 'DisplayName', 'Resampleada (long. arco)');
%plot_traj = plot3(curve1_resampled_3D(:, 1),curve1_resampled_3D(:, 2),curve1_resampled_3D(:, 3),'Color', color_traj,'o', 'MarkerSize', 3, 'LineWidth', 2, 'DisplayName', 'Resampleada (long. arco)');
hold all
%plot_traj = plot(curve1_resampled_3D(:, 1), curve1_resampled_3D(:, 2),'Color', color_traj, 'Marker','o', 'MarkerSize', 3, 'LineWidth', 2, 'DisplayName', 'Resampleada (long. arco)');
%plot(trayectoria_resampleada(:, 1), trayectoria_resampleada(:, 2), 'yo-', 'DisplayName', 'Resampleada (long. arco)');
%plot(x_hom(1,:), -x_hom(2,:), 'go-', 'DisplayName', 'GT Polinomial');  %GT Trajectory)

%Desired 
plot_desired = plot3(curve2_resampled_3D(:, 1),curve2_resampled_3D(:, 2),curve2_resampled_3D(:, 3), 'Marker','o', 'Color', color_curve2, 'MarkerSize', 5, 'LineWidth', 2, 'DisplayName', 'Resampleada (long. arco)');
hold all
%plot_desired = scatter3(curve2_resampled_3D(:, 1),curve2_resampled_3D(:, 2),curve2_resampled_3D(:, 3),'Color', color_desired,'o', 'MarkerSize', 3, 'LineWidth', 2, 'DisplayName', 'Resampleada (long. arco)');
%plot_desired = plot(curve2_resampled_3D(:, 1), curve2_resampled_3D(:, 2),'Color', color_desired, 'Marker','o', 'MarkerSize', 3, 'LineWidth', 2, 'DisplayName', 'Resampleada (long. arco)');
%plot(uv_desired(1,:), uv_desired(2,:), 'go-', 'DisplayName', 'GT DESIRED'); 






%pair points
global traj3D_bool
traj3D_bool =true;
[p1 , p2] = join_pairs(pairing_table_3D, plot_interval, curve1_resampled_3D, curve2_resampled_3D, total_points);

%COLOR map

distance_vector = calc_3d_dist_vector (p1, p2);


%choose color map->Parula, jet
color_map_toplot = colormap(jet(length(p1)));


[a, b] = sort(distance_vector, 'ascend');
[~,distance_vector_sorted_indices] = sort(b);

for i = 1:length(p1)

    color_to_plot = color_map_toplot(distance_vector_sorted_indices(i),:);
    
        X = [p1(1,i), p2(1,i)];
        Y = [p1(2,i), p2(2,i)];
        Z = [p1(3,i), p2(3,i)];

     plot3(X, Y, Z, '-', 'Color', color_to_plot, 'LineWidth', 1);
    %plot([p1(1,i), p2(1,i)], [p1(2,i), p2(2,i)],  'Color', color_to_plot, 'LineWidth', 2)
    
end

xlabel('X');
ylabel('Y');
zlabel('Z');

%legend('show');
title('Distance to 3D Desired');
grid on;
hold off;

legend([plot_desired plot_traj], {"Trajectory calculated", "Trajectory Executed"},'Location','southwest')

axis equal;
end
