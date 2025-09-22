% 2025 Balance Calculator
% v1
clearvars; clc

close all

sfSplit = true; % is SF-1 split?
saveBC = false;
resultsFP = "C:\Users\EastonPrice\OneDrive - Spire Motorsports LLC\Documents\2025(P) Race Engineering\2025 Schedule\25_31BRI2\Balance Calculator\manualBC_25BRI2_Race_FilteredResults.csv";
summaryFP = "C:\Users\EastonPrice\OneDrive - Spire Motorsports LLC\Documents\2025(P) Race Engineering\2025 Schedule\25_31BRI2\Balance Calculator\manualBC_25BRI2_Race_Summary.csv";
batchFP = "C:\Users\EastonPrice\OneDrive - Spire Motorsports LLC\Documents\2025(P) Race Engineering\2025 Schedule\25_31BRI2\Balance Calculator\manualBC_25BRI2_Race.csv";

resultsRaw = readmatrix(resultsFP, "Range", "A1", 'OutputType','char');
summaryRaw = readmatrix(summaryFP, "Range", "A1", 'OutputType','char');
batchRaw = readmatrix(batchFP, "Range", "A1", 'OutputType','char');


m_paramHeaders = batchRaw(1,:);

idxSolveFor = contains(m_paramHeaders, 'Solve for', 'IgnoreCase',true);
m_paramHeaders = m_paramHeaders(~idxSolveFor);

%Getting rid of hooked CW since sim IDs are the same as unhooked
idxHooked = contains(m_paramHeaders, 'Cross Weight % Race Hooked');
m_paramHeaders = m_paramHeaders(~idxHooked);


%% get indexes of parameter changes thru the batch csv 

% from the row they appear in the batch
% [nr, nc] = size(batchRaw);
% guessBaseline = batchRaw(1,:); 
% batchIndexes = batchRaw(1,:);
% for c = 1:nc
%     currHeader = batchRaw{1,c};
%     if contains(currHeader, 'Blade Position')
%         if contains(currHeader, 'LF')
%             currIdx = 2:6;
%         elseif contains(currHeader, 'RF')
%             currIdx = 7:11;
%         elseif contains(currHeader, 'LR')
%             currIdx = 12:16;
%         else
%             currIdx = 17:21;
%         end
% 
%     elseif contains(currHeader, 'Rollout Delta RR')
%         currIdx = 352:360;
%     else
%         currCol = batchRaw(2:end,c);
%         currCol_cat = categorical(currCol);
%         counts = countcats(currCol_cat);
%         [~,idxGC] = max(counts);
%         mostCommon = categories(currCol_cat);
%         mostCommonValue = mostCommon{idxGC};
%         currBaseline = guessBaseline{1,c};
%         idxMatch = cellfun(@(x) isequal(x,mostCommonValue),currCol);
%         matchIndices = find(idxMatch);
% 
%         [m,i] = max(diff(matchIndices));
%         currIdx = matchIndices(i)+2:(matchIndices(i)+m);
% 
%         % disp(currHeader)
%         % disp(currIdx);
% 
%     end
%     batchIndexes{2,c} = currIdx;
% end

%% Find failed sims

load("C:\Users\EastonPrice\OneDrive - Spire Motorsports LLC\Documents\2025(P) Race Engineering\Balance Calculator\2025\BalanceCalculator_Creator\batchIndexes_v1.mat");
idxFailed = find(contains(summaryRaw(:,2),'Failed')); %should be a +1 offset from batchIndexes. Batch indexes should be line up with the actual sim ID
simIDFailed = cell2mat(convertCellChars2Num((summaryRaw(idxFailed,1))));

[~, nc] = size(batchIndexes);

for k = 1:nc
    if any(ismember(simIDFailed, batchIndexes{2,k}))
        [~, idx] = ismember(batchIndexes{2,k},simIDFailed);
        mask = idx == 0;
        keepIdx = batchIndexes{2,k}(mask);
        batchIndexes{2,k} = keepIdx;
        
    end
