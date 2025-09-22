function url = getLicenseURL(obf)
    % Decode: shift characters back by -3
    url = char(double(obf) - 3);
end