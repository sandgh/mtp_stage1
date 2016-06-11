function [HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels,te_time]=M3MIML_test(train_bags,train_target,test_bags,test_target,svm,Alpha,Beta,Bias)
%M3MIML_test tests the trained multi-instance multi-label learning maximal margin classifier
%
%    Syntax
%
%       [HammingLoss,RankingLoss,OneError,Coverage,Average_Precision,Outputs,Pre_Labels,te_time]=M3MIML_test(train_bags,train_target,test_bags,test_target,svm,Alpha,Beta,Bias)
%
%    Description
%
%       M3MIML_test takes,
%           train_bags       - An M1x1 cell, the ith training bag is stored in train_bags{i,1}
%           train_target     - A QxM1 array, if the ith training bag belongs to the jth class, then train_target(j,i) equals +1, otherwise train_target(j,i) equals -1
%           test_bags        - An M2x1 cell, the ith test bag is stored in test_bags{i,1}
%           test_target      - A QxM2 array, if the ith test bag belongs to the jth class, test_target(j,i) equals +1, otherwise test_target(j,i) equals -1
%           svm              - svm.type gives the type of svm used in training, which can take the value of 'RBF', 'Poly' or 'Linear'; svm.para gives the corresponding parameters used for the svm:
%                              1) if svm.type is 'RBF', then svm.para gives the value of gamma, where the kernel is exp(-Gamma*|x(i)-x(j)|^2)
%                              2) if svm.type is 'Poly', then svm.para(1:3) gives the value of gamma, coefficient, and degree respectively, where the kernel is (gamma*<x(i),x(j)>+coefficient)^degree.
%                              3) if svm.type is 'Linear', then svm.para is [].
%           Alpha            - An M1xQ cell storing the learned dual variables
%           Beta             - An M1xQ cell storing the learned dual variables
%           Bias             - The bias for the l-th seperating hyperplane is stored in Bias(1,l)
%      and returns,
%           HammingLoss      - The hamming loss on testing data as described in [1]
%           RankingLoss      - The ranking loss on testing data as described in [1]
%           OneError         - The one-error on testing data as described in [1]
%           Coverage         - The coverage on testing data as described in [1]
%           Average_Precision- The average precision on testing data as described in [1]
%           Outputs          - The output of the ith testing bag on the l-th class is stored in Outputs(l,i)
%           Pre_Labels       - If the ith testing bag belongs to the l-th class, then Pre_Labels(l,i) is +1, otherwise Pre_Labels(l,i) is -1
%           te_time          - The testing time
%
%    [1] Schapire R. E., Singer Y. BoosTexter: a boosting based system for text categorization. Machine Learning, 39(2/3): 135-168, 2000.

    start_time=cputime;
    
    [num_class,num_train]=size(train_target);
    [num_class,num_test]=size(test_target);
    
    train_bag_size=zeros(1,num_train);
    for i=1:num_train
        [tempsize,tempvalue]=size(train_bags{i,1});
        train_bag_size(1,i)=tempsize;
    end
    
    test_bag_size=zeros(1,num_test);
    for i=1:num_test
        [tempsize,tempvalue]=size(test_bags{i,1});
        test_bag_size(1,i)=tempsize;
    end
    
    kernel=cell(num_train,num_test);
    
    for i=1:num_train
        if(mod(i,100)==0)
            disp(strcat(num2str(i),'/',num2str(num_train)));
        end
        for j=1:num_test
            kernel{i,j}=zeros(train_bag_size(1,i),test_bag_size(1,j));
            for temp1=1:train_bag_size(1,i)
                vec1=train_bags{i,1}(temp1,:);
                for temp2=1:test_bag_size(1,j)
                    vec2=test_bags{j,1}(temp2,:);
                    if(strcmp(svm.type,'RBF'))
                        gamma=svm.para(1);
                        kernel{i,j}(temp1,temp2)=exp(-gamma*sum((vec1-vec2).^2));
                    else
                        if(strcmp(svm.type,'Poly'))
                            gamma=svm.para(1);
                            coefficient=svm.para(2);
                            degree=svm.para(3);
                            kernel{i,j}(temp1,temp2)=(gamma*vec1*vec2'+coefficient)^degree;
                        else
                            kernel{i,j}(temp1,temp2)=vec1*vec2';
                        end
                    end
                end
            end
        end
    end
    
    Outputs=zeros(num_class,num_test);
    for i=1:num_test
        for l=1:num_class
            temp_output=zeros(1,test_bag_size(1,i));
            for j=1:test_bag_size(1,i)
                temp=0;
                for k=1:num_train
                    if(train_target(l,k)==1)
                        temp=temp+((sum(kernel{k,i}(:,j))*Alpha{k,l})/train_bag_size(1,k));
                    else
                        temp=temp+(-Beta{k,l}*kernel{k,i}(:,j));
                    end
                end
                temp=temp+Bias(1,l);
                temp_output(1,j)=temp;
            end
            Outputs(l,i)=max(temp_output);
        end
    end
    
    Pre_Labels=((Outputs>=0)-0.5)*2;
    
%     HammingLoss=Hamming_loss(Pre_Labels,test_target);
    HammingLoss=T_Criterion(Outputs,test_target);

    RankingLoss=Ranking_loss(Outputs,test_target);
    OneError=One_error(Outputs,test_target);
    Coverage=coverage(Outputs,test_target);
    Average_Precision=Average_precision(Outputs,test_target);
    
    te_time=cputime-start_time;