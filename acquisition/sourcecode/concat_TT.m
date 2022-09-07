function TT = concat_TT(TT1, TT2)

% This function concatenate timetables, identify the existing variables and
% add new variables into the destination TT if missing

allvar = TT2.Properties.VariableNames ;

timename2 = TT2.Properties.DimensionNames{1} ;

for ivar = 1:numel(allvar)
    if ~isempty(TT1)
        if isvar(TT1, allvar(ivar))
            timename1 = TT1.Properties.DimensionNames{1} ;
            TT_temp = [TT1.(allvar{ivar}) ; TT2.(allvar{ivar})] ;
            TT_Time = [TT1.(timename1) ; TT2.(timename2)] ;
            TT.(allvar{ivar}) = array2timetable(TT_temp,"RowTimes",TT_Time,"VariableNames",allvar(ivar)) ;
        else
            TT.(allvar{ivar}) = array2timetable(TT2.(allvar{ivar}),"RowTimes",TT2.(timename2), "VariableNames",allvar(ivar)) ;
        end
    else
        TT.(allvar{ivar}) = array2timetable(TT2.(allvar{ivar}),"RowTimes",TT2.(timename2), "VariableNames",allvar(ivar)) ;
    end
end
res = struct2cell(TT);
TT = synchronize(res{:});