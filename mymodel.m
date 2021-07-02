function y=mymodel(x)
% the mean and std of each input variable in training dataset
x_mean = [-0.401683117170400;10.9634186182346;1.55644457546536;0.514100423515089;-0.213933399463502;0.844106097722622;288.374673791912;193.597131397280;33.6938182453687];
x_std = [0.466081637250410;8.47537062745524;0.310463562366853;0.757147996921099;0.385965637340045;0.565870817030699;49.1276286211894;77.2574674260594;1.29821952503464];

% the mean and std of the target variable in training dataset
t_mean = 0.432707144419365;
t_std = 0.430129569149648;

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