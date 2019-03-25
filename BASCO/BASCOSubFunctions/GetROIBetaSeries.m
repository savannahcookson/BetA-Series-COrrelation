function bs = GetROIBetaSeries(SPMfile,ROIfile,ROISummaryFunction)
% get ROI beta series: estimate model based on ROI summary
D  = mardo(SPMfile); % Marsbar design object
R  = maroi(ROIfile); % Marsbar ROI object
fprintf('Retrieving data from ROI %s using summary function %s ... \n',ROIfile,ROISummaryFunction);
Y  = get_marsy(R,D,ROISummaryFunction); % put data into marsbar data object
E  = estimate(D,Y); % estimate model based on ROI summary
bs = betas(E); % retrieve estimated beta-values
end