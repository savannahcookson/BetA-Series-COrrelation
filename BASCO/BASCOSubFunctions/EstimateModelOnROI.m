function [voxelbs_cond] = EstimateModelOnROI(handles,isubj,ROIfile,ROISummaryFunction,thecond)
% estimate model on ROI (for selected condition)
data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
thecond    = str2num(get(handles.editconditionrissman,'String'));
SPMfile    = fullfile(data_path,outdirname,'SPM.mat');
fprintf('Retrieving design for subject %d from SPM file: %s \n',isubj,SPMfile);
bs = GetROIBetaSeries(SPMfile,ROIfile,ROISummaryFunction);
str = sprintf('Number of beta-values: %d',length(bs));
handles.InfoText = WriteInfoBox(handles,str,true);
voxelbs_cond = CondSelBS(handles.anaobj{isubj},thecond,bs);
end