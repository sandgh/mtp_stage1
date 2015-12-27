function [time CBest] = doCVForC(XTrain, yTrain, options, numValidating, trainingRoutine)
	CVOptions = options;
    
    if size(XTrain,2) ~= length(yTrain)
        error('Mismatch in number of validation examples and labels\n');
    end
    
    if length(yTrain) ~= 2*numValidating
        error('Too few or too many validation examples given\n');
    end
    
    time = 0;
	CBest = -inf;
	perfBest = 0;
    
    XTrainFold = XTrain(:,1:numValidating);
    XTestFold = XTrain(:,numValidating+1:end);
    
    yTrainFold = yTrain(1:numValidating);
    yTestFold = yTrain(numValidating+1:end);

	Crange = 10.^[-6:4];
    for i = Crange
        CVOptions.C = i;
        
        % Try out this value of C
        % The training routine may return an array of results - take only the last one.
        [tempTime, ~, tempPerf] = trainingRoutine(XTrainFold, yTrainFold, XTestFold, yTestFold, CVOptions);
        time = time + tempTime(end);
        
        fprintf('%d: %d\n', i, tempPerf(end));
        
        if tempPerf(end) > perfBest
            perfBest = tempPerf(end);
            CBest = i;
        end
    end
    
    if(CBest == -Inf)
        CBest = Crange(1);
    end
    
	fprintf(1,'OpAM: The best %s value is %d\n', options.perfMeasure, perfBest);
	fprintf(1,'OpAM: The best penalty parameter is %d\n', CBest);
end