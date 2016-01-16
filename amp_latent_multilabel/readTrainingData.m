function [gold_db_matrix, feature_vect, NO_OF_RELNS, num_egs, max_feature, count_of_sentences, no_sentences_per_example, TEST_RELATIONS] = readTrainingData(config)
    %% read examples
    
    [gold_db_matrix,delimiter] = importdata(strcat(config.TrainFile,'_goldDB'),' ');
    
    [no_sentences_per_example,delimiter] = importdata(strcat(config.TrainFile,'_mentionVect'),' ');
    
    [feature_vect_temp,delimiter] = importdata(strcat(config.TrainFile,'_feature'),' ');
    
    [count_of_sentences, max_feature] = size(feature_vect_temp);

    [num_egs, NO_OF_RELNS] = size(gold_db_matrix);

    NO_OF_RELNS=NO_OF_RELNS+1;
   
    max_feature = max_feature-1;
    
    gold_db_matrix = [zeros(num_egs,1) gold_db_matrix];
    
    feature_vect = feature_vect_temp(:,1:max_feature);

    if(config.TEST_RELATIONS <=0)
        TEST_RELATIONS = NO_OF_RELNS;
    end
    
end