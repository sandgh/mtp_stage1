
function [data, datasize] =  generateTrainData(samples, isMixed)

%% class imbalance
samples1 = samples/6;
samples2 = samples;
samples3 = samples/20;
samples4 = samples/20;
% 
% samples1 = samples;
% samples2 = samples;
% samples3 = samples/10;
% samples4 = samples/10;


%%
if(isMixed == 0)
    %% Separated Data Generaation- 

%     mu = [-1 -1]; Sigma = [3 1; 1 2];
%     r1 = mvnrnd(mu, Sigma, samples);
%     figure(1);plot(r1(:,1),r1(:,2),'ro'); 
% 
%     hold on;
% 
%     mu = [24 15]; Sigma = [1 0; 0 9];
%     r2 = mvnrnd(mu, Sigma, samples);
%     plot(r2(:,1),r2(:,2),'b+');
% 
%     mu = [10 10]; Sigma = [3 0; 0 3];final
%     r3 = mvnrnd(mu, Sigma, samples);
%     plot(r3(:,1),r3(:,2),'y*');

else
    %% Mixture Data Generation-
    % concentric circular data
%      mu1 = [7 -1]; Sigma1 = [4 0; 0 4];
%     r2 = mvnrnd(mu1, Sigma1, samples2);
%     figure(1);plot(r2(:,1),r2(:,2),'b+');
%     title('Training Data');
%     hold on;
%     
%     mu2 = [-1.5 -1.5]; Sigma2 = [4 1; 1 3];
%     r1 = mvnrnd(mu2, Sigma2, samples1);
%     plot(r1(:,1),r1(:,2),'r+'); 
% 
%     mu3 = [6.5 -1]; Sigma3 = [1.5 0; 0 1];
%     r3 = mvnrnd(mu3, Sigma3, samples3);
%     plot(r3(:,1),r3(:,2),'y+');
% 
%     mu4 = [-2 -1.5]; Sigma4 = [1 0; 0 1];
%     r4 = mvnrnd(mu4, Sigma4, samples4);
%     plot(r4(:,1),r4(:,2),'g+');
%     hold off;
    
    %%% 4 Gussians high mixure
    mu1 = [9 -1]; Sigma1 = [8 0; 0 8];
    r2 = mvnrnd(mu1, Sigma1, samples2);
    figure(1);plot(r2(:,1),r2(:,2),'b+');
    title('Training Data');
    hold on;
    
    mu2 = [-1.5 -1.5]; Sigma2 = [4 1; 1 3];
    r1 = mvnrnd(mu2, Sigma2, samples1);
    plot(r1(:,1),r1(:,2),'r+'); 

    mu3 = [1 2]; Sigma3 = [1 0; 0 1.5];
    r3 = mvnrnd(mu3, Sigma3, samples3);
    plot(r3(:,1),r3(:,2),'y+');

    mu4 = [3 -5]; Sigma4 = [2.5 0; 0 1];
    r4 = mvnrnd(mu4, Sigma4, samples4);
    plot(r4(:,1),r4(:,2),'g+');
    hold off;
    
    
%     [X1,X2] = meshgrid(-10:20,-10:20);
%     figure;
%     F = mvnpdf([X1(:) X2(:)],mu1,Sigma1);
%     F = reshape(F,length(X2),length(X1));
%     surf(X1,X2,F);
%     caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
%     hold on;
%     
% %     [X1,X2] = meshgrid(r3(:,1),r3(:,2));
%     F = mvnpdf([X1(:) X2(:)],mu2,Sigma2);
%     F = reshape(F,length(X2),length(X1));
%     surf(X1,X2,F);
%     caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
%     
% %     [X1,X2] = meshgrid(r2(:,1),r2(:,2));
%     F = mvnpdf([X1(:) X2(:)],mu3,Sigma3);
%     F = reshape(F,length(X2),length(X1));
%     surf(X1,X2,F);
%     caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
%     
%     [X1,X2] = meshgrid(r1(:,1),r1(:,2));
%     F = mvnpdf([X1(:) X2(:)],mu4,Sigma4);
%     F = reshape(F,length(X2),length(X1));
%     surf(X1,X2,F);
%     caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
%      hold off;
%     
    %% 4 Gussians low mixure
%     samples1 = samples/12;
%     mu = [-2.5-2 -1.5-2]; Sigma = [4 0; 0 4];
%     r1 = mvnrnd(mu, Sigma, samples1);
%     figure(1);plot(r1(:,1),r1(:,2),'ro'); 
% 
%     hold on;
%     
% %     samples2 = samples/6;
%     mu = [7 -2-2]; Sigma = [3 0; 0 5];
%     r2 = mvnrnd(mu, Sigma, samples2);
%     plot(r2(:,1),r2(:,2),'b+');
%     
% %     samples3 = samples/3;
%     mu = [7+2 7+2]; Sigma = [3 0; 0 6];
%     r3 = mvnrnd(mu, Sigma, samples3);
%     plot(r3(:,1),r3(:,2),'y*');
%     
% %     samples4 = samples;
%     mu = [3-5 3+6]; Sigma = [5 0; 0 5];
%     r4 = mvnrnd(mu, Sigma, samples4);
%     plot(r4(:,1),r4(:,2),'gx');
    
    %% 3 Gussians high mixurefinal
