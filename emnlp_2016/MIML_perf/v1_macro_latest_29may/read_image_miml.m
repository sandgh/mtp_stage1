function [config] = read_image_miml(config)

targets = [];
load(config.file_name);

% config.gold_y_labels=targets';
% config.feature_vect=cell2mat(bags);
% config.ent_mntn_cnt=ones(size(bags,1),1)*9;
load('10CV.mat');

shfl=Indexes;
% shfl = randperm(size(bags,1));
bags_shfl = bags(shfl,:);

%%%%%%%%%%%% for text miml dataset %%%%%%%%%%%
if length(targets) == 0
    targets = target;
    clear target;
end
targets_t = targets';

targets_shfl = targets_t(shfl,:);

train_cnt = 1:1200;
validation_cnt = 1201:1600;
test_cnt = 1601:2000;
% train_cnt = 1:120;
% validation_cnt = 121:160;
% test_cnt = 161:200;

config.gold_y_labels=targets_shfl(train_cnt,:);
config.gold_y_labels=config.gold_y_labels(:,:)>0;
config.feature_vect=cell2mat(bags_shfl(train_cnt,:));
sz_array=cell2mat(cellfun(@size,bags_shfl(train_cnt,:),'UniformOutput',0));
config.ent_mntn_cnt=sz_array(:,1);


config.validation_gold_y_labels = targets_shfl(validation_cnt,:);
config.validation_gold_y_labels =config.validation_gold_y_labels(:,:)>0;
config.validation_feature_vect = cell2mat(bags_shfl(validation_cnt,:));
sz_array=cell2mat(cellfun(@size,bags_shfl(validation_cnt,:),'UniformOutput',0));
config.validation_ent_mntn_cnt =sz_array(:,1);


config.test_gold_y_labels = targets_shfl(test_cnt,:);
config.test_gold_y_labels =config.test_gold_y_labels(:,:)>0;
config.test_feature_vect = cell2mat(bags_shfl(test_cnt,:));
sz_array=cell2mat(cellfun(@size,bags_shfl(test_cnt,:),'UniformOutput',0));

config.test_ent_mntn_cnt = sz_array(:,1);


 config.g_std=getAvgSqEucDistAcc(config.feature_vect,size(config.feature_vect,1))
 
 
 %% code to print the MDS plot
 
 
% config.g_std=sum(sum(pdist2(config.feature_vect,config.feature_vect,'euclidean')))/(size(config.feature_vect,1)*(size(config.feature_vect,1)));
% clr = ['r', 'g', 'b', 'm', 'y'];
% mrk = ['+', 'o', '*', 's', 'd'];
% for i=1:5test_no_of_sntstest_no_of_snts
%     g = config.gold_y_labels(:,i);
%     g1 = repmat(g', [9,1]);
%     g2 = reshape(g1, [1,900]);
%     
%     dissimilarities = pdist(config.feature_vect);
%     [Y,stress,disparities] = mdscale(dissimilarities,3);%, 'criterion','metricsstress');
%     % figure;scatter3(Y(:,1), Y(:,2), Y(:,3));
%     
%     [r,c]= size(Y);
%     figure(1); hold on;
% %     clr = ['r', 'g'];
%     for iy=1:r
%         
%         if(g2(1,iy) == 1)
%             figure(1);scatter3(Y(iy,1), Y(iy,2), Y(iy,3), 20, clr(1,i), mrk(1,i) );
%             hold on;
%         end
%         
%     end
% %     hold off;
%     
% end
%  hold off;
end