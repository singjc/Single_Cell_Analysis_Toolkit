function result = fun(plugin_name, plugin_num, img, seeds, threshold_smooth_param, watershed_smooth_param, thresh_param, min_area, max_area, boarder_clear, debug_level)
    
  warning off all
  cwp=gcp('nocreate');
  if isempty(cwp)
      warning off all
  else
      pctRunOnAll warning off all %Turn off Warnings
  end

  % Smooth
  img_smooth = imgaussfilt(img,threshold_smooth_param);
  if ismember(debug_level,{'All'})
    f = figure(886); clf; set(f,'name','smooth for threshold','NumberTitle', 'off');
    imshow(img_smooth,[]);
  end

  % threshold
  img_thresh = img_smooth > thresh_param;
  if ismember(debug_level,{'All'})
    f = figure(885); clf; set(f,'name','threshold','NumberTitle', 'off');
    imshow(img_thresh,[]);
  end

  % remove seeds outside of our img mask
  if ~isequal(seeds,false)
    seeds(img_thresh==0)=0;

    % Debug with plot
    if ismember(debug_level,{'All'})
      [X Y] = find(seeds);
      f = figure(826); clf; set(f,'name','input seeds','NumberTitle', 'off')
      imshow(img,[]);
      hold on;
      plot(Y,X,'or','markersize',2,'markerfacecolor','r')
    end
  end

  if isequal(watershed_smooth_param,false)
    img_smooth2 = img;
  else
    img_smooth2 = imgaussfilt(img,watershed_smooth_param);
  end
  if ismember(debug_level,{'All'})
    f = figure(889); clf; set(f,'name','smooth for watershed','NumberTitle', 'off');
    imshow(img_smooth2,[]);
  end


  %% Watershed
  if ~isequal(seeds,false)
    img_min = imimposemin(max(img_smooth2(:))-img_smooth2,seeds); % set locations of seeds to be -Inf as per  matlab's watershed
  else
    img_min = max(img_smooth2(:))-img_smooth2;
  end

  if ismember(debug_level,{'All'})
    f = figure(564); clf; set(f,'name','imimposemin','NumberTitle', 'off')
    imshow(img_min,[]);
  end
  
  img_ws = watershed(img_min);
  if ismember(debug_level,{'All'})
    f = figure(562); clf; set(f,'name','watershed','NumberTitle', 'off')
    imshow(img_ws,[]);
  end

  img_ws(img_thresh==0)=0; % remove areas that aren't in our img mask
  if ismember(debug_level,{'All'})
    f = figure(561); clf; set(f,'name','watershed & threshold','NumberTitle', 'off')
    imshow(img_ws,[]);
  end

  % Clear cells touching the boarder
  if isnumeric(boarder_clear)
    if isequal(boarder_clear,0)
      bordercleared_img = imclearborder(img_ws);
    else
      % Clear objects touching boarder too much (ex. too much could be 1/4 of perimeter)
      bordercleared_img = img_ws;
      for idx=1:max(img_ws(:))
        single_object = img_ws == idx;
        [x y] = find(single_object);
        count_edge_touches = ismember([x; y], [1 size(single_object,1), size(single_object,2)]);
        count_perim = bwperim(single_object);
        % If the object touches the edge for more than 1/5 the length of the perimeter, delete it
        if sum(count_edge_touches) > sum(count_perim(:)) / (100 / boarder_clear)
          bordercleared_img(bordercleared_img==idx)=0; % delete this object
        end
      end
    end
    if ismember(debug_level,{'All'})
      f = figure(511); clf; set(f,'name','imclearborder','NumberTitle', 'off')
      imshow(bordercleared_img,[]);
    end
  else
    bordercleared_img = img_ws;
  end

  % Fill holes
  filled_img = imfill(bordercleared_img,'holes');
  if ismember(debug_level,{'All'})
    f = figure(512); clf; set(f,'name','imfill','NumberTitle', 'off')
    imshow(filled_img,[]);
  end

  % Remove segments that don't have a seed
  if ~isequal(seeds,false)
    reconstruct_img = imreconstruct(logical(seeds),logical(filled_img));
    labelled_img = bwlabel(reconstruct_img);
    if ismember(debug_level,{'All'})
      f = figure(514); clf; set(f,'name','imreconstruct','NumberTitle', 'off')
      imshow(reconstruct_img,[]);
    end
  else
    labelled_img = bwlabel(filled_img);
  end

  % Remove objects that are too small or too large
  stats = regionprops(labelled_img,'area');
  area = cat(1,stats.Area);  
  labelled_img(ismember(labelled_img,find(area > max_area | area < min_area)))=0;

  % Return result
  result = bwlabel(labelled_img);

  if ismember(debug_level,{'All','Result Only','Result With Seeds'})
    f = figure(743); clf; set(f,'name',[plugin_name ' Result'],'NumberTitle', 'off')
    % Display original image
    % Cast img as double, had issues with 32bit
    img8 =  img; %im2uint8(double(img));
    if min(img8(:)) < prctile(img8(:),99.5)
        min_max = [min(img8(:)) prctile(img8(:),99.5)];
    else
        min_max = [];
    end
    imshow(img8,[min_max]);
    hold on
    % Display color overlay
    labelled_perim = imdilate(bwlabel(bwperim(labelled_img)),strel('disk',5));
    labelled_rgb = label2rgb(uint32(labelled_perim), 'jet', [1 1 1], 'shuffle');
    himage = imshow(im2uint8(labelled_rgb),[min_max]);
    himage.AlphaData = labelled_perim*1;
    if ismember(debug_level,{'All','Result With Seeds'})
      if ~isequal(seeds,false)
        seeds(labelled_img<1)=0;
        % Display red dots for seeds
        [xm,ym]=find(seeds);
        hold on
        plot(ym,xm,'or','markersize',2,'markerfacecolor','r','markeredgecolor','r')
      end
    end
    hold off
  end
  
end