%     mu = [2.5 1.5]; Sigma = [4 1; 1 3];
%     r1 = mvnrnd(mu, Sigma, samples);
%     figure(1);plot(r1(:,1),r1(:,2),'ro'); 
% 
%     hold on;
% 
%     mu = [7 -2]; Sigma = [3 0; 0 5];
%     r2 = mvnrnd(mu, Sigma, samples);
%     plot(r2(:,1),r2(:,2),'b+');
% 
%     mu = [6 6.5]; Sigma = [3 0; 0 3];
%     r3 = mvnrnd(mu, Sigma, samples);
%     plot(r3(:,1),r3(:,2),'y*');
    
    %% 3 Gussians low mixure
%     mu = [-2.5 1.5]; Sigma = [4 1; 1 3];
%     r1 = mvnrnd(mu, Sigma, samples);
%     figure(1);plot(r1(:,1),r1(:,2),'ro'); 
% 
%     hold on;
% 
%     mu = [9 -2]; Sigma = [3 0; 0 5];
%     r2 = mvnrnd(mu, Sigma, samples);
%     plot(r2(:,1),r2(:,2),'b+');
% 
%     mu = [6 8]; Sigma = [3 0; 0 3];
%     r3 = mvnrnd(mu, Sigma, samples);
%     plot(r3(:,1),r3(:,2),'y*');

end

%% Generate data
%%3 classes
% data = [r1,ones(samples,1),zeros(samples,1),zeros(samples,1);r2,zeros(samples,1),ones(samples,1),zeros(samples,1);r3,zeros(samples,1),zeros(samples,1),ones(samples,1)];
%%4 classes
data = [r1,ones(samples1,1),zeros(samples1,1),zeros(samples1,1),zeros(samples1,1);r2,zeros(samples2,1),ones(samples2,1),zeros(samples2,1),zeros(samples2,1); ...
                        r3,zeros(samples3,1),zeros(samples3,1),ones(samples3,1),zeros(samples3,1);r4,zeros(samples4,1),zeros(samples4,1),zeros(samples4,1),ones(samples4,1)];
                    
% p1 = mvnpdf([r1; r2; r3; r4],mu1,Sigma1);
% p2 = mvnpdf([r1; r2; r3; r4],mu2,Sigma2);
% p3 = mvnpdf([r1; r2; r3; r4],mu3,Sigma3);
% p4 = mvnpdf([r1; r2; r3; r4],mu4,Sigma4);

% d=[r1;r2;r3;r4];
% 
% % norm(r1-mu1);
% 
% for i=1:size(d,1)
% 
%     final(i,1) = d(i,1); 
%     final(i,2) = d(i,2);
%     
%     if(sqrt((d(i,1)-mu1(1))^2 + (d(i,2)-mu1(2))^2) < 2*sqrt(det(Sigma1)))
%         final(i,3) = 1;
%     else 
%         final(i,3) = 0;
%     end
%     
%     if(sqrt((d(i,1)-mu2(1))^2 + (d(i,2)-mu2(2))^2) < 2*sqrt(det(Sigma2)))
%         final(i,4) = 1;
%     else 
%         final(i,4) = 0;
%     end
%     
%     if(sqrt((d(i,1)-mu3(1))^2 + (d(i,2)-mu3(2))^2) < 2*sqrt(det(Sigma3)))
%         final(i,5) = 1;
%     else 
%         final(i,5) = 0;
%     end
%     
%     if(sqrt((d(i,1)-mu4(1))^2 + (d(i,2)-mu4(2))^2) < 2*sqrt(det(Sigma4)))
%         final(i,6) = 1;
%     else 
%         final(i,6) = 0;
%     end
%     
% end
% 
% final_labels=final(:,3:6)';
% x=sum(final_labels);
% t=find(x==2);
% final(t,1:2)
% plot(final(t,1),final(t,2),'co');
% hold on;
% 
% t=find(x==3);
% final(t,1:2)
% plot(final(t,1),final(t,2),'mo');
% hold on;
% 
% t=find(x==4);
% final(t,1:2)
% plot(final(t,1),final(t,2),'ko');
% hold on;
% 
% t=find(x==0);
% final(t,1:2)
% plot(final(t,1),final(t,2),'wo');
% 
% hold off;


%% Shuffle data
data = data(randperm(size(data,1)),:);
% final = final(randperm(size(final,1)),:);
datasize = samples1+samples2+samples3+samples4;
% hold off;
% drawnow;
end