end
idxHooked = contains(batchIndexes(1,:), 'Cross Weight % Race Hooked');
batchIndexes = batchIndexes(:,~idxHooked);
%% Check results for failed

% results dont include failed sims

% check and make sure those sims are not in the results
% remove the indexes from the parameter indexes gathered from the batch
% pass those indexes into the algorithm similar to before


% gets both parameter and output data, based on index of laptime.
% sfSplit should have value of true if the SF is split into a and b
% sectionssave
[paramData, outputs, lapTime, simIDs] = getDataOfInterest(resultsRaw,m_paramHeaders, sfSplit);

%%

idxIsNum = cellfun(@isnumeric, lapTime);
lapTime_num = convertCellChars2Num(lapTime);
idxEmpty = cellfun(@isempty, lapTime_num);
lapTime_num(idxEmpty) = num2cell(NaN);
lapTime_num = cell2mat(lapTime_num);
idx0LapTime = (lapTime_num == 0);
rowsWithTrue = find(any(idx0LapTime, 2));



outputNames = outputs(1,:); % output names + segments, first row of outputs
idxUnderScore = strfind(outputNames(1,:), '_'); % Assuming output names occur before the first underscore

for k = 1:length(idxUnderScore)
    sectorNames{k} = outputNames{k}(idxUnderScore{k}(1)+1:end); % extracted segment name
    outputNames{k} = outputNames{k}(1:idxUnderScore{k}(1)-1); % extracted output name

end

outputNames = unique(outputNames);
sectorNames = unique(sectorNames);

%idxUnhooked = find(contains(paramData(1,:), 'Unhooked'));
idxToeAngle = find(contains(paramData(1,:), 'Toe Angle'));
idxfARB = find(contains(paramData(1,:), 'ARB Front'));
idxrARB = find(contains(paramData(1,:), 'ARB Rear'));
idxUD0 = find(contains(paramData(1,:),'UD0'));



paramData(:, [idxToeAngle, idxfARB, idxrARB, idxUD0]) = [];
% %% Find Parameter Indexes
% 
baselineParam = paramData(2,:);
% 
% paramDeltasIdx = getParamIndexes(summaryRaw);
%% gotta return simIds to row indexes
[~, nc] = size(batchIndexes);
n = 3;
paramDeltasIdx = batchIndexes(1,:);
for i = 1:nc
    paramDeltasIdx{2,i} = n:n+numel(batchIndexes{2,i})-1;
    n = n+numel(batchIndexes{2,i});
end


%paramDeltasIdx = batchIndexes;


%% Get outputs of interest

outputsOI = getCalcData(outputs, lapTime);

idxEmpty = find(cellfun(@isempty, outputsOI));

%%
clear linFit currInputIdx polyFit
minRlinear = 0.85;
minRquad = 0.7;

warning('off', 'MATLAB:polyfit:PolyNotUnique');

q = 1;

linFit(2:size(paramData,2)+1,1) = paramData(1,:);
linFit(1,2:size(outputsOI,2)+1) = outputsOI(1,:);

polyFit = linFit;
polyFit{1,1} = "a";
polyFit{size(paramData,2) + 2, 1} = "b";
boffset = size(paramData,2) + 1;
polyFit{boffset + size(paramData,2) + 2,1} = "c";
coffset = boffset + size(paramData,2) + 1;

polyFit(boffset + 2:boffset+2+size(paramData,2)-1,1) = paramData(1,:);
polyFit(coffset + 2: coffset+2+size(paramData,2)-1,1) = paramData(1,:);

polyFit{coffset + size(paramData,2) + 2,1} = "d";
doffset = coffset + size(paramData,2) + 3;
polyFit(doffset:doffset+size(paramData,2)-1,1) = paramData(1,:);

polyFit{doffset + size(paramData,2),1} = "Baseline Data";
baseOffset = doffset + size(paramData,2) + 1;


