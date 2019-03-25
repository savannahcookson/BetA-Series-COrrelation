function newstr = WriteInfoBox(handles,str,append)
disp(str);
oldstr = handles.InfoText;
if append==true
    newstr = sprintf('%s \n%s',str,oldstr);
else
    newstr = sprintf('%s',str);
end
set(handles.infobox,'String',newstr);
drawnow;
end