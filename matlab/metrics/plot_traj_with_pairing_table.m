function plot_traj_with_pairing_table(curve1_resampled, curve2_resampled, plot_interval, pairing_table,  total_points, calc_initial, calc_middle, calc_final,max_search_radius, figure_number,search_case) 

figure(figure_number);

%trajectoria SIM
if search_case ==1
    color_curve1 = 'blue';
    color_curve2 = "yellow" ; 
else
    color_curve1 = 'yellow';
    color_curve2 = "blue" ; 
end

%color_traj = 'yellow';
plot_traj = plot(curve1_resampled(:, 1), curve1_resampled(:, 2),'Color', color_curve1, 'Marker','o', 'MarkerSize', 3, 'LineWidth', 7, 'DisplayName', 'Resampleada (long. arco)');
%plot(trayectoria_resampleada(:, 1), trayectoria_resampleada(:, 2), 'yo-', 'DisplayName', 'Resampleada (long. arco)');
%plot(x_hom(1,:), -x_hom(2,:), 'go-', 'DisplayName', 'GT Polinomial');  %GT Trajectory)

%Desired
%color_desired = "green" ; 
plot_desired = plot(curve2_resampled(:, 1), curve2_resampled(:, 2),'Color', color_curve2, 'Marker','o', 'MarkerSize', 3, 'LineWidth', 5, 'DisplayName', 'Resampleada (long. arco)');
%plot(uv_desired(1,:), uv_desired(2,:), 'go-', 'DisplayName', 'GT DESIRED'); 

break_point1 = max_search_radius;
break_point2 = length (curve1_resampled) -max_search_radius;



%for debugging
if (calc_initial == true) && (calc_middle == false)  && (calc_final == false)
    pairing_table_edited = pairing_table(1:break_point1,:);
end

if (calc_initial == false) && (calc_middle == true)  && (calc_final == false)
    pairing_table_edited = pairing_table(break_point1+1:break_point2,:);
end

if (calc_initial == false) && (calc_middle == false)  && (calc_final == true)
    pairing_table_edited = pairing_table(break_point2+1:end,:);
end

if (calc_initial == true) && (calc_middle == true)  && (calc_final == true)
    pairing_table_edited = pairing_table;
end


%pair points
[p1 , p2] = join_pairs(pairing_table_edited, plot_interval, curve1_resampled, curve2_resampled, total_points);

%COLOR map

distance_vector = calc_2d_dist_vector (p1, p2);
max_dist_color = max(distance_vector);
min_dist_color = min(distance_vector);

%choose color map->Parula, jet
color_map_toplot = colormap(jet(length(p1)));


[a, b] = sort(distance_vector, 'ascend');
[~,distance_vector_sorted_indices] = sort(b);
for i = 1:length(p1)

    color_to_plot = color_map_toplot(distance_vector_sorted_indices(i),:);

    plot([p1(1,i), p2(1,i)], [p1(2,i), p2(2,i)],  'Color', color_to_plot, 'LineWidth', 2)
    
end

xlabel('X');
ylabel('Y');
%legend('show');
title('Distance to 2D Desired');
grid on;
hold off;

%trajectoria SIM
if search_case ==1
legend([plot_desired plot_traj], {"Desired Drawing", "Trajectory Executed"},'Location','southwest')

else
legend([plot_desired plot_traj], { "Trajectory Executed", "Desired Drawing"},'Location','southwest')

end


end
