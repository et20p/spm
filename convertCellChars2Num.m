function convertedData = convertCellChars2Num(currData)


inputIsChar = cellfun(@ischar, currData);
for k = 1:numel(inputIsChar)
    if inputIsChar(k)
        currData{k} = str2num(currData{k});
    end
end

convertedData = currData;

end