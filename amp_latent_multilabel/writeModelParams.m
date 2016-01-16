function [] = writeModelParams(config, TP_micro, TN_micro, epochId, iteration_no, v, f_score)
    
    fid_parameters = fopen(config.resultFile, 'a');
    if(epochId==1 && iteration_no==1)
        fprintf(fid_parameters,'\n-----------------------------------------------------------------------------------------------\n'); 
    end
    fprintf(fid_parameters, 'EPOCH - %d \titeration - %d\n\tv- %f\n\tTP_micro - %f \tTN_micro - %f \n\tw_1_cost- %f \t w_0_cost - %f \n\t Test_F_Score - %f\n', ...
                                                        epochId, iteration_no, v, TP_micro, TN_micro, config.w_1_cost, config.w_0_cost, f_score);
    
    
    fclose(fid_parameters);

end
