function editbox_Callback(hObject, eventdata, axHist)

inputV = str2double(get(hObject,'String'));
if isnan(inputV)
  errordlg('You must enter a numeric value','Invalid Input','modal')
  uicontrol(hObject)
  return
else
    if strcmp(hObject.Tag,'rhs')
        axHist.RTwindow(2) = inputV;
    else
        axHist.RTwindow(1) = inputV;
    end
end