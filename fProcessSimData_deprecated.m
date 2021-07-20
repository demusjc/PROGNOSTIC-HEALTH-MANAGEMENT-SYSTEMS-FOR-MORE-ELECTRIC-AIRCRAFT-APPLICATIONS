function [DATA, TABLE] = fProcessSimData(LTSPICE, Index)

    t = LTSPICE.time_vect;
    Fs = 1/mode(diff(t));
    
    DATA = struct('Original_Time', {}, 'Original_Data', {}, 'Data', {}, 'Time', {}, 'avg', {}, 'rms', {}, 'name', {});
    
    for i=1:length(Index)
        
        k = Index(i);
        DATA(i).Original_Time = t;
        DATA(i).Original_Data = LTSPICE.variable_mat(k,:);
        [DATA(i).Data, DATA(i).Time] = resample(LTSPICE.variable_mat(k,:), t, Fs);
        DATA(i).avg   = mean(DATA(i).Data);
        DATA(i).rms   = rms(DATA(i).Data);
        DATA(i).name = LTSPICE.variable_name_list(k);
                 
    end
    
    TABLE = table([DATA(:).name]', ...
    [DATA(:).avg]', ...
    [DATA(:).rms]',...
    'VariableNames',{'Variable','Avg','RMS'});
    TABLE = sortrows(TABLE);
end