function [] = writeModelParams(config, f_score_text, f_score)
    
    fid_parameters = fopen(config.resultFile, 'a');
    fprintf(fid_parameters, [f_score_text, ' - %f,'], f_score);
    fclose(fid_parameters);

end