function pushbuttonlevel2analysis_Callback(~, ~, handles)
% SPM level 2 analysis of correlation maps:
% paired t-test, two-sample t-test or 2x2 flexible factorial
thetest = get(handles.popupmenulevel2,'Value'); % test to perform
spm('Defaults','fMRI');
spm_jobman('initcfg');

%
% paired t-test (between conditions)
%
if thetest==1
    tmppath = pwd;
    cd(fullfile(handles.anaobj{1}.Ana{1}.AnaDef.DataPath,handles.anaobj{1}.Ana{1}.AnaDef.OutDir));
    file = uigetfile({'*.nii';'*.img'},'Select two maps.','MultiSelect','on');
    cd(tmppath);
    thedir = uigetdir('Select output directory');
    fname1 = file{1};
    fname2 = file{2};
    cd(thedir);
    NumSubj = handles.NumJobs;
    thefiles1=cell(1,NumSubj);
    thefiles2=cell(1,NumSubj);
    for isubj=1:NumSubj % loop over subjects
        data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        thefiles1{isubj} = fullfile(data_path,outdirname,fname1);
        thefiles2{isubj} = fullfile(data_path,outdirname,fname2);
    end % end loop over subjects
    
    matlabbatch{1}.spm.stats.factorial_design.dir = {thedir};
    for isubj=1:NumSubj
        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(isubj).scans = { thefiles1{isubj} ; thefiles2{isubj} };
    end
    matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
end

%
% two-sample t-test (between groups)
%
if thetest==2
    [file,anapath] = uigetfile('*.mat','Select two files','MultiSelect','on');
    thedir = uigetdir('Select output directory');
    load(fullfile(anapath,file{1}))
    NumSubj1  = length(anaobj);
    thefiles1 = cell(1,NumSubj1);
    cd(fullfile(anaobj{1}.Ana{1}.AnaDef.DataPath,anaobj{1}.Ana{1}.AnaDef.OutDir));
    [fname,path] = uigetfile({'*.img';'*.nii'},'Select correlation/degree map','MultiSelect','off');
    for isubj=1:NumSubj1 % loop over subjects
        data_path  = anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        thefiles1{isubj} = fullfile(data_path,outdirname,fname);
    end % end loop over subjects
    load(fullfile(anapath,file{2}));
    NumSubj2  = length(anaobj);
    thefiles2 = cell(1,NumSubj2);
    for isubj=1:NumSubj2 % loop over subjects
        data_path  = anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        thefiles2{isubj} = fullfile(data_path,outdirname,fname);
    end % end loop over subjects
    cd(thedir);
    matlabbatch{1}.spm.stats.factorial_design.dir = {thedir};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = cellstr(thefiles1);
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = cellstr(thefiles2);
    matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
end

%
% flexible factorial
%
if thetest==3
    disp('Flexible factorial: Subject and 2 factors.');
    prompt    = { 'Factor A' , 'Factor B' };
    dlg_title = 'Configure level 2 analysis (flexible factorial)';
    num_lines = 1;
    def       = { 'A' , 'B' };
    answer    = inputdlg(prompt,dlg_title,num_lines,def);
    tmppath = pwd;
    cd(fullfile(handles.anaobj{1}.Ana{1}.AnaDef.DataPath,handles.anaobj{1}.Ana{1}.AnaDef.OutDir));
    [fname1] = uigetfile({'*.nii';'*.img'},'Select connectivity/degree map: A1 B1','MultiSelect','off');
    [fname2] = uigetfile({'*.nii';'*.img'},'Select connectivity/degree map: A1 B2','MultiSelect','off');
    [fname3] = uigetfile({'*.nii';'*.img'},'Select connectivity/degree map: A2 B1','MultiSelect','off');
    [fname4] = uigetfile({'*.nii';'*.img'},'Select connectivity/degree map: A2 B2','MultiSelect','off');
    cd(tmppath);
    thedir = uigetdir('Select output directory');
    cd(thedir);
    NumSubj = handles.NumJobs;
    thefiles1=cell(1,NumSubj);
    thefiles2=cell(1,NumSubj);
    thefiles3=cell(1,NumSubj);
    thefiles4=cell(1,NumSubj);
    for isubj=1:NumSubj % loop over subjects
        data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        %delete(fullfile(data_path,outdirname,'*vox*'));
        thefiles1{isubj} = fullfile(data_path,outdirname,fname1);
        thefiles2{isubj} = fullfile(data_path,outdirname,fname2);
        thefiles3{isubj} = fullfile(data_path,outdirname,fname3);
        thefiles4{isubj} = fullfile(data_path,outdirname,fname4);
    end % end loop over subjects
    matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(thedir);
    % factors
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'Subject';
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = answer{1};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = answer{2};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;
    for i=1:NumSubj % add subjects to analysis
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = { thefiles1{i} ; thefiles2{i} ; thefiles3{i} ; thefiles4{i} };
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = [1 1
            1 2
            2 1
            2 2];
    end
    % main effects and interactions
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 2;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 3;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{3}.inter.fnums = [2 ; 3];
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
end % end flexible factorial

%
% estimation
%
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(thedir,'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
spm('defaults', 'FMRI');
spm_jobman('interactive',matlabbatch);  % open a GUI containing all the setup
end