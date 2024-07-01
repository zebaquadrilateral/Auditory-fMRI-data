function preprocessing_fmri_auditory(task)
    %clear all % clear all variables
    %clc % clear command window
    % Data Management
    datadir = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\fM00223'; %Directory for fMRI image data 
    cd(datadir) 
    sourcedir = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\sM00223'; %Directory for Source data
    cd(sourcedir) 
    tpm_path = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12\tpm'; %This is the directory for NIFTI files for segmentation
    cd(tpm_path )
    specdir = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\classical'; %Directory for the collection of the job files for first level analysis
    cd(specdir)
    participantdir = {}; % participant directory stubs
    %rundir=    {[]};          % participant specific run numbers
    spmdir = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12'; %SPM present working directory:
    addpath(spmdir)
    spm('Defaults', 'FMRI');        % Reset SPM defaults for fMRI (not sure necessary - safety catch?)
    %global defaults;               % Reset Global defaults (not sure why needed?)
    spm_jobman('initcfg')           %spm_jobman initialization
    
    %This functionis a batch script for pre-processing fMRI data
    % INPUT ARGUMENTS:
    %%%%% 'task'
    % if task not given, then it defaults to '123456'
    %           
    %           1 = REALIGNMENT
    %           2 = COREGISTRATION 
    %           3 = SEGMENTATION
    %           4 = NORMALISATION (functional)
    %           5 = NORMALISATION_PART2 (Structural)
    %           6 = SMOOTHING
    if ~exist('task','var') 
        task='12345'; 
    end % if nothing is specified in "task" ,this is the default action
    %% 
    
    if contains(task,'1')
        disp('implementing task 1');
        %REALIGNMENT (Spatial realignment- motion correction)
        % This will run the realign job which will estimate the 6 parameter (rigid body) spatial transformation 
        % that will align the times series of images and will modify the header of the input images(*.hdr),
        % such that they reflect the relative orientation of the data after correction for movement artefacts
     
        job                                                   = []    ; %structure initialization
        f_files                                               = spm_select('List',datadir,'^fM','.img');     % this will give the full path to the task data, NaN will ensure you are loading all volumes present (i.e. consider the 4D file as a whole)                  
        func_files                                            = cellstr([repmat([datadir filesep], size(f_files,1), 1) f_files, repmat(',1',size(f_files,1),1)]);
        job{1}.spm.spatial.realign.estwrite.data              = {func_files}; % filenames of volume to realign
        %disp('everything works until line 48!!!!!')
        job{1}.spm.spatial.realign.estwrite.eoptions.quality  = 0.9       ; % estimation option quality 
        job{1}.spm.spatial.realign.estwrite.eoptions.sep      = 4         ; % estimation option separation
        job{1}.spm.spatial.realign.estwrite.eoptions.fwhm     = 5         ; % estimation option smoothing
        job{1}.spm.spatial.realign.estwrite.eoptions.rtm      = 1         ; % estimation option reference volume (0: register to first image)
        job{1}.spm.spatial.realign.estwrite.eoptions.interp   = 2         ; % estimation option interpolation for estimation 
        job{1}.spm.spatial.realign.estwrite.eoptions.wrap     = [0 0 0]   ; % estimation option wrapping 
        job{1}.spm.spatial.realign.estwrite.eoptions.weight   = ''        ; % estimation option weighting
        job{1}.spm.spatial.realign.estwrite.roptions.which    = [0 1]     ; % resmapling option (all about mean image)
        job{1}.spm.spatial.realign.estwrite.roptions.interp   = 4         ; % resampling option 4th B-spline interpolation
        job{1}.spm.spatial.realign.estwrite.roptions.wrap     = [0 0 0]   ; % resampling option wrapping
        job{1}.spm.spatial.realign.estwrite.roptions.mask     = 1         ; % resamplimg option using mask
        job{1}.spm.spatial.realign.estwrite.roptions.prefix   = 'r'       ; % output file prefix
        spm_jobman('run',job) % execute the batch
        clear Job % clear job 
    end
    %% 
     %COREGISTRATION 
        % SPM will then implement a coregistration between the structural and functional data that maximises the mutual information.
        
    if contains(task,'2')
        disp('implementing task 2');
        job                                                 = [];% Structure Initialization
        job{1}.spm.spatial.coreg.estimate.ref               = {strcat(datadir,'\meanfM00223_004.img,1')};
        job{1}.spm.spatial.coreg.estimate.source            = {strcat(sourcedir,'\sM00223_002.img,1')};
        job{1}.spm.spatial.coreg.estimate.other             = {''};
        job{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        job{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
        job{1}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        job{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];
        spm_jobman('run',job) % execute the batch
        clear job % clear job
    end
    %% 
    %SEGMENTATION
    %SPM will segment the structural image using the default tissue probabilitymaps as priors 
    % SPM will create gray and white matter images and bias-field corrected structural image
    if contains(task,'3')
        disp('implementing task 3');
        job                                              = [];
        job{1}.spm.spatial.preproc.channel.vols          = {strcat(sourcedir,'\sM00223_002.img,1')};
        job{1}.spm.spatial.preproc.channel.biasreg       = 0.001;
        job{1}.spm.spatial.preproc.channel.biasfwhm      = 60;
        job{1}.spm.spatial.preproc.channel.write         = [0 1];
        job{1}.spm.spatial.preproc.tissue(1).tpm         = {strcat(spmdir,'\tpm\TPM.nii,1')};
        job{1}.spm.spatial.preproc.tissue(1).ngaus       = 1;
        job{1}.spm.spatial.preproc.tissue(1).native      = [1 0];
        job{1}.spm.spatial.preproc.tissue(1).warped      = [0 0];
        job{1}.spm.spatial.preproc.tissue(2).tpm         = {strcat(spmdir,'\tpm\TPM.nii,2')};
        job{1}.spm.spatial.preproc.tissue(2).ngaus       = 1;
        job{1}.spm.spatial.preproc.tissue(2).native      = [1 0];
        job{1}.spm.spatial.preproc.tissue(2).warped      = [0 0];
        job{1}.spm.spatial.preproc.tissue(3).tpm         = {strcat(spmdir,'\tpm\TPM.nii,3')};
        job{1}.spm.spatial.preproc.tissue(3).ngaus       = 2;
        job{1}.spm.spatial.preproc.tissue(3).native      = [1 0];
        job{1}.spm.spatial.preproc.tissue(3).warped      = [0 0];
        job{1}.spm.spatial.preproc.tissue(4).tpm         = {strcat(spmdir,'\tpm\TPM.nii,4')};
        job{1}.spm.spatial.preproc.tissue(4).ngaus       = 3;
        job{1}.spm.spatial.preproc.tissue(4).native      = [1 0];
        job{1}.spm.spatial.preproc.tissue(4).warped      = [0 0];
        job{1}.spm.spatial.preproc.tissue(5).tpm         = {strcat(spmdir,'\tpm\TPM.nii,5')};
        job{1}.spm.spatial.preproc.tissue(5).ngaus       = 4;
        job{1}.spm.spatial.preproc.tissue(5).native      = [1 0];
        job{1}.spm.spatial.preproc.tissue(5).warped      = [0 0];
        job{1}.spm.spatial.preproc.tissue(6).tpm         = {strcat(spmdir,'\tpm\TPM.nii,6')};
        job{1}.spm.spatial.preproc.tissue(6).ngaus       = 2;
        job{1}.spm.spatial.preproc.tissue(6).native      = [0 0];
        job{1}.spm.spatial.preproc.tissue(6).warped      = [0 0];
        job{1}.spm.spatial.preproc.warp.mrf              = 1;
        job{1}.spm.spatial.preproc.warp.cleanup          = 1;
        job{1}.spm.spatial.preproc.warp.reg              = [0 0.001 0.5 0.05 0.2];
        job{1}.spm.spatial.preproc.warp.affreg           = 'mni';
        job{1}.spm.spatial.preproc.warp.fwhm             = 0;
        job{1}.spm.spatial.preproc.warp.samp             = 3;
        job{1}.spm.spatial.preproc.warp.write            = [0 1];
        job{1}.spm.spatial.preproc.warp.vox              = NaN;
        job{1}.spm.spatial.preproc.warp.bb               = [NaN NaN NaN;NaN NaN NaN]; %Bounding box
        %save job % save the setup into a matfile called preprocessing_batch.mat
        spm_jobman('run',job) % execute the batch
        clear job% clear job
    end
    %% 
     %NORMALISATION 
        % Given that the structural and functional data are in alignment, this can be used to spatially normalise the functional data
        % SPM will then write spatially normalised files to the functional data directory. 
        % These files have the prefix w.
    if contains(task,'4')
        disp('implementing task 4');
        job                                                  = [];
        f_files                                              = spm_select('List',datadir,'^fM','.img');
        func_files                                           = cellstr([repmat([datadir filesep], size(f_files,1), 1) f_files, repmat(',1',size(f_files,1),1)]);
        s_files                                              = spm_select('List',sourcedir,'^y','.nii');
        source_files                                         = cellstr([repmat([sourcedir filesep], size(s_files,1), 1) s_files]);
        job{1}.spm.spatial.normalise.write.subj.def          = source_files;            %Deformation Field?          
        job{1}.spm.spatial.normalise.write.subj.resample     = func_files;              %Images to Write?
        job{1}.spm.spatial.normalise.write.woptions.bb       = [-78 -112 -70; 78 76 85];   %Bounding box?
        job{1}.spm.spatial.normalise.write.woptions.vox      = [3 3 3];
        job{1}.spm.spatial.normalise.write.woptions.interp   = 4;
        job{1}.spm.spatial.normalise.write.woptions.prefix   = 'w';
        %save job % save the setup into a matfile called preprocessing_batch.mat
        spm_jobman('run',job) % execute the batch
        clear job % clear job
    end
    %% 
    %if strfind(task,'5')
    %NORMALISATION_PART2 
    %If you wish to superimpose a subjects functional activations on their own anatomy 
    % you will also need to apply the spatial normalisation parameters to their (bias-corrected) anatomical image.
    
    %job{1}.spm.spatial.normalise.write.subj.def = {strcat(sourcedir,'\y_sM00223_002.nii')};
    %job{1}.spm.spatial.normalise.write.subj.resample = {strcat(sourcedir,'\y_sM00223_002.nii,1')};
    %job{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              %78 76 85];
    %job{1}.spm.spatial.normalise.write.woptions.vox = [1 1 3];
    %job{1}.spm.spatial.normalise.write.woptions.interp = 4;
    %job{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    %spm_jobman('run', job);
    %end;
    %% 
    
    if contains(task,'5')
        %%SMOOTHING
        job                                             = [];
        smooth_files                                    = (spm_select('List',datadir,'^wf','.img'));
        smoothing_files                                 = cellstr([repmat([datadir filesep], size(smooth_files,1), 1) smooth_files, repmat(',1',size(smooth_files,1),1)]);
        job{1}.spm.spatial.smooth.data                  = smoothing_files;
        job{1}.spm.spatial.smooth.fwhm                  = [6 6 6];
        job{1}.spm.spatial.smooth.dtype                 = 0;
        job{1}.spm.spatial.smooth.im                    = 0;
        job{1}.spm.spatial.smooth.prefix                = 's';
        save job % save the setup into a matfile called preprocessing_batch.mat
        spm_jobman('run',job) % execute the batch
        clear job % clear job
    end
end
