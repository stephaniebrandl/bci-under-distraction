set_paths

data_dir = DATA_PATH_MAT;
figs_dir = FIGS_DIR;

conditions = {'clean', 'eyes', 'news', 'numbers', 'flicker', 'stimulation'};

n_subjects = 16;
n_conditions = length(conditions) + 1; %+calibration


erd_r_all = cell(7,1);
epo_all = cell(n_subjects,7);
erd_all = cell(1,7);

f_step_log = 0.1;
f_start = 5;
f_stop = 35;
freqs = 2.^( log2(f_start):f_step_log:log2(f_stop) );

ival = [-1000 4500];
band = [9 13];
filtOrder = 3;

try
    load(['epos_', num2str(band(1)), '-', num2str(band(2))])
    load(['erds_', num2str(band(1)), '-', num2str(band(2))])
    
catch
    
    for ip = 1:n_subjects
        
        fprintf(' loading subject %02d/%02d\n', ip, n_subjects);
        
        load(fullfile(data_dir,['pp' num2str(ip)]),'cnt_orig','mrk_orig')
        
        cnt_orig{1} = proc_selectChannels(cnt_orig{1}, 'not', 'EOG*');
        
        %calibration
        mrk{1} = mrk_defineClasses(mrk_orig{1}, {11 12; 'left' 'right'});
        [filt_b,filt_a]= butter(filtOrder, band/cnt_orig{1}.fs*2);
        cnt{1} = proc_filtfilt(cnt_orig{1}, filt_b, filt_a);
        
        epo.calibration = proc_segmentation(cnt{1},mrk{1},ival);
        epo_all{ip,1} = epo.calibration;
        
        
        cnt_orig{2} = proc_selectChannels(cnt_orig{2}, 'not', 'EOG*');
        cnt{2} = proc_filtfilt(cnt_orig{2}, filt_b, filt_a);
        
        for icond = 1:6
            mrk{2} = mrk_defineClasses(mrk_orig{2}, {icond*10+1 icond*10+2; 'left' 'right'});
            epo_all{ip,icond+1} = proc_segmentation(cnt{2},mrk{2},ival);
        end
        
        
    end
    
    
    for ip=1:n_subjects
        fprintf(' loading subject %02d/%02d\n', ip, n_subjects);
        erd= proc_envelope(epo_all{ip,1}, 'MovAvgMsec', 200);
        erd_all{1} = proc_appendEpochs(erd_all{1}, erd);
        for icond=1:6
            erd= proc_envelope(epo_all{ip,icond+1}, 'MovAvgMsec', 200);
            erd_all{icond+1} = proc_appendEpochs(erd_all{icond+1}, erd);
        end
    end
    
    tmp = proc_baseline(erd_all{1}, [-1000 0]);
    erd_r_all{1}= proc_rSquareSigned(tmp);
    erd_all{1} = proc_selectChannels(erd_all{1},{'C3','C4'});
    for icond=1:6
        tmp = proc_baseline(erd_all{icond+1}, [-1000 0]);
        erd_r_all{icond+1}= proc_rSquareSigned(tmp);
        erd_all{icond+1} = proc_selectChannels(erd_all{1+icond},{'C3','C4'});
    end
    save(['erds_', num2str(band(1)), '-', num2str(band(2))],'erd_all','erd_r_all','-v7.3')
    
    
    for n=1:n_subjects
        epo_all{n,1} = proc_selectChannels(epo_all{n,1},{'C3','C4'});
        for icond=1:6
            epo_all{n,1+icond} = proc_selectChannels(epo_all{n,1+icond},{'C3','C4'});
        end
    end
    save(['epos_', num2str(band(1)), '-', num2str(band(2))],'epo_all','-v7.3')
    
end
%%
for icond = 1   %calibration data
    figure
    tmp = proc_baseline(erd_all{icond}, [-1000 0]);
    
    opt.IvalColor = [0.8000    0.8000    0.8000;
        0.6000    0.6000    0.6000];
    nColors = 2;
    
    ival_scalps =   [500 1500;
        1500 2500;
        2500 3500;
        3500 4500];
    
    
    subplot(2,8,1:4)
    plot_channel(proc_selectClasses(tmp,'right'), {'C3','C4'},...
        'ColorOrder',[0.2 0.2 0.2],'Legend',0);
    
    for cc= 1:min(nColors,size(ival_scalps,1))
        grid_markInterval(ival_scalps(cc:nColors:end,:), {'C3','C4'}, opt.IvalColor(cc,:));
    end
    set(gca,'FontSize',15)
    
    subplot(2,8,9:12)
    plot_channel(proc_selectClasses(tmp,'left'), {'C3','C4'},...
        'ColorOrder',[0.2 0.2 0.2], 'Legend',0);
    for cc= 1:min(nColors,size(ival_scalps,1))
        grid_markInterval(ival_scalps(cc:nColors:end,:), {'C3','C4'}, opt.IvalColor(cc,:));
    end
    set(gca,'FontSize',15)
    
    subplot(2,8,5:8)
    plot_channel(erd_r_all{icond}, {'C3','C4'},'ColorOrder',[0.2 0.2 0.2],'Legend',0);
    
    for cc= 1:min(nColors,size(ival_scalps,1))
        grid_markInterval(ival_scalps(cc:nColors:end,:), {'C3','C4'}, opt.IvalColor(cc,:));
    end
    set(gca,'FontSize',15)
    
    mnt = mnt_setElectrodePositions(erd_r_all{icond}.clab);
    mnt= mnt_setGrid(mnt, 'M');
    clab = {'C3','C4'};
    own_opt = defopt_scalp_r;
    opt = struct;
    opt.Extrapolation=0;
    opt.clim = [-8*1e-3 8*1e-3];
    opt.Colormap = own_opt.Colormap;
    opt.TicksAtContourLevels = 0;
    opt.ScalePos = 'none';  %remove if you want to add colorbar
    
    ival_scalps =   [500 1500;
        1500 2500;
        2500 3500;
        3500 4500];
    
    
    
    for iival = 1:size(ival_scalps,1)
        subplot(2,8,12+iival)
        iival1 = find(erd_r_all{icond}.t==ival_scalps(iival,1));
        iival2 = find(erd_r_all{icond}.t==ival_scalps(iival,2));
        w = mean(erd_r_all{icond}.x(iival1:iival2,:));
        plot_scalp(mnt, w, opt)
        set(gca,'FontSize',15)
        title([num2str(ival_scalps(iival,1)),'-',num2str(ival_scalps(iival,2)),' ms'])
        
    end
    
    fig = get(gcf,'Number');
    fig_set(fig,'Resize',[1.5 1.5])
    if ~isempty(figs_dir)
        print(fullfile(figs_dir, 'figure1'),'-djpeg')
    end
    
    
end