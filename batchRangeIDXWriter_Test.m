fp = "C:\Users\EastonPrice\OneDrive - Spire Motorsports LLC\Documents\2025(P) Race Engineering\Balance Calculator\2025\BalanceCalculator_Creator\batchHeaders.xlsx";

raw = readcell(fp);

batchheaders = raw(1,:);
load("exBaselineSetup.mat")

%^save("batchHeaders_template.mat","batchheaders")

%%

batchRangeIdx = batchheaders;

for k = 1:length(batchRangeIdx)
    currParam = batchRangeIdx{1,k};
    if contains(currParam, 'ARB Arm Blade') % Blade Positions
        batchRangeIdx{2,k} = [{'P1'},{'P2'},{'P3'},{'P4'},{'P5'}];
    elseif contains(currParam, 'Rollout Delta RR') % Rollout Delta (RR)
        batchRangeIdx{2,k} = num2cell(linspace(-2,2,9));
    elseif contains(currParam, 'ARB Rounds') % ARB Rounds
        batchRangeIdx{2,k} = num2cell(linspace(-4,4,8));
    elseif contains(currParam, 'Fuel Mass') % Addl' Fuel Mass
        batchRangeIdx{2,k} = num2cell(linspace(-15,15,8));
    elseif contains(currParam, 'Spring Rounds') % Spring Rounds
        batchRangeIdx{2,k} = num2cell(linspace(-4,4,10));
    elseif contains(currParam, 'Air Pressure') %Air Pressure
        batchRangeIdx{2,k} = num2cell(linspace(-2,2,5));
    elseif contains(currParam, 'Air Temperature') % Air Temp
        batchRangeIdx{2,k} = num2cell(linspace(-15,15,6));
    elseif contains(currParam, 'Relative Humidity') % Humidity
        batchRangeIdx{2,k} = num2cell(linspace(-10,10,5));
    elseif contains(currParam, 'Camber') % Camber
        batchRangeIdx{2,k} = num2cell(linspace(-1.5,1.5,10));
    elseif contains(currParam, 'Spring Rate')
        batchRangeIdx{2,k} = num2cell(linspace(-400,400,10));
    elseif contains(currParam, 'Toe Inches') % Toe"
        batchRangeIdx{2,k} = num2cell(linspace(-.1,.1,10));
    elseif contains(currParam, 'Diff') % Diff Preload Pressure
        batchRangeIdx{2,k} = num2cell(linspace(-250,250,5));
    elseif contains(currParam, 'Cross Weight') % CW - Hooked and UH
        batchRangeIdx{2,k} = num2cell(linspace(-3.5,3.5,12));
    elseif contains(currParam, 'Nose Weight') %NW
        batchRangeIdx{2,k} = num2cell(linspace(-2,2,12));
    elseif contains(currParam, 'Frame Height')
        batchRangeIdx{2,k} = num2cell(linspace(-.1,.1,10));
    elseif contains(currParam, 'Tire Cold Pressure')
        batchRangeIdx{2,k} = num2cell(linspace(-4,8,12));
    elseif contains(currParam, 'Right Side')
        batchRangeIdx{2,k} = num2cell(linspace(-150,150,8));
    elseif contains(currParam, 'Track Mu')
        batchRangeIdx{2,k} = num2cell(linspace(-0.5,.5,15));
    else
        fprintf('Missed one\n');
    end
end

%% Write Batch inputs
clc
[~, nc] = size(batchRangeIdx);
batchInputs = batchRangeIdx(1,:);
for c = 1:nc
    currParam = batchRangeIdx{1,c}; % based off sample batch
    currRange = batchRangeIdx{2,c};
    if contains(currParam, 'Atmospheric Conditions')
        idxdash = strfind(currParam, ' - ');
        fixedParam = currParam(idxdash+3:end);
        currParam = fixedParam;
    elseif contains(currParam, 'Toe Inches')
        corner = currParam(end-1:end);
        currParam = append('Toe Length ', corner, ' Tech');
    elseif contains(currParam, 'Speed Profile Lap Sim Track Mu')
        currParam = 'DLS Track Mu';
    end

    idxParamBaseline = find(contains(baselineSetup(1,:), currParam), 1);
    currBaseline = baselineSetup{2,idxParamBaseline}; % from setup compare
    if contains(currParam, 'Blade Position')
        batchInputs(2:1+numel(currRange),c) = currRange';
    elseif contains(currParam, 'Rollout Delta')
        batchInputs(2:1+numel(currRange),c) = currRange';
    else

        batchInputs(2:1+numel(currRange),c) = num2cell(str2num(currBaseline) + cell2mat(currRange))';
    end
    baseline4Batch{2,c} = currBaseline;
    baseline4Batch{1,c} = currParam;


end
%%
totalElements = 0;

[nr, nc] = size(batchInputs(1:end,:));
for c = 1:nc
    for r = 2:nr
        t = batchInputs{r,c};
        if ~isempty(batchInputs{r,c})
            totalElements = totalElements + 1;
        end
    end
end

disp(['Total elements: ' num2str(totalElements)]);

%% Make batch

idxUHCW = contains(batchInputs(1,:),'Cross Weight % Race Unhooked');
idxHCW = contains(batchInputs(1,:),'Cross Weight % Race Hooked');
inputs_UHCW = batchInputs(:,idxUHCW);
idxEmpty = cellfun(@isempty,inputs_UHCW);
numCWRuns = numel(inputs_UHCW) - sum(idxEmpty) - 1;
numRuns = totalElements - numCWRuns;
fprintf('\nNum Generated Sim Runs (CW and UH combined): %d\n',numRuns);


outputBatch = batchInputs(1,:);
[~, nc] = size(batchInputs);
currRow = 3;
for c = 1:nc
    
    currCol = batchInputs(:,c);
    idxNonEmpty = ~cellfun(@isempty, currCol);
    currInputs = currCol(idxNonEmpty);
    outputBatch{1,c} = currInputs{1};
    outputBatch{2,c} = baseline4Batch{2,c};
    
    if c == find(idxUHCW)
        outputBatch(currRow:currRow + numel(currInputs)-2,c) = currInputs(2:end);
        outputBatch(currRow:currRow + numel(currInputs)-2,c+1) = currInputs(2:end);
        currRow = currRow + numel(currInputs) - 1;
    elseif c == find(idxHCW)
        continue;
    else

        outputBatch(currRow:currRow + numel(currInputs)-2,c) = currInputs(2:end);
    
        currRow = currRow + numel(currInputs) - 1;
    end
end

[nRows, nCols] = size(outputBatch);

for col = 1:nCols
    % Find empty cells in the current column
    emptyMask = cellfun(@isempty, outputBatch(:, col));

    % Replace empty cells with the value from row 2 of the same column
    outputBatch(emptyMask, col) = repmat(outputBatch(2, col), sum(emptyMask), 1);
end

% Don't need baseline row (row 2 in outputBatch), getting rid of it here:
outputBatch(2,:) = [];

%% Export batch
[filename, pathname] = uiputfile('*.csv','Save as');
if ischar(filename)
    fullpath = fullfile(pathname, filename);
    try
        writetable(cell2table(outputBatch),fullpath, 'WriteVariableNames',false);
    catch ME
        uialert(figure, 'Save Error', 'Error')
    end
end

    
        

