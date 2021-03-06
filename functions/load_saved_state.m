function fun(app,saved_app,createCallbackFcn)
  % Display Tab
  app.PlateDropDown.Items = saved_app.PlateDropDown.Items;
  app.PlateDropDown.ItemsData = saved_app.PlateDropDown.ItemsData;
  app.PlateDropDown.Value = saved_app.PlateDropDown.Value;
  
  % Input Tab
  filter_names = { ...
    'rows', ...
    'columns', ...
    'fields', ...
    'timepoints' ...
  };
  for plate_num = 1:length(app.plates)
    app.plates(plate_num).checkbox.Value = saved_app.plates(plate_num).checkbox.Value;
    for filt_num = 1:length(filter_names)
      filter_name = filter_names{filt_num};
      app.plates(plate_num).(['filter_' filter_name]).Value = saved_app.plates(plate_num).(['filter_' filter_name]).Value;
    end
    changed_FilterInput(app,plate_num);
  end
  changed_EnabledPlates(app);

  % Preprocess Tab
  component_names = { ...
    'fields', ...
    'labels', ...
  };
  for proc_num=1:length(saved_app.preprocess)
    add_preprocess(app,createCallbackFcn);

    app.preprocess{proc_num}.AlgorithmDropDown.Value = saved_app.preprocess{proc_num}.AlgorithmDropDown.Value;
    app.preprocess{proc_num}.ChannelDropDown.Value = saved_app.preprocess{proc_num}.ChannelDropDown.Value;
    app.preprocess{proc_num}.Name.Value = saved_app.preprocess{proc_num}.Name.Value;
    app.preprocess{proc_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update'); % update dynamic param uielems to match the algo name's definition 

    for cid=1:length(component_names) % loop over known ui component types that the app awknowleges
      comp_name = component_names{cid}; % get known ui component type name
      if isfield(app.preprocess{proc_num},comp_name) % only if it exists
        for idx=1:length(app.preprocess{proc_num}.(comp_name)) % loop over each item of this type
          if isfield(saved_app.preprocess{proc_num}.(comp_name){idx}.UserData,'ParamOptionalCheck')
            app.preprocess{proc_num}.(comp_name){idx}.UserData.ParamOptionalCheck.Value = saved_app.preprocess{proc_num}.(comp_name){idx}.UserData.ParamOptionalCheck.Value;
          end
          field_names = fieldnames(app.preprocess{proc_num}.(comp_name){idx}); % get all the value field names on this ui element
          for field_name=field_names' % loop over each field on this ui element, setting the app's value using the saved value
            if ismember(field_name,{'BeingDeleted', 'Type', 'OuterPosition','Parent','ValueChangedFcn','HandleVisibility', 'BusyAction', 'Interruptible', 'CreateFcn', 'DeleteFcn'})
              continue % skip blacklisted property names that are known to be readonly
            end
            % Handle UserData specially 
            if ismember(field_name,{'UserData'}) && isstruct(app.preprocess{proc_num}.(comp_name){idx}.UserData) % only if UserData is a struct 
              data_fields = fieldnames(app.preprocess{proc_num}.(comp_name){idx}.UserData);
              for data_field_name=data_fields' % Loop over UserData fields copying them one by one except for the optional checkbox
                if ismember(data_field_name,{'ParamOptionalCheck'})
                    continue % skip blacklisted property
                end
                app.preprocess{proc_num}.(comp_name){idx}.UserData.(data_field_name{:}) = saved_app.preprocess{proc_num}.(comp_name){idx}.UserData.(data_field_name{:}); % set saved value
              end
              continue % Skip to next because UserData has now been handled
            end
            try
              % Place the saved value into the app
              app.preprocess{proc_num}.(comp_name){idx}.(string(field_name)) = saved_app.preprocess{proc_num}.(comp_name){idx}.(string(field_name));
            catch ME
              if strfind(ME.message,'You cannot set the read-only property')
                warning(ME.message); % only warn if a read-only error ocures
                continue
              end
            end
          end
        end
      end
    end
  end

  % Segment Tab
  component_names = { ...
    'fields', ...
    'labels', ...
    'SegmentDropDown', ...
    'SegmentDropDownLabel', ...
    'ChannelDropDown', ...
    'ChannelDropDownLabel', ...
  };
  for seg_num=1:length(saved_app.segment)
    add_segment(app,createCallbackFcn);

    app.segment{seg_num}.AlgorithmDropDown.Value = saved_app.segment{seg_num}.AlgorithmDropDown.Value;
    app.segment{seg_num}.Name.Value = saved_app.segment{seg_num}.Name.Value;
    app.segment{seg_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update'); % update dynamic param uielems to match the algo name's definition 

    for cid=1:length(component_names) % loop over known ui component types that the app awknowleges
      comp_name = component_names{cid}; % get known ui component type name
      if isfield(app.segment{seg_num},comp_name) % only if it exists
        for idx=1:length(app.segment{seg_num}.(comp_name)) % loop over each item of this type
          if isfield(saved_app.segment{seg_num}.(comp_name){idx}.UserData,'ParamOptionalCheck')
            app.segment{seg_num}.(comp_name){idx}.UserData.ParamOptionalCheck.Value = saved_app.segment{seg_num}.(comp_name){idx}.UserData.ParamOptionalCheck.Value;
          end
          field_names = fieldnames(app.segment{seg_num}.(comp_name){idx}); % get all the value field names on this ui element
          for field_name=field_names' % loop over each field on this ui element, setting the app's value using the saved value
            if ismember(field_name,{'BeingDeleted', 'Type', 'OuterPosition','Parent','ValueChangedFcn','HandleVisibility', 'BusyAction', 'Interruptible', 'CreateFcn', 'DeleteFcn'})
              continue % skip blacklisted property names that are known to be readonly
            end
            % Handle UserData specially 
            if ismember(field_name,{'UserData'}) && isstruct(app.segment{seg_num}.(comp_name){idx}.UserData) % only if UserData is a struct 
              data_fields = fieldnames(app.segment{seg_num}.(comp_name){idx}.UserData);
              for data_field_name=data_fields' % Loop over UserData fields copying them one by one except for the optional checkbox
                if ismember(data_field_name,{'ParamOptionalCheck'})
                    continue % skip blacklisted property
                end
                app.segment{seg_num}.(comp_name){idx}.UserData.(data_field_name{:}) = saved_app.segment{seg_num}.(comp_name){idx}.UserData.(data_field_name{:}); % set saved value
              end
              continue % Skip to next because UserData has now been handled
            end
            % Place the saved value into the app
            try
              app.segment{seg_num}.(comp_name){idx}.(string(field_name)) = saved_app.segment{seg_num}.(comp_name){idx}.(string(field_name)); % set saved value
            catch ME
              if strfind(ME.message,'You cannot set the read-only property')
                warning(ME.message); % only warn if a read-only error ocures
                continue
              end
            end
          end
        end
      end
    end
  end

  % Measure Tab
  app.PrimarySegmentDropDown.Items = saved_app.PrimarySegmentDropDown.Items;
  app.PrimarySegmentDropDown.ItemsData = saved_app.PrimarySegmentDropDown.ItemsData;
  app.PrimarySegmentDropDown.Value = saved_app.PrimarySegmentDropDown.Value;
  component_names = { ...
    'fields', ...
    'labels', ...
    'ChannelDropDown', ...
    'ChannelDropDownLabel', ...
    'ChannelListbox', ...
    'ChannelListboxLabel', ...
    'SegmentListbox', ...
    'SegmentListboxLabel', ...
  };
  for meas_num=1:length(saved_app.measure)
    add_measure(app,createCallbackFcn);

    app.measure{meas_num}.AlgorithmDropDown.Value = saved_app.measure{meas_num}.AlgorithmDropDown.Value;
    app.measure{meas_num}.Name.Value = saved_app.measure{meas_num}.Name.Value;
    app.measure{meas_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update'); % update dynamic param uielems to match the algo name's definition 

    for cid=1:length(component_names) % loop over known ui component types that the app awknowleges
      comp_name = component_names{cid}; % get known ui component type name
      if isfield(app.measure{meas_num},comp_name) % only if it exists
        for idx=1:length(app.measure{meas_num}.(comp_name)) % loop over each item of this type
          if isfield(saved_app.measure{meas_num}.(comp_name){idx}.UserData,'ParamOptionalCheck')
            app.measure{meas_num}.(comp_name){idx}.UserData.ParamOptionalCheck.Value = saved_app.measure{meas_num}.(comp_name){idx}.UserData.ParamOptionalCheck.Value;
          end
          field_names = fieldnames(app.measure{meas_num}.(comp_name){idx}); % get all the value field names on this ui element
          for field_name=field_names' % loop over each field on this ui element, setting the app's value using the saved value
            if ismember(field_name,{'BeingDeleted', 'Type', 'OuterPosition','Parent','ValueChangedFcn','HandleVisibility', 'BusyAction', 'Interruptible', 'CreateFcn', 'DeleteFcn'})
              continue % skip blacklisted property names that are known to be readonly
            end
            % Handle UserData specially 
            if ismember(field_name,{'UserData'}) && isstruct(app.measure{meas_num}.(comp_name){idx}.UserData) % only if UserData is a struct 
              data_fields = fieldnames(app.measure{meas_num}.(comp_name){idx}.UserData);
              for data_field_name=data_fields' % Loop over UserData fields copying them one by one except for the optional checkbox
                if ismember(data_field_name,{'ParamOptionalCheck'})
                    continue % skip blacklisted property
                end
                app.measure{meas_num}.(comp_name){idx}.UserData.(data_field_name{:}) = saved_app.measure{meas_num}.(comp_name){idx}.UserData.(data_field_name{:}); % set saved value
              end
              continue % Skip to next because UserData has now been handled
            end
            try
              % Place the saved value into the app
              app.measure{meas_num}.(comp_name){idx}.(string(field_name)) = saved_app.measure{meas_num}.(comp_name){idx}.(string(field_name));
            catch ME
              if strfind(ME.message,'You cannot set the read-only property')
                warning(ME.message); % only warn if a read-only error ocures
                continue
              end
            end
          end
        end
      end
    end
  end

  % Analyze Tab
  component_names = { ...
    'fields', ...
    'labels', ...
    'MeasurementDropDown', ...
    'MeasurementLabel', ...
    'ParamOptionalCheck', ...
  };
  for an_num=1:length(saved_app.analyze)
    add_analyze(app,createCallbackFcn);

    app.analyze{an_num}.AlgorithmDropDown.Value = saved_app.analyze{an_num}.AlgorithmDropDown.Value;
    app.analyze{an_num}.Name.Value = saved_app.analyze{an_num}.Name.Value;
    app.analyze{an_num}.AlgorithmDropDown.ValueChangedFcn(app, 'Update'); % update dynamic param uielems to match the algo name's definition 

    for cid=1:length(component_names) % loop over known ui component types that the app awknowleges
      comp_name = component_names{cid}; % get known ui component type name
      if isfield(app.analyze{an_num},comp_name) % only if it exists
        for idx=1:length(app.analyze{an_num}.(comp_name)) % loop over each item of this type
          if isfield(saved_app.analyze{an_num}.(comp_name){idx}.UserData,'ParamOptionalCheck')
            app.analyze{an_num}.(comp_name){idx}.UserData.ParamOptionalCheck.Value = saved_app.analyze{an_num}.(comp_name){idx}.UserData.ParamOptionalCheck.Value;
          end
          field_names = fieldnames(app.analyze{an_num}.(comp_name){idx}); % get all the value field names on this ui element
          for field_name=field_names' % loop over each field on this ui element, setting the app's value using the saved value
            if ismember(field_name,{'BeingDeleted', 'Type', 'OuterPosition','Parent','ValueChangedFcn','HandleVisibility', 'BusyAction', 'Interruptible', 'CreateFcn', 'DeleteFcn'})
              continue % skip blacklisted property names that are known to be readonly
            end
            % Handle UserData specially 
            if ismember(field_name,{'UserData'}) && isstruct(app.analyze{an_num}.(comp_name){idx}.UserData) % only if UserData is a struct 
              data_fields = fieldnames(app.analyze{an_num}.(comp_name){idx}.UserData);
              for data_field_name=data_fields' % Loop over UserData fields copying them one by one except for the optional checkbox
                if ismember(data_field_name,{'ParamOptionalCheck'})
                    continue % skip blacklisted property
                end
                app.analyze{an_num}.(comp_name){idx}.UserData.(data_field_name{:}) = saved_app.analyze{an_num}.(comp_name){idx}.UserData.(data_field_name{:}); % set saved value
              end
              continue % Skip to next because UserData has now been handled
            end
            try
              % Place the saved value into the app
              app.analyze{an_num}.(comp_name){idx}.(string(field_name)) = saved_app.analyze{an_num}.(comp_name){idx}.(string(field_name));
            catch ME
              if strfind(ME.message,'You cannot set the read-only property')
                warning(ME.message); % only warn if a read-only error ocures
                continue
              end
            end
          end
        end
      end
    end
  end

  %% ResultTable
  if any(ismember(fields(saved_app),'ResultTable')) && istable(saved_app.ResultTable)
    app.ResultTable = saved_app.ResultTable;
    app.Button_ViewMeasurements.Visible = 'on';
    app.Button_ExportMeasurements.Visible = 'on';
  end

  %% ResultTable_for_display
  if any(ismember(fields(saved_app),'ResultTable_for_display')) && istable(saved_app.ResultTable_for_display)
    app.ResultTable_for_display = saved_app.ResultTable_for_display;
  end

end