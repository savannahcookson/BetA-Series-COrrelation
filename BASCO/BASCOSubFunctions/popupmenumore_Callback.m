function popupmenumore_Callback(hObject, eventdata, handles)
selected = get(hObject,'Value');
switch selected
    case 2
        handles = basco_meanbetavalues(handles);
        guidata(hObject, handles);
    case 3
        basco_univariateroi();
    case 4
        basco_checkestimation(handles);
    case 5 % rename nodes/ROIs
        [file, path]    = uigetfile('*.txt');
        fid             = fopen(fullfile(path,file));
        importeddata    = textscan(fid,'%s');
        NumSubj = handles.NumJobs;
        for isubj=1:NumSubj
            NumNodes = size(importeddata{1},1);
            for inode=1:1:NumNodes
                handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names{inode} = char(importeddata{1}(inode,:));
                fprintf('%d -> %s \n',inode,handles.anaobj{isubj}.Ana{1}.Configure.ROI.Names{inode});
            end % end loop over nodes
        end % end loop over subjects
    case 6 % reslice image (gray matter mask)
        matlabbatch{1}.spm.spatial.coreg.write.ref = '<UNDEFINED>';
        matlabbatch{1}.spm.spatial.coreg.write.source = '<UNDEFINED>';
        matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 1;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
        spm('defaults', 'FMRI');
        spm_jobman('initcfg')
        spm_jobman('interactive',matlabbatch);
    case 7
        prompt = {'Select subjects.'};
        dlg_title = 'Select subjects';
        num_lines = 1;
        def = {sprintf('1:%d',length(handles.anaobj))};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        idx = str2num(answer{1});
        cnt=0;
        for i=idx
            cnt=cnt+1;
            newanaobj{cnt} = handles.anaobj{i};
            fprintf('%d : Selected subject %d ...\n',cnt,i);
        end
        clear('handles.anaobj');
        handles.anaobj = newanaobj;
        handles.NumJobs = length(handles.anaobj);
        handles.InfoText = WriteInfoBox(handles,sprintf('Selected %d subjects.\n',handles.NumJobs),true);
        guidata(hObject, handles);
    case 8
        ROIS = spm_select([1],'image','Select number labelled ROI file.');
        NumSubj = handles.NumJobs;
        % loop over subjects
        for isubj=1:NumSubj
            handles.anaobj{isubj}.Ana{1}.Configure.ROI.ROIFILE = ROIS;
        end % end loop over subjects
        guidata(hObject, handles);
    case 9
        disp('Smooth data.');
        tmppath = pwd;
        cd(fullfile(handles.anaobj{1}.Ana{1}.AnaDef.DataPath,handles.anaobj{1}.Ana{1}.AnaDef.OutDir));
        [fname1,path] = uigetfile('*.nii','Select map.','MultiSelect','off');
        cd(tmppath);
        NumSubj   = handles.NumJobs;
        thefiles  = cell(1,NumSubj);
        for isubj=1:NumSubj % loop over subjects
            data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
            outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
            thefiles{isubj} = fullfile(data_path,outdirname,fname1);
        end % end loop over subjects
        matlabbatch{1}.spm.spatial.smooth.data   = thefiles;
        matlabbatch{1}.spm.spatial.smooth.fwhm   = [8 8 8];
        matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
        matlabbatch{1}.spm.spatial.smooth.im     = 1;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
        spm('defaults', 'FMRI');
        spm_jobman('initcfg')
        spm_jobman('interactive',matlabbatch);
    case 10
        
    case 11
        basco_checkmaps(handles);
end % end switch
end