# BCI under Distraction: Motor Imagery in a Pseudo-Realistic Environment  

__Data can be downloaded [here](https://depositonce.tu-berlin.de/handle/11303/10934)__  

## Introduction
We have recorded a motor imagery-based BCI study under 5 types of distractions that mimic out-of-lab environments and a control task. The aim of this study was to investigate the robustness of standard BCI procedures in a more realistic scenario. The distractions/secondary tasks include watching a flickering video, searching the room for a specific number, listening to news, closing the eyes, vibro-tactile stimulation and a control task. We recorded 16 healthy participants (6 female; age range: 22-30 years; mean age: 26.3 years) of which only three had previously participated in another BCI experiment.

## Experiment
Before the main experiment, we recorded 8 trials in which participants had to alternately keep their eyes open or closed for 15 seconds.

The main experiment was divided into 7 runs. Each run lasted about 10 minutes and included 72 trials. Each trial lasted 4.5 s and was defined by one motor imagery task plus one of the 6 secondary tasks. The first run served as a calibration phase where no feedback was given and no distraction task added. The subsequent runs included the control task and the 5 distraction tasks and auditory online feedback. Feedback was based on Laplacian filters of the C3 and C4 electrodes and regularized linear discriminant analysis (RLDA). 

## Data Description
For each participant there are 5 variables:  
``cnt_imp`` contains the impedance measurements before the experiment.  
``cnt_rest`` contains the continuous raw EEG data from the eyes open/closed trials and ``mrk_rest`` contains the corresponding markers.  
``cnt_orig`` contains the continuous raw EEG data from the main experiment and ``mrk_orig`` contains the corresponding markers that indicate when a trial starts, when it ends and what kind of trial it is (i.e. which secondary task and whether left or right ).  
Both variables are 2-dimensional cell arrays where the first entry contains data from the calibration phase (72 trials, no secondary tasks) and the second entry data from the feedback phase (432 trials with secondary tasks and auditory feedback).  
In ``mnt`` the coordinates of all 63 electrodes are stored and can be used for visualization. The two variables ``bands`` and ``ivals`` contain individual frequency bands and time intervals for each participant optimized for CSP analysis.  
Please note that some trials were lost in the recording, so for some participants the total number of trials might slightly vary.  
The data is stored in a format that can easily be further processed and analysed with the [BBCI toolbox](https://github.com/bbci/bbci_public). Data can also be transformed to a format that is compatible with other toolboxes as e.g. EEGLAB, this however needs to be done manually as there currently is no function to do that.

A more detailed data description is uploaded [here](https://github.com/stephaniebrandl/bci-under-distraction/blob/master/data_description.pdf).

## Code
With the Matlab code in this repository you can conduct the CSP analyses that have been done in [1]. You need to install the [BBCI toolbox](https://github.com/bbci/bbci_public) before you can run the code. It follows a short description of all scripts.  
``load_raw_data.m``  
This has been added to show how raw data has been transformed into .mat files and how frequency band and time interval have been optimized.  
``set_paths.m``  
There you can set the local paths where you have stored the raw data and where epoched data should be stored.  
``preprocessing.m``  
Data is cut into epochs and band-pass filtered. This can be done with the individual time intervals/frequency bands or other intervalds (in ms) and bands (in Hz) can be set.  
``csp.m``, ``separate_csp.m``, ``ensemble_csp.m`` and ``two_step_csp.m``  
Here you can conduct the CSP analyses as explained in [1]. Results might differ from the original paper as some parameters have been adapted.




For further information we refer to:  

[1]  
__Brandl S.__, Frøhlich L., Höhne J., Müller K.-R., Samek W.,  
[Brain-computer interfacing under distraction: an evaluation study.](https://iopscience.iop.org/article/10.1088/1741-2560/13/5/056012/meta)  
Journal of Neural Engineering, 13 056012, 2016.
