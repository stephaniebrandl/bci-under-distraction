vp_dirs = {
    'VPod_14_04_15'
    'VPnjy_14_04_17'
    'VPnjz_14_04_25'
    'VPnkk_14_04_30'
    'VPnkl_14_05_05'
    'VPnkm_14_06_16'
    'VPnkn_14_06_17'
    'VPnko_14_06_19'
    'VPnkp_14_06_24'
    'VPnkq_14_07_01'
    'VPnkr_14_07_02'
    'VPnks_14_07_03'
    'VPnkt_14_07_08'
    'VPobx_14_07_10'
    'VPnku_14_07_17'
    'VPma4_14_07_18'
    };

n_subjects = length(vp_dirs);
er = zeros(n_subjects, 7);

raw_dir = '/home/bbci/data/bbciRaw/artifacts_study';
data_dir = '/home/bbci/private/steffi/artifacts_study/1000';
frequency_bands = zeros(n_subjects, 2);
time_intervals = zeros(n_subjects, 2);

for ip = 1:n_subjects
    
    % load raw data
    cnt_orig = cell(1,2);
    mrk_orig = cell(1,2);
    [cnt_orig{1}, mrk_orig{1}] = file_readBV(fullfile(raw_dir, vp_dirs{ip}, 'calibration*'));
    [cnt_orig{2}, mrk_orig{2}] = file_readBV(fullfile(raw_dir, vp_dirs{ip}, 'MI_*'));
    
    fname = strsplit(vp_dirs{ip},'_');
    
    
    % select ival
    band = [8 30];
    ival = [750 3500];
    filtOrder = 2;
    
    cnt = cell(1,2);
    mrk = cell(1,2);
    epo_all = cell(1,6);
    
    %calibration
    mrk{1} = mrk_defineClasses(mrk_orig{1}, {11 12; 'left' 'right'});
    [filt_b,filt_a]= butter(filtOrder, band/cnt_orig{1}.fs*2);
    cnt{1}= proc_filtfilt(cnt_orig{1}, filt_b, filt_a);
    mnt= mnt_setElectrodePositions(cnt{1}.clab);
    
    %select timeival and frequency band
    cnt{1} = proc_selectChannels(cnt_orig{1},'not','EOG*');
    ival = select_timeival(cnt{1}, mrk{1}, 'channelwise', 1, 'maxIval', [250 4500]);
    
    frequency_bands(ip,:) = select_bandnarrow(cnt{1}, mrk{1}, ival, 'band', [8 30]);
    [filt_b,filt_a]= butter(filtOrder, frequency_bands(ip,:)/cnt_orig{1}.fs*2);
    cnt{1}= proc_filtfilt(cnt_orig{1}, filt_b, filt_a);
    cnt{1} = proc_selectChannels(cnt_orig{1},'not','EOG*');
    
    time_intervals(ip,:) = select_timeival(cnt{1}, mrk{1});
    
    if ~exist(data_dir, 'dir')
        mkdir(data_dir)
    end
    
    
    save(fullfile(data_dir,fname{1}),'cnt_orig','mrk_orig', '-v7.3')
end

save([data_dir,'/ivals'], 'time_intervals')
save([data_dir,'/bands'], 'frequency_bands')