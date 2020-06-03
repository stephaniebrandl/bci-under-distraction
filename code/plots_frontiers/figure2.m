set_paths

data_dir = DATA_PATH_MAT;
n_subjects = 16;

conditions = {'clean', 'eyes', 'news', 'numbers', 'flicker', 'stimulation'};

filtOrder = 3;
spec = cell(16,6);
mrk = cell(1,2);

for ip = 1:n_subjects
    
    fprintf(' loading subject %02d/%02d\n', ip, n_subjects);
    
    load(fullfile(data_dir,['pp' num2str(ip)]))
    
    cnt_orig{1} = proc_selectChannels(cnt_orig{1}, 'not', 'EOG*');
    cnt_orig{2} = proc_selectChannels(cnt_orig{2}, 'not', 'EOG*');
    
    mrk{2} = mrk_defineClasses(mrk_orig{2}, {[11:10:61] [12:10:72]; 'left', 'right'});
    
    %     clab{ip} = cnt_orig{2}.clab;
    
    for icond = 1:6
        
        %calibration
        mrk{2} = mrk_defineClasses(mrk_orig{2}, {[icond*10+1 icond*10+2]; 'condition'});
        
        spec{ip,icond} = proc_spectrum(proc_segmentation(cnt_orig{2},mrk{2},[0 4500]), [3 45],'scaling','power');
        
    end
end

%%
spec_all = cell(6,1);
nfreqs = size(spec{1,1}.x,1);
for ip=1:n_subjects
    for icond = 1:6
        spec{ip,icond}.x = mean(spec{ip,icond}.x,3)./repmat(sum(mean(spec{ip,icond}.x,3),1),[nfreqs,1]);
    end
end

for icond = 1:6
    spec_all{icond} = proc_appendEpochs(spec(:,icond));
end

%%
clim = [-0.1 0.1];
band = [9 13];

try
    load(['erds_', num2str(band(1)), '-', num2str(band(2))])
catch
    error("couldn't load ERDs, maybe run figure1.m first")
end

freqs_scalp = [6,10;7,9;6,10]; %frequency indices for scalp plots

ii=0; %counter for plots
iii=0; %counter for freqs_scalp
figure
for icond = [2, 5, 4]
    iii=iii+1;
    ii=ii+1;
    subplot(3,3,ii)
    freqs = 1:43;
    plot(squeeze(mean(spec_all{icond}.x(freqs,61:end),2)),'LineWidth', 2);
    xticks(1:2:size(spec_all{icond}.x,1)-4)
    xticklabels(spec_all{icond}.t(freqs(1):2:end))
    set(gca,'FontSize', 15)
    ylabel('Normalized Power','FontSize',20)
    xlabel('Frequency in Hz','FontSize',20)
    title([conditions{icond}],'FontSize',20)
    axis tight
    
    ii=ii+1;
    subplot(3,3,ii)
    
    mnt = mnt_setElectrodePositions(cnt_orig{2}.clab);
    plot_scalp(mnt, mean(mean(spec_all{icond}.x(freqs_scalp(iii,1):freqs_scalp(iii,2),:,:),1),3),'clim',clim,'TicksAtContourLevels',0,'Extrapolation',0)
    set(gca,'FontSize', 15)
    title([num2str(spec_all{c}.t(freqs_scalp(iii,1))),'-',num2str(spec_all{icond}.t(freqs_scalp(iii,2))),' Hz'],'FontSize',20)
    
    
    opt.IvalColor = [0.8000    0.8000    0.8000;
        0.6000    0.6000    0.6000];
    nColors = 2;
    ival_scalps =   [500 1500;
        1500 2500;
        2500 3500;
        3500 4500];
    
    tmp = proc_baseline(erd_all{icond+1}, [-1000 0]);
    tmp.yUnit = cnt_orig{1}.yUnit;
    
    ii=ii+1;
    subplot(3,3,ii)
    plot_channel(proc_selectClasses(tmp,'right'), {'C3','C4'},...
        'ColorOrder',[0.2 0.2 0.2],'Legend',0);
    for cc= 1:min(nColors,size(ival_scalps,1))
        grid_markInterval(ival_scalps(cc:nColors:end,:), {'C3','C4'}, opt.IvalColor(cc,:));
    end
    set(gca,'FontSize',15)
    
end

fig = get(gcf,'Number');
fig_set(fig,'Resize',[2 1.5])
if ~isempty(figs_dir)
    print(fullfile(figs_dir, 'figure2'),'-djpeg')
end