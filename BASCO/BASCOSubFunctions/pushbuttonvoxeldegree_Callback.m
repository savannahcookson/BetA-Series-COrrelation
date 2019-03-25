function pushbuttonvoxeldegree_Callback(hObject, eventdata, handles)
% create condition specific voxel degree/strength map
handles.InfoText = WriteInfoBox(handles,'Configure analysis.',true);
prompt    = { 'absolute threshold' , 'Select condition(s)' , 'ID' , 'Mask','Fast'};
dlg_title = 'Configure analysis';
num_lines = 1;
def       = { '0.25' , '1' , 'test' , '1' , '0'};
answer    = inputdlg(prompt,dlg_title,num_lines,def);
th        = str2num(answer{1});
thecondv  = str2num(answer{2});
idstr     = answer{3};
use_mask  = str2num(answer{4});
fastpro   = str2num(answer{5});

NumSubj = handles.NumJobs;
str=sprintf('Number of subjects: %d ',NumSubj);
handles.InfoText = WriteInfoBox(handles,str,true);
hrfderivs = handles.anaobj{1}.Ana{1}.AnaDef.HRFDERIVS; % regressors for temporal derivatives?

if use_mask==1
    maskfile                = spm_select(1,'image','Select mask (nifti image).');
    handles.InfoText        = WriteInfoBox(handles,'Mask selected.',true);
    maskvol                 = spm_vol(maskfile);
    maskimg                 = spm_read_vols(maskvol);
    [mx,my,mz]              = size(maskimg);
    maskvec                 = reshape(maskimg,mx*my*mz,1);
    imask                   = find(maskvec);
    str                     = sprintf('Number of voxels within mask: %d ',size(imask,1));
    handles.InfoText        = WriteInfoBox(handles,str,true);
    maskvec(find(~maskvec)) = nan;
end

for jcond=1:length(thecondv)
    thecond = thecondv(jcond);
    
    str=sprintf('===> Condition %d <===',thecond);
    handles.InfoText = WriteInfoBox(handles,str,true);
    
    for isubj=1:NumSubj % loop over subjects
        %
        % retrieve location of files from analysis object
        str=sprintf('===> Subject %d <===',isubj);
        handles.InfoText = WriteInfoBox(handles,str,true);
        data_path  = handles.anaobj{isubj}.Ana{1}.AnaDef.DataPath;
        outdirname = handles.anaobj{isubj}.Ana{1}.AnaDef.OutDir;
        
        %
        % path to beta-files
        beta_path  = fullfile(data_path,outdirname);
        BETAFILES  = spm_select('FPList',beta_path, ['^beta*.*\.img']); % get all beta-files
        if isempty(BETAFILES)
           BETAFILES = spm_select('FPList',beta_path, ['^beta*.*\.nii']);
        end
        str = sprintf('Correlate beta-series for condition(s): %s',num2str(thecond));
        handles.InfoText = WriteInfoBox(handles,str,true);
        fprintf('Number of beta-files (regressors): %d \n',size(BETAFILES,1));
        X = handles.anaobj{isubj}.Ana{1}.AnaDef.X; % design (runs,regressors)
        NumReg = size(X,2);
        if NumReg~=size(BETAFILES,1)
            disp('Number of beta-files and number of regressors in design matrix do not match!');
            return;
        end
        
        disp('Loading beta-files ...');
        for idx=1:NumReg
            betavol{idx}       = spm_vol(BETAFILES(idx,:));
            betaimg(:,:,:,idx) = spm_read_vols(betavol{idx});
            [Vx, Vy, Vz, beta] = size(betaimg); % number of voxels in x, y and z direction
        end
        Nvox = Vx*Vy*Vz;
        str = sprintf('%s \nVoxel dimensions (beta-images): %d %d %d %d',str,Vx,Vy,Vz,beta);
        handles.InfoText = WriteInfoBox(handles,str,true);
        mat = reshape(betaimg,Vx*Vy*Vz,beta); % reshape to matrix (voxel,beta)
        
        if use_mask==1
            try
                summat = sum(mat,2)+maskvec;
            catch
                handles.InfoText = WriteInfoBox(handles,'Mask not in the same space as the beta-files. Resample mask.',true);
                return;
            end
            idat   = find(~isnan(summat));
            str=sprintf('Number of voxels within mask and with data: %d ',size(idat,1));
            handles.InfoText = WriteInfoBox(handles,str,true);
        else
            idat   = find(~isnan(sum(mat,2)));
            str=sprintf('Number of voxels with data: %d ',size(idat,1));
            handles.InfoText = WriteInfoBox(handles,str,true);
        end
        ibeta = Condition2Indices(handles.anaobj{isubj},thecond);
        if hrfderivs(1)==0 && hrfderivs(2)==0
            datmat = mat(idat,ibeta);
        end
        % temporal derivatives
            % Estimating the "amplitude" of the effects at each voxel = sign(V1).*sqrt(V1.^2+V2.^2)
            % where V1 is the canonical effect contrast volume, and V2 is the temporal derivative
            % effect contrast volume. [Calhoun (2004)]        
        if hrfderivs(1)==1 && hrfderivs(2)==0
            datmatA = mat(idat,ibeta);
            datmatB = mat(idat,ibeta+1);
            datmat = sign(datmatA).*sqrt(datmatA.^2+datmatB.^2);
        end
        if hrfderivs(1)==1 && hrfderivs(2)==1
            datmatA = mat(idat,ibeta);
            datmatB = mat(idat,ibeta+1);
            datmatC = mat(idat,ibeta+2);
            datmat = sign(datmatA).*sqrt(datmatA.^2+datmatB.^2+datmatC.^2);
        end

        [degvec_idat, strvec_idat] = FastDeg(datmat',th,fastpro);
         
        %
        % degree
        degvec        = nan(1,Vx*Vy*Vz);
        degvec(idat)  = degvec_idat;
        voxdegmap     = reshape(degvec,[Vx Vy Vz]);
        outvol = betavol{1};
        outvol.fname = fullfile(data_path,outdirname,sprintf('voxdegmap_%s_%.2f_%s.nii',idstr,th,strrep(num2str(thecond),' ','_')));
        spm_write_vol(outvol,voxdegmap);
        %
        % z-transformed degree map
        outvol.fname = fullfile(data_path,outdirname,sprintf('zvoxdegmap_%s_%.2f_%s.nii',idstr,th,strrep(num2str(thecond),' ','_')));
        zdegmap = (voxdegmap-nanmean(voxdegmap(:)))/nanstd(voxdegmap(:));
        zdegmap(find(isnan(voxdegmap)))=nan;
        spm_write_vol(outvol,zdegmap);
        %
        % strength
        strvec        = nan(1,Vx*Vy*Vz);
        strvec(idat)  = strvec_idat;
        voxstrmap     = reshape(strvec,[Vx Vy Vz]);
        outvol = betavol{1};
        outvol.fname = fullfile(data_path,outdirname,sprintf('voxstrmap_%s_%.2f_%s.nii',idstr,th,strrep(num2str(thecond),' ','_')));
        spm_write_vol(outvol,voxstrmap);     
        fprintf('Wrote image(s) (%d voxels). \n',Nvox);
        
    end % loop over subjects
end % loop over conditions

handles.InfoText = WriteInfoBox(handles,'Voxel degree/strength maps created. Proceed to => Level 2 analysis <=.',true);
guidata(hObject, handles);
end