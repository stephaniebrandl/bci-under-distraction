%ensemble CSP approach, i.e. task-specific classifiers are applied and an 
%average decides on the label, this is done in an n-fold cross validation

set_paths

%epoched data
data_dir = DATA_PATH_EPO;

conditions = {'clean', 'eyes', 'news', 'numbers', 'flicker', 'stimulation'};

n_subjects = 16;
%number of folds
n_folds = 6;
n_conditions = length(conditions);
%we need to train 6 classifiers in each fold
classifier = cell(length(conditions),1);
csp_wcv = cell(length(conditions),1);

%where accuracy is stored
accuracy = zeros(n_subjects,n_folds);

for ip = 1:n_subjects
    
    fprintf(' loading subject %02d/%02d\n', ip, n_subjects);
    
    load(fullfile(data_dir,['pp', num2str(ip)]))
    
    %number of samples for all conditions
    n_samples = size(epo.all.x,3);
    %number of test data per fold and condition
    n_te = floor(n_samples/(n_folds*n_conditions));
    %number of train data
    n_tr = floor(n_samples/n_folds) - n_te;
    
    for ifold = 1:n_folds
        
        %index of test data
        idx_te = ((ifold-1)*n_te+1:ifold*n_te)
        epo_te_ensemble = [];
        
        %for each secondary task we train one classifier 
        %we also collect test data to apply innext loop
        for icond=1:length(conditions)
            
            epo_task = epo.(conditions{icond});
            
            %train data for task-specific classifier
            epo_tr = proc_selectEpochs(epo_task, 'not', idx_te);
            
            [fv,csp_wcv{icond}]=proc_cspAuto(epo_tr,...
                'patterns',3,'selectPolicy','equalperclass');
            
            
            fv= proc_variance(fv);
            fv= proc_logarithm(fv);
            %classifier trained only on respective task
            classifier{icond} = train_RLDAshrink(squeeze(fv.x),fv.y);
            
            %in the meantime we also collect test data from all conditions
            epo_te_ensemble = proc_appendEpochs(epo_te_ensemble,...
                proc_selectEpochs(epo_task,idx_te));
            
        end
        
        n_epochs = size(epo_te_ensemble.x,3);
        out = zeros(n_folds, n_epochs);
        
        %after training all classifiers on idx_te we apply them to the
        %collected test data
        for jcond=1:length(conditions)
            
            fv= proc_linearDerivation(epo_te_ensemble, csp_wcv{jcond});
            fv= proc_variance(fv);
            fv= proc_logarithm(fv);
            
            out(jcond,:) = apply_separatingHyperplane(...
                classifier{jcond}, squeeze(fv.x));
            
        end
        
        accuracy(ip, ifold) = 1-mean([-1 1]*fv.y~=sign(squeeze(mean(out(:,1:n_epochs)))));
        
    end
    
end

ensemble_csp_accuracy = mean(accuracy,2);

if ~exist('csp_results.mat', 'file')
    save(fullfile('.','csp_results'),'ensemble_csp_accuracy')
else
    save(fullfile('.','csp_results'),'ensemble_csp_accuracy','-append')
end