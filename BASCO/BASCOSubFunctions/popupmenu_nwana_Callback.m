function popupmenu_nwana_Callback(hObject, eventdata, handles)
selected = get(hObject,'Value');
switch selected
    case 2
        [Files, sts] = spm_select([2],'mat','Select two files containing the analyses objects.');
        if ~sts
            disp('Select two files.');
            return;
        end
        load(strtrim(Files(1,:)));
        ana{1}=anaobj;
        load(strtrim(Files(2,:)));
        ana{2}=anaobj;
        leg{1}='A';
        leg{2}='B';
        GrAnaEdge(ana,leg);
        guidata(hObject, handles);
    case 3
        disp('Not yet implemented.');
        guidata(hObject, handles);

end % end switch
end