function paramDeltasIdx = getParamIndexes_DLSOffset(summaryRaw)



for k = 3:size(summaryRaw,1)
    if strcmp(summaryRaw{k,2}, 'Failed')
        idxFailed(k) = true;
    else
        idxFailed(k) = false;
    end
end


goodRuns = summaryRaw(~idxFailed,:);



% Fix summaryRaw
justParams_sumRaw = goodRuns(:,6:end);
mostCommon = cell(1, size(justParams_sumRaw, 2));

for col = 1:size(justParams_sumRaw, 2)
    currCol = justParams_sumRaw(2:end, col);  % Skip header row

    % Convert column to string array (handles mixed types)
    strCol = string(currCol);

    % Count unique values
    [uniqueVals, ~, idx] = unique(strCol);
    counts = accumarray(idx, 1);
    [~, maxIdx] = max(counts);

    % Get original value (with original type)
    mostCommon{col} = currCol{find(idx == maxIdx, 1)};
end
base_summary = [justParams_sumRaw(1,:);mostCommon;justParams_sumRaw(3:end,:)];


%
% idxFirstRun = find(~ismissing(goodRuns(2:end, 6:end)));
% idxFirstRun = idxFirstRun(1);
%
% [rowFirstRun, colFirstRun] = ind2sub(size(goodRuns(2:end, 6:end)), idxFirstRun);
% rowFirstRun = rowFirstRun + 1;
% colFirstRun = colFirstRun + 5;
%
% out = [goodRuns(1,colFirstRun:end); goodRuns(rowFirstRun:end,colFirstRun:end)];
% initialRun = summaryRaw(2,:);
%
% if strcmp(summaryRaw{2,2}, 'Failed')
%     disp('Initial Sim Failed');
%     quit;
% end


[nr, nc] = size(base_summary);
out = cell(size(base_summary));
out(1,:) = base_summary(1,:); % sets the header values from the summary to out
for c = 1:nc
    currBase = base_summary{2,c}; % current baseline value

    currParam = base_summary{1,c};
    if contains(currParam, 'Blade') || contains(currParam, 'Rollout')
        if contains(currParam, 'Blade')
            pattern = {'P1'; 'P2'; 'P3'; 'P4'; 'P5'};
        else
            pattern = [-2;-1.5;-1;-0.5;0;0.5;1;1.5;2];
            pattern = string(pattern);
        end
        currCol = base_summary(3:end,c);
        matchIdx = [];


        for i = 1:(length(currCol) - length(pattern) + 1)
            if isequal(currCol(i:i+length(pattern)-1),pattern)
                matchIdx = i:i+length(pattern)-1;

                break
            end
        end

        allIdx = 1:length(currCol);
        otherIdx = setdiff(allIdx, matchIdx);
        currCol(otherIdx) = {''};
        out(3:end,c) = currCol;


    else % deltas
        currCol = base_summary(3:end,c);
        currCol = cellstr(currCol);
        currBase = string(currBase);
        idxMatch = strcmp(currBase, currCol);

        x = idxMatch;
        x_cleaned = x;
        is_spike = [false; ~x(1:end-2) & x(2:end-1) & ~x(3:end); false];
        x_cleaned(is_spike) = false;

        currCol(x_cleaned) = {''};
        out(3:end,c) = currCol;

        

    end
end




for c = 1:size(out,2)
    for r = 2:size(out,1)
        if isempty(out{r,c})
            idxEmpty(r,c) = true;
        else
            idxEmpty(r,c) = false;
        end
    end
end
idxEmpty(1,:) = true;

paramIdx = find(~idxEmpty);
[rowParamIdx, colParamIdx] = ind2sub(size(out), paramIdx);

[~, ia] = unique(colParamIdx);

paramDeltasIdx = out(1,:);

% for k = 1:numel(ia) - 1
%     paramDeltasIdx{2,k} = (rowParamIdx(ia(k)) + 1 :rowParamIdx(ia(k+1)-1) + 1) - 1;
% end
% 
% paramDeltasIdx{2,numel(ia)} = rowParamIdx(ia(k + 1)) + 1:rowParamIdx(end) + 1;

[nr, nc] = size(out);
for c = 1:nc
    currParam = out{1,c};
    currIdx = find(~idxEmpty(:,c));
    paramDeltasIdx{2,c} = currIdx;
end


end