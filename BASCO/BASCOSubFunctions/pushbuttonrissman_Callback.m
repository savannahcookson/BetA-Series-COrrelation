function pushbuttonrissman_Callback(hObject, eventdata, handles)
spm('Defaults','fMRI');
spm_jobman('initcfg');
marsbar('on');
if ~exist(handles.maskfile,'file')
    handles.InfoText = WriteInfoBox(handles,'Please select mask first.',true);
    guidata(hObject, handles);
    return;
end
% correlate seed-ROI beta-series to voxel beta-series
seedroifile = handles.SeedROI;
thecond     = str2num(get(handles.editconditionrissman,'String'));

NumSubj     = handles.NumJobs;
str         = sprintf('Number of subjects: %d ',NumSubj);
handles.InfoText = WriteInfoBox(handles,str,true);
str = sprintf('Correlate beta-series for condition(s): %s',num2str(thecond));
handles.InfoText = WriteInfoBox(handles,str,true);

for isubj=1:NumSubj % loop over subjects
    theidx = Condition2Indices(handles.anaobj{isubj},thecond); % indices in beta-series for chosen condition(s)
    tic
    % retrieve location of files from analysis object
    data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
    outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
    % get design
    SPMfile    = fullfile(data_path,outdirname,'SPM.mat');
    str=sprintf('Retrieving design for subject %d from SPM file: %s',isubj,SPMfile);
    handles.InfoText = WriteInfoBox(handles,str,true);
    % estimate model on ROI
    ROISummaryFunction = handles.anaobj{isubj}.Ana{1}.AnaDef.ROISummaryFunction;
    str=sprintf('Retrieving seed-ROI beta-series for subject %d (summary function: %s).',isubj,ROISummaryFunction);
    handles.InfoText = WriteInfoBox(handles,str,true);
    roibs = GetROIBetaSeries(SPMfile,seedroifile,ROISummaryFunction); % estimate model (from design in SPM-file) for seed-ROI
    % path to beta-files
    beta_path = fullfile(data_path,outdirname);
    BETAFILES = spm_select('FPList',beta_path, '^beta*.*\.img'); % get all beta-files
    if isempty(BETAFILES)
       BETAFILES = spm_select('FPList',beta_path, '^beta*.*\.nii');
    end
    fprintf('Number of beta-files (regressors): %d\n',size(BETAFILES,1));
    % get voxel timeseries within mask
    clear('y','vXYZ');
    handles.InfoText = WriteInfoBox(handles,'Extracting voxel timeseries ...',true);
    roi = maroi(handles.maskfile);
    roi = spm_hold(roi,0);
    [y, ~, vXYZ] = getdata(roi,BETAFILES,'l');
    % y    : (time,voxel) voxel timeseries
    % vXYZ : (xyz,voxel)  voxel position
    NumPts = size(y,1);
    NumVox = size(y,2);
    str=sprintf('Number of voxels: %d',NumVox);
    handles.InfoText = WriteInfoBox(handles,str,true);
    str=sprintf('Number of time points: %d',NumPts);
    handles.InfoText = WriteInfoBox(handles,str,true);
    str='Calculating functional connectivity map.';
    handles.InfoText = WriteInfoBox(handles,str,true);
    % create correlation map
    Aall   = [roibs y];
    A      = Aall(theidx,:); % select trials
    An     = bsxfun(@minus,A,mean(A,1));
    An     = bsxfun(@times,An,1./sqrt(sum(An.*An,1)));
    tsmat  = repmat(An(:,1),1,NumVox+1);
    C      = sum(tsmat.*An,1);
    fcvec  = C(2:NumVox+1);
    fcvec  = atanh(fcvec);
    % save correlation map to file
    outvol   = spm_vol(BETAFILES(1,:));
    corrmap  = zeros(outvol.dim(1),outvol.dim(2),outvol.dim(3));
    zcorrmap = zeros(outvol.dim(1),outvol.dim(2),outvol.dim(3));
    themean  = mean(fcvec(~isnan(fcvec)));
    thestd   = std(fcvec(~isnan(fcvec)));
    for ivox=1:NumVox % loop over voxels
        corrmap(vXYZ(1,ivox),vXYZ(2,ivox),vXYZ(3,ivox))  = fcvec(ivox);
        zcorrmap(vXYZ(1,ivox),vXYZ(2,ivox),vXYZ(3,ivox)) = atanh(fcvec(ivox)); % Fisher-z transformation of correlation coefficients
    end
    outvol.fname   = fullfile(data_path,outdirname,sprintf('fcmap_%s_%s.nii',handles.SeedROIName,strrep(num2str(thecond),' ','_')));
    spm_write_vol(outvol,corrmap);
    % write z-transformed map
    outvol.fname = fullfile(data_path,outdirname,sprintf('zfcmap_%s_%s.nii',handles.SeedROIName,strrep(num2str(thecond),' ','_')));
    spm_write_vol(outvol,zcorrmap);
    toc
end % end loop over subjects
handles.InfoText = WriteInfoBox(handles,'Seed-based connectivity analysis completed. Proceed to => Level 2 analysis <=.',true);
guidata(hObject, handles);
end