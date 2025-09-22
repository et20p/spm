function combined = avgSF1ab_v2(raw)
rowHeaders = raw(1,:);

idx_sfa = contains(rowHeaders,'SF-1-a','IgnoreCase',true);
idx_sfb = contains(rowHeaders, 'SF-1-b', 'IgnoreCase',true);

finalHeaders = rowHeaders(~idx_sfb);

headers_sfa = rowHeaders(idx_sfa);
headers_sfb = rowHeaders(idx_sfb);

% Max
idx_a_max = contains(rowHeaders,'Max') & idx_sfa;
idx_b_max = contains(rowHeaders,'Max') & idx_sfb;

headers_sfa_max = rowHeaders(idx_a_max);
a = cell2mat(convertCellChars2Num(raw(2:end,idx_a_max)));
b = cell2mat(convertCellChars2Num(raw(2:end,idx_b_max)));
newData = num2cell(max(a,b));
%newHeaders = replace(headers_sfa_max,'SF-1-a','SF-1');
newData_max = [headers_sfa_max; newData]; %has sfa but its really sf-1

% Min
idx_a_min = contains(rowHeaders,'Min') & idx_sfa;
idx_b_min = contains(rowHeaders,'Min') & idx_sfb;
headers_sfa_min = rowHeaders(idx_a_min);
a = cell2mat(convertCellChars2Num(raw(2:end,idx_a_min)));
b = cell2mat(convertCellChars2Num(raw(2:end,idx_b_min)));
newData = num2cell(min(a,b));
%newHeaders = replace(headers_sfa_max,'SF-1-a','SF-1');
newData_min = [headers_sfa_min; newData]; %has sfa but its really sf-1

%Times
idx_a_Times = contains(rowHeaders,'Times') & idx_sfa;
idx_b_Times = contains(rowHeaders,'Times') & idx_sfb;
headers_sfa_Times = rowHeaders(idx_a_Times);
a = cell2mat(convertCellChars2Num(raw(2:end,idx_a_Times)));
b = cell2mat(convertCellChars2Num(raw(2:end,idx_b_Times)));
newData = num2cell(a + b);
%newHeaders = replace(headers_sfa_max,'SF-1-a','SF-1');
newData_Times = [headers_sfa_Times; newData]; %has sfa but its really sf-1


% Average
idx_a_mean = contains(rowHeaders,'Average') & idx_sfa;
idx_b_mean = contains(rowHeaders,'Average') & idx_sfb;
headers_sfa_mean = rowHeaders(idx_a_mean);
a = cell2mat(convertCellChars2Num(raw(2:end,idx_a_mean)));
b = cell2mat(convertCellChars2Num(raw(2:end,idx_b_mean)));
newData = num2cell((a + b)/2);
%newHeaders = replace(headers_sfa_max,'SF-1-a','SF-1');
newData_mean = [headers_sfa_mean; newData]; %has sfa but its really sf-1


% Add to new raw
combined = raw;

% avg
[isMatch_mean, idx_member_mean] = ismember(newData_mean(1,:),combined(1,:));
combined(:, idx_member_mean(isMatch_mean)) = newData_mean(:, isMatch_mean);

% max
[isMatch_max, idx_member_max] = ismember(newData_max(1,:),combined(1,:));
combined(:, idx_member_max(isMatch_max)) = newData_max(:, isMatch_max);

% min
[isMatch_min, idx_member_min] = ismember(newData_min(1,:),combined(1,:));
combined(:, idx_member_min(isMatch_min)) = newData_min(:, isMatch_min);

% times
[isMatch_times, idx_member_times] = ismember(newData_Times(1,:),combined(1,:));
combined(:, idx_member_times(isMatch_times)) = newData_Times(:, isMatch_times);

combined(1,:) = replace(combined(1,:),'SF-1-a','SF-1');
combined(:,idx_sfb) = [];







end