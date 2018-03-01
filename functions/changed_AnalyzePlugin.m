function result = fun(app, an_num, createCallbackFcn)

  % Setup a function needed later (note that functions cannot be defined in loops)
  function ParamOptionalCheckBoxCallback(uiElem, Update, app)
    an_num = uiElem.UserData.an_num;
    param = uiElem.UserData.param;
    param_index = uiElem.UserData.param_index;
    val = 'off';
    if uiElem.Value
      val = 'on';
    end
    if ismember(param.type,{'numeric','text','dropdown'})
      app.analyze{an_num}.fields{param_index}.Enable = val;
    elseif strcmp(param.type,'measurement_dropdown')
      app.analyze{an_num}.MeasurementDropDown{param_index}.Enable = val;
    end
    do_analyze_(app,'Update');
  end

  function Help_Callback(uiElem, Update, app)
    help_text = uiElem.UserData.help_text;
    param_name = uiElem.UserData.param_name;
    uialert(app.UIFigure,help_text,param_name, 'Icon','info');
  end

  function checkbox = MakeOptionalCheckbox(app, an_num, param, param_index)
    check_pos = [param_pos(1)-20 param_pos(2)+4 25 15];
    userdata = {}; % context to pass to callback
    userdata.an_num = an_num;
    userdata.param = param;
    userdata.param_index = param_index;
    default_state = true;
    default_enable = 'on';
    if isfield(param,'optional_default_state') && ~isempty(param.optional_default_state)
      default_state = param.optional_default_state;
      default_enable = 'off';
    end
    checkbox = uicheckbox(app.analyze{an_num}.tab, ...
    'Position', check_pos, ...
    'Value', default_state, ...
    'Text', '', ...
    'UserData', userdata, ...
    'ValueChangedFcn', {@ParamOptionalCheckBoxCallback, app});
    if ismember(param.type,{'numeric','text','dropdown'})
      app.analyze{an_num}.fields{param_index}.Enable = default_enable;
    elseif strcmp(param.type,'analyze_dropdown')
      app.analyze{an_num}.MeasurementDropDown{param_index}.Enable = default_enable;
    elseif strcmp(param.type,'image_channel_dropdown')
      app.analyze{an_num}.ChannelDropDown{param_index}.Enable = default_enable;
    end
  end

  % Callback for when parameter value is changed by the user
  function do_analyze_(app, Update)
    if ~app.analyze{an_num}.run_button.Value
        return
    end
        
    % Display log
    app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
    pause(0.1); % enough time for the log text area to appear on screen

    do_analyze(app, an_num);

    % Delete log
    delete(app.StartupLogTextArea);
  end
  
    

    



  try
    % Get new selection of plugin
    algo_name = app.analyze{an_num}.AlgorithmDropDown.Value;

    % Delete existing UI components before creating new ones on top
    delete_analyze(app,[an_num]);
    
    % Load parameters of the algorithm plugin
    [params, algorithm] = eval(['definition_' algo_name]);

   % ------------------------- WORK IN PROGRESS HERE -----------------
   % Create subtabs for parameters
   if isfield(params,'sub_tab')
       tmp_params_table= struct2table(params);
       tab_count=1;tab_names=cell(1,1);
       for p = 1:size(tmp_params_table.sub_tab,1)
           tab_names(tab_count,1)=tmp_params_table.sub_tab(p);
           tab_count=tab_count+1;
       end
       tab_names = unique(tab_names(~cellfun('isempty', tab_names)),'stable');
       sub_tbgroup = uitabgroup('parent', app.analyze{an_num}.tab, 'Position',[405 25 390 390]); %[left bottom width height]
       for num_tab = 1:size(tab_names,1)
           uitab('parent', sub_tbgroup, 'Title', char(tab_names(num_tab)));
       end
   end
    % ---------------------- END OF PROGRESS ------------------------
    
    
   % Display GUI component for each parameter to the algorithm
   if isfield(params,'sub_tab')
    v_offset = 365; %[100 332 125 22]
   else
    v_offset = 419;
   end
    prev_tab = 'None';
    for idx=1:length(params)
        
      param = params(idx); 
      
      % Set which tab becomes parent to parameter components
      if isfield(param,'sub_tab')
       sub_tbgroup.SelectedTab = sub_tbgroup.Children(contains(tab_names,param.sub_tab));
       current_tab = sub_tbgroup.SelectedTab;
       
       if current_tab~=prev_tab
           v_offset = 365; %[100 332 125 22] 
       end
       prev_tab = current_tab;
      else
      	current_tab = app.analyze{an_num}.tab;
      end
      
      % Location of GUI component
      if isfield(param,'sub_tab')
          v_offset = v_offset - 33;
      else
          v_offset = v_offset - 33;
      end
      if isfield(param,'sub_tab')
          param_pos = [100 v_offset 125 22]; %[100 332 125 22]
      else
          param_pos = [620 v_offset 125 22];
      end
      if isfield(param,'sub_tab')
          label_pos = [5 v_offset-56 80 70]; %[5 280 80 70]
      else
          label_pos = [400 v_offset-5 200 22];
      end
      
      help_pos = [param_pos(1)+130 param_pos(2)+1 20 20];
      param_index = NaN;

      % Change spacing if optional parameter to allow space for a checkbox
      if isfield(param,'optional') && ~isempty(param.optional)
        param_pos = [param_pos(1)+20 param_pos(2) param_pos(3)-20 param_pos(4)];
      end

      % Correct unavailable user set default value
      if ismember(param.type,{'dropdown','listbox'})
        if ~ismember(param.default, param.options) 
            param.default = param.options{1};
        end
      end
      % Parameter Input Box
      if ismember(param.type,{'numeric','text','dropdown','checkbox','slider','listbox'})
        % Set an index number for this component
        if ~isfield(app.analyze{an_num},'fields')
          app.analyze{an_num}.fields = {};
        end
        
        field_num = length(app.analyze{an_num}.fields) + 1;
        param_index = field_num;
        % Create UI components
        if strcmp(param.type,'numeric')
          app.analyze{an_num}.fields{field_num} = uispinner(current_tab);
          if isfield(param,'limits') & size(param.limits)==[1 2]
            app.analyze{an_num}.fields{field_num}.Limits = param.limits;
          end
          app.analyze{an_num}.fields{field_num}.ValueDisplayFormat = '%g';
        elseif strcmp(param.type,'text')
          app.analyze{an_num}.fields{field_num} = uieditfield(current_tab);
        elseif strcmp(param.type,'dropdown')
          app.analyze{an_num}.fields{field_num} = uidropdown(current_tab);
          app.analyze{an_num}.fields{field_num}.Items = param.options;
        elseif strcmp(param.type,'checkbox')
          app.analyze{an_num}.fields{field_num} = uicheckbox(current_tab);
          app.analyze{an_num}.fields{field_num}.Text = '';
          param_pos = [param_pos(1) param_pos(2)+4 25 15];
        elseif strcmp(param.type,'listbox')
          app.analyze{an_num}.fields{field_num} = uilistbox(current_tab, ...
            'Items', param.options, ...
            'Multiselect', 'on');
          v_offset = v_offset - 34;
          param_pos = [param_pos(1) v_offset param_pos(3) param_pos(4)+34];
        elseif strcmp(param.type,'slider')
          param_pos = [param_pos(1) param_pos(2)+5 param_pos(3) param_pos(4)];
          app.analyze{an_num}.fields{field_num} = uislider(current_tab, ...
            'MajorTicks', [], ...
            'MajorTickLabels', {}, ...
            'MinorTicks', []);
          if isfield(param,'limits') & size(param.limits)==[1 2]
            app.analyze{an_num}.fields{field_num}.Limits = param.limits;
          end
        
        end
        app.analyze{an_num}.fields{field_num}.ValueChangedFcn = createCallbackFcn(app, @do_analyze_, true);
        app.analyze{an_num}.fields{field_num}.Position = param_pos;
        app.analyze{an_num}.fields{field_num}.Value = param.default;
        app.analyze{an_num}.fields{field_num}.UserData.param_idx = idx;
        app.analyze{an_num}.labels{field_num} = uilabel(current_tab);
        app.analyze{an_num}.labels{field_num}.HorizontalAlignment = 'right';
        app.analyze{an_num}.labels{field_num}.Position = label_pos;
        app.analyze{an_num}.labels{field_num}.Text = param.name;
        % Handle if this parameter is optional 
        if isfield(param,'optional') && ~isempty(param.optional)
          app.analyze{an_num}.fields{field_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index);
        end

      % Create analyze selection dropdown box
      elseif strcmp(param.type,'measurement_dropdown')
        % Set an index number for this component
        if ~isfield(app.analyze{an_num},'MeasurementDropDown')
          app.analyze{an_num}.MeasurementDropDown = {};
        end
        drop_num = length(app.analyze{an_num}.MeasurementDropDown) + 1;
        param_index = drop_num;
        % Create UI components
        dropdown = uidropdown(current_tab, ...
          'Position', param_pos, ...
          'ValueChangedFcn', createCallbackFcn(app, @do_analyze_, true), ...
          'Items', {} );
        label = uilabel(current_tab, ...
          'Text', param.name, ...
          'HorizontalAlignment', 'right', ...
          'Position', label_pos);
        % Save ui elements
        app.analyze{an_num}.MeasurementDropDown{drop_num} = dropdown;
        app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData.param_idx = idx;
        app.analyze{an_num}.MeasurementLabel{drop_num} = label;
        % Handle if this parameter is optional 
        if isfield(param,'optional') && ~isempty(param.optional)
          app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index);
        end
    
        
      elseif strcmp(param.type,'ResultTable_Box')
          
%         if contains(param.sub_tab,tab_names)
%         
%            sub_tbgroup.SelectedTab = sub_tbgroup.Children(contains(tab_names,param.sub_tab));
%            current_tab = sub_tbgroup.SelectedTab;
% %             app.analyze{an_num}.sub_tab=current_tab;
%             
% %             current_tab = app.analyze{an_num}.tab.Children(1).Children(1);
%         edit_field = uieditfield('parent',current_tab, ...
%           'Position', [100 332 125 22], ...
%           'ValueChangedFcn', createCallbackFcn(app, @do_analyze_, true), ...
%           'Value', 'ResultTable', ...
%           'BackgroundColor', [1 1 1], ...
%           'Editable', 'off');
%       
%         label = uilabel('parent',current_tab, ...
%           'Text', param.name, ...
%           'HorizontalAlignment', 'right', ...
%           'Position', [5 280 80 70]);
%             
%             
%         end
        
        % Set an index number for this component
        if ~isfield(app.analyze{an_num},'ResultTableBox')
          app.analyze{an_num}.ResultTableBox = {};
        end
        
        drop_num = length(app.analyze{an_num}.ResultTableBox) + 1;
        param_index = drop_num;
        % Create UI components
        edit_field = uieditfield(current_tab, ...
          'Position', param_pos, ...
          'ValueChangedFcn', createCallbackFcn(app, @do_analyze_, true), ...
          'Value', 'ResultTable', ...
          'BackgroundColor', [0.9 0.9 0.9], ...
          'Editable', 'off');
        label = uilabel(current_tab, ...
          'Text', param.name, ...
          'HorizontalAlignment', 'right', ...
          'Position', label_pos);
        % Save ui elements
        app.analyze{an_num}.ResultTableBox{drop_num} = edit_field;
        app.analyze{an_num}.ResultTableBox{drop_num}.UserData.param_idx = idx;
        app.analyze{an_num}.ResultTableLabel{drop_num} = label;
        
        
      elseif strcmp(param.type,'MeasurementListBox')
          % Set an index number for this component
          if ~isfield(app.analyze{an_num},'MeasurementListBox')
              app.analyze{an_num}.MeasurementListBox = {};
          end
          drop_num = length(app.analyze{an_num}.MeasurementListBox) + 1;
          param_index = drop_num;
          % Create GUI Componenets
          listbox = uilistbox(current_tab, ...
              'Position', [param_pos(1) param_pos(2)-34 param_pos(3) param_pos(4)+34], ...
              'ValueChangedFcn', createCallbackFcn(app, @do_analyze_, true), ...
              'Items', {}, ...
              'Multiselect', 'on');
          label = uilabel(current_tab, ...
              'Text', param.name, ...
              'HorizontalAlignment', 'right', ...
              'Position', label_pos);
          v_offset = v_offset - 34;
          param_pos = [param_pos(1) v_offset param_pos(3) param_pos(4)+34];
          % Save ui elements
          app.analyze{an_num}.MeasurementListBox{drop_num} = listbox;
          app.analyze{an_num}.MeasurementListBox{drop_num}.UserData.param_idx = idx;
          app.analyze{an_num}.MeasurementListLabel{drop_num} = label;
          if isfield(param,'optional') && ~isempty(param.optional)
            app.analyze{an_num}.MeasurementListLabel{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index);
          end
          
   
      else
        msg = sprintf('Unkown parameter type with name "%s" and type "%s". See file "definition_%s.m" and correct this issue.',param.name, param.type,algo_name);
        uialert(app.UIFigure,msg,'Known Parameter Type', 'Icon','error');
        error(msg);
      end

      % Question mark help button
      if isfield(param,'help') && ~isempty(param.help)
        userdata.help_text = param.help;
        userdata.param_name = param.name;
        if ~isfield(app.analyze{an_num},'HelpButton')
          app.analyze{an_num}.HelpButton = {};
        end
        help_num = length(app.analyze{an_num}.HelpButton) + 1;
        app.analyze{an_num}.HelpButton{help_num} = uibutton(current_tab, ...
        'Text', '', ... 
        'Icon', 'question-sign.png', ...
        'BackgroundColor', [0.5 0.5 0.5], ...
        'UserData', userdata, ...
        'ButtonPushedFcn', {@Help_Callback, app}, ...  
        'Position', help_pos);
      end
    end

    % Example image
    if isfield(algorithm,'image')
      app.analyze{an_num}.ExampleImage = uibutton(app.analyze{an_num}.tab, ...
        'Text', '', ...
        'Icon', algorithm.image, ...
        'BackgroundColor', [1 1 1 ], ...
        'Position', [50,105,350,235]);
      help_box_pos = [50,24,350,80];
      help_text_pos = [0,0,350,61];
    else
      help_box_pos = [50,60,350,280];
      help_text_pos = [0,0,350,261];
    end
    

    % Display help information for this algorithm in the GUI
    app.analyze{an_num}.DocumentationBox = uipanel(app.analyze{an_num}.tab, ...
      'Title',['Plugin Documentation '], ...
      'Position',help_box_pos, 'FontSize', 12, 'FontName', 'Yu Gothic UI');
    help_text = uitextarea(app.analyze{an_num}.DocumentationBox,'Value',algorithm.help, 'Position',help_text_pos,'Editable','off');

    % Update list of measurements in the analyze tab
    changed_MeasurementNames(app);

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end