linFit{end+1,1} = "Baseline Setup";
[nr, ~] = size(linFit);
for k = 1:size(paramData,2)
    currB = paramData{2,k};
    currB = replace(currB, 'P', '');
    currB = str2num(currB);
    linFit{nr,k+1} = paramData{1,k};
    linFit{nr+1,k+1} = currB;
end

r = 2; c = 2;
for i = 1:size(paramData,2)
    currInputIdx = find(contains(paramDeltasIdx(1,:), paramData{1,i}));
    currInputDeltaIdx = paramDeltasIdx{2,currInputIdx};

    currInputs = paramData(currInputDeltaIdx, i);

    if contains(paramData(1,i), 'Blade')
        for q = 1:numel(currInputs)
            currInputs{q} = replace(currInputs{q}, 'P', '');
        end
    end

    if contains(paramData(1,i), 'Camber RR')
        5;
    end

    currInputs = convertCellChars2Num(currInputs);
    rawInputs = currInputs;



    for o = 1:size(outputsOI,2)

        currOutputs = outputsOI(currInputDeltaIdx, o);

        currOutputs = convertCellChars2Num(currOutputs);
        idxIsEmpty = find(cellfun(@isempty, currOutputs));
        currOutputs(idxIsEmpty) = {0};

        idxIs0LapTime = ismember(currInputDeltaIdx, rowsWithTrue);
        if any(idxIs0LapTime)
            currInputs = currInputs(~idxIs0LapTime);
            currOutputs = currOutputs(~idxIs0LapTime);
        end

        xraw = cell2mat(currInputs);
        yraw = cell2mat(currOutputs);

        [y, io] = rmoutliers(yraw, 'movmedian',2);
        x = xraw;
        x(io) = [];

        if nnz(io) ~= 0
            removedOutliers{q,1} = paramDeltasIdx{1,currInputIdx};
            removedOutliers{q,2} = outputsOI{1,o};
            q = q + 1;
        end

        if numel(x) <= 3
            fprintf('Few points:\nx: %s  \ny: %s\n', paramData{1,i}, outputsOI{1,o})
            fprintf('Num Outliers = %d\n',nnz(io))
            fprintf('Num Points Remaining = %d\n\n', numel(xraw) - nnz(io))
            fprintf('----------------------------------------------')
        end
        [pl, sl] = polyfit(x, y, 1);
        [pq, sq] = polyfit(x, y, 3);

        polyFit{baseOffset, c} = cell2mat(convertCellChars2Num(outputsOI(2,o)));



        % linFit{r,c} = pl(1);
        % polyFit{r,c} = 12345;
        % polyFit{r + boffset, c} = 12345;
        % polyFit{r + coffset, c} = 12345;
        % polyFit{r + doffset - 2, c} = 12345;

        if contains(paramData(1,i), 'Rounds LF') && contains(outputsOI(1, o), 'VehicleDynamicCWPercent_Apx-1-2_Average')
            5;
        end

        if sl.rsquared > minRlinear || numel(y) <= 3
            linFit{r,c} = pl(1);
            polyFit{r,c} = 12345;
            polyFit{r + boffset, c} = 12345;
            polyFit{r + coffset, c} = 12345;
            polyFit{r + doffset - 2, c} = 12345;

        else
            linFit{r,c} = 12345;
            polyFit{r,c} = pq(1);
            polyFit{r + boffset, c} = pq(2);
            polyFit{r + coffset, c} = pq(3);
            polyFit{r + doffset - 2, c} = pq(4);
        end

        % if contains(paramData(1,i), 'LTS Track Mu') && contains(outputsOI(1, o), 'Times')
        %     linFit{r,c} = pl(1);
        %     polyFit{r,c} = 12345;
        % end


        c = c + 1;

        currInputs = rawInputs;

        if numel(currOutputs) < 3
            5;
        end
    end

    c = 2;
    r = r + 1;
end
open linFit
open polyFit

%% Bumpstop Data

