function theindices = Condition2Indices(anaobj,thecond)
theindices = [];
NumCond    = length(thecond);
for icond=1:NumCond
    theindices = [theindices anaobj.Ana{1}.AnaDef.RegCondVec{thecond(icond)}];
end
end