function fun(app)

  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  % Delete UI components that were there before
  for seg_num=1:length(app.display.segment)    
      delete(app.display.segment{seg_num}.checkbox);
      delete(app.display.segment{seg_num}.label);
      delete(app.display.segment{seg_num}.gain_slider);
      delete(app.display.segment{seg_num}.color_picker);
      delete(app.display.segment{seg_num}.perimeter_toggle);
      delete(app.display.segment{seg_num}.perimeter_thickness);
  end
  app.display.segment = {};

  function CheckCallback(uiElem, Update, app, plate_num, seg_num)
    app.input_data.plates(plate_num).enabled_segments(seg_num) = app.display.segment{seg_num}.checkbox.Value;
    update_figure(app);
  end

  function Gain_Slider_Callback(uiElem, Update, app, plate_num, seg_num)
    update_figure(app);
  end

  function ColorPicker_Callback(uiElem, Update, app, plate_num, seg_num)
    current_RGB = app.input_data.plates(plate_num).seg_colors(seg_num,:);
    new_RGB = uisetcolor(current_RGB);
    app.input_data.plates(plate_num).seg_colors(seg_num,:) = new_RGB;
    update_figure(app);
  end

  function Perimeter_Toggle_Callback(uiElem, Update, app, plate_num, seg_num)
    update_figure(app);
  end

  function Perimeter_Thickness_Callback(uiElem, Update, app, plate_num, seg_num)
    update_figure(app);
  end

  v_offset = 329;

  % Loop over segments
  for seg_num=1:length(app.segment)
    % Location of GUI component
    check_pos = [470,v_offset,25,15]; % 309
    label_pos = [487,v_offset,61,15]; % 309
    gain_pos = [552,v_offset-5,3,24]; % 304
    color_picker_pos = [563,v_offset-4,27,24]; % 306
    perimeter_toggle_pos = [593,v_offset-4,29,24]; % 306
    perimeter_thickness_pos = [625,v_offset-3,43,22]; % 307
  
    % Check Box
    app.display.segment{seg_num}.checkbox = uicheckbox(app.Tab_Display, ...
      'Position', check_pos, ...
      'Value', true, ...
      'Text', '', ...
      'ValueChangedFcn', {@CheckCallback, app, plate_num, seg_num});
      % 'Value', app.input_data.plates(plate_num).enabled_segments(seg_num), ...

    % Segment Label
    if strcmp(app.segment{seg_num}.Name.Value,'')
      segment_name = sprintf('Segment %i', seg_num);
    else
      segment_name = app.segment{seg_num}.Name.Value;
    end
    app.display.segment{seg_num}.label = uilabel(app.Tab_Display, ...
      'Text', segment_name, ...
      'Position', label_pos);

    % Gain Slider
    app.display.segment{seg_num}.gain_slider = uislider(app.Tab_Display, ...
      'MajorTicks', [], ...
      'MajorTickLabels', {}, ...
      'MinorTicks', [], ...
      'Orientation', 'vertical', ...
      'Value', 100, ...
      'ValueChangedFcn', {@Gain_Slider_Callback, app, plate_num, seg_num}, ...
      'Position', gain_pos); 

    % Colour Picker
    app.display.segment{seg_num}.color_picker = uibutton(app.Tab_Display, ...
      'Text', '', ...
      'Icon', 'painter-palette.png', ...
      'BackgroundColor', [.3,.75,.9], ...
      'ButtonPushedFcn', {@ColorPicker_Callback, app, plate_num, seg_num}, ...
      'Position', color_picker_pos);

    % Perimeter Toggle
    app.display.segment{seg_num}.perimeter_toggle = uibutton(app.Tab_Display, 'state', ...
      'Text', '', ...
      'Icon', 'check-box-empty.png', ...
      'BackgroundColor', [.3,.75,.9], ...
      'ValueChangedFcn', {@Perimeter_Toggle_Callback, app, plate_num, seg_num}, ...
      'Position', perimeter_toggle_pos);

    % Perimeter Thickness
    app.display.segment{seg_num}.perimeter_thickness = uispinner(app.Tab_Display, ...
      'Value', 2, ...
      'Limits', [1 Inf], ...
      'ValueChangedFcn', {@Perimeter_Thickness_Callback, app, plate_num, seg_num}, ...
      'Position', perimeter_thickness_pos);

    v_offset = v_offset - 35;
  end

end
