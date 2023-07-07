close all;
disp('Getting frequency data...')
[freqfilepath, freqdir, filind1] = uigetfile('../*.*',...
    'Select Frequency Data File',' ');
if(filind1 == 0)
    disp('Quitting analysis program now...')
    return
else
    disp(' ')
    fprintf('%s selected for analysis', freqfilepath)
    disp(' ')
    freqfile = fopen(strcat(freqdir, freqfilepath), 'r', 'b');
end

disp('Getting time data...')
[timefilepath, timedir, filind2] = uigetfile('../*.*',...
    'Select time File',' ');
if(filind2 ~= 0)
    timefile = fopen(strcat(timedir, timefilepath), 'r', 'b');
else
    disp(' ')
    disp('Continuing analysis without time data...')
end

freqs = fread(freqfile, 'float64=>double');
times = fread(timefile, 'float64=>double');

plot(1:length(freqs), freqs)
input('Press any key when ready to crop...', 's')
fprintf('Select left boundary...\n')
[x_left, ~] = ginput(1);
x_left = round(x_left);

fprintf('Select right boundary...\n')
[x_right, ~] = ginput(1);
x_right = round(x_right);

freqs_cropped = freqs(x_left:x_right);
times_cropped = times(x_left:x_right);

disp('Select new directory to save cropped files...')
new_dir = uigetdir;
new_dir = [new_dir filesep];
freqfile_new = fopen(strcat(new_dir, freqfilepath, '_slice'), 'w', 'b');
timefile_new = fopen(strcat(new_dir, timefilepath, '_slice'), 'w', 'b');

fwrite(freqfile_new, freqs_cropped, 'float64', 0, 'b');
fwrite(timefile_new, times_cropped, 'float64', 0, 'b');