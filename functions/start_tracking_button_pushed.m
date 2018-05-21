function fun(app)
  if ~istable(app.ResultTable) || isempty(app.ResultTable)
    uialert(app.UIFigure,'You must collect measurements before tracking. See the "Measure" tab.','No Measurements', 'Icon','warn');
    return
  end
  if isempty(app.TrackMeasuresListBox.Value)
    uialert(app.UIFigure,'You must choose measurements before tracking. See the "Choose Measurements" box.','No Measurements Selected', 'Icon','warn');
    return
  end

  % Display log
%   app.StartupLogTextArea = uitextarea(app.UIFigure,'Position', [127,650,728,105]);
% app.StartupLogTextArea = txt_update;
%   pause(0.1); % enough time for the log text area to appear on screen

  busy_state_change(app,'busy');
  app.log_processing_message(app, 'Starting tracking...');

  %% METRIC WEIGHTS
  % Importance of each metric for when calculating composite distances.
  % Higher value is more important.
  % Metrics that don't have a weight setting will be ignored.
  weights = {};
%   for meas_name = app.TrackMeasuresListBox.Value
%     meas_name = meas_name{:};
%     weights.(meas_name) = 1;
%   end
  meas_name = app.TrackMeasuresListBox.Value;
  weights.(meas_name) = 1; % Only one weight limitation
  CentroidName = meas_name; % Only one weight limitation

  % The column in the measurements table that denotes time passing
  % time_column_name = app.TimeColumnDropDown.Value;
  time_column_name = 'timepoint';

  % Loop over images tracking each one
  TrackedTable = table();
  for image_name = unique(app.ResultTable.ImageName)'
    %% CALC DIFFERENCES BETWEEN FRAMES
    imageTable = app.ResultTable(ismember(app.ResultTable.ImageName,image_name),:);
    app.log_processing_message(app, 'Measuring differences between frames...');
    [raw_differences, normalized_differences, composite_differences] = DifferentialMeasurements(imageTable,weights,time_column_name);

    %% TRACK CELLS
    app.log_processing_message(app, 'Tracking...');
    [imageTable,DiffTable] = cell_tracking_v1_simple(imageTable, composite_differences, time_column_name, CentroidName);
  
    % Store result
    TrackedTable = [TrackedTable; imageTable];
  end
  app.ResultTable = TrackedTable;

  % Get the new results for the objects currently in the display figure, find them by UUID 
  app.ResultTable_for_display = app.ResultTable(ismember(app.ResultTable.ID,app.ResultTable_for_display.ID),:); 

  % Update list of measurements in the analyze tab
  changed_MeasurementNames(app);

  app.log_processing_message(app, 'Finished tracking.');
  busy_state_change(app,'not busy');

  uialert(app.UIFigure,'Tracking complete.','Success', 'Icon','success');

  
  % Delete log
%   delete(app.StartupLogTextArea);
%     app.StartupLogTextArea.tx.String = {};
end