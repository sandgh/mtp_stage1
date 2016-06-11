function hammloss=T_Criterion(Outputs,test_target)
%Computing the hamming loss
%Outputs: the predicted outputs of the classifier, the output of the ith instance for the jth class is stored in Outputs(j,i)
%test_target: the actual labels of the test instances, if the ith instance belong to the jth class, test_target(j,i)=1, otherwise test_target(j,i)=-1

    [num_class,num_instance]=size(Outputs);
    Pre_Labels=((Outputs>=0)-0.5)*2;
    
    for i=1:num_instance
        if(sum(Pre_Labels(:,i)==-1)==num_class)
            [tempvalue,index]=max(Outputs(:,i));
            Pre_Labels(index,i)=1;
        end
    end
    
    hammloss=Hamming_loss(Pre_Labels,test_target);