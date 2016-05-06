function [config] = read_image_miml(config)

load(config.file_name);

% config.gold_y_labels=targets';
% config.feature_vect=cell2mat(bags);
% config.ent_mntn_cnt=ones(size(bags,1),1)*9;


shfl = randperm(size(bags,1));
bags_shfl = bags(shfl,:);
targets_t = targets';
targets_shfl = targets_t(shfl,:);

train_cnt = 1:1600;
test_cnt = 1601:2000;
% train_cnt = 1:50;
% test_cnt = 50:75;

config.gold_y_labels=targets_shfl(train_cnt,:);
config.gold_y_labels=config.gold_y_labels(:,:)>0;
config.feature_vect=cell2mat(bags_shfl(train_cnt,:));
config.ent_mntn_cnt=ones(size(train_cnt,2),1)*9;

config.test_gold_y_labels = targets_shfl(test_cnt,:);
config.test_gold_y_labels =config.test_gold_y_labels(:,:)>0;
config.test_feature_vect = cell2mat(bags_shfl(test_cnt,:));
config.test_ent_mntn_cnt = ones(size(test_cnt,2),1)*9;

% clr = ['r', 'g', 'b', 'm', 'y'];
% mrk = ['+', 'o', '*', 's', 'd'];
% for i=1:5
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