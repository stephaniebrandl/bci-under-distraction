%2-step approach where in a first step the most noisy task 'numbers' is
%separated from all the other tasks, in a 2nd step one of two classifiers
%is applied to separate left/right (i.e. one for 'numbers' and one for 'not
%numbers' as in Table 6 in JNE Paper

set_paths

%where raw data is stored
mat_dir = DATA_PATH_MAT;
epo_dir = DATA_PATH_EPO;

n_subjects = 16;
n_folds=6;

%individual frequency bands and time intervals
load(fullfile(mat_dir, 'bands'))
load(fullfile(mat_dir, 'ivals'))

two_step_csp_accuracy = zeros(n_subjects, 4);

for ip=1:n_subjects
        
    fprintf(' loading subject %02d/%02d\n', ip, n_subjects);
        
    n_num = zeros(n_folds,1);
    n_notnum = zeros(n_folds,1);
    er_1st = zeros(n_folds,1);
    
    band=frequency_bands(ip,:);
    ival = time_intervals(ip,:);
    filtOrder = 3;
    
    load(fullfile(mat_dir,['pp' num2str(ip)]))
    load(fullfile(epo_dir,['pp' num2str(ip)]))
    
    [filt_b,filt_a]= butter(filtOrder, band/cnt_orig{2}.fs*2);
    cnt= proc_filtfilt(cnt_orig{2}, filt_b, filt_a);
    
    %training data for first step (distinguish between numbers and all
    %other tasks
    mrk = mrk_defineClasses(mrk_orig{2},...
        {[11,12,21,22,31,32,51,52,61,62] [41,42]; 'not numbers' 'numbers'});    
    epo_1st = proc_segmentation(cnt,mrk,ival);
    
    %training data for 2nd step (left/right for 'not numbers' tasks)
    mrk = mrk_defineClasses(mrk_orig{2},...
        {[11,21,31,51,61] [12,22,32,52,62]; 'left' 'right'});
    epo_notnum = proc_segmentation(cnt,mrk,ival);
    er_notnum = zeros(n_folds,1);
    er_num = zeros(n_folds,1);
    
    %number of test data for 1st step, numbers and not numbers classifiers
    nte = floor(size(epo_1st.x,3)/n_folds);
    nte_notnum = floor(size(epo_notnum.x,3)/n_folds);
    nte_num = floor(size(epo.numbers.x,3)/n_folds);
    
    for ifold=1:n_folds
        
        idx_te=((ifold-1)*nte+1:ifold*nte);
        
        %selecting epochs for test set
        epo_1st_tr = proc_selectEpochs(epo_1st, 'not', idx_te);
        epo_1st_te = proc_selectEpochs(epo_1st, idx_te);
        epo_te = proc_selectEpochs(epo.all, idx_te);
        
        idx_te=((ifold-1)*nte_notnum+1:ifold*nte_notnum);        
        epo_notnum_tr = proc_selectEpochs(epo_notnum, 'not', idx_te);
        
        idx_te=((ifold-1)*nte_num+1:ifold*nte_num);        
        epo_num_tr = proc_selectEpochs(epo.numbers, 'not', idx_te);
        
        %training of classifiers for 1st step, left/right numbers and
        %left/right not numbers
        [fv,w_1st]=proc_cspAuto(epo_1st_tr,...
            'patterns',3,'selectPolicy','equalperclass');
        fv= proc_variance(fv);
        fv= proc_logarithm(fv);
        classifier_1st = train_RLDAshrink(squeeze(fv.x),fv.y);
        
        [fv,w_not_num]=proc_cspAuto(epo_notnum_tr,...
            'patterns',3,'selectPolicy','equalperclass');
        fv= proc_variance(fv);
        fv= proc_logarithm(fv);
        classifier_notnum = train_RLDAshrink(squeeze(fv.x),fv.y);
        
        [fv,w_num]=proc_cspAuto(epo_num_tr,...
            'patterns',3,'selectPolicy','equalperclass');
        fv= proc_variance(fv);
        fv= proc_logarithm(fv);
        classifier_num = train_RLDAshrink(squeeze(fv.x),fv.y);
        
        %decide which task the data is in
        fv= proc_linearDerivation(epo_1st_te, w_1st);
        fv= proc_variance(fv);
        fv= proc_logarithm(fv);
        out= apply_separatingHyperplane(classifier_1st, squeeze(fv.x));
        
        class1 = proc_selectEpochs(epo_te, sign(out)==1);  %numbers
        class2 = proc_selectEpochs(epo_te, sign(out)==-1);   %not numbers
        
        %to calculate the overall accuracy in the end we want to know the
        %number of classified data points in both classes
        n_num(ifold) = size(class1.y,2);
        n_notnum(ifold) = size(class2.y,2);
        
        er_1st(ifold) = 1-mean([-1 1]*fv.y~=sign(out));
        
        %classification for 'numbers' and 'not numbers' classes separately
        if ~isempty(class2.y)
            
            fv= proc_linearDerivation(class2, w_not_num);
            fv= proc_variance(fv);
            fv= proc_logarithm(fv);
            out=apply_separatingHyperplane(classifier_notnum, squeeze(fv.x));
            er_notnum(ifold) = 1-mean([-1 1]*fv.y~=sign(out));
            
        end
        
        if ~isempty(class1.y)
            
            fv= proc_linearDerivation(class1, w_num);
            fv= proc_variance(fv);
            fv= proc_logarithm(fv);
            out=apply_separatingHyperplane(classifier_num, squeeze(fv.x));
            er_num(ifold) = 1-mean([-1 1]*fv.y~=sign(out));
            
        end
        
    end
    
    %overall accuracy as weighted average of the accuracies of 'not
    %numbers' and 'numbers'
    two_step_csp_accuracy(ip,1) = ((n_notnum'*er_notnum)+(n_num'*er_num))/(sum(n_notnum)+sum(n_num));
    two_step_csp_accuracy(ip,2) = mean(er_1st);
    two_step_csp_accuracy(ip,3) = n_notnum'*er_notnum/sum(n_notnum);
    two_step_csp_accuracy(ip,4) = n_num'*er_num/sum(n_num);
end

% if ~exist('csp_results.mat', 'file')
%     save(fullfile('.','csp_results'),'two_step_csp_accuracy')
% else
%     save(fullfile('.','csp_results'),'two_step_csp_accuracy','-append')
% end