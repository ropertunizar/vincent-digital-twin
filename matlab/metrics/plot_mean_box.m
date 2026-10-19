figure
exist_variable = exist('metrics_stored');
if exist_variable == 0
    metrics_stored = readmatrix (metrics_folder_path +"/metrics_stored.txt"); 
end


    
metrics_to_plot = metrics_stored'; %transpose

%DURATION
    %subplot(3,3,2)
           
    %boxplot([metrics_to_plot(:,1)],'Labels',labels_metrics(1))
    %title(titles_metrics(1))


%% CHECK WHEN VELOCITY
for i = 1:total_metrics_stored
    subplot(3,3,i)
           
    boxplot([metrics_to_plot(:,i)],'Labels',labels_metrics(i))
    title(titles_metrics(i))



end


%add title
title_string ="Metrics for total runs =" + string(total_runs);
sgtitle({title_string; ""});

