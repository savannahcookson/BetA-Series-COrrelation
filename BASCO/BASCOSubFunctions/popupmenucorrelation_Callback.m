function popupmenucorrelation_Callback(hObject, ~, handles)
sel = get(hObject,'Value');
NumSubj = handles.NumJobs;
% correlation coefficients from 'corrcoef'
if sel==1
    for isubj=1:NumSubj
        BS = handles.anaobj{isubj}.Ana{1}.BetaSeries;
        [NWM, pNWM] = corrcoef(BS);
        NWM = NWM-eye(size(NWM,1));
        handles.anaobj{isubj}.Ana{1}.Matrix  = NWM;
        handles.anaobj{isubj}.Ana{1}.MatrixP = pNWM;
    end
    str='Calculated correlation coefficients from beta-series.';
    handles.InfoText = WriteInfoBox(handles,str,true);
end
% Spearman correlation coefficients
if sel==2
    handles.InfoText = WriteInfoBox(handles,'Calculating Spearman correlation coefficients from beta-series. Please wait.',true);
    for isubj=1:NumSubj
        BS          = handles.anaobj{isubj}.Ana{1}.BetaSeries;
        [NWM, pNWM] = corr(BS,'type','Spearman');
        NWM         = NWM-eye(size(NWM,1));
        handles.anaobj{isubj}.Ana{1}.Matrix  = NWM;
        handles.anaobj{isubj}.Ana{1}.MatrixP = pNWM;
    end
    handles.InfoText = WriteInfoBox(handles,'Calculated Spearman correlation coefficients from beta-series.',true);
end
% arc-hyperbolic tangent transformation
if sel==3
    for isubj=1:NumSubj
        handles.anaobj{isubj}.Ana{1}.Matrix = atanh(handles.anaobj{isubj}.Ana{1}.Matrix);
    end
    handles.InfoText = WriteInfoBox(handles,'Correlation matrices arc-hyperbolic tangent transformed.',true);
end
% outlier rejection
if sel==4
    zthr = 4.0; % z-thresjhold for outlier rejection
    for isubj=1:NumSubj
        bs     = handles.anaobj{isubj}.Ana{1}.BetaSeries; % (trials,rois)
        NWMpre = corrcoef(bs);
        NWMpre = NWMpre-eye(size(NWMpre,1));
        ztrbs  = (bs-repmat(mean(bs),size(bs,1),1))./repmat(std(bs),size(bs,1),1);
        ztrmax = abs(min(ztrbs'));
        inidx  = find(ztrmax<zthr);
        fprintf('Subject %d ===> rejected outlier (%.2f) : %d (%d) \n',isubj,zthr,size(bs,1)-length(inidx),size(bs,1));
        [NWM, pNWM] = corrcoef(bs(inidx,:));
        NWM         = NWM-eye(size(NWM,1));
        handles.anaobj{isubj}.Ana{1}.Matrix  = atanh(NWM);
        handles.anaobj{isubj}.Ana{1}.MatrixP = pNWM;
    end
    str='Calculated correlation coefficients from beta-series (outlier rejection; Fisher-z transformed).';
    handles.InfoText = WriteInfoBox(handles,str,true);
end
guidata(hObject, handles);
end