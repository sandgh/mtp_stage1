function [model] = trainSVM(ylabels, classId, feature_vect, config)

        %% On only those mentions which are true for the curr relation
        temp_reln_labels = zeros(size(ylabels,1),1);
        temp_reln_labels(ylabels==classId) = 1;
       
        
        %% when no +ve examples are there for a relation, return
%         noPositiveFlag=0;
%         if(sum(temp_reln_labels) == 0)
%             noPositiveFlag = 1;
%             return;
%         end
%         
        
        %% LibSVM Train
%         model = svmtrain(temp_reln_labels, feature_vect, strcat('-s 0 -t 2 -c 1 -g 0.1 -w1 ', num2str(config.w_1_cost),' -w0 ',num2str(config.w_0_cost)));
          params = ['-s 0 -t 2 -c ', num2str(2^config.c), ' -g ', num2str(2^config.g), ' -w1 ', num2str(config.w_1_cost),' -w0 ',num2str(config.w_0_cost)]
         % params = ['-s 0 -t 2 -c ', num2str(2^config.c), ' -g ', num2str(2^config.g)]

          model = svmtrain(temp_reln_labels, feature_vect, params);
        
%         best_acc = 0;
%         for log2c = -1:3,
%           for log2g = -4:1,
% %             cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
%             params = ['-s 0 -t 2 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g), ' -w1', num2str(config.w_1_cost),' -w0',num2str(config.w_0_cost)]
% %             cv = svmtrain(heart_scale_label, heart_scale_inst, cmd);
%             cv = svmtrain(temp_reln_labels, feature_vect, params);
%             
%             [~, accuracy, decision_values] = svmpredict(ylabels, feature_vect, cv);
%             if(accuracy>best_acc)
%                 model = cv;
%             end
% %             fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
%           end
%         end
          
          
        % Need to verify next 2 lines  (taken from http://stackoverflow.com/questions/10131385/matlab-libsvm-how-to-find-the-w-coefficients)
%         w = (model.sv_coef' * full(model.SVs));
%         bias=-model.rho;

end