function pushbuttonmodelspecest_Callback(hObject, ~, handles)

str = sprintf('Running model specification and estimation ...');
handles.InfoText = WriteInfoBox(handles,str,true);

% load configuration file
[file,path] = uigetfile('*.m','MultiSelect','off');
str=sprintf('Loading file %s.',fullfile(path,file));
handles.InfoText = WriteInfoBox(handles,str,true);
run(fullfile(path,file));

NumSubj = AnaDef.NumSubjects;
handles.InfoText = WriteInfoBox(handles,sprintf('Number of subjects: %d',NumSubj),true);
ImgType = AnaDef.Img;
Img4D   = AnaDef.Img4D;

if AnaDef.ROIAnalysis==true % retrieve ROIs
    if strcmp(AnaDef.ROIDir,'')==true
        AnaDef.ROIDir = uigetdir(BaseDirectory);
    end
    ROIFile  = cellstr(spm_select('FPList',AnaDef.ROIDir,['^' AnaDef.ROIPrefix '.*.mat']));
    ROINum   = size(ROIFile,1);
    if ROINum==0
        handles.InfoText = WriteInfoBox(handles,'ROIs not found.',true);
        guidata(hObject, handles);
        return;
    else
        handles.InfoText = WriteInfoBox(handles,sprintf('Number of ROIs: %d',ROINum),true);
    end
    try
        fid = fopen(fullfile(AnaDef.ROINames));
    catch
        handles.InfoText = WriteInfoBox(handles,'File containing ROI names not found.',true);
        guidata(hObject, handles);
        return;
    end
    scnames = textscan(fid,'%s');
    thenames = char(scnames{1});
    if length(thenames)~=ROINum
        handles.InfoText = WriteInfoBox(handles,'Check number of ROIs in txt-file.',true);
        guidata(hObject, handles);
        return;
    end
end
handles.InfoText = WriteInfoBox(handles,sprintf('Output directory: %s',AnaDef.OutDir),true);
fprintf('Units for SPM design: %s \n',AnaDef.units);

