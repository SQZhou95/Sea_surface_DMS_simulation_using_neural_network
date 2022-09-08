% This script is used to train the artifial neural network (ANN) for 
% simulating DMS concentrations. Created by SQ Zhou.
% Y_bin is the target (log10(DMS)). X_bin refers to preditors (inputs). Each row is
% one sample.

% Randomly select 5% samples to be excluded from training.
index_out = randperm(length(Y_bin),round(0.05*length(Y_bin)));
index_out = (sort(index_out))';
x = X_bin';
x(:,index_out)=[];
t = Y_bin';
t(index_out)=[];

% Standarization. The mean and std of inputs and target should be used in 
% subsequent ANN simulation.
x = zscore(x,0,2); %标准化
t = zscore(t,0,2);

x_mean = mean(x,2);
x_std = std(x,0,2);
t_mean = mean(t);
t_std = std(t);

% ANN training for 100 times, and each training session started
% independently.
% Ysim --> the output of each session
% netSet --> 100 trained networks
Ysim=NaN(length(t),100);
netSet=cell(100,1);

for i=1:100
    trainFcn = 'trainlm';  % Levenberg-Marquardt
    
    % Create a Fitting Network
    hiddenLayerSize = 20;
    net = fitnet(hiddenLayerSize,trainFcn);
    
    % Setup Division of Data for Training, Validation, Testing
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;
    
    % Train the Network
    [net,tr] = train(net,x,t);
    
    % Test the Network
    y = net(x);
    e = gsubtract(t,y);
    performance = perform(net,t,y);
    
    Ysim(:,i)=y';
    
    netSet{i}=net;
end

x = x';
t = t';
