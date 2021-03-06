function fun(app, createCallbackFcn, plugin_identifier)

  function Delete_Callback(app, event)
    if an_num < length(app.analyze)
      uialert(app.UIFigure,'Sorry, there is a bug which prevents you from deleting a Analysis which is not the last one.','Sorry', 'Icon','warn');
      return
    end
    delete_analyze(app, an_num);
    app.analyze(an_num) = [];
    delete(tab);
    if length(app.analyze) == 0
      delete(app.analyze_tabgp);
      app.analyze_tabgp = [];
      app.Button_RunAllAnalysis.Visible = 'off';
    end
  end
    
  function changed_AnalyzeName(app, event)
    if strcmp(app.analyze{an_num}.Name.Value,'')
      app.analyze{an_num}.tab.Title = sprintf('Analysis %i', an_num);
    else
      app.analyze{an_num}.tab.Title = sprintf('Analysis %i: %s', an_num, app.analyze{an_num}.Name.Value);
    end
  end
    

  function Play_Callback(app,event)
    if app.analyze{an_num}.run_button.Value
      do_analyze(app, an_num);
    end
  end

  try
    plate_num = app.PlateDropDown.Value;
    plugin_definitions = dir('./plugins/analyze/**/definition*.m');
    % save('analyze_plugins.mat','plugin_definitions');
    if isempty(plugin_definitions)
        load('analyze_plugins.mat');
    end
    plugin_names = {};
    plugin_pretty_names = {};
    for plugin_num = 1:length(plugin_definitions)
      plugin = plugin_definitions(plugin_num);
      plugin_name = plugin.name(1:end-2);
      [params, algorithm] = eval(plugin_name);
%       if ~app.plates(plate_num).supports_3D && isfield(algorithm,'supports_3D') && algorithm.supports_3D
%         continue % unsupported plugin due to it having 3D support
%       end
      available_plugins.(plugin_name){1,1} = params;
      available_plugins.(plugin_name){1,2} = algorithm;
      plugin_name = strsplit(plugin_name,'definition_');
      plugin_names{length(plugin_names)+1} = plugin_name{2};
      plugin_pretty_names{length(plugin_pretty_names)+1} = algorithm.name;
    end

    if isempty(plugin_names)
      msg = 'Sorry, no analze plugins found.';
      if app.plates(plate_num).supports_3D
        msg = sprintf('%s There may be no plugins installed for 3D images.',msg)
      end
      uialert(app.UIFigure,msg,'No Plugins', 'Icon','warn');
      return
    end

    % Setup
    if isempty(app.analyze_tabgp)
      app.analyze_tabgp = uitabgroup(app.Tab_Analyze,'Position',[17,20,803,496]);
    end
    tabgp = app.analyze_tabgp;
    an_num = length(tabgp.Children)+1;
    app.analyze{an_num} = {};
        app.analyze{an_num}.params = params;
    app.analyze{an_num}.algorithm_info = algorithm;

    app.Button_RunAllAnalysis.Visible = 'on';

    % Create new tab
    tab = uitab(tabgp,'Title',sprintf('Analyze %i',an_num), ...
      'BackgroundColor', [1 1 1]);
    app.analyze{an_num}.tab = tab;

    v_offset = 385;

    % Analyze name edit field
    app.analyze{an_num}.Name = uieditfield(tab, ...
      'Value', '', ...
      'ValueChangedFcn', createCallbackFcn(app, @changed_AnalyzeName, true), ...
      'Position', [162,v_offset,200,22]);
    label = uilabel(tab, ...
      'Text', 'Analyze Name', ...
      'Position', [57,v_offset+5,90,15]);
    v_offset = v_offset - 33;

    % Create algorithm selection dropdown box
    Callback = @(app, event) changed_AnalyzePlugin(app, an_num, createCallbackFcn);
    app.analyze{an_num}.AlgorithmDropDown = uidropdown(tab, ...
      'Items', plugin_pretty_names, ...
      'ItemsData', plugin_names, ...
      'ValueChangedFcn', createCallbackFcn(app, Callback, true), ...
      'Position', [162,v_offset,200,22]);
    label = uilabel(tab, ...
      'Text', 'Algorithm', ...
      'Position', [90,v_offset+5,57,15]);
    v_offset = v_offset - 33;

    % Create Titles
    label = uilabel(tab, ...
      'Text', 'Details', ...
      'FontName', 'Yu Gothic UI Light', ...
      'FontSize', 28, ...
      'Position', [70,421,218,41]);
    label = uilabel(tab, ...
      'Text', 'Parameters', ...
      'FontName', 'Yu Gothic UI Light', ...
      'FontSize', 28, ...
      'Position', [480,421,218,41]);

    % Delete button
    delete_button = uibutton(tab, ...
      'Text', [app.Delete_Unicode.Text ''], ...
      'BackgroundColor', [.95 .95 .95], ...
      'ButtonPushedFcn', createCallbackFcn(app, @Delete_Callback, true), ...
      'Position', [369,385,26,23]);
    
    % Run button
    app.analyze{an_num}.run_button = uibutton(tab, 'state', ...
      'Text','',...
      'Icon', 'play-button.png', ...
      'Value',0,...
      'BackgroundColor', [.95 .95 .95], ...
      'ValueChangedFcn', createCallbackFcn(app, @Play_Callback, true), ...
      'Position', [369,352,26,23]);

    %% Set a display color to see in the figure
    app.analyze{an_num}.display_color = [];

    %% Initialize display check box for this channel
    plate_num = app.PlateDropDown.Value; % Currently selected plate number
    
    % Switch to new tab
    app.analyze_tabgp.SelectedTab = app.analyze{an_num}.tab;

    % Set the current algorithm if directed to
    if exist('plugin_identifier')
      % Sanity Check that plugin name exists
      index = find(strcmp(app.analyze{an_num}.AlgorithmDropDown.Items,plugin_identifier));
      if isempty(index)
        msg = sprintf('An incorrect analysis algorithm name "%s" has been specified. Please double check the spelling and check what plugin names are available.',plugin_identifier);
        title_ = 'User Error - Incorrect Plugin Name';
        throw_application_error(app,msg,title_)
      end
      % Set plugin name
      algo_name = app.analyze{an_num}.AlgorithmDropDown.ItemsData{index};
      app.analyze{an_num}.AlgorithmDropDown.Value = algo_name;
    end

    % Populate GUI components in new tab
    app.analyze{an_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update');

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end