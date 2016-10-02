function [G_grt] = TheriakPTpath_readOut(...
    theriakOutput,GrtName,T,P)

% TheriakPTpath_readOut.m
% This function reads the output from the theriak loop routine (e.g.,
% 'ThkOut.txt') to extract the free energy values of garnet.

fid = fopen(theriakOutput,'r');

% If the output file was not created, show an error message
if fid < 0
    errorMess1 = strcat(theriakOutput,' not found.');
    error('\n%s\n',errorMess1)
else
    T = round(T,2);
    P = round(P,2);
    G_grt = ones(length(T),1);
    n = 1;
    T1 = num2str(T(1),'%.2f');
    T2 = num2str(T(2),'%.2f');
    P1 = num2str(P(1),'%.2f');
    P2 = num2str(P(2),'%.2f');
    % fprintf('\n%s %s %s %s\n',T1, T2, P1, P2)
    % Read line-by-line to search for the T values
    tline = fgetl(fid);
    while n <= length(G_grt)
        % If PT(n) found, look for garnet
        if strfind(tline,T1) > 0 & strfind(tline,P1) > 0
            if n < length(G_grt)
                % If PT(n+1) not found yet, continue looking for garnet
                c = 0;
                while isempty(strfind(tline,T2)) & isempty(strfind(tline,P2))
                    tline = fgetl(fid);
                    % Look for the line with the garnet name, non-zero
                    % moles, non-zero G.  If G already retreived (c > 0),
                    % skip this.
                    if (strfind(tline,GrtName) == 11 & ...
                            str2double(tline(30:36)) > 0 & ...
                            c < 1)
                        % Get the free energy value
                        G_grt(n) = str2double(tline(43:54));
                        c = 1;
                    end
                end
            elseif n == length(G_grt)
                c = 0;
                while ischar(tline)
                    tline = fgetl(fid);
                    % Look for the line with the garnet name, non-zero
                    % moles, non-zero G.  If G already retreived (c > 0),
                    % skip this.
                    if (strfind(tline,GrtName) == 11 & ...
                            str2double(tline(30:36)) > 0 & ...
                            c < 1)
                        % Get the free energy value
                        G_grt(n) = str2double(tline(43:54));
                        c = 1;
                    end
                end
            end
            tline = fgetl(fid);
            n = n + 1;
            if n <= length(G_grt)
                T1 = num2str(T(n),'%.2f');
                P1 = num2str(P(n),'%.2f');
            end
            if n < length(G_grt)
                T2 = num2str(T(n+1),'%.2f');
                P2 = num2str(P(n+1),'%.2f');
            end
            % fprintf('\n%s %s %s %s\n',T1, T2, P1, P2)
        end
        tline = fgetl(fid);
    end
end
% G_grt = G_grt(2:end); % Remove placeholder on first line
% fprintf('\n%#.8g\n',G_grt)
fclose(fid);
end
