function dt = getExpirationDate_xor()
    % Obfuscated payload
    obf = 'Njo8HCk7PwQ2Pw=='; % <- replace with real 
    key = uint8([4, 10, 14, 41]); % small repeating key
    
    raw = matlab.net.base64decode(obf);      % decode base64 -> uint8 bytes
    keyRep = repmat(key, 1, ceil(numel(raw)/numel(key)));
    decBytes = bitxor(raw, keyRep(1:numel(raw)));
    s = char(decBytes);                      % should be a date string "2025-11-25"
    dt = datetime(strtrim(s), 'InputFormat','yyyy-MM-dd');
end