for isubj=1:NumSubj % loop over subjects  %%%%%%%%%%%%%%%%%%%%%
    % store information analysis-object
    handles.anaobj{isubj}.Ana{1}.AnaDef                    = AnaDef.Subj{isubj};
    handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir             = AnaDef.OutDir;
    handles.anaobj{isubj}.Ana{1}.AnaDef.Prefix             = AnaDef.Prefix;
    handles.anaobj{isubj}.Ana{1}.AnaDef.Cond               = AnaDef.Cond;
    handles.anaobj{isubj}.Ana{1}.AnaDef.NumCond            = AnaDef.NumCond;
    handles.anaobj{isubj}.Ana{1}.AnaDef.RT                 = AnaDef.RT;
    handles.anaobj{isubj}.Ana{1}.AnaDef.fmri_t             = AnaDef.fmri_t;
    handles.anaobj{isubj}.Ana{1}.AnaDef.fmri_t0            = AnaDef.fmri_t0;
    handles.anaobj{isubj}.Ana{1}.AnaDef.OnsetModifier      = AnaDef.OnsetModifier;
    handles.anaobj{isubj}.Ana{1}.AnaDef.units              = AnaDef.units;
    handles.anaobj{isubj}.Ana{1}.AnaDef.HRFDERIVS          = AnaDef.HRFDERIVS;
    handles.anaobj{isubj}.Ana{1}.AnaDef.ROIAnalysis        = AnaDef.ROIAnalysis;        % ROI or voxel level model estimation
    handles.anaobj{isubj}.Ana{1}.AnaDef.ROIDir             = AnaDef.ROIDir;
    handles.anaobj{isubj}.Ana{1}.AnaDef.ROISummaryFunction = AnaDef.ROISummaryFunction; % 'mean' or 'median'
    handles.anaobj{isubj}.AnaCurrent                       = 1;
    handles.anaobj{isubj}.Ana{1}.AnaDef.NumRissman         = 0;
    %
    str=sprintf('====>> Processing subject %d <<====',isubj);
    handles.InfoText = WriteInfoBox(handles,str,true);
    data_path  = AnaDef.Subj{isubj}.DataPath; % path to data
    outdirname = AnaDef.OutDir;
    clear('matlabbatch');
    % model specification
    matlabbatch{1}.spm.util.md.basedir = cellstr(data_path);
    matlabbatch{1}.spm.util.md.name    = outdirname;
    matlabbatch{2}.spm.stats.fmri_spec.dir            = cellstr(fullfile(data_path,outdirname));
    matlabbatch{2}.spm.stats.fmri_spec.timing.units   = AnaDef.units;
    matlabbatch{2}.spm.stats.fmri_spec.timing.RT      = AnaDef.RT;
    matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t  = AnaDef.fmri_t;
    matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t0 = AnaDef.fmri_t0;
    NumRuns    = AnaDef.Subj{isubj}.NumRuns;
    regcounter = 0;
    
    for irun=1:NumRuns % loop over runs
        % run directory
        rundir     = fullfile(data_path,AnaDef.Subj{isubj}.RunDirs{irun});
        fprintf('Directory run %d: %s \n',irun,rundir);
        % read run specific onsets and durations
        onsetfile  = fullfile(rundir,AnaDef.Subj{isubj}.Onsets{irun});
        fprintf('Onsets: %s \n',onsetfile);
        onsets     = dlmread(onsetfile); % read onsets
        handles.anaobj{isubj}.Ana{1}.AnaDef.OnsetsMat{irun} = onsets;
        if AnaDef.durType == 2
            durationfile = fullfile(rundir,AnaDef.Subj{isubj}.Duration{irun});
            fprintf('Durations: %s \n',durationfile);
            durations     = dlmread(durationfile); % read onsets
            handles.anaobj{isubj}.Ana{1}.AnaDef.DursMat{irun} = durations;
        end
        % onsets
        onsets = onsets-AnaDef.OnsetModifier; % modify onsets (scans omitted)
        %
        % model specification
        %
        disp('Functional data:');
        if Img4D
            file4D = dir(fullfile(rundir,[AnaDef.Prefix '*.' AnaDef.Img]));
            files  = spm_select('ExtFPList',rundir, file4D.name ,Inf);
        else
            files  = spm_select('FPList',rundir, ['^' AnaDef.Prefix '*.*\.' AnaDef.Img ]);
        end
        if isempty(files)
            handles.InfoText = WriteInfoBox(handles,'Functional data not found. Check path and file name.',true);
            return;
        end
        disp(files(1,:));
        matlabbatch{2}.spm.stats.fmri_spec.sess(irun).scans = cellstr(files);
        counter  = 0;
        for icond=1:AnaDef.NumCond % loop over conditions
            NumOnsets = nnz(onsets(icond,2:end))+1;
            fprintf('Condition %d: %d trials \n',icond,NumOnsets);
            for ionsets=1:1:NumOnsets % loop over individual trials of given condition
                trialonset = onsets(icond,ionsets);
                if isnan(trialonset) || trialonset<0
                    disp('Onset NaN or <0! Bailing out ...');
                    return;
                end
                if AnaDef.durType == 2
                    trialdur = durations(icond, ionsets);
                    if isnan(trialdur)
                        disp('Dur NaN! Did you forget one? Bailing out ...');
                        return
                    end
                end
                counter=counter+1;
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).name     = sprintf('%s%d',AnaDef.Cond{icond},ionsets);
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).onset    = trialonset;
                if AnaDef.durType == 1
                    matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).duration = AnaDef.Subj{isubj}.Duration(icond);
                elseif AnaDef.durType == 2
                    matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).duration = trialdur;
                else
                    ('Duration type not specified, bailing out...')
                    return
                end
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).tmod     = 0;
                matlabbatch{2}.spm.stats.fmri_spec.sess(irun).cond(counter).pmod     = struct('name', {}, 'param', {}, 'poly', {});
                % store information on regressors and the corresponding condition
                regcounter=regcounter+1;
                handles.anaobj{isubj}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{icond}(ionsets) = regcounter;
                if AnaDef.HRFDERIVS(1)==1 && AnaDef.HRFDERIVS(2)==0
                    regcounter=regcounter+1;
                end
            end % end loop over onsets
        end % end loop over conditions
        
        %
        % motion regressors
        %
        listmot   = spm_select('FPList',fullfile(data_path,AnaDef.Subj{isubj}.RunDirs{irun}), ['^rp_*.*\.txt']);
        sclistmot = strtrim(listmot(1,:));
        handles.anaobj{isubj}.RealignmentParameters{irun} = dlmread(sclistmot); % store motion regressors
        disp('Realignment parameters:');
        disp(sclistmot);
        fprintf('%d x %d\n',size(handles.anaobj{isubj}.RealignmentParameters{irun}));
        %
        % add global mean as regressor
        %
        % brain mask
        maskpath    = fileparts(mfilename('fullpath'));
        maskpath    = fullfile(maskpath,'masks');
        roipath     = maskpath;
        brainmask   = 'brainmask_roi.mat';
        roifiles    = [ '' ];
        roifiles{1} = brainmask;
        % retrieve time course
        handles.InfoText = WriteInfoBox(handles,sprintf('Retrieving global time course for run %d ...',irun),true);
        TC{irun} = GetRawTimeCourses(files,roipath,roifiles);
        handles.anaobj{isubj}.GlobalMean{irun} = TC{irun}; % store global mean time course for each run
        filereg = sprintf('%s.globalmean.dat',sclistmot);
        dlmwrite(filereg,[handles.anaobj{isubj}.RealignmentParameters{irun} TC{irun}]);
        
        matlabbatch{2}.spm.stats.fmri_spec.sess(irun).multi = {''};
        matlabbatch{2}.spm.stats.fmri_spec.sess(irun).regress = struct('name', {}, 'val', {});
        
        if AnaDef.GlobalMeanReg==true && AnaDef.MotionReg==true
            matlabbatch{2}.spm.stats.fmri_spec.sess(irun).multi_reg = cellstr(filereg);
            regcounter = regcounter+7; % increase regressor-counter
        end
        if AnaDef.GlobalMeanReg==false && AnaDef.MotionReg==true
            matlabbatch{2}.spm.stats.fmri_spec.sess(irun).multi_reg = cellstr(sclistmot);
            regcounter = regcounter+6; % increase regressor-counter
        end
        
        % configure HP filter
        matlabbatch{2}.spm.stats.fmri_spec.sess(irun).hpf = 128;
        
    end % end loop over runs
    
    % book-keeping: which regressor belongs to certain condition
    for icond=1:AnaDef.NumCond
        tmpvec = [];
        for irun=1:NumRuns
            tmpvec = [ tmpvec handles.anaobj{isubj}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{icond} ];
        end
        handles.anaobj{isubj}.Ana{1}.AnaDef.RegCondVec{icond} = tmpvec;
        fprintf('Regressors: condition %d : \n',icond);
        tmpvec
    end
    
    matlabbatch{2}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
    matlabbatch{2}.spm.stats.fmri_spec.bases.hrf.derivs = AnaDef.HRFDERIVS;
    matlabbatch{2}.spm.stats.fmri_spec.volt             = 1;
    matlabbatch{2}.spm.stats.fmri_spec.global           = 'None';
    matlabbatch{2}.spm.stats.fmri_spec.mask             = {''};
    matlabbatch{2}.spm.stats.fmri_spec.cvi              = 'AR(1)';
    
    %
    % model estimation (voxel)
    %
    if AnaDef.VoxelAnalysis==true % voxel-betaseries
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
        matlabbatch{3}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
        matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
    end
    
    % run SPM job
    spm('defaults', 'FMRI');
    spm_jobman('initcfg')
    %spm_jobman('serial', jobs, '', inputs{:});
    %spm_jobman('interactive',matlabbatch); % open a GUI containing all the setup
    spm_jobman('run',matlabbatch);          % execute the batch
    
    %
    % ROI-based model estimation (estimate model on mean ROI time courses)
    %
    if AnaDef.ROIAnalysis==true
        h = waitbar(0,'','Name','Estimation ROI level ...');
        clear('bmat','b','E');
        for iROI=1:ROINum % loop over ROIs
            if ishandle(h)
                waitbar(iROI/ROINum,h,[num2str(round(100*iROI/ROINum)) '%']);
            end
            SPMfile = fullfile(data_path,outdirname,'SPM.mat');
            str=sprintf('Retrieving design for subject %d from SPM file: %s',isubj,SPMfile);
            handles.InfoText = WriteInfoBox(handles,str,true);
            D = mardo(SPMfile); % Marsbar design object
            R = maroi(ROIFile{iROI}); % Marsbar ROI object
            str=sprintf('Retrieving data from ROI %d using summary function %s ...',iROI,AnaDef.ROISummaryFunction);
            handles.InfoText = WriteInfoBox(handles,str,true);
            Y = get_marsy(R,D,AnaDef.ROISummaryFunction); % put data into marsbar data object
            E = estimate(D,Y); % estimate model based on ROI summary
            b = betas(E); % retrieve estimated beta-values
            bmat(:,iROI) = b; % matrix of beta-values: (rows: beta-values,columns: ROI)
        end % end loop over ROIs
        handles.anaobj{isubj}.Ana{1}.BetaSeries  = bmat;
        try
            close(h);
        end
        
        % store information in analysis object
        handles.anaobj{isubj}.Ana{1}.Configure.ROI.Path        = AnaDef.ROIDir;
        handles.anaobj{isubj}.Ana{1}.Configure.ROI.Num         = ROINum;
        handles.anaobj{isubj}.Ana{1}.Configure.ROI.File        = ROIFile;
        handles.anaobj{isubj}.AnaCurrent                       = 1;
        handles.anaobj{isubj}.AnaNum                           = 1;
        handles.anaobj{isubj}.Ana{1}.Configure.UseSPMDesign    = false;
        handles.anaobj{isubj}.Ana{1}.Configure.datapath        = data_path;
        handles.anaobj{isubj}.Ana{1}.Configure.SamplingRate    = handles.anaobj{isubj}.Ana{1}.AnaDef.RT;
        handles.anaobj{isubj}.Ana{1}.Configure.OmitVolumes     = 0;
        handles.anaobj{isubj}.Ana{1}.Label                     = 'ROI-beta-series analysis';
        handles.anaobj{isubj}.Ana{1}.Cut                       = -1.0;
        handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names       = cellstr(thenames);
        
    end % end ROI analysis
    
    % load design
    data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
    outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
    spmfile    = 'SPM.mat';
    spmpath    = fullfile(data_path,outdirname);
    load(fullfile(spmpath,spmfile));
    X = [SPM.xX.X]; % (runs,regressors)
    handles.anaobj{isubj}.Ana{1}.AnaDef.X=X; % store design matrix
    
end % end loop over subjects   %%%%%%%%%%%%%%%%%%%

handles.NumJobs  = NumSubj;
handles.InfoText = WriteInfoBox(handles,'... model specification and estimation done.',true);

% save analysis object
anaobj = handles.anaobj;
if isfield(AnaDef,'Outfile') && strcmp(AnaDef.Outfile,'')==false
    try
        save(AnaDef.Outfile,'anaobj');
    catch
        handles.InfoText = WriteInfoBox(handles,'Error saving data. Select folder and enter file name.',true);
        [name, folder] = uiputfile('*','Select folder and enter file name.');
        save(fullfile(folder,strcat(name,'.mat')),'anaobj');
    end
else
    handles.InfoText = WriteInfoBox(handles,'Save data: Select folder and enter file name.',true);
    [name, folder] = uiputfile('*','Select folder and enter file name.');
    save(fullfile(folder,strcat(name,'.mat')),'anaobj');
end

handles.InfoText = WriteInfoBox(handles,'File saved.',true);
guidata(hObject, handles);
end