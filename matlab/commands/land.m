%% Landing sequence

% Get the current position 
poseMsg = currPosSub.LatestMessage;

exampleHelperUAVLand(posePub,poseMsg,r); %land at current position
