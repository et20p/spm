% Run this locally (not in deployed app) to produce obf string
function obf = makeObfDate(dateStr, key)
    bytes = uint8(dateStr);
    keyRep = repmat(key, 1, ceil(numel(bytes)/numel(key)));
    enc = bitxor(bytes, keyRep(1:numel(bytes)));
    obf = matlab.net.base64encode(enc);
end

% Example:
% obf = makeObfDate('2025-11-25', uint8([13,42,7,99]))
% copy the printed obf into the getExpirationDate_xor function