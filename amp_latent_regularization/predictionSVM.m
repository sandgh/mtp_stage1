function [predictions_vect] = predictionSVM(datasize, bias, W, feature_vect)

    %% Prediction
    
    %Replicate bias to add with W
    bias_repl=repmat(bias,1,datasize);

    %Prediction vector (need to be more verbose with comments)
    [predictions_score,predictions_vect] = max(W * feature_vect' + bias_repl);
    
    %%%-1 as we define NA as realtion 1 before
    predictions_vect = predictions_vect-1;
end