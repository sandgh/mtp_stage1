function [predicted_db_matrix] = jointPrediction(num_egs, NO_OF_RELNS, no_sentences_per_example, predictions_vect)

    %% Joint Prediction
    
    %%%initialize
    sentence_index=0;
    predicted_db_matrix=zeros(num_egs,NO_OF_RELNS);
    
    %%% Loop over all data points
    for len=1:num_egs
        for s=1:no_sentences_per_example(1,len)
           sentence_index=sentence_index+1;
           
           %%% at least one assumption
           if(predictions_vect(sentence_index) ~= 0)
                predicted_db_matrix(len,predictions_vect(sentence_index)+1)=1; 
           end

        end    

    end

end