%CSP analysis where classifier is trained on calibration phase and tested
%on secondary tasks as Table 2 in JNE Paper
set_paths

%where epoched data is stored
data_dir = DATA_PATH_EPO;
n_subjects = 16;

%labels for different secondary tasks as stored in epo
conditions = {'clean', 'eyes', 'news', 'numbers',...
    'flicker', 'stimulation'};

er = zeros(n_subjects,7);

for ip = 1:n_subjects
    
    fprintf(' loading subject %02d/%02d\n', ip, n_subjects);
    
    load(fullfile(data_dir,['pp', num2str(ip)]))
    
    %compute CSP filters and patterns
    [fv, W, A, ~] = proc_cspAuto(epo.calibration,...
        'patterns',3,'selectPolicy','equalperclass');
    fv = proc_variance(fv);
    fv = proc_logarithm(fv);
    
    %train shrinkage LDA classifier
    classifier = train_RLDAshrink(squeeze(fv.x), fv.y);
    
    %each secondary task is classified individually
    for icond = 1:6
        
        %computing test features
        fv_test = proc_linearDerivation(epo.(conditions{icond}), W);
        fv_test = proc_variance(fv_test);
        fv_test = proc_logarithm(fv_test);
        
        %apply classifier and calculate accuracy in er
        out = apply_separatingHyperplane(classifier, squeeze(fv_test.x));
        er(ip,icond+1) = 1-mean([-1 1]*fv_test.y~=sign(out));
        
    end
    
    %overall accuracy
    er(ip,1) = mean(er(ip,2:7));
    
end

csp_accuracy = er;
if ~exist('csp_results.mat', 'file')
    save(fullfile('.','csp_results'),'csp_accuracy')
else
    save(fullfile('.','csp_results'),'csp_accuracy','-append')
end