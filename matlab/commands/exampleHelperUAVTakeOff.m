function exampleHelperUAVTakeOff(stateSub, setModeCli, armingCli, srvReqTimeout)
% 20261014 Local takeoff helper: request OFFBOARD, then arming, spaced by srvReqTimeout.
% Pilot override: once OFFBOARD was reached, if the mode changes away from OFFBOARD
% (pilot flips the RC switch or moves the sticks with COM_RC_OVERRIDE=3), it NEVER requests
% OFFBOARD or arming again. Run "clear functions" before each MULTIRUNS_ROS to reset.
    persistent lastReq wasOffboard overridden
    if isempty(lastReq), lastReq = -inf; wasOffboard = false; overridden = false; end
    st = stateSub.LatestMessage;
    if isempty(st) || ~st.Connected || overridden, return, end
    if strcmp(st.Mode, 'OFFBOARD')
        wasOffboard = true;
    elseif wasOffboard
        overridden = true;
        fprintf('      PILOT OVERRIDE (mode = %s): no more OFFBOARD/arming requests\n', st.Mode);
        return
    end
    now_s = posixtime(datetime('now'));
    if now_s - lastReq < srvReqTimeout, return, end
    if ~strcmp(st.Mode, 'OFFBOARD')
        req = rosmessage(setModeCli); req.CustomMode = 'OFFBOARD';
        try, resp = call(setModeCli, req, 'Timeout', 2); fprintf('      set_mode OFFBOARD -> sent=%d\n', resp.ModeSent);
        catch ex, fprintf('      set_mode OFFBOARD failed: %s\n', ex.message); end
        lastReq = now_s;
    elseif ~st.Armed
        req = rosmessage(armingCli); req.Value = true;
        try, resp = call(armingCli, req, 'Timeout', 2); fprintf('      arming -> success=%d\n', resp.Success);
        catch ex, fprintf('      arming failed: %s\n', ex.message); end
        lastReq = now_s;
    end
end