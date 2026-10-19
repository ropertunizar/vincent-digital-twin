metrics_figs_prefix = "/04_metrics/00_figs/"; 
path_metrics_figs_folder = path_actual_test_folder+ metrics_figs_prefix;
mkdir(path_metrics_figs_folder);

    
    fig1_tosave = figure(1);
    fig1_name = "Metrics_exec.fig";

    fig2_tosave = figure(2);
    fig2_name = "2D_exec.fig";

    fig3_tosave = figure(3);
    fig3_name = "3D_exec_traj.fig";

    fig4_tosave = figure(4);
    fig4_name = "Graphs_exec.fig";

    fig6_tosave = figure(6);
    fig6_name = "Velocity_errors_exec.fig";


    fig8_tosave = figure(8);
    fig8_name = "Frechet_3D_exec.fig";


    fig88_tosave = figure(88);
    fig88_name = "Frechet_2D_exec.fig";

    savefig(fig1_tosave,path_metrics_figs_folder+fig1_name);
    savefig(fig2_tosave,path_metrics_figs_folder+fig2_name);
    savefig(fig3_tosave,path_metrics_figs_folder+fig3_name);
    savefig(fig4_tosave,path_metrics_figs_folder+fig4_name);
    savefig(fig6_tosave,path_metrics_figs_folder+fig6_name);
    savefig(fig8_tosave,path_metrics_figs_folder+fig8_name);
    savefig(fig88_tosave,path_metrics_figs_folder+fig88_name);