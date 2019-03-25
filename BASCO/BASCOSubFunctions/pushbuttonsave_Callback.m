function pushbuttonsave_Callback(~, ~, handles)
% save analysis object to file
anaobj         = handles.anaobj;
[name, folder] = uiputfile('*','Select folder and enter file name.');
save(fullfile(folder,strcat(name,'.mat')),'anaobj'); % fix me!
end