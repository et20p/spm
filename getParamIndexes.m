function paramDeltasIdx = getParamIndexes(summaryRaw)

for k = 3:size(summaryRaw,1)
    if strcmp(summaryRaw{k,2}, 'Failed')
        idxFailed(k) = true;
    else
        idxFailed(k) = false;
    end
end


goodRuns = summaryRaw(~idxFailed,:);

idxFirstRun = find(~ismissing(goodRuns(2:end, 6:end)));
idxFirstRun = idxFirstRun(1);

[rowFirstRun, colFirstRun] = ind2sub(size(goodRuns(2:end, 6:end)), idxFirstRun);
rowFirstRun = rowFirstRun + 1;
colFirstRun = colFirstRun + 5;

out = [goodRuns(1,colFirstRun:end); goodRuns(rowFirstRun:end,colFirstRun:end)];
initialRun = summaryRaw(2,:);

if strcmp(summaryRaw{2,2}, 'Failed')
    disp('Initial Sim Failed');
    quit;
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

for k = 1:numel(ia) - 1
    paramDeltasIdx{2,k} = rowParamIdx(ia(k)) + 1 :rowParamIdx(ia(k+1)-1) + 1;
end

paramDeltasIdx{2,numel(ia)} = rowParamIdx(ia(k + 1)) + 1:rowParamIdx(end) + 1;
end