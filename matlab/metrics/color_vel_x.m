figure(6);hold on;
plot(t_resampling, curve1_interp_x, Color = color_bag, LineWidth=linewidth_3Dvel, DisplayName='Rosbag vel');
plot(t_resampling, curve2_interp_x, Color = color_traj, LineWidth=linewidth_3Dvel, DisplayName='Published vel');
            xlabel('t')    
            ylabel('Velocity-X')

% VEL X COLOR
distance_vector_x = sqrt(error_3Dvel_x.^2);
max_dist_color_x = max(distance_vector_x);
min_dist_color_x = min(distance_vector_x);

%choose color map->Parula, jet
color_map_toplot = colormap(jet((resampling_size)));


[a, b] = sort(distance_vector_x, 'ascend');
[~,distance_vector_x_sorted_indices] = sort(b);

for i = 1:plot_interval_3Dvel:(resampling_size)

    color_to_plot_x = color_map_toplot(distance_vector_x_sorted_indices(i),:);
    plot( [t_resampling(i), t_resampling(i)], [curve1_interp_x(i), curve2_interp_x(i)], 'Color', color_to_plot_x, 'LineWidth', 1, 'HandleVisibility','off')
    
end
legend