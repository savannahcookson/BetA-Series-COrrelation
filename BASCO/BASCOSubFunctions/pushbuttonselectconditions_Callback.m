function pushbuttonselectconditions_Callback(hObject, eventdata, handles)
prompt    = { 'Select condition' };
dlg_title = 'Select condition';
num_lines = 1;
def       = { '1' };
answer    = inputdlg(prompt,dlg_title,num_lines,def);
thecond   = str2num(answer{1});
NumCond   = size(thecond,2);
hrfderivs = handles.anaobj{1}.Ana{1}.AnaDef.HRFDERIVS; % regressors for temporal derivatives?
if isfield(handles.anaobj{1}.Ana{1},'BetaSeriesFull')==true
    handles.InfoText = WriteInfoBox(handles,'Reverting previous selection of beta-series.',true);
    for isubj=1:handles.NumJobs % loop over subjects
        handles.anaobj{isubj}.Ana{1}.BetaSeries = handles.anaobj{isubj}.Ana{1}.BetaSeriesFull; % restore beta-series
    end
    handles.InfoText = WriteInfoBox(handles,'... done.',true);
end

for isubj=1:handles.NumJobs % loop over subjects
    % backup of all beta-values
    handles.anaobj{isubj}.Ana{1}.BetaSeriesFull     = handles.anaobj{isubj}.Ana{1}.BetaSeries;
    % beta-series selected
    handles.anaobj{isubj}.Ana{1}.BetaSeriesSel      = true;
    % store which conditions were selected
    handles.anaobj{isubj}.Ana{1}.SelectedConditions = thecond;
    %
    theindices = Condition2Indices(handles.anaobj{isubj},thecond);
    handles.anaobj{isubj}.Ana{1}.ConditionIndices = theindices; % store indices

    clear('bs','newbs');
    bs=handles.anaobj{isubj}.Ana{1}.BetaSeries;
    for inode=1:size(bs,2)
        newbs(:,inode) = CondSelBS(handles.anaobj{isubj},thecond,bs(:,inode));
    end
    
    clear(sprintf('handles.anaobj{%d}.Ana{1}.BetaSeries',isubj));
    handles.anaobj{isubj}.Ana{1}.BetaSeries = newbs;
    % correlation matrix
    [NWM, Pmat ] = corrcoef(handles.anaobj{isubj}.Ana{1}.BetaSeries); % rows: time and columns: ROI
    NWM = NWM-eye(size(NWM,1));
    handles.anaobj{isubj}.Ana{1}.Matrix  = NWM;
    handles.anaobj{isubj}.Ana{1}.MatrixP = Pmat;
end % end loop over subjects

handles.InfoText = WriteInfoBox(handles,sprintf('Selection performed: %s',answer{1}),true);
guidata(hObject, handles);
end