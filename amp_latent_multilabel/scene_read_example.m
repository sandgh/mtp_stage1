function [gold_db_matrix, feature_vect] = scene_read_example(filename)
    M=dlmread(filename);
    no_of_labels = 6;
    [a,b]=size(M);
    feature_vect=M(:,1:b-no_of_labels);
    gold_db_matrix=M(:,b-no_of_labels+1:b);
end 

