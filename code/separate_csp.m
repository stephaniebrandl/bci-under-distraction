%CSP analysis where with cross-validation one classifier for each secondary
%task is trained individually and only applied to the respective task

set_paths

%epoched data
data_dir = DATA_PATH_EPO;

conditions = {'clean', 'eyes', 'news', 'numbers', 'flicker', 'stimulation'};

nfolds = 6;
n_subjects = 16;
cver = zeros(length(conditions), nfolds);

separate_csp_accuracy = zeros(n_subjects, 6);

for ip = 1:n_subjects
    
    fprintf(' loading subject %02d/%02d\n', ip, n_subjects);
    
    load(fullfile(data_dir,['pp', num2str(ip)]))
    
    %for each secondary task individually
    for icond=1:6
        
        epocv = epo.(conditions{icond});
        
        %number of training samples in respective condition per fold
        ntr = floor(size(epocv.x,3)/nfolds);
        idx = 1:nfolds*ntr;
        
        %cross-validation over nfolds
        for ifold=1:nfolds          
            
            %indices for training and test data for task-specific
            %classifier
            idx_te = ((ifold-1)*ntr+1:ifold*ntr);
            idx_tr = setdiff(idx,idx_te);
            
            %train and test data for task-specific classifier
            epo_te = proc_selectEpochs(epocv, idx_te);
            epo_tr = proc_selectEpochs(epocv, idx_tr);
            
            %computing CSP filters csp_wcv and features fv
            [fv,csp_wcv]=proc_cspAuto(epo_tr,...
                'patterns',3,'selectPolicy','equalperclass');
            
            fv= proc_variance(fv);
            fv= proc_logarithm(fv);
            %classifier trained only on respective task
            classifiercv = train_RLDAshrink(squeeze(fv.x),fv.y);
            
            %computer test features
            fv= proc_linearDerivation(epo_te, csp_wcv);
            fv= proc_variance(fv);
            fv= proc_logarithm(fv);
            %apply classifier and compute accuracy cver
            out=apply_separatingHyperplane(classifiercv, squeeze(fv.x));
            cver(icond,ifold) = 1-mean([-1 1]*fv.y~=sign(out));
            
        end
        
    end
    
    separate_csp_accuracy(ip,:) = mean(cver,2);
end

if ~exist('csp_results.mat', 'file')
    save(fullfile('.','csp_results'),'separate_csp_accuracy')
else
    save(fullfile('.','csp_results'),'separate_csp_accuracy','-append')
end