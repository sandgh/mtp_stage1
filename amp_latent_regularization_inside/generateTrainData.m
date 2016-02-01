
function [data] =  generateTrainData(samples, isMixed)

if(isMixed == 0)
    %% Separated Data Generaation- 

    mu = [-1 -1]; Sigma = [3 1; 1 2];
    r1 = mvnrnd(mu, Sigma, samples);
    figure(1);plot(r1(:,1),r1(:,2),'ro'); 

    hold on;

    mu = [24 15]; Sigma = [1 0; 0 9];
    r2 = mvnrnd(mu, Sigma, samples);
    plot(r2(:,1),r2(:,2),'b+');

    mu = [10 10]; Sigma = [3 0; 0 3];
    r3 = mvnrnd(mu, Sigma, samples);
    plot(r3(:,1),r3(:,2),'y*');

else
    %% Mixture Data Generation-
    %%% high overlapping
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
    
    %%% low overlapping
     mu = [-2.5 1.5]; Sigma = [4 1; 1 3];
    r1 = mvnrnd(mu, Sigma, samples);
    figure(1);plot(r1(:,1),r1(:,2),'ro'); 

    hold on;

    mu = [9 -2]; Sigma = [3 0; 0 5];
    r2 = mvnrnd(mu, Sigma, samples);
    plot(r2(:,1),r2(:,2),'b+');

    mu = [6 8]; Sigma = [3 0; 0 3];
    r3 = mvnrnd(mu, Sigma, samples);
    plot(r3(:,1),r3(:,2),'y*');

end
data = [r1,ones(samples,1),zeros(samples,1),zeros(samples,1);r2,zeros(samples,1),ones(samples,1),zeros(samples,1);r3,zeros(samples,1),zeros(samples,1),ones(samples,1)];

%% Shuffle data
data = data(randperm(size(data,1)),:);

hold off;
drawnow;
end
