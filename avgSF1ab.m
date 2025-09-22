function combined = avgSF1ab(raw)
    %   combined = doe file with sf-1 consisting of averaged a & b segements
    %   raw = doe file with seperated sf-1
    
    combined = {};
    [~, nc] = size(raw);
    rowHeaders = raw(1,:);

    i = 1;
    while i <= nc
   
        currHeader = rowHeaders{i};
    
        if contains(currHeader, 'SF-1-a','IgnoreCase',true)
            indb = find(contains(rowHeaders(i:end), 'SF-1-b'),1) + i - 1;

            if ~isempty(indb)
                nameSplit = split(currHeader, "_SF-1-a");
                avgHeader = append(nameSplit{1}, '_SF-1', nameSplit{2});
                avgHeader = erase(avgHeader, " ");

                if i == 872
                    5;
                end

                adataraw = raw(2:end,i);
                bdataraw = raw(2:end,indb);

                for k = 1:numel(adataraw)
                    if isempty(adataraw{k})
                        idxmissing(k) = true;
                    else
                        idxmissing(k) = false;
                    end
                end
                adata = adataraw;
                adata(idxmissing) = {"0"};

                clear idxmissing

                for k = 1:numel(bdataraw)
                    if k == 32
                        5;
                    end
                    if isempty(bdataraw{k})
                        idxmissing(k) = true;
                    else
                        idxmissing(k) = false;
                    end
                    
                end
                bdata = bdataraw;
                bdata(idxmissing) = {"0"};

                adata = cell2mat(num2cell(cellfun(@str2num, adata)));
                bdata = cell2mat(num2cell(cellfun(@str2num, bdata)));

                % adata = cell2mat(raw(2:end, i));
                % bdata = cell2mat(raw(2:end, indb));
                avgData = num2cell(mean([adata, bdata],2));


                combined = [combined, [{avgHeader}; avgData]];
            end

            i = i + 1;

        elseif ~contains(currHeader, 'SF-1-b', 'IgnoreCase', true)
            combined = [combined, raw(:,i)];
            i = i + 1;

        else
            i = i + 1;
        end
    end

end