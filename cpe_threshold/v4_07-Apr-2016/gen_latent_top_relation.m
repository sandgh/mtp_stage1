%%%
%%%
%%%

function [ latent_y_labels ] = gen_latent_top_relation( config )

latent_y_labels = config.cpe.*0;
thresh_temp =  config.thresholds;
thresh_temp(thresh_temp==0) = 0.5;
[max_cpes max_cpes_indexes]=max((config.cpe - repmat(thresh_temp,[size(config.cpe,1),1]))');
latent_y_labels(sub2ind(size(latent_y_labels),[1:length(max_cpes_indexes')]',max_cpes_indexes')) = 1;

end

