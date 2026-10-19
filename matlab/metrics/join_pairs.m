function [p1, p2] = join_pairs(pairing_table, plot_interval,curve1, curve2, total_points )
global traj3D_bool


points_to_plot = round((total_points/plot_interval),0);
size_traj = size(curve1);

if size_traj(1) > size_traj(2) 
    curve1 = curve1';
    curve2 = curve2';
end

if traj3D_bool
        p1 = zeros(3,points_to_plot);
        p2 = p1 ;
else
    
        p1 = zeros(2,points_to_plot);
        p2 = p1 ;

end

j=1;

for i = 1:plot_interval:total_points
    
    p1(:,j) = curve1(: , pairing_table(i,1)); % desired
    p2(:,j) = curve2(: , pairing_table(i,2)); % traj sim 
    
    j=j+1;

    
end


end



