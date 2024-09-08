%% Group-level analysis for SomaTI-Example dataset

% set up SPM
spmdir = 'C:\Users\zebaq\Documents\MATLAB\spm12\spm12'; %SPM present working directory:
addpath(spmdir)
spm('Defaults', 'FMRI');        % Reset SPM defaults for fMRI (not sure necessary - safety catch?)
%global defaults;               % Reset Global defaults (not sure why needed?)
spm_jobman('initcfg')           % spm_jobman initial configuration


% data directory
firstlevel_dir = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\SomaTI-Example';
cd(firstlevel_dir)
output_dir = 'C:\Users\zebaq\Documents\MATLAB\MoAEpilot\SomaTI-Example\02 group level analysis';


%% input data
% loop over each subject and compile paths to the first level contrast images

firstlevel_con = {};
subfolder = dir(firstlevel_dir);

for i = 1:length(subfolder)
    if subfolder(i).isdir && startsWith(subfolder(i).name, 'sub')
        filter = '^con.*\.img$';
        selected_con = spm_select('List', fullfile(firstlevel_dir, subfolder(i).name), filter);
        firstlevel_con{length(firstlevel_con)+1} = cellstr(strcat(firstlevel_dir, '\', subfolder(i).name, '\', selected_con,',1'));
    end
end

%
factor_name = {'PER-IMG', 'Position'};
conditions = [1 1; 1 2; 1 3; 1 4; 2 1; 2 2; 2 3; 2 4];
effects = {[1 2]}; %interaction


%% =====================Flexible factorial design=====================
% output directory
matlabbatch = {};
matlabbatch{1}.spm.stats.factorial_design.dir = {output_dir};

% factorial design
for i = 1:length(factor_name)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).name = factor_name{1};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).ancova = 0;
end

% input scans
for i = 1:length(firstlevel_con)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = firstlevel_con{i};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = conditions;
end

% main effect/interaction
for i = 1:length(effects)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{i}.inter.fnums = effects{i};
end

%
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


% run estimation
nrun = 1;
inputs = cell(0, nrun);
spm_jobman('run', matlabbatch, inputs{:});

%% =====================Estimate contrast and output result table/figure=====================

spmmat_path = fullfile(output_dir, 'SPM.mat');

name = {'imagery>perception',
        'perceptLH>perceptOTHER'};
vec = {[-1 -1 -1 -1 1 1 1 1],
       [1 -1 -1 -1 0 0 0 0]};
stat = 't';
    
%==================ESTIMATE CONTRAST======================
matlabbatch = {};

for i = 1:length(name)
    j = i*2-1;

    % specify matlabbatch
    matlabbatch{j}.spm.stats.con.spmmat = {spmmat_path};

    % define contrast
    if stat == 't'
        matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = name{i};
        matlabbatch{j}.spm.stats.con.consess{1}.tcon.weights = vec{i};
        matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    elseif stat == 'f'
        matlabbatch{j}.spm.stats.con.consess{1}.fcon.name = name{i};
        matlabbatch{j}.spm.stats.con.consess{1}.fcon.weights = vec{i};
        matlabbatch{j}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
    end
    if j==1
        matlabbatch{j}.spm.stats.con.delete = 1;
    end
    
    %===================RESULT TABLE====================
    p_value_threshold = 0.05;
    
    matlabbatch{j+1}.spm.stats.results.spmmat = {spmmat_path};
    matlabbatch{j+1}.spm.stats.results.conspec(1).titlestr = name{i};
    matlabbatch{j+1}.spm.stats.results.conspec(1).contrasts = i;
    matlabbatch{j+1}.spm.stats.results.conspec(1).threshdesc = 'FWE'; % 'FWE' for family-wise error correction, 'FDR' for false discovery rate, or 'none'
    matlabbatch{j+1}.spm.stats.results.conspec(1).thresh = p_value_threshold;
    matlabbatch{j+1}.spm.stats.results.conspec(1).extent = 0; % minimum cluster size
    matlabbatch{j+1}.spm.stats.results.conspec(1).conjunction = 1;
    matlabbatch{j+1}.spm.stats.results.conspec(1).mask.none = 1; % no mask

 end
    
 spm_jobman('run', matlabbatch);