function params = definition_subsegments_count()
  n = 0;
  n = n + 1;
  params(n).name = 'Segments to Measure';
  params(n).default = '';
  params(n).help = 'The primary segment you wish to measure';
  params(n).type = 'segment_listbox';

  n = n + 1;
  params(n).name = 'Sub-Segments to Count';
  params(n).default = '';
  params(n).help = 'The sub-segments to count in primary segment';
  params(n).type = 'segment_listbox';

end