function d = calc_3d_dist_vector(p1, p2)
    for i=1:length(p1)
    d(1,i) = sqrt((p1(1,i)-p2(1,i))^2 + (p1(2,i)-p2(2,i))^2 + (p1(3,i)-p2(3,i))^2 );

    
    end
end
