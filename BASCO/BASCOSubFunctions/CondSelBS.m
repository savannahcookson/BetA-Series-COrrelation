function newbs = CondSelBS(anaobj,thecond,bs)
hrfderivs  = anaobj.Ana{1}.AnaDef.HRFDERIVS; % regressors for temporal derivatives?
theindices = Condition2Indices(anaobj,thecond);
if hrfderivs(1)==0 && hrfderivs(2)==0
    newbs = bs(theindices);
end
if hrfderivs(1)==1 && hrfderivs(2)==0
    X = anaobj.Ana{1}.AnaDef.X; % design (runs,regressors)
    for itrial=1:length(theindices)
        idx   = theindices(itrial);
        beta1 = bs(idx);
        beta2 = bs(idx+1);
        newbs(itrial) = sign(beta1)*sqrt(beta1^2+beta2^2);
    end
end
if hrfderivs(1)==1 && hrfderivs(2)==1 % fix me!
    X = anaobj.Ana{1}.AnaDef.X; % design (runs,regressors)
    for itrial=1:length(theindices)
        idx   = theindices(itrial);
        beta1 = bs(idx);
        beta2 = bs(idx+1);
        newbs(itrial) = sign(beta1)*sqrt(beta1^2+beta2^2);
    end
end
end