function pushbuttonextractroibetaseries_Callback(hObject, eventdata, handles)
%
% extract beta-series for a set of ROIs (voxel mean)
%
handles.InfoText = WriteInfoBox(handles,'Extracting ROI beta-series ...',true);
BaseDirectory  = pwd;
[ROIFile, sts] = spm_select([Inf],'mat','Select ROIs (Marsbar format).');
if ~sts
    handles.InfoText = WriteInfoBox(handles,'No ROIs selected.',true);
    guidata(hObject, handles);
    return;
end
ROINum = size(ROIFile,1);
handles.InfoText = WriteInfoBox(handles,sprintf('Selected %d ROIs.',ROINum),true);

% get ROI names from txt-file
[ROINames, sts] = spm_select([1],'mat','Select txt-file containing ROI names.');
if ~sts
    for i=1:ROINum
        thenames{i}=['ROI_' num2str(i)];
    end
else
    fid = fopen(fullfile(ROINames));
    scnames  = textscan(fid,'%s');
    thenames = cellstr(char(scnames{1}));
end
if length(thenames)~=ROINum
    handles.InfoText = WriteInfoBox(handles,'Number of ROIs do not match.',true);
    guidata(hObject, handles);
    return;
end
% c.o.m. of ROIs
for iroi=1:ROINum
    load(strtrim(ROIFile(iroi,:)));
    compos(:,iroi) = c_o_m(roi);
end

for isubj=1:handles.NumJobs
    handles.InfoText = WriteInfoBox(handles,sprintf('Processing subject number %d ...',isubj),true);
    if isfield(handles.anaobj{isubj}.Ana{1},'Configure')==true
        if isfield(handles.anaobj{isubj}.Ana{1}.Configure.ROI,'Path')==true
            disp('Clearing previous ROI definition ...');
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names = {};
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.File  = {};
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.Num   = 0;
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.Path  = '';
        end
    end
    % store information in analysis object
    ROIPath = fileparts(ROIFile(1,:));
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.Path        = ROIPath;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.Num         = ROINum;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.File        = cellstr(ROIFile);
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.ROICOM      = compos;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names       =  thenames;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.ROIShortLabel = thenames;
    handles.anaobj{isubj}.AnaCurrent                       = 1;
    handles.anaobj{isubj}.AnaNum                           = 1;
    handles.anaobj{isubj}.Ana{1}.Configure.UseSPMDesign    = false;
    handles.anaobj{isubj}.Ana{1}.Configure.datapath        = fullfile(handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath,handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir);
    handles.anaobj{isubj}.Ana{1}.Configure.SamplingRate    = handles.anaobj{isubj}.Ana{1}.AnaDef.RT;
    handles.anaobj{isubj}.Ana{1}.Configure.OmitVolumes     = 0;
    handles.anaobj{isubj}.Ana{1}.Label                     = 'beta series analysis (voxel)';
    handles.anaobj{isubj}.Ana{1}.Cut                       = -1.0;
    handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names = cellstr(thenames);
    
    % create list of files which contain the beta-values
    beta_path  = fullfile(handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath,handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir);
    DATA = spm_select('FPList',beta_path, ['^beta*.*\.img']);
    % retrieve beta values
    handles.InfoText = WriteInfoBox(handles,'Retrieving beta-values ...',true);
    
    rois = maroi('load_cell', ROIFile);             % make maroi ROI objects
    mY = get_marsy(rois{:}, DATA, 'mean','v');      % extract data into marsy data object
    bs = summary_data(mY);                          % get summary time course(s)
    handles.anaobj{isubj}.Ana{1}.BetaSeries  = bs;  % rows: beta-value and columns: ROIs
    numcols = size(bs,2);
    if numcols~=ROINum
        handles.InfoText = WriteInfoBox(handles,sprintf('Subject %d. Missing data (%d).',isub,numcols),true);
    end
    disp('... done.');
    % correlation matrix
    handles.InfoText = WriteInfoBox(handles,'Computing correlation matrix ...',true);
    [NWM, Pmat] = corrcoef(handles.anaobj{isubj}.Ana{1}.BetaSeries); % rows: time and columns: ROI
    handles.InfoText = WriteInfoBox(handles,'... done.',true);
    handles.anaobj{isubj}.Ana{1}.Matrix  = NWM;
    handles.anaobj{isubj}.Ana{1}.MatrixP = Pmat;
end % end loop over subjects
handles.InfoText = WriteInfoBox(handles,'Extracted beta-series.',true);
guidata(hObject, handles);
end