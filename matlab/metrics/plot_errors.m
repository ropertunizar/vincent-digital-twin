function [p1  p2] =plot_errors(traject_sim_resampled, desired_resampled, error_plot_interval);
total_points = length(traject_sim_resampled);
points_to_plot = round((total_points/error_plot_interval),0)+1;

traject_sim_resampled = traject_sim_resampled';
desired_resampled = desired_resampled';

p1 = zeros(2,points_to_plot);
p2 = p1 ;
j=1;

for i = 1:error_plot_interval:total_points
    p1(:,j) = traject_sim_resampled(:,i);
    p2(:,j) = desired_resampled(:,i);
    j=j+1;

    
end

%x= [p1(1,:), p2(1,:)];


%plot([x1, x2], [y1, y2], 'b-')
end
