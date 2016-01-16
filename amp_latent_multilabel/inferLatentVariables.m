function [latent_labels, latent_size,x1] = inferLatentVariables(config)

    %% delete existing
    system('rm -f tmp1/inf_lat_var_all.result');

    
    %% call java to get latent labels
    system(['./infer_latent_cmd.sh ', config.TrainFile]);

    
    %% reading java results
    fileID = fopen('tmp1/inf_lat_var_all.result','r');
    latent_labels = fscanf(fileID,'%d');
    [latent_size,x1]=size(latent_labels);

end