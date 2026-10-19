%function to return the min_dist and index in curve 2
%input p1 and p2

function [min_dist, min_dist_index_2 ] = walk_vector(p1,p2,i, min_dist, min_dist_index_2)
global traj3D_bool  % to calculate 3D distance, else 2D


                 %---
                if i==1 %initialize min_dist and min_dist_index

                    %min_dist = calc_2d_dist(p1,p2);
                        if traj3D_bool
                            min_dist = calc_3d_dist(p1,p2);
                        else
                            min_dist = calc_2d_dist(p1,p2);
                        end

                    min_dist_index_2= i;
                    %fprintf("initial min_dist=%.2f\n", min_dist);

                    else %compare and find min and index
                        if traj3D_bool
                            compare_dist = calc_3d_dist(p1,p2);
                        else
                            compare_dist = calc_2d_dist(p1,p2);
                        end

                    
                    %fprintf("compare_dist=%.2f\n", compare_dist);

                    if compare_dist < min_dist %If compare is less
                        %fprintf("NEW min_dist=%.4f\n", compare_dist);
                        
                        min_dist = compare_dist; % assign new min
                        min_dist_index_2= i; % and new index
                        %fprintf("rel INDEX=%i\n", min_dist_index_2);
                    else
                        return
                    end

                end
                %---
                
 
end
