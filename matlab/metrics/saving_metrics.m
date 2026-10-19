metrics_prefix = "/04_metrics"; 
path_metrics_folder = path_actual_test_folder+ metrics_prefix;
mkdir(path_metrics_folder);
path_metrics = path_metrics_folder  +"/metrics_stored.txt";
writematrix (metrics_stored,path_metrics); 