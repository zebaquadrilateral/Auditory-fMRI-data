%FIRST LEVEL ANALYSIS
datadir = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\fM00223'; %Directory for fMRI image data 
cd(datadir) 
sourcedir = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\sM00223'; %Directory for Source data
cd(sourcedir) 
tpm_path = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12\tpm'; %This is the directory for NIFTI files for segmentation
cd(tpm_path )
specdir = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\classical'; %Directory for the collection of the job files for first level analysis
cd(specdir)
SomaTIdir ='C:\Users\zebaq\Documents\MATLAB\MoAEpilot\SomaTI-Example\RFX1';
cd(SomaTIdir)
spmdir = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12'; %SPM present working directory:
addpath(spmdir)
spm('Defaults', 'FMRI');        % Reset SPM defaults for fMRI (not sure necessary - safety catch?)
%global defaults;               % Reset Global defaults (not sure why needed?)
spm_jobman('initcfg')           % spm_jobman initial configuration

%fMRI model specification
job = {};
job{1}.spm.stats.fmri_spec.dir = {specdir};
job{1}.spm.stats.fmri_spec.timing.units = 'scans';
job{1}.spm.stats.fmri_spec.timing.RT = 7;
job{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
job{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

f_level_images = spm_select('List',datadir,'^sw','.img');
f_l_images= cellstr([repmat([datadir filesep], size(f_level_images,1), 1) f_level_images, repmat(',1',size(f_level_images,1),1)]);
job{1}.spm.stats.fmri_spec.sess.scans = f_l_images;

job{1}.spm.stats.fmri_spec.sess.cond.name = 'listening';
job{1}.spm.stats.fmri_spec.sess.cond.onset = [6 18 30 42 54 66 78];
job{1}.spm.stats.fmri_spec.sess.cond.duration = 6;
job{1}.spm.stats.fmri_spec.sess.cond.tmod = 0;
job{1}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
job{1}.spm.stats.fmri_spec.sess.cond.orth = 1;
job{1}.spm.stats.fmri_spec.sess.multi = {''};
job{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
job{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
job{1}.spm.stats.fmri_spec.sess.hpf = 128;
job{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
job{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
job{1}.spm.stats.fmri_spec.volt = 1;
job{1}.spm.stats.fmri_spec.global = 'None';
job{1}.spm.stats.fmri_spec.mthresh = 0.8;
job{1}.spm.stats.fmri_spec.mask = {''};
job{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
spm_jobman('run',job); % execute the batch
clear job; % clear job
%% %Estimation
job = [];
job{1}.spm.stats.fmri_est.spmmat = {strcat(specdir,'\SPM.mat')};
job{1}.spm.stats.fmri_est.write_residuals = 0;
job{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('run',job)


