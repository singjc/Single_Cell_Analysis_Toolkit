function fun(app, NewResultCallback)
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  function ProcessingLogQueueCallback(msg)
    app.log_processing_message(app, msg);
  end

  function UiAlertQueueCallback(msg)
    uialert(app.UIFigure,msg.body,msg.title,'Icon',msg.type);
  end

  function NewResultQueueCallback(iterTable)
    % Resolve missing table columns, they must all be present in both tables before combining
    [iterTable app.ResultTable] = append_missing_columns_table_pair(iterTable, app.ResultTable);
    
    % Concatenate Results
    app.ResultTable = [iterTable; app.ResultTable];
    
    % For Display
    app.ResultTable_for_display = app.ResultTable;

    %% Update Progress Bar
    finished_count = finished_count + 1;
    progress = finished_count/NumberOfImages;
    app.ProgressSlider.Value = progress;

    if isprop(app, 'progressdlg') && isvalid(app.progressdlg)
      app.progressdlg.Message = sprintf('Processing images in parallel. Please see the Matlab terminal window for further progress messages.\n\nFinished image %d of %d.', finished_count, NumberOfImages);
    end
  end

  try
    %% Setup
    app.ProgressSlider.Value = 0; % reset progress bar to 0
    finished_count  = 0; % for progress bar
    app.ProcessingLogTextArea.Value = '';
    app.processing_running = true;
    app.log_processing_message(app, 'Start processing...');
    pause(0.1);

    % Get image names to process
    if app.CheckBox_TestRun.Value
      % Limit to only one image if requested by check box
      imgs_to_process = [get_current_multi_channel_image(app)];
    else
      % Get image names that weren't filtered from all plates
      imgs_to_process = get_images_to_process(app);
    end

    NumberOfImages = length(imgs_to_process);
    
    %% Loop over images and process each one
    timerOn = true; % Default leave timer on
    tStart = tic; % Start Timer
    if app.CheckBox_Parallel.Value
      app.log_processing_message(app, 'Starting parallel processing pool.');
      app.log_processing_message(app, 'Please see the Matlab terminal window for further progress messages.');
      app.progressdlg = uiprogressdlg(app.UIFigure,'Title','Parallel Processing', 'Message','Processing images in parallel. Please see the Matlab terminal window for further progress messages.','Indeterminate','on');
      assignin('base','app_progressdlg',app.progressdlg); % needed to delete manually if neccessary, helps keep developer's life sane, otherwise it gets in the way
      ProcessingLogQueue = parallel.pool.DataQueue;
      app.ProcessingLogQueue = ProcessingLogQueue;
      afterEach(ProcessingLogQueue, @ProcessingLogQueueCallback);
      UiAlertQueue = parallel.pool.DataQueue;
      afterEach(UiAlertQueue, @UiAlertQueueCallback);
      NewResultQueue = parallel.pool.DataQueue;
      afterEach(NewResultQueue, @NewResultQueueCallback);
      is_parallel_processing = true;

      % Make parallel worker pool
      num_workers = app.ParallelWorkersField.Value;
      poolobj = gcp('nocreate'); % If no pool, do not create new one.
      if isempty(poolobj)
        parpool(num_workers);
      else
        if poolobj.NumWorkers ~= num_workers
          % Number of workers changed so recreate the pool
          delete(poolobj)
          parpool(num_workers);
        end
      end

      % Pre-open the figures needed for saving snapshots, otherwise they may not open properly
      if ~strcmp(app.measure_snapshot_selection,'No')
        for wid=1:num_workers
          f = figure(110+wid); clf; set(f, 'name',['Display ' num2str(wid)],'NumberTitle', 'off');
        end
        pause(1);
      end
      % Convert app's class from class GUI to class struct
      % Had to convert from class GUI to class struct, because for some
      % reason, when passed through to parfor, app is passed as an empty
      % GUI, but this is not the case for class struct. Weird...
      app_struct = class_app_gui_to_struct(app);
      %% PARALLEL LOOP
      parfor (current_img_number = 1:NumberOfImages)
        process_single_image(app_struct,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,NewResultQueue,ProcessingLogQueue,UiAlertQueue)
      end
    else
      is_parallel_processing = false;
      if nargin==1
        % Default behaviour is to use result handler function defined in this file
        callback_fnc = @NewResultQueueCallback;
      end
      if nargin==2
        % Override default result handler function with the passed in function
        callback_fnc = NewResultCallback;
      end
      for current_img_number = 1:NumberOfImages
        process_single_image(app,current_img_number,NumberOfImages,imgs_to_process,is_parallel_processing,callback_fnc);
        if app.progressdlg.CancelRequested
            close(app.progressdlg);
            return
        end
      end 
    end

    close(app.progressdlg);
    app.log_processing_message(app, 'Finished.');
    app.ProgressSlider.Value = 1; % set progress bar to 100%
    
    % Stop Timer
    if timerOn == true
        tEnd = toc(tStart); % Stop Timer
        msg = sprintf('Processing took: %d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));
        app.log_processing_message(app, msg);
    end

    % Update list of measurements in the display tab
    draw_display_measure_selection(app); 

    % Update list of measurements in the analyze tab
    changed_MeasurementNames(app);

    app.processing_running = false;

    if isprop(app, 'progressdlg') && isvalid(app.progressdlg)
      close(app.progressdlg)
    end

  % Catch Application Error
  catch ME
    error_msg = getReport(ME,'extended','hyperlinks','off');
    disp(error_msg);
    handle_application_error(app,ME);
  end
end