function paramHeaders = getParamHeaders(summaryRaw)
% summaryRaw = exported Summary File from DOE
% paramHeaders = returned paramater headers

idxNotes = find(strcmp(summaryRaw(1,:), 'Notes')); % used the index of Notes to get headers, since it occurs right before parameter headers
paramHeadersRaw = summaryRaw(1,idxNotes(1)+1:end);

idxSolveFor = contains(paramHeadersRaw, 'Solve for', 'IgnoreCase',true);
paramHeaders = paramHeadersRaw(~idxSolveFor);
end

%[appendix]{"version":"1.0"}
%---