bumpstopDataidx = contains(outputsOI(1,:),'Bumpstop');
bumpstopData = outputsOI(:,bumpstopDataidx);
% 
% [nr, nc] = size(paramDeltasIdx);
% for c = 1:nc
%     currIdx = paramDeltasIdx{2,c};
%     inputIdx = strcmp(paramDeltasIdx{1,c},paramData(1,:));
%     currInputs = cell2mat(convertCellChars2Num(paramData(currIdx,inputIdx)));
%     currOutputs = cell2mat(convertCellChars2Num(outputsOI))
[nr, ~] = size(bumpstopData);
divider = repmat({'Pause'},nr,1);
ender = repmat({'End'},nr,1);

stopViewer = [paramData, divider, bumpstopData, ender];
open stopViewer

stopViewerIdx = paramDeltasIdx(1,:);
[~, nc] = size(stopViewerIdx);
for c = 1:nc
    l = numel(paramDeltasIdx{2,c});
    for k = 1:l
        stopViewerIdx{k+1,c} = paramDeltasIdx{2,c}(k);
    end
end
open stopViewerIdx
b_paramHeaders = paramData(1,:)';
b_bumpstopHeaders = bumpstopData(1,:)';
open b_paramHeaders
open b_bumpstopHeaders
%% Parameter Plots



% getVariable = 'Spring Rate LF';
% getOutput = 'SatBalancePercent_T5';
% 
% 
% 
% currInputIdx = find(contains(paramDeltasIdx(1,:), getVariable));
% currInputDeltaIdx = paramDeltasIdx{2,currInputIdx};
% 
% currInputs = paramData(currInputDeltaIdx, contains(paramData(1,:), getVariable));
% 
% 
% currOutputs = outputsOI(currInputDeltaIdx, contains(outputsOI(1,:), getOutput,"IgnoreCase",true));
% 
% currOutputs = convertCellChars2Num(currOutputs);
% idxIsEmpty = find(cellfun(@isempty, currOutputs));
% currOutputs(idxIsEmpty) = {0};
% 
% 
% 
% idxIs0LapTime = ismember(currInputDeltaIdx, rowsWithTrue);
% if any(idxIs0LapTime)
%     currInputs = currInputs(~idxIs0LapTime);
%     currOutputs = currOutputs(~idxIs0LapTime);
% end
% 
% if contains(currInputs, 'P')
%         for q = 1:numel(currInputs)
%             currInputs{q} = replace(currInputs{q}, 'P', '');
%         end
% end
% 
% 
% x = cell2mat(convertCellChars2Num(currInputs));
% y = cell2mat(currOutputs);
% 
% %x = [3.6889, 4.1334]; y = [158.9755, 190.8875];
% 
% scatter(x,y);
% xlabel(getVariable);
% ylabel(getOutput)
% 
% [y, io] = rmoutliers(y, 'movmedian',3);
% x(io) = [];
% hold on
% scatter(x,y, 'r')
% hold off
% 
% [p1, s1] = polyfit(x,y,1);
% [p2, s2] = polyfit(x,y,3);
% 
% syms d
% hold on
% if s1.rsquared > s2.rsquared
%     fplot(p1(1)*d + p1(2), [min(x) max(x)])
%     % title('lin')
% else
%     fplot(@(d) p2(1)*d.^3 + p2(2)*d.^2 + p2(3)*d + p2(4), [min(x) max(x)], 'b','DisplayName','Curve Fit')
%     p = polyfit(x, y, 3);
%     y_fit = polyval(p,x);
%     plot(x,y_fit,'r--','DisplayName','3rd Degree Fit')
%     % title('quad')
% end
% % 
% % hold off
% % hold on
% % fplot(p1(1)*d + p1(2), [min(x) max(x)]);
% % hold off
% % 
% % [p3, s3] = polyfit(x,y,3);
% % hold on
% % fplot(p3(1)*d^3 + p3(2)*d^2 + p3(3)*d + p3(4), [min(x) max(x)])
% % hold off
% hold off

%% Variation Plots

varChannel = [paramData, outputsOI];

