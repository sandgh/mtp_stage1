function output=M3MIML_neg_dual(Lambda,para,para_new,bag_size,para_pos,train_target,num_train,num_class)

    global kernel
    
    para=para+Lambda*(para_new-para);

    output=0;
    for l=1:num_class
        for i=1:num_train
            if(train_target(l,i)==1)
                for j=1:num_train
                    if(train_target(l,j)==1)
                        output=output+((sum(sum(kernel{i,j}))*para(1,para_pos{i,l})*para(1,para_pos{j,l}))/(bag_size(1,i)*bag_size(1,j)));
                    else
                        output=output+2*(((-sum(kernel{i,j}*(para(1,para_pos{j,l})')))*para(1,para_pos{i,l}))/bag_size(1,i));
                    end
                end
            else
                for j=1:num_train
                    if(train_target(l,j)==-1)
                        output=output+(para(1,para_pos{i,l})*kernel{i,j}*para(1,para_pos{j,l})');
                    end
                end
            end
        end
    end
    
    output=0.5*output-sum(para);