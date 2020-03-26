# BCI under Distraction: Motor Imagery in a Pseudo Realistic Environment


## Introduction
We have recorded a motor imagery-based BCI study under 5 types of distractions that mimic out-of-lab environments and a control task. The aim of this study was to investigate the robustness of standard BCI procedures in a more realistic scenario. The distractions/secondary tasks include watching a flickering video, searching the room for a specific number, listening to news, closing the eyes, vibro-tactile stimulation and a control task. We recorded 16 healthy participants (6 female; age range: 22-30 years; mean age: 26.3 years) of which only three had previously participated in another BCI experiment.

## Experiment
The main experiment was divived into 7 runs. Each run lasted about 10 minutes and included 72 trials. Each trial lasted 4.5 s and was defined by one motor imagery task plus one of the 6 secondary tasks. The first run served as a calibration phase where no feedback was given and no distraction task added. The subsequent runs included the control task and the 5 distraction tasks and auditory online feedback. Feedback was based on Laplacian filters of the C3 and C4 electrodes and regularized linear discriminant analysis (RLDA). 

## Data Description
For each participant there are 2 types of variables:  
``cnt_orig`` contains the continuous raw EEG data and ``mrk_orig`` contains the markers that indicate when a trial starts, when it ends and what kind of trial it is (i.e. which secondary task and whether left or right ).  
Both variables are 2-dimensional cell arrays where the first entry contains data from the calibration phase (72 trials, no secondary tasks) and the second entry data from the feedback phase (432 trials with secondary tasks and auditory feedback).  
In ``mnt`` the coordinates of all 63 electrodes are stored and can be used for visualization. The two variables ``bands`` and ``ivals`` contain individual frequency bands and time intervals for each participant optimized for CSP analysis.  
Please note that some trials were lost in the recording, so for some participants the total number of trials might slightly vary. 
The data is stored in a format that can easily be further processed and analysed with the [BBCI toolbox](https://github.com/bbci/bbci_public). Data can also be transformed to a format that is compatible with other toolboxes as e.g. EEGLAB, this however needs to be done manually as there currently is no function to do that.

For further information we refer to:  

[https://github.com/stephaniebrandl/bci-under-distraction](https://github.com/stephaniebrandl/bci-under-distraction)  

__Brandl S.__, Frøhlich L., Höhne J., Müller K.-R., Samek W.,  
[Brain-computer interfacing under distraction: an evaluation study.](https://iopscience.iop.org/article/10.1088/1741-2560/13/5/056012/meta)
Journal of Neural Engineering, 13 056012, 2016.