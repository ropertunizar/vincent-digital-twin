figure(6);hold on;
plot(t_resampling, curve1_interp_y, Color = color_bag, LineWidth = linewidth_3Dvel,DisplayName='Rosbag vel');
plot(t_resampling, curve2_interp_y, Color = color_traj, LineWidth = linewidth_3Dvel,DisplayName='Published vel');
            xlabel('t')    
            ylabel('Velocity-Y')

% VEL Y COLOR
distance_vector_y = sqrt(error_3Dvel_y.^2);
max_dist_color_y = max(distance_vector_y);
min_dist_color_y = min(distance_vector_y);

%choose color map->Parula, jet
color_map_toplot = colormap(jet((resampling_size)));


[a, b] = sort(distance_vector_y, 'ascend');
[~,distance_vector_y_sorted_indices] = sort(b);

for i = 1:plot_interval_3Dvel:(resampling_size)

    color_to_plot_y = color_map_toplot(distance_vector_y_sorted_indices(i),:);
    plot( [t_resampling(i), t_resampling(i)], [curve1_interp_y(i), curve2_interp_y(i)], 'Color', color_to_plot_y, 'LineWidth', 1,'HandleVisibility','off')
    
end
legend