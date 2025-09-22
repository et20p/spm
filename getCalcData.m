function outputsOI = getCalcData(outputs,lapTime)

outputs_key = ["ARBLinkForce", "AeroAnglePitch", "AeroAngleYaw", "AeroHeightFront", "AeroHeightRear",...
    "AeroLiftBalance", "AeroLiftForceSAE", "BumpstopForce", "DiffuserSkirtElbowHeight", "TireCombSatBalancePercent",...
    "TireSlipAngle", "DynamicCWPercent","DynamicNWPercent","VehicleRollCoupleDistribution", "WheelToeAngle", ...
    "CamberAngle", "SplitterHeight", "BumpstopGap", "USG"];


c = 1;
for k = 1:numel(outputs_key)
    currIdx = find(contains(outputs(1,:), outputs_key{k}));

    if isempty(currIdx)
        disp(outputs_key{k});
    end

    currData = outputs(:,currIdx);

    [nr, nc] = size(currData);

    outputsOI(1:nr, c:c+nc-1) = currData;

    c = c + nc;
end


outputsOI = [outputsOI, lapTime];
end