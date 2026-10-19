function exampleHelperUAVLand(posePub, poseMsg, r)
% 20261014 Local replacement for MathWorks' example helper.
% Descends from the current pose at ~0.25 m/s (setpoints at rate r) to 0.05 m, then holds for 3 s.
% For the REAL drone the pilot still lands/disarms with the RC; this only brings it down gently.
    z = poseMsg.Pose.Position.Z;
    dz = 0.25 / r.DesiredRate;
    poseMsg.Header.FrameId = char('map');
    while z > 0.05
        z = max(z - dz, 0.05);
        poseMsg.Pose.Position.Z = z;
        send(posePub, poseMsg);
        waitfor(r);
    end
    for k = 1:round(3 * r.DesiredRate)
        send(posePub, poseMsg);
        waitfor(r);
    end
end
