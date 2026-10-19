function [ nodeName, bagName] = rosbag_record(targetFolder,topics)

    % --- SETUP ---
    % 1. Create directory if it doesn't exist
    if ~exist(targetFolder, 'dir')
        mkdir(targetFolder);
        fprintf('Created directory: %s\n', targetFolder);
    end

    % Generate unique timestamp
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

    % 2. Create unique Node Name (to avoid conflicts with other nodes)
    % We replace hyphens with underscores because node names can't have '-'
    safeTimestamp = strrep(timestamp, '-', '_');
    nodeName = sprintf('matlab_rec_%s', safeTimestamp);


    % 2. Generate unique filename (Year-Month-Day_Hour-Min-Sec)
    %timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    bagName = sprintf('recording_%s.bag', timestamp);
    fullPath = fullfile(targetFolder, bagName);

    % --- EXECUTION (NON-BLOCKING) ---
    % We add '&' at the end to run in background.
    % We add 'echo $!' to return the Process ID (PID) of the background job.
    command = sprintf('rosbag record -O %s %s __name:=%s > /dev/null 2>&1 &', ...
                      fullPath, topics, nodeName);

    fprintf('Starting recording node: /%s\n', nodeName);
    fprintf('BagName: %s\n', bagName);

    % Execute in background
    status = system(command);
    
    if status ~= 0
        warning('Failed to launch rosbag node.');
        nodeName = ''; 
    end
end