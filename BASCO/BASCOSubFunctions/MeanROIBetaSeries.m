function [seedroimeanbs_selcond] = MeanROIBetaSeries(handles,isubj,ROIfile,thecond)
% mean ROI beta-series
% create list of files which contain the beta-values
beta_path = fullfile(handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath,handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir)
DATA = spm_select('FPList',beta_path,'^beta*.*\.img');
if isempty(DATA)
  DATA = spm_select('FPList',beta_path,'^beta*.*\.nii');
end
% retrieve beta values
handles.InfoText = WriteInfoBox(handles,'Retrieving beta-values for voxels in selected ROI.',true);
rois = maroi('load_cell', ROIfile);           % make maroi ROI objects
mY = get_marsy(rois{:}, DATA, 'mean');        % extract data into marsy data object
seedroimeanbs = summary_data(mY);             % get summary time course(s)
seedroimeanbs_selcond = CondSelBS(handles.anaobj{isubj},thecond,seedroimeanbs);
end