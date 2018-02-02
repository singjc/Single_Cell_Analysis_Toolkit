function fun(app)
  % Currently selected plate number
  plate_num = app.PlateDropDown.Value;

  %% Build path to current image from dropdown selections
  img_dir = app.input_data.plates(plate_num).ImageDir;
  plate_file_num = app.input_data.plates(plate_num).plate_num; % The plate number in the filename of images
  row = app.RowDropDown.Value;
  column = app.ColumnDropDown.Value;
  field = app.FieldDropDown.Value;
  timepoint = app.TimepointDropDown.Value;

  %% Load Images
  if strcmp(app.input_data.plates(plate_num).ImageNamingScheme, 'Operetta')
    for chan_num=[app.input_data.plates(plate_num).channels]
      app.image(chan_num).path = sprintf(...
        '%s/r%02dc%02df%02dp%02d-ch%dsk%dfk1fl1.tiff',...
        img_dir,row,column,field,plate_file_num,chan_num,timepoint);
      if ~exist(app.image(chan_num).path) % If the file doesn't exist, reset the dropdown box values and return to avoid updating the figure
        draw_display(app);
        return
      end
      app.image(chan_num).data = imread(app.image(chan_num).path);
    end
  end
  
  %% Display Images
  % Initialize image of a composite of one or more channels
  first_chan_num = app.input_data.plates(plate_num).channels(1); % may not always be 1 in position 1, it's a crazy world out there
  composite_img = uint16(zeros([size(app.image(first_chan_num).data),3]));

  % Build composite image from enabled channels
  channel_nums = app.input_data.plates(plate_num).channels;
  enabled_channels = app.input_data.plates(plate_num).enabled_channels;
  enabled_channel_nums = channel_nums(enabled_channels);
  for chan_num=[enabled_channel_nums]
    colour = rand(1,3);
    scaled_img = app.image(chan_num).data./length(enabled_channels); % reduce intensity so not to go overbounds of uint16
    colour_img = uint16(zeros(size(composite_img)));
    colour_img(:,:,1) = scaled_img .* colour(1);
    colour_img(:,:,2) = scaled_img .* colour(2);
    colour_img(:,:,3) = scaled_img .* colour(3);
    composite_img = composite_img + colour_img;
  end
  % Increase image brightness to use full range of unit16 values
  scale_factor = 2^16/max(composite_img(:));
  composite_img = composite_img .* scale_factor;

  % Display
  f = figure(111); clf; set(f, 'name','Image','NumberTitle', 'off');
  imshow(composite_img,[]);
  hold on

  % Display segments as colorized layers
  for seg_num=1:length(app.segment)
    if ~isfield(app.segment{seg_num},'data')
      continue
    end
    seg = app.segment{seg_num}.data;
    seg = imdilate(seg,strel('disk',5));
    seg_colors = label2rgb(uint16(seg), 'jet', [1 1 1], 'shuffle');
    layer = imshow(seg_colors,[]);
    layer.AlphaData = logical(seg)*.5;
  end

  hold off

end