figure(6);hold on;
plot(t_resampling, curve1_interp_z, Color = color_bag, LineWidth = linewidth_3Dvel, DisplayName='Rosbag vel');
plot(t_resampling, curve2_interp_z, Color = color_traj, LineWidth = linewidth_3Dvel, DisplayName='Published vel');
            xlabel('t')    
            ylabel('Velocity-Z')

% VEL Z COLOR
distance_vector_z = sqrt(error_3Dvel_z.^2);
max_dist_color_z = max(distance_vector_z);
min_dist_color_z = min(distance_vector_z);

%choose color map->Parula, jet
color_map_toplot = colormap(jet((resampling_size)));


[a, b] = sort(distance_vector_z, 'ascend');
[~,distance_vector_z_sorted_indices] = sort(b);

for i = 1:plot_interval_3Dvel:(resampling_size)

    color_to_plot_z = color_map_toplot(distance_vector_z_sorted_indices(i),:);
    plot( [t_resampling(i), t_resampling(i)], [curve1_interp_z(i), curve2_interp_z(i)], 'Color', color_to_plot_z, 'LineWidth', 1, 'HandleVisibility','off')
    
end
legend