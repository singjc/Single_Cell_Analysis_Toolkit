function result = fun(app, meas_num, createCallbackFcn)
  % Get new selection of algorithm
  algo_name = app.measure{meas_num}.AlgorithmDropDown.Value;

  % Delete existing UI components before creating new ones on top
  component_names = { ...
    'fields', ...
    'labels', ...
    'ChannelDropDown', ...
    'ChannelLabel', ...
    'ChannelListbox', ...
    'ChannelListboxLabel', ...
    'SegmentListbox', ...
    'SegmentListboxLabel', ...
  };
  for cid=1:length(component_names)
    comp_name = component_names{cid};
    if isfield(app.measure{meas_num},comp_name)
      for idx=1:length(app.measure{meas_num}.(comp_name))
        delete(app.measure{meas_num}.(comp_name){idx});
      end
      app.measure{meas_num}.(comp_name) = {};
    end
  end

  % Load parameters of the algorithm plugin
  params = eval(['definition_' algo_name]);

  % Display GUI component for each parameter to the algorithm
  v_offset = 293;
  for idx=1:length(params)
    param = params(idx);

    % Location of GUI component
    v_offset = v_offset - 33;

    param_pos = [620 v_offset 125 22];
    label_pos = [400 v_offset-5 200 22];

    % Correct unavailable user set default value
    if ismember(param.type,{'dropdown','listbox'})
      if ~ismember(param.default, param.options) 
          param.default = param.options{1};
      end
    end
    % Parameter Input Box
    if ismember(param.type,{'numeric','text','dropdown','listbox'})
      % Set an index number for this component
      if ~isfield(app.measure{meas_num},'fields')
        app.measure{meas_num}.fields = {};
      end
      param_num = length(app.measure{meas_num}.fields) + 1;
      % Create UI components
      if strcmp(param.type,'numeric')
        app.measure{meas_num}.fields{param_num} = uispinner(app.measure{meas_num}.tab);
        if isfield(param,'limits')
          app.measure{meas_num}.fields{param_num}.Limits = param.limits;
        end
      elseif strcmp(param.type,'text')
        app.measure{meas_num}.fields{param_num} = uieditfield(app.measure{meas_num}.tab);
      elseif strcmp(param.type,'dropdown')
        app.measure{meas_num}.fields{param_num} = uidropdown(app.measure{meas_num}.tab);
        app.measure{meas_num}.fields{param_num}.Items = param.options;
      elseif strcmp(param.type,'listbox')
        app.measure{meas_num}.fields{param_num} = uilistbox(app.measure{meas_num}.tab, ...
          'Items', param.options, ...
          'Multiselect', 'on');
        v_offset = v_offset - 34;
        param_pos = [param_pos(1) v_offset param_pos(3) param_pos(4)+34];
      end
      app.measure{meas_num}.fields{param_num}.Position = param_pos;
      app.measure{meas_num}.fields{param_num}.Value = param.default;
      app.measure{meas_num}.labels{param_num} = uilabel(app.measure{meas_num}.tab);
      app.measure{meas_num}.labels{param_num}.HorizontalAlignment = 'right';
      app.measure{meas_num}.labels{param_num}.Position = label_pos;
      app.measure{meas_num}.labels{param_num}.Text = param.name;

    % Create segment selection dropdown box
    elseif strcmp(param.type,'segment_dropdown')
      % Set an index number for this component
      if ~isfield(app.measure{meas_num},'SegmentDropDown')
        app.measure{meas_num}.SegmentDropDown = {};
      end
      drop_num = length(app.measure{meas_num}.SegmentDropDown) + 1;
      % Create UI components
      dropdown = uidropdown(app.measure{meas_num}.tab, ...
        'Position', param_pos);
        'Items', app.segment_names, ...
      label = uilabel(app.measure{meas_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.measure{meas_num}.SegmentDropDown{drop_num} = dropdown;
      app.measure{meas_num}.SegmentLabel{drop_num} = label;

    % Create input channel selection dropdown box
    elseif strcmp(param.type,'image_channel_dropdown')
      % Set an index number for this component
      if ~isfield(app.measure{meas_num},'ChannelDropDown')
        app.measure{meas_num}.ChannelDropDown = {};
      end
      ui_elem_num = length(app.measure{meas_num}.ChannelDropDown) + 1;
      % Create UI components
      dropdown = uidropdown(app.measure{meas_num}.tab, ...
        'Items', app.input_data.channel_names, ...
        'Position', param_pos);
      label = uilabel(app.measure{meas_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.measure{meas_num}.ChannelDropDown{ui_elem_num} = dropdown;
      app.measure{meas_num}.ChannelLabel{ui_elem_num} = label;

    % Create input channel selection list box
    elseif strcmp(param.type,'image_channel_listbox')
      % Set an index number for this component
      if ~isfield(app.measure{meas_num},'ChannelListbox')
        app.measure{meas_num}.ChannelListbox = {};
      end
      ui_elem_num = length(app.measure{meas_num}.ChannelListbox) + 1;
      % Create UI components
      listbox = uilistbox(app.measure{meas_num}.tab, ...
        'Items', app.input_data.channel_names, ...
        'Multiselect', 'on', ...
        'Position', [param_pos(1) param_pos(2)-34 param_pos(3) param_pos(4)+34]);
      label = uilabel(app.measure{meas_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.measure{meas_num}.ChannelListbox{ui_elem_num} = listbox;
      app.measure{meas_num}.ChannelListboxLabel{ui_elem_num} = label;
      v_offset = v_offset - 34;

    % Create segment selection list box
    elseif strcmp(param.type,'segment_listbox')
      % Set an index number for this component
      if ~isfield(app.measure{meas_num},'SegmentListbox')
        app.measure{meas_num}.SegmentListbox = {};
      end
      ui_elem_num = length(app.measure{meas_num}.SegmentListbox) + 1;
      % Create UI components
      listbox = uilistbox(app.measure{meas_num}.tab, ...
        'Items', app.segment_names, ...
        'Multiselect', 'on', ...
        'Position', [param_pos(1) param_pos(2)-34 param_pos(3) param_pos(4)+34]);
      label = uilabel(app.measure{meas_num}.tab, ...
        'Text', param.name, ...
        'HorizontalAlignment', 'right', ...
        'Position', label_pos);
      app.measure{meas_num}.SegmentListbox{ui_elem_num} = listbox;
      app.measure{meas_num}.SegmentListboxLabel{ui_elem_num} = label;
      v_offset = v_offset - 34;



    else
      msg = sprintf('Unkown parameter type with name "%s" and type "%s". See file "definition_%s.m" and correct this issue.',param.name, param.type,algo_name);
      errordlg(msg);
      error(msg);
    end

  end

end