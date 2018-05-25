function fun(app,createCallbackFcn)
  try
    set(0,'DefaultFigureWindowStyle','docked');
    warning('off','images:initSize:adjustingMag');
    warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
    
    % Initialize variables
    init_variables(app);

    % Select tab to display on opening
    app.TabGroup.SelectedTab = app.Tab_Input;

    % Open browse by default
    % browse_button_pushed(app,createCallbackFcn);

  % Catch Application Error
  catch ME
    handle_application_error(app,ME);
  end

end