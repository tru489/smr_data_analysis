%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This code processes Coulter counter .#m4 files to plot single-cell
%  volume data.
%
%  February 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all, close all, clc
% open the files
    [fname,pname] = uigetfile('*.#m4',['Select file to process: ']); % selects file
    if fname == 0 % if no file selected
        disp('Program cancelled');
        fclose('all'); % close all open programs
        return % end program
    end
    cd(pname); % changes the current directory to the one with the file
    fid = fopen(fname); %opens file for reading
    if fid == -1 % if file can't be opened
        disp('File could not be opened');
        return % end program
    end

% declare constant
    countspervolt = 1/(4*298.02e-9);
    
% get the following data from file: nPulses, Kd, current,
% resistance, MaxHtCorr, pulse data    
    
    % get the number of pulses
    linenum = 135;
    aPulses = textscan(fid, '%*9s %n', 1, 'delimiter',...
        '\n', 'headerlines', linenum-1); 
    nPulses = aPulses{1};
    fseek(fid, 0, 'bof'); % resets pointer to bof
        
    % get the Kd value
    linenum = 127;
    aKd = textscan(fid, '%*4s %n', 1, 'delimiter',...
        '\n', 'headerlines', linenum-1);
    Kd = aKd{1}; % converts the cell array into an integer
    fseek(fid, 0, 'bof'); % resets pointer to the beginning of file

    % get the aperture current (mA)
    linenum = 178;
    aCurrent = textscan(fid, '%*9s %n', 1, 'delimiter',...
        '\n', 'headerlines', linenum-1); 
    current = aCurrent{1}/1000; % gets current as an integer in mA
    fseek(fid, 0, 'bof'); % resets pointer to the beginning of file

    % get the gain and convert it to resistance
    linenum = 184;
    gain = textscan(fid, '%*6s %n', 1, 'delimiter',...
        '\n', 'headerlines', linenum-1); 
    resistance = 25*gain{1}; % convert gain to equiv resistance (kohms)
    fseek(fid, 0, 'bof'); % resets pointer to the beginning of file

    % get the MaxHeight Correction
    linenum = 187;
    MaxHtCorr = textscan(fid, '%*11s %n', 1, 'delimiter',...
        '\n', 'headerlines', linenum-1); 
    fseek(fid, 0, 'bof'); % resets pointer to the beginning of file

    % get the pulse data
    linenum = 1533;
    pulsearray = textscan(fid,'%s %*s %*s %*s %*s', nPulses, ...
        'delimiter', ',', 'headerlines', linenum-1); 

    st = fclose(fid); % closes file after getting all useful data

    % convert the pulse data to volume
    height = (hex2dec(pulsearray{1}) + MaxHtCorr{1})';
    diameter = Kd*((height./(countspervolt*resistance*current)).^(1/3));
    volume = 4/3*pi*(diameter/2).^3;

% Plot the pulse data
    plot(volume,'b.','MarkerSize',3)