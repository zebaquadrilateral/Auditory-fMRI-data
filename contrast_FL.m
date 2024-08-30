%-----------------------------------------------------------------------
% Job saved on 30-Aug-2024 02:17:35 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
spmdir = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12'; %SPM present working directory:
addpath(spmdir)
spm('Defaults', 'FMRI'); 
spm_mat = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\classical\SPM.mat';

    
%-----------------------------------------------------------------------
job =[]; %structure intialization

job{1}.spm.stats.con.spmmat = {spm_mat};   %loading the spm mat file
    
% define contrast
%One sided main effects for the listening condition (i.e., a one-sided t-test) is specified  as “1” (listening > rest) and “-1” (rest > listening).

job{1}.spm.stats.con.consess{1}.tcon.name = 'listening > rest';
job{1}.spm.stats.con.consess{1}.tcon.weights = 1;
job{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
job{1}.spm.stats.con.consess{2}.tcon.name = 'rest > listening';
job{1}.spm.stats.con.consess{2}.tcon.weights = -1;
job{1}.spm.stats.con.delete = 1;
spm_jobman('run', job);
    %----------------------RESULT TABLE---------------------------------------
for i = 1:2
    p_value_threshold = 0.05;
    
    job{i}.spm.stats.results.spmmat = {spm_mat};
    if i == 1
       job{i}.spm.stats.results.conspec(1).titlestr = 'listening > rest';
    elseif i == 2
           job{i}.spm.stats.results.conspec(1).titlestr = 'rest > listening';
    end
    job{i}.spm.stats.results.conspec(1).contrasts = i;
    job{i}.spm.stats.results.conspec(1).threshdesc = 'FWE'; % 'FWE' for family-wise error correction, 'FDR' for false discovery rate, or 'none'
    job{i}.spm.stats.results.conspec(1).thresh = p_value_threshold;
    job{i}.spm.stats.results.conspec(1).extent = 0; % minimum cluster size
    job{i}.spm.stats.results.conspec(1).conjunction = 1;
    job{i}.spm.stats.results.conspec(1).mask.none = 1; % no mask
    spm_jobman('run', job);
end
    
    