for c = 1:size(varChannel, 2)
    for r = 2:size(varChannel,1)
        if ischar(varChannel{r,c})
            varChannel{r,c} = replace(varChannel{r,c}, 'P', '');
            varChannel{r,c} = str2num(varChannel{r,c});
        end


    end
    varChannel{1,c} = convertCharsToStrings(varChannel{1,c});
end

%%
% [filename, pathname] = uigetfile('*.xlsm','Save Balance Calculator as');
% % if ischar(filename)
% %     savePath = fullfile(pathname, filename);
% %     try
% %         writetable(cell2table(outputBatch),savePath, 'WriteVariableNames',false);
% %         uialert(app.UIFigure, 'B.C. Save Successful', 'Success',Icon='success');
% %     catch ME
% %         uialert(app.UIFigure, 'Save Error', 'Error')
% %     end
% % end
% templatePath = fullfile(pathname, filename);
% justFN = split(resultsFP, '_FilteredResults');
% justFN = justFN{1};
% savePath = strcat(justFN, '_BC','.xlsm');
% copyfile(templatePath, savePath);
% 
% writecell(linFit(1,2:end), savePath, 'Sheet', '1stD', 'Range', 'B1'); %write linear fit headers
% writecell(linFit(2:end,:), savePath, 'Sheet', '1stD', 'Range', 'A3') %write linfit data
% 
% writecell(polyFit(1,2:end), savePath, 'Sheet', '3rdD', 'Range', 'B1') %write poly headers
% writecell(polyFit(2:end,:), savePath, 'Sheet', '3rdD', 'Range', 'A3') %write poly data
% 
% writecell(stopViewer, savePath, 'Sheet', 'Bumpstop Viewer', 'Range', 'BA1');
% writecell(b_paramHeaders, savePath, 'Sheet', 'Bumpstop Viewer', 'Range', 'AX10');
% writecell(b_bumpstopHeaders, savePath, 'Sheet', 'Bumpstop Viewer', 'Range', 'AY10');
% 
% writecell(stopViewerIdx, savePath, 'Sheet', 'Stop Viewer Data', 'Range', 'B1');
% disp('Done exporting')

%% Save and Export


if saveBC
    templateFP = "C:\Users\EastonPrice\Documents\2025(P) Race Engineering\Balance Calculator\2025\2025BalanceCalculator_Template.xlsm";

    pasteFP = "C:\Users\EastonPrice\Documents\2025(P) Race Engineering\Balance Calculator\2025\Paste_BC.xlsx.xlsm";

    copyWorkbook(templateFP, pasteFP);

    params = linFit(2:end-2,1);
    outputs_NamePaste = linFit(1,2:end);

    linData = linFit(2:end,:);

    quadData = poly3Fit(2:end,:);

    writecell(outputs_NamePaste, pasteFP, 'Sheet', 'Import Quad', 'Range', 'A1');

    writecell(quadData, pasteFP, 'Sheet', 'Import Quad', 'Range', 'A3');

    writecell(outputs_NamePaste, pasteFP, 'Sheet', 'Maths', 'Range', 'B1');

    writecell(linData, pasteFP, 'Sheet', 'Maths', 'Range', 'X1');

    writecell(aeroPlotData, pasteFP, 'Sheet', 'Aero Plotter Maths', 'Range', 'K1');

    fprintf('Data pasted to %s', pasteFP);

%% Copy Template File and Paste into Normal Folder



    % Split Full File Path
    sp = split(fp,'\');
    destFolder = join(sp(1:end-1),'\'); % Destination Folder

    raceID = char(sp(end-1));
    idx = false(size(raceID));
    idxUnd = strfind(raceID,'_');
    for k = idxUnd + 1:length(raceID)
        curr = str2num(raceID(k));
        if isempty(curr)
            idx(k) = 1;
        else
            idx(k) = 0;
        end
    end
    idx = logical(idx);
    newFN = strcat(raceID(1:2),'_',raceID(idx),raceID(end),'_77_Balance Calculator.xlsm');

    destFile = strcat(destFolder,'\',newFN)

    copyWorkbook(pasteFP, destFile);

end