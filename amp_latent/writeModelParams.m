function [] = writeModelParams(config, TP_micro, TN_micro, epochId, v)

    fid_parameters = fopen([config.TrainFile,'_','current_parameters'], 'a');
    fprintf(fid_parameters, 'EPOCH - %d \n\tv- %f\n\tTP_micro - %f \tTN_micro - %f \n\tw_1_cost- %f \t w_0_cost- %f \n',epochId, v, TP_micro, TN_micro, config.w_1_cost, config.w_0_cost);

end
