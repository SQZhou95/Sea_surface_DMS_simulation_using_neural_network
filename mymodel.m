function y=mymodel(x)
% the mean and std of each input variable in training dataset
x_mean = [-0.404914936417546;10.9635658347150;1.55644698936310;0.514061274342741;-0.213956096366143;0.844093292859711;288.373510472313;193.596086824324;33.6938514936484];
x_std = [0.451496993796699;8.47528206361085;0.310458988220584;0.757168263979359;0.385981600495870;0.565866762523735;49.1273126820493;77.2564589619306;1.29821330257730];

% the mean and std of the target variable in training dataset
t_mean = 0.432695227822245;
t_std = 0.430126719887878;

global netS

a = NaN(size(x));
for i = 1:length(x_mean)
    a(:,i) = (x(:,i)-x_mean(i))/x_std(i);
end
a=a';

y_temp=NaN(size(x,1),length(netS));
for m=1:length(netS)
    y_temp(:,m)=(sim(netS{m},a))' * t_std + t_mean;
end
y=nanmean(y_temp,2);
end