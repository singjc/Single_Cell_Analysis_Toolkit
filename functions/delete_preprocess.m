function fun(app, proc_nums)
  if ~any(ismember(fields(app),'preprocess'))
    return
  end

  component_names = { ...
    'fields', ...
    'labels', ...
    'ParamOptionalCheck', ...
    'HelpButton', ...
  };
  for proc_num=proc_nums
    for cid=1:length(component_names)
      comp_name = component_names{cid};
      if isfield(app.preprocess{proc_num},comp_name)
        for idx=1:length(app.preprocess{proc_num}.(comp_name))
          if isfield(app.preprocess{proc_num}.(comp_name){idx}.UserData,'ParamOptionalCheck')
            delete(app.preprocess{proc_num}.(comp_name){idx}.UserData.ParamOptionalCheck);
          end
          delete(app.preprocess{proc_num}.(comp_name){idx});
          app.preprocess{proc_num}.(comp_name){idx} = [];
        end
        app.preprocess{proc_num}.(comp_name) = {};
      end
    end
  end
end