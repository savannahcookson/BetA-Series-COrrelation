function pushbuttonseedroiinfo_Callback(~, ~, handles)
seedroifile = handles.SeedROI;
t1path      = fullfile(fileparts(which('spm')),'canonical');
t1file      = 'avg152T1.nii';
mars_display_roi('display',seedroifile,fullfile(t1path,t1file));
end