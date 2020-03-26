%preprocessing of raw EEG data into epochs

%you can choose to use the individually selected time intervals/frequency
%bands or use one time interval/frequency band for all participants as e.g.
%8-30Hz or 750-3500ms
select_ival = 'individual';
select_band = 'individual';

set_paths

%path where raw data is stored
data_dir = DATA_PATH_MAT;
%path where epoched data will be stored
out_dir = DATA_PATH_EPO;
%number of subjects
n_subjects = 16;
%paramter for Butterworth filter
filtOrder = 3;

%time interval/frequency band is set depending on parameters above
if strcmp(select_ival, 'individual')
    fprintf(' individual time windows will be used\n')
    load([data_dir,'/ivals'])
elseif numel(select_ival)==2
    fprintf(' all data will be epoched in a time windowd of %d - %d \n', select_ival(1), select_ival(2))
    ival = select_ival;
else
    error('ival not known')
end

if strcmp(select_band, 'individual')
    fprintf(' individual frequency bands will be used\n')
    load([data_dir,'/bands'])
elseif numel(select_band)==2
    fprintf(' all data will be band-pass filtered in a frequency range of %d - %d \n', select_band(1), select_band(2))
    band = select_band;
else
    error('band not known')
end

for ip = 1:n_subjects
    
    fprintf(' loading subject %02d/%02d\n', ip, n_subjects);
    
    if strcmp(select_ival, 'individual')
        ival = time_intervals(ip,:);
    end
    
    if strcmp(select_band, 'individual')
        band = frequency_bands(ip,:);
    end
    
    %raw EEG data is loaded
    load(fullfile(data_dir,['pp', num2str(ip)]))
    cnt = cell(1,2);    %continuous EEG data
    mrk = cell(1,2);    %marker stream
    epo_all = cell(1,6);    %where epoched data will be stored
    
    %calibration (run1; no distractions)
    mrk{1} = mrk_defineClasses(mrk_orig{1}, {11 12; 'left' 'right'});
    [filt_b,filt_a]= butter(filtOrder, band/cnt_orig{1}.fs*2);
    cnt{1} = proc_filtfilt(cnt_orig{1}, filt_b, filt_a);
    
    %epoched data
    epo.calibration = proc_segmentation(cnt{1},mrk{1},ival);
    
    % run2-7 with distraction/secondary tasks
    cnt{2} = proc_filtfilt(cnt_orig{2}, filt_b, filt_a);
    
    %data will be stored for each secondary task individually
    for icond= 1:6
        mrk_tmp = mrk_defineClasses(mrk_orig{2}, {icond*10+1 icond*10+2; 'left' 'right'});
        epo_all{icond} = proc_segmentation(cnt{2}, mrk_tmp, ival);
    end
    
    epo.clean = epo_all{1};
    epo.eyes = epo_all{2};
    epo.news = epo_all{3};
    epo.numbers = epo_all{4};
    epo.flicker = epo_all{5};
    epo.stimulation = epo_all{6};
    
    %last entry in epo contains all data from runs 2-7
    mrk_all = mrk_defineClasses(mrk_orig{2}, {[11:10:61] [12:10:62]; 'left' 'right'});
    epo.all = proc_segmentation(cnt{2}, mrk_all, ival);
    
    
    if ~exist(out_dir, 'dir')
        mkdir(out_dir)
    end
    
    save(fullfile(out_dir,['pp', num2str(ip)]),'epo','band','ival', '-v7.3')
    
    fprintf(' finished subject %02d/%02d\n\n', ip, n_subjects);
    
end