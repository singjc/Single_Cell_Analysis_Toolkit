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
        elseif strcmp(param.type,'segment_dropdown')
            app.analyze{an_num}.SegmentDropDown{param_index}.Enable = val;
        elseif strcmp(param.type,'image_channel_dropdown')
            app.analyze{an_num}.ChannelDropDown{param_index}.Enable = val;
        elseif strcmp(param.type,'WellConditionListBox')
            app.analyze{an_num}.WellConditionListBox{param_index}.Enable = val;
        elseif strcmp(param.type,'static_Text')
            app.analyze{an_num}.static_Text{param_index}.Enable = val;
        end
        do_analyze_(app,'Update');
    end

    function Help_Callback(uiElem, Update, app)
        help_text = uiElem.UserData.help_text;
        param_name = uiElem.UserData.param_name;
        uialert(app.UIFigure,help_text,param_name, 'Icon','info');
    end

    function checkbox = MakeOptionalCheckbox(app, an_num, param, param_index, current_tab)
        if isfield(params,'sub_tab')
            check_pos = [param_pos(1)-30 param_pos(2)+4 25 15];
        else
            check_pos = [param_pos(1)-20 param_pos(2)+4 25 15];
        end
        
        userdata = {}; % context to pass to callback
        userdata.an_num = an_num;
        userdata.param = param;
        userdata.param_index = param_index;
        default_state = true;
        default_enable = 'on';
        if isfield(param,'optional_default_state') && isequal(param.optional_default_state,false)
            default_state = false;
            default_enable = 'off';
        end
        checkbox = uicheckbox('parent',current_tab, ...
            'Position', check_pos, ...
            'Value', default_state, ...
            'Text', '', ...
            'UserData', userdata, ...
            'ValueChangedFcn', {@ParamOptionalCheckBoxCallback, app});
        if ismember(param.type,{'numeric','text','dropdown'})
            app.analyze{an_num}.fields{param_index}.Enable = default_enable;
        elseif strcmp(param.type,'analyze_dropdown')
            app.analyze{an_num}.MeasurementDropDown{param_index}.Enable = default_enable;
        elseif strcmp(param.type,'segment_dropdown')
            app.analyze{an_num}.SegmentDropDown{param_index}.Enable = default_enable;
        elseif strcmp(param.type,'image_channel_dropdown')
            app.analyze{an_num}.ChannelDropDown{param_index}.Enable = default_enable;
        elseif strcmp(param.type,'WellConditionListBox')
            app.analyze{an_num}.WellConditionListBox{param_index}.Enable = default_enable;
        elseif strcmp(param.type, 'static_Text')
            app.analyze{an_num}.static_Text{param_index}.Enable = default_enable;
        end
    end

% Callback for when parameter value is changed by the user
    function do_analyze_(app, Update)
        if ~app.analyze{an_num}.run_button.Value
            return
        end
        
        % Display log
%         app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
%     app.StartupLogTextArea = txt_update;
%         pause(0.1); % enough time for the log text area to appear on screen
        
        do_analyze(app, an_num);

        % Delete log
%         delete(app.StartupLogTextArea);
% 	app.StartupLogTextArea.tx.String = {};
    end

try
    % Get new selection of plugin
    algo_name = app.analyze{an_num}.AlgorithmDropDown.Value;
    
    % Delete existing UI components before creating new ones on top
    delete_analyze(app,[an_num]);
    
    % Load parameters of the algorithm plugin
    [params, algorithm] = eval(['definition_' algo_name]);
    % Re-initialize paramater info and algorithm info for current algorithm plugin.
    app.analyze{an_num}.params = params;
    app.analyze{an_num}.algorithm_info = algorithm;
    if ~isfield(app.analyze{an_num}.algorithm_info,'maintainer')
      app.analyze{an_num}.algorithm_info.maintainer = 'Unknown';
    end
    if ~isfield(app.analyze{an_num}.algorithm_info,'supports_3D')
      app.analyze{an_num}.algorithm_info.supports_3D = false; % TODO: sanity check that user provided true or false
    end

    % Create subtabs for parameters
    if isfield(params,'sub_tab')
        tmp_params_table= struct2table(params);
        tab_count=1;tab_names=cell(1,1);
        for p = 1:size(tmp_params_table.sub_tab,1)
            tab_names(tab_count,1)=tmp_params_table.sub_tab(p);
            tab_count=tab_count+1;
        end
        tab_names = unique(tab_names(~cellfun('isempty', tab_names)),'stable');
        sub_tbgroup = uitabgroup('parent', app.analyze{an_num}.tab, 'Position',[405 20 390 400]); %[left bottom width height]
        for num_tab = 1:size(tab_names,1)
            newtab = uitab('parent', sub_tbgroup, 'Title', char(tab_names(num_tab)));
            newtab.BackgroundColor = rand(1,3);
            newtab.ForegroundColor = rand(1, 3);
        end
        app.analyze{an_num}.sub_tab = sub_tbgroup;
    else
        app.analyze{an_num}.sub_tab = 'None';
    end
    
    
    % Display GUI component for each parameter to the algorithm
    if isfield(params,'sub_tab')
        v_offset = 375; %[100 332 125 22]
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
                v_offset = 375; %[100 332 125 22]
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
            param_pos = [200 v_offset 125 22]; %[100 332 125 22]
        else
            param_pos = [620 v_offset 125 22];
        end
        if isfield(param,'sub_tab')
            label_pos = [-50 v_offset-25 200 70]; %[5 280 80 70] old: [-20 v_offset-52 200 70]
        else
            label_pos = [400 v_offset 200 22];
        end
        
        help_pos = [param_pos(1)+130 param_pos(2)+1 20 20];
        param_index = NaN;
        
        % Change spacing if optional parameter to allow space for a checkbox
        if isfield(param,'optional') && ~isempty(param.optional)
            if isfield(param,'sub_tab')
                param_pos = [param_pos(1)+20 param_pos(2) param_pos(3)-20 param_pos(4)];
            else
                param_pos = [param_pos(1)+20 param_pos(2) param_pos(3)-20 param_pos(4)];
            end
        end
        
        % Correct unavailable user set default value
        if ismember(param.type,{'dropdown','listbox'})
            if ~ismember(param.default, param.options)
                param.default = param.options{1};
            end
        end
        % Parameter Input Box
        if ismember(param.type,{'numeric','text','dropdown','checkbox','slider','listbox','operate_on'})
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
            elseif strcmp(param.type,'operate_on')
                app.analyze{an_num}.fields{field_num} = uidropdown(current_tab);
                app.analyze{an_num}.fields{field_num}.Items = param.options;
                app.analyze{an_num}.fields{field_num}.UserData.operate_on = true; % set this special flag
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
                if isfield(param,'sub_tab')
                    app.analyze{an_num}.fields{field_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index,current_tab);
                else
                    app.analyze{an_num}.fields{field_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index,current_tab);
                end
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
                app.analyze{an_num}.MeasurementDropDown{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index,current_tab);
            end
            
        % Create segment selection dropdown box
        elseif strcmp(param.type,'segment_dropdown')
          % Set an index number for this component
          if ~isfield(app.analyze{an_num},'SegmentDropDown')
            app.analyze{an_num}.SegmentDropDown = {};
          end
          drop_num = length(app.analyze{an_num}.SegmentDropDown) + 1;
          param_index = drop_num;
          % Create UI components
          dropdown = uidropdown(app.analyze{an_num}.tab, ...
            'Position', param_pos, ...
            'ValueChangedFcn', createCallbackFcn(app, @do_analyze_, true), ...
            'Items', {} );
          label = uilabel(app.analyze{an_num}.tab, ...
            'Text', param.name, ...
            'HorizontalAlignment', 'right', ...
            'Position', label_pos);
          % Save ui elements
          app.analyze{an_num}.SegmentDropDown{drop_num} = dropdown;
          app.analyze{an_num}.SegmentDropDown{drop_num}.UserData.param_idx = idx;
          app.analyze{an_num}.SegmentDropDownLabel{drop_num} = label;
          % Handle if this parameter is optional 
          if isfield(param,'optional') && ~isempty(param.optional)
            app.analyze{an_num}.SegmentDropDown{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index);
          end

        % Create image selection dropdown box
        elseif strcmp(param.type,'image_channel_dropdown')
            % Set an index number for this component
            if ~isfield(app.analyze{an_num},'ChannelDropDown')
                app.analyze{an_num}.ChannelDropDown = {};
            end
            drop_num = length(app.analyze{an_num}.ChannelDropDown) + 1;
            param_index = drop_num;
            % Get channel names based on the currently displaying plate
            plate_num = app.PlateDropDown.Value;
            if ~isnumeric(app.PlateDropDown.Value)
                plate_num=1; % bad startup value
            end
            chan_names = app.plates(plate_num).chan_names;
            chan_nums = app.plates(plate_num).channels;
            % Create UI components
            dropdown = uidropdown(current_tab, ...
                'Position', param_pos, ...
                'ValueChangedFcn', createCallbackFcn(app, @do_analyze_, true), ...
                'Items', chan_names, ...
                'ItemsData', chan_nums );
            label = uilabel(current_tab, ...
                'Text', param.name, ...
                'HorizontalAlignment', 'right', ...
                'Position', label_pos);
            % Save ui elements
            app.analyze{an_num}.ChannelDropDown{drop_num} = dropdown;
            app.analyze{an_num}.ChannelDropDown{drop_num}.UserData.param_idx = idx;
            app.analyze{an_num}.ChannelDropDown{param_index}.UserData.chan_names = chan_names;
            app.analyze{an_num}.ChannelDropDownLabel{drop_num} = label;
            % Handle if this parameter is optional
            if isfield(param,'optional') && ~isempty(param.optional)
                app.analyze{an_num}.ChannelDropDown{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index,current_tab);
            end
            
        elseif strcmp(param.type,'ResultTable_Box')
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
        
        % Static Text-Box
        elseif strcmp(param.type,'static_Text')
            % Set an index number for this component
            if ~isfield(app.analyze{an_num},'static_Text')
                app.analyze{an_num}.static_Text = {};
            end
            
            drop_num = length(app.analyze{an_num}.static_Text) + 1;
            param_index = drop_num;
            % Create UI components
            edit_field = uieditfield(current_tab, ...
                'Position', param_pos, ...
                'ValueChangedFcn', createCallbackFcn(app, @do_analyze_, true), ...
                'Value', param.default, ...
                'BackgroundColor', [0.9 0.9 0.9], ...
                'Editable', 'off');
            label = uilabel(current_tab, ...
                'Text', param.name, ...
                'HorizontalAlignment', 'right', ...
                'Position', label_pos);
            % Save ui elements
            app.analyze{an_num}.static_Text{drop_num} = edit_field;
            app.analyze{an_num}.static_Text{drop_num}.UserData.param_idx = idx;
            app.analyze{an_num}.static_TextLabel{drop_num} = label;     
            
            if isfield(param,'optional') && ~isempty(param.optional)
                app.analyze{an_num}.static_Text{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index,current_tab);
            end
            
        elseif strcmp(param.type,'ResultTable_for_current_display')
            
            % Set an index number for this component
            if ~isfield(app.analyze{an_num},'ResultTableDisp')
                app.analyze{an_num}.ResultTableDisp = {};
            end
            
            drop_num = length(app.analyze{an_num}.ResultTableDisp) + 1;
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
            app.analyze{an_num}.ResultTableDisp{drop_num} = edit_field;
            app.analyze{an_num}.ResultTableDisp{drop_num}.UserData.param_idx = idx;
            app.analyze{an_num}.ResultTableDispLabel{drop_num} = label;            
            
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
                app.analyze{an_num}.MeasurementListBox{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index,current_tab);
            end
            
        elseif strcmp(param.type,'WellConditionListBox')
            % Set an index number for this component
            if ~isfield(app.analyze{an_num},'WellConditionListBox')
                app.analyze{an_num}.WellConditionListBox = {};
            end
            drop_num = length(app.analyze{an_num}.WellConditionListBox) + 1;
            param_index = drop_num;
            % Create GUI Componenets
            listbox = uilistbox(current_tab, ...
                'Position', [param_pos(1)-70 param_pos(2)-90 param_pos(3)+70 param_pos(4)+90], ...
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
            app.analyze{an_num}.WellConditionListBox{drop_num} = listbox;
            app.analyze{an_num}.WellConditionListBox{drop_num}.UserData.param_idx = idx;
            app.analyze{an_num}.WellConditionListLabel{drop_num} = label;
            if isfield(param,'optional') && ~isempty(param.optional)
                app.analyze{an_num}.WellConditionListBox{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index,current_tab);
            end
            
            % uitable
        elseif strcmp(param.type,'InputUITable')
            % Set an index number for this component
            if ~isfield(app.analyze{an_num},'InputUITable')
                app.analyze{an_num}.InputUITable = {};
            end
            drop_num = length(app.analyze{an_num}.InputUITable) + 1;
            param_index = drop_num;
            % Create GUI Componenets
            emptyRow = cell(7,2);
            tableData = emptyRow;
            table = uitable(current_tab, ...
                'Position', [param_pos(1)-185 param_pos(2)-90 param_pos(3)+180 param_pos(4)+90], ...
                'ColumnName',{'Path' 'TimePoint'},... 
                'ColumnFormat',({[] []}),... 
                'ColumnEditable', true,...
                'Data',tableData,...
                'CellEditCallBack',createCallbackFcn(app, @do_analyze_, true));
            label = uilabel(current_tab, ...
                'Text', param.name, ...
                'HorizontalAlignment', 'right', ...
                'Position', label_pos);
            v_offset = v_offset - 34;
            param_pos = [param_pos(1) v_offset param_pos(3) param_pos(4)+34];
            % Save ui elements
            app.analyze{an_num}.InputUITable{drop_num} = table;
            app.analyze{an_num}.InputUITable{drop_num}.UserData.param_idx = idx;
            app.analyze{an_num}.InputUITableLabel{drop_num} = label;
            if isfield(param,'optional') && ~isempty(param.optional)
                app.analyze{an_num}.InputUITable{drop_num}.UserData.ParamOptionalCheck = MakeOptionalCheckbox(app, an_num, param, param_index,current_tab);
            end
            
        else
            msg = sprintf('Unkown parameter type with name "%s" and type "%s". See file "definition_%s.m" and correct this issue.',param.name, param.type,algo_name);
            title_ = 'Plugin Error - Unknown Parameter Type';
            throw_application_error(app,msg,title_);
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

    % Fill in the names of segments across the GUI including here
    changed_SegmentName(app);
    
    % Catch Application Error
catch ME
    handle_application_error(app,ME);
end

end
