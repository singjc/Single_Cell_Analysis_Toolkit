function MeasureTable = subsegments_count(primary_seg, subsegments)


MeasureTable = table();
tmp=table();

% Nothing to do if no segments are given
if isempty(primary_seg)
    return;
end
if isempty(subsegments)
    return;
end

seg_names = fields(segments);
  
subsegments=primary_seg
p=primary_seg.Watershet;
s=primary_seg.Seed;

for prim_field = fields(primary_seg)'
    
   p = primary_seg.(char(prim_field));
   single_cell_ID=unique(p);
   
   for sub_field = fields(sub_seg)'
       
       s = sub_seg.(char(sub_field));
%        single_subsegment=s;
%        Sum_List=cell([length(single_cell_ID) 1]);
       list_idx=1;
       for i = single_cell_ID'
           
           single_subsegment=s;
           single_subsegment(p~=i)=0;
           single_subsegment=bwlabel(single_subsegment);
%            Sum_List(list_idx,1)=num2cell(max(single_subsegment(:)));
%             tmp{:,[char(prim_field) '_' char(sub_field) '_ObjectCount']}=max(single_subsegment(:))
           MeasureTable{list_idx,[char(prim_field) '_' char(sub_field) '_ObjectCount']}=max(single_subsegment(:))
           list_idx=list_idx+1;
           
       end
       
   end
    
end



%   MeasureTable = table();
%
%   % Nothing to do if no segments are given
%   if isempty(segments)
%     return;
%   end
%   seg_names = fields(segments);
%
%   % Get channel names if there are any
%   if ~isempty(imgs)
%     chan_names = fields(imgs);
%   end
%
%
%   % Remove special measurements from the stats_per_channel list, these can't be passed to regionprops and will be handled seperately
%   TotalIntensity_enabled = find(strcmp(stats_per_channel,'TotalIntensity'));
%   if TotalIntensity_enabled
%     stats_per_channel(TotalIntensity_enabled) = [];
%   end
%   GradientMeanIntensity_enabled = find(strcmp(stats_per_channel,'GradientMeanIntensity'));
%   if GradientMeanIntensity_enabled
%     stats_per_channel(GradientMeanIntensity_enabled) = [];
%   end
%   GradientTotalIntensity_enabled = find(strcmp(stats_per_channel,'GradientTotalIntensity'));
%   if GradientTotalIntensity_enabled
%     stats_per_channel(GradientTotalIntensity_enabled) = [];
%   end
%
%   % Loop over segments
%   for seg_num=1:length(segments)
%     seg_name = seg_names{seg_num};
%     seg_data = segments.(seg_name);
%
%     % Calculate shape stats
%     if ~isempty(stats_per_label)
%       stats = regionprops(seg_data,stats_per_label);
%       for stat_num=1:length(stats_per_label)
%         stat_name = stats_per_label{stat_num};
%         MeasureTable{:,[seg_name '_' stat_name]}=cat(1,stats.(stat_name));
%       end
%     end
%
%     % Skip image measurements if no images
%     if isempty(imgs)
%       continue;
%     end
%     % Calculate intensity stats for each channel
%     for chan_num=1:length(chan_names)
%       chan_name = chan_names{chan_num};
%       % Calculate total intensity
%       if TotalIntensity_enabled
%         stats = regionprops(seg_data,imgs.(chan_name),{'Area', 'MeanIntensity'});
%         MeasureTable{:,[seg_name '_' chan_name '_TotalIntensity']}=cat(1,stats.MeanIntensity).*cat(1,stats.Area);
%       end
%       % Calculate intensity stats
%       if ~isempty(stats_per_channel)
%         stats = regionprops(seg_data,imgs.(chan_name),stats_per_channel);
%         for stat_num=1:length(stats_per_channel)
%           stat_name = stats_per_channel{stat_num};
%           MeasureTable{:,[seg_name '_' chan_name '_' stat_name]}=cat(1,stats.(stat_name));
%         end
%       end
%       % Calculate gradient (std dev) total and mean
%       if any([GradientMeanIntensity_enabled, GradientTotalIntensity_enabled])
%         gradient_im = imgradient(imgs.(chan_name));
%         stats = regionprops(seg_data,gradient_im,{'Area', 'MeanIntensity'});
%         MeasureTable{:,[seg_name '_' chan_name '_GradientMeanIntensity']}=cat(1,stats.MeanIntensity);
%         MeasureTable{:,[seg_name '_' chan_name '_GradientTotalIntensity']}=cat(1,stats.MeanIntensity).*cat(1,stats.Area);
%       end
%     end
%   end

end