function [w, bias, noPositiveFlag,model] = trainSVM(datasize, ylabels, classId, feature_vect, config)

        %% On only those mentions which are true for the curr relation
        temp_reln_labels = zeros(datasize,1);
        temp_reln_labels(ylabels==classId) = 1;
        w=zeros(1,1);
        bias=0;
        
        %% when no +ve examples are there for a relation, return
        noPositiveFlag=0;
        if(sum(temp_reln_labels) == 0)
            noPositiveFlag = 1;
            return;
        end
        
        
        %% LibSVM Train
%         model = svmtrain(temp_reln_labels, feature_vect, strcat('-s 0 -t 2 -c 1 -g 0.1 -w1 ', num2str(config.w_1_cost),' -w0 ',num2str(config.w_0_cost)));
          params = ['-s 0 -t 2 -c 1 -g 0.1 -w1 ', num2str(config.w_1_cost),' -w0 ',num2str(config.w_0_cost)]
          model = svmtrain(temp_reln_labels, feature_vect, params);
        
        % Need to verify next 2 lines  (taken from http://stackoverflow.com/questions/10131385/matlab-libsvm-how-to-find-the-w-coefficients)
        w = (model.sv_coef' * full(model.SVs));
        bias=-model.rho;

end