function outputVector = createXRangeforMu(idxMatch)

    % Find the index of the true value
    trueindex = find(idxMatch);

    % Count consecutive zeros to the left
    a_left = 0;
    for i = trueindex - 1:-1:1
        if idxMatch(i) == 0
            a_left = a_left + 1;
        else
            break;
        end
    end

    % Count consecutive zeros to the right
    a_right = 0;
    for i = trueindex + 1:numel(idxMatch)
        if idxMatch(i) == 0
            a_right = a_right + 1;
        else
            break;
        end
    end

    % % Now, calculate the final range from -a_left to a_right
    % start_idx = trueindex - a_left;  % Start index is the true index minus a_left zeros
    % end_idx = trueindex + a_right;   % End index is the true index plus a_right zeros
    % 
    % % Ensure the output range is within the bounds of the array
    % outputVector = start_idx:end_idx;
    % outputVector = outputVector(outputVector >= 1 & outputVector <= numel(idxMatch));

    outputVector = -a_left:a_right;
    if outputVector(trueindex) ~= 0
        errordlg("Base Index does not match","Error in Lap Mu X Creation");
        quit;
    end

    % Return the result as a row vector
    outputVector = transpose(outputVector);

end
