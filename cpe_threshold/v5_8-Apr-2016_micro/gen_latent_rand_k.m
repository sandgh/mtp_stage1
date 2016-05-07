%%%
%%%
%%%

function [ latent_y_labels ] = gen_latent_rand_k( config )

ent_mntn_cnt_cum=cumsum(config.ent_mntn_cnt);

latent_y_labels = config.cpe.*0;


for i=1:config.no_of_relns
    
    %find ent_pair indexes which are true for the curr reln
    idxs = find(config.gold_y_labels(:,i)>0);
    
    curr_idx_start=0;
    
    for j = 1:numel(idxs)
        
        %find how many sentences are there for the ent_pair
        sntnc_cnt = config.ent_mntn_cnt(idxs(j));
        
        %make k% of total sentences true
        k_prcnt = ceil(sntnc_cnt*config.sntnce_k_prcnt);
        
        if idxs(j) ~= 1
            curr_idx_start = ent_mntn_cnt_cum(idxs(j)-1);
        end
        
        %get the CPEs for the curr ent_pair sentences
        curr_cpes = config.cpe(curr_idx_start+1:curr_idx_start+sntnc_cnt, i);
        
        %%choose k% sentences probabilistically.
        %%high CPE leads high prob the sentences will be marked true.
        
        choose_k = datasample(1:sntnc_cnt, k_prcnt, 'Replace',... 
                            false, 'Weights',curr_cpes) + curr_idx_start;
        
        latent_y_labels(choose_k,i) = 1;
        
    end
    
    
end

end

