function [] = writeModelParams(config, f_score_text, f_score)
    
    fid_parameters = fopen(config.resultFile, 'a');
%     fprintf(fid_parameters, [f_score_text, ' - %f\n'], f_score);
    fprintf(fid_parameters, ['%f,'], f_score);

    fclose(fid_parameters);

end
