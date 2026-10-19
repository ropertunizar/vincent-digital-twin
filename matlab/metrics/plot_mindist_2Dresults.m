
%fprintf ("plot_interval = %i\n", plot_interval);

     %for debugging
    calc_initial = true ;
    calc_middle = true;
    calc_final = true; 
    total_points = 0; %for plotting
    
    if calc_initial == true
        total_points = total_points + max_search_radius;
    end
    if calc_middle == true
        total_points = total_points + length (curve1_search) - 2*max_search_radius ; 
    end
    if calc_final == true
        total_points = total_points + max_search_radius;
    end

    %fprintf("total points to plot = %i\n", total_points);

    % plotting results
    %create camera view with desired wp's
    create_fig88_camera_view % create camera view (gray image)
    %plot_2D_points_onCameraView   % PLOT PROJECTED x_hom points on the camera
    plot_joined_wp = false; % to plot green joined wp's
    plot_fig88_2D_lines_onCameraView
    %lgd=legend;
    %delete(lgd);
    hold on;
    figure_number=88;
    
  global traj3D_bool  
  traj3D_bool = false;

  

  %% coloring curves, order matters

        plot_traj_with_pairing_table(curve1_search, curve2_search, ...
            plot_interval, pairing_table, total_points,calc_initial, ...
            calc_middle, calc_final,max_search_radius,figure_number,search_case);


