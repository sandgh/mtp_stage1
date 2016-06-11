function [Alpha,Beta,Bias,tr_time]=M3MIML_train(train_bags,train_target,svm,cost,lambda_tol,norm_tol)
%M3MIML trains the multi-instance multi-label learning maximal margin classifier
%
%    Syntax
%
%       [Alpha,Beta,Bias,tr_time]=M3MIML_train(train_bags,train_target,svm,cost)
%
%    Description
%
%       M3MIML_train takes,
%           train_bags       - An Mx1 cell, the ith training bag is stored in train_bags{i,1}
%           train_target     - A QxM array, if the ith training bag belongs to the jth class, then train_target(j,i) equals +1, otherwise train_target(j,i) equals -1
%           svm              - svm.type gives the type of svm used in training, which can take the value of 'RBF', 'Poly' or 'Linear'; svm.para gives the corresponding parameters used for the svm:
%                              1) if svm.type is 'RBF', then svm.para gives the value of gamma, where the kernel is exp(-Gamma*|x(i)-x(j)|^2)
%                              2) if svm.type is 'Poly', then svm.para(1:3) gives the value of gamma, coefficient, and degree respectively, where the kernel is (gamma*<x(i),x(j)>+coefficient)^degree.
%                              3) if svm.type is 'Linear', then svm.para is [].
%           cost             - The cost parameter used in SVM
%           lambda_tol       - The tolerance value for lambda described in the appendix of [1] for Franke and Wolfe's method; default value is 1e-6
%           norm_tol         - The tolerance value for difference between alpha(p+1) and alpha(p) described in the appendix of [1] for Franke and Wolfe's method; default value is 1e-4
%      and returns,
%           Alpha            - An MxQ cell storing the learned dual variables
%           Beta             - An MxQ cell storing the learned dual variables
%           Bias             - The bias for the l-th seperating hyperplane is stored in Bias(1,l)
%           tr_time          - The training time
%
%    [1] Elisseeff A, Weston J. Kernel methods for multi-labelled classfication and categorical regression problems. Technical Report, BIOwulf Technologies, 2001.


    start_time=cputime;
    
    if(nargin<4)
        error('Not enough input parameters, please check again.');
    end

    if(nargin<6)
        norm_tol=1e-4;
    end
    if(nargin<5)
        lambda_tol=1e-6;
    end
    
    global kernel

    [num_class,num_train]=size(train_target);
    Alpha=cell(num_train,num_class);
    Beta=cell(num_train,num_class);
    bag_size=zeros(1,num_train);
    para_size=zeros(num_train,num_class);
    para_pos=cell(num_train,num_class);
    
    for i=1:num_train
        [tempsize,tempvalue]=size(train_bags{i,1});
        bag_size(1,i)=tempsize;
    end
    
    for i=1:num_train
        for l=1:num_class
            if(train_target(l,i)==1)
                para_size(i,l)=1;
            else                
                para_size(i,l)=bag_size(1,i);
            end
        end
    end
    
    count=0;
    for i=1:num_train
        for l=1:num_class
            para_pos{i,l}=[(count+1):(count+para_size(i,l))];
            count=count+para_size(i,l);
        end
    end
    
    for i=1:num_train
        for l=1:num_class
            if(train_target(l,i)==1)
                Alpha{i,l}=0;
            else                
                Beta{i,l}=zeros(1,bag_size(1,i));
            end
        end
    end
    
    Aeq=zeros(num_class,sum(sum(para_size)));
    beq=zeros(num_class,1);

    for l=1:num_class
        index1=[];
        index2=[];
        for i=1:num_train
            if(train_target(l,i)==1)
                index1=[index1,para_pos{i,l}];
            else
                index2=[index2,para_pos{i,l}];
            end
        end
        Aeq(l,index1)=1;
        Aeq(l,index2)=-1;
    end

    LB=zeros(sum(sum(para_size)),1);
    UB=cost*ones(sum(sum(para_size)),1);
    
    disp('Computing kernel values');
    kernel=cell(num_train,num_train);
    for i=1:num_train
        if(mod(i,100)==0)
            disp(strcat(num2str(i),'/',num2str(num_train)));
        end
        for j=i:num_train
            kernel{i,j}=zeros(bag_size(1,i),bag_size(1,j));
            for temp1=1:bag_size(1,i)
                vec1=train_bags{i,1}(temp1,:);
                for temp2=1:bag_size(1,j)
                    vec2=train_bags{j,1}(temp2,:);  
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
            kernel{j,i}=kernel{i,j}';
        end
    end
    
    para=zeros(1,sum(sum(para_size)));
    
    %Find the dual variables using Franke and Wolfe method [1]
    continuing=true;
    max_iter=5;
    iteration=0;
    while(continuing)        
        tic;
        iteration=iteration+1;
        disp(strcat('current iteration: ',num2str(iteration),'/',num2str(max_iter)));
        
        %computing gradient
        gradient=[];
        for i=1:num_train
            for l=1:num_class
                if(train_target(l,i)==1)
                    tempsum=0;
                    for j=1:num_train
                        if(train_target(l,j)==1)
                            tempsum=tempsum+((sum(sum(kernel{j,i}))*Alpha{j,l})/(bag_size(1,j)*bag_size(1,i)));
                        else
                            tempsum=tempsum+((-sum(sum(kernel{j,i}.*concur(Beta{j,l}',bag_size(1,i)))))/(bag_size(1,i)));
                        end
                    end
                    tempsum=-tempsum+1;
                    gradient=[gradient,tempsum];
                else
                    for k=1:bag_size(1,i)
                        tempsum=0;
                        for j=1:num_train
                            if(train_target(l,j)==1)
                                tempsum=tempsum+(((-sum(kernel{j,i}(:,k)))*Alpha{j,l})/bag_size(1,j));
                            else
                                tempsum=tempsum+(Beta{j,l}*kernel{j,i}(:,k));
                            end
                        end
                        tempsum=-tempsum+1;
                        gradient=[gradient,tempsum];
                    end
                end
            end
        end
        
        para_new=linprog((-gradient)',[],[],Aeq,beq,LB,UB);
        para_new=para_new';
        
        Lambda=fminbnd(@M3MIML_neg_dual,0,1,optimset('Display','iter'),para,para_new,bag_size,para_pos,train_target,num_train,num_class);
        
        if((abs(Lambda)<=lambda_tol)|(Lambda*sqrt(sum((para_new-para).^2))<=norm_tol))
            continuing=false;
            disp('program terminated normally');
        else
            if(iteration>=max_iter)
                continuing=false;
                warning('maximum number of iterations reached, procedure not convergent');
            else
                para=para+Lambda*(para_new-para);
                for i=1:num_train
                    for l=1:num_class
                        if(train_target(l,i)==1)
                            Alpha{i,l}=para(1,para_pos{i,l});
                        else
                            Beta{i,l}=para(1,para_pos{i,l});
                        end
                    end
                end
            end
        end        
        toc;
    end
    
    Bias=[];
    for l=1:num_class
        temp=0;
        count=0;
        for i=1:num_train
            if(train_target(l,i)==1)
                if((Alpha{i,l}>0)&(Alpha{i,l}<cost))
                    count=count+1;
                    temp=temp+gradient(1,para_pos{i,l});
                end
            else
                for j=1:bag_size(1,i)
                    if((Beta{i,l}(1,j)>0)&(Beta{i,l}(1,j)<cost))
                        count=count+1;
                        temp=temp+(-gradient(1,para_pos{i,l}(1,j)));
                    end
                end
            end
        end
        Bias=[Bias,temp/count];
    end
    
    tr_time=cputime-start_time;
    
    clear global;