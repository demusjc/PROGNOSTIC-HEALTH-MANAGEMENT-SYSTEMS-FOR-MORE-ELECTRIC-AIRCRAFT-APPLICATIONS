%% fCreateNETLIST
% Modifies base LTSpice netlist file (HeaderFileName), modifies it, then
% outputs the result (NetlistFileName) in Netlist Folder
function fCreateNETLIST( ...
    NetlistFileName,...     % Filename of Netlist
    HeaderFileName,...   % Filename of Netlist Header
    Temperature,...
    devicePrefix)

%% Initialize
temp = num2str(Temperature, '%0.1f');
%% OPEN UP FILES FOR CREATING THE NETLIST
fid_w = fopen(NetlistFileName, 'w');  % Overwrite the netlist everytime.
fid_r = fopen(HeaderFileName);        % Contains header file for netlist.

%% Copy the Header Information
%    Get First Line
Hline = fgetl(fid_r);

while (~isequal(Hline,-1) || isempty(Hline))
    % If using Infineon IGBT (manufacturer provided models), adjust
    % TEMP parameter accordingly; else, if using MOSFET, update the model in simulation (no TEMP
    % param used)
    if(contains(Hline, '.TEMP'))
        Hline = [Hline(1:strfind(Hline, '=')) temp];
    elseif(~strcmp(devicePrefix, 'IKW') && contains(Hline, devicePrefix))
        Hline = [Hline(1:strfind(Hline, devicePrefix)+2) temp];
    end
    fprintf(fid_w,'%s\n', Hline);
    Hline = fgetl(fid_r);
end

%% Close File Name
fclose(fid_w);
fclose(fid_r);

end