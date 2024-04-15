%% INFO:
%
%  Script for converting Lucrezia Lonardo's TPL data. To run, place data in
%  the data subfolder and press F5. The data should be Tobii Pro lab
%  exported tsv, with one recording per file.
%
%   - Elio Sjak-Shie, April 2024.
%--------------------------------------------------------------------------

% Init:
addpath(genpath('.\code\'));
close all; clear; clc;

% Variable names:
timestamp_var_name = 'Computer timestamp [ms]';
L_diam_var_name    = 'Pupil diameter left [mm]';
R_diam_var_name    = 'Pupil diameter right [mm]';
event_var_name     = 'Presented Stimulus name';

% Data file location:
file_data_array = dir('.\data\');
file_data_array(~endsWith({file_data_array.name}, '.tsv')) = [];

% Loop through files:
fprintf('\nConverting %i files ...\n', numel(file_data_array));
for file_data = file_data_array(:)' % file_data = file_data(1)

    % Load file as table:
    fn = [file_data.folder filesep file_data.name];
    [~, name, ~] = fileparts(fn);

    raw_tpl_data = readtable(fn ....
        , 'FileType', 'delimitedtext' ...
        , 'Delimiter', '\t' ...
        , 'VariableNamingRule', 'preserve' ...
        , 'DateLocale','nl_NL' ...
        ,'DecimalSeparator',',');
    assert(isnumeric(raw_tpl_data.(L_diam_var_name)) ...
        && isnumeric(raw_tpl_data.(R_diam_var_name)) ...
        , 'The diameter data not numeric, check decimal separator.')

    % Make timestamp variable:
    raw_tpl_data.TimeStamp = raw_tpl_data.(timestamp_var_name);

    % Fix non-monotonically increasing time, and zero the time:
    s_incr = makeStrictlyIncrease(raw_tpl_data.TimeStamp);
    raw_tpl_data = raw_tpl_data(s_incr.new_indx, :);
    zeroTime_ms = raw_tpl_data.TimeStamp(1);
    raw_tpl_data.TimeStamp   = raw_tpl_data.TimeStamp - zeroTime_ms;

    % Assemble the diameter data.
    diam_data = struct('t_ms', raw_tpl_data.TimeStamp ...
        , 'L', raw_tpl_data.(L_diam_var_name) ...
        , 'R', raw_tpl_data.(R_diam_var_name) ...
        );
    noData = isnan(diam_data.L) & isnan(diam_data.R);
    diam_data.t_ms(noData) = [];
    diam_data.L(noData)    = [];
    diam_data.R(noData)    = [];

    % Make events:
    listIn = raw_tpl_data.(event_var_name);
    [event_labels, event_sections] = analyzeList(raw_tpl_data.TimeStamp ...
        , listIn);

    % Make data:
    pdtData                                 = struct();
    pdtData.data.eyeTracking.diameter       = diam_data;
    pdtData.data.eyeTracking.labels         = [];
    pdtData.data.eyeTracking.name           = name;
    pdtData.data.eyeTracking.eventSections  = event_sections;
    pdtData.data.eyeTracking.raw_t_ms_max   = raw_tpl_data.TimeStamp(end);
    pdtData.data.eyeTracking.diameterUnit   = 'mm';

    % Before saving, add some metadata to the file (optional):
    pdtData.physioDataInfo.rawDataSource       = fn;
    pdtData.physioDataInfo.pdtFileCreationDate = char(datetime('now'));
    pdtData.physioDataInfo.pdtFileCreationUser = getenv('USERNAME');

    % Save contents of the data struct (pdtData) to a physioData file:
    save(['.\data\' name '.physioData'] ...
        , '-struct', 'pdtData');
    fprintf('Done with %s.\n', name);

end
fprintf('Done.\n');
