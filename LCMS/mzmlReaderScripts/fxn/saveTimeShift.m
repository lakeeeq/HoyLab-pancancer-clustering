function timeShiftTable = saveTimeShift(timeShiftTable,mrmName,timeShift,rowPickTable,tst_name)

if isempty(timeShiftTable)
    timeShiftTable{1,1} = mrmName;
    timeShiftTable{1,2} = timeShift;
    
    fileMap = rowPickTable{1};
    for i = 2:numel(rowPickTable)
        fileMap = [fileMap rowPickTable{i}];
    end
    timeShiftTable{1,3} = fileMap;
    save(tst_name,'timeShiftTable');
    return
end

hitRow = strcmp(mrmName,timeShiftTable(:,1));

if isempty(hitRow) || ~any(hitRow)
    timeShiftTable{end+1,1} = mrmName;
    timeShiftTable{end,2} = timeShift;
    fileMap = rowPickTable{1};
    for i = 2:numel(rowPickTable)
        fileMap = [fileMap rowPickTable{i}];
    end
    timeShiftTable{end,3} = fileMap;
else
    timeShiftTemp = timeShiftTable{hitRow,2};
    fileMapTemp = timeShiftTable{hitRow,3};
    cc = 1;
    for i = 1:numel(rowPickTable)
        for j = 1:numel(rowPickTable{i})
            hitTS = fileMapTemp==rowPickTable{i}(j);
            if any(hitTS)
                timeShiftTemp(hitTS) = timeShift(cc);
            else
                timeShiftTemp(end+1) = timeShift(cc);
                fileMapTemp(end+1) = rowPickTable{i}(j);
            end
            cc = cc + 1;
        end
    end
    timeShiftTable{hitRow,2} = timeShiftTemp;
    timeShiftTable{hitRow,3} = fileMapTemp;
end
save(tst_name,'timeShiftTable');

