% Partial dependence plot (PDP) for analyzing the relationships between DMS
% and 9 environmental factors for different oceanic regions.
% Created by SQ Zhou.

global netS
netS = netSet; % netSet is the cell array containing the trained neural networks

DMS_limit = [-1; 2];
DMS_interval = (DMS_limit(2) - DMS_limit(1))/100;

grid_count_region_rand = NaN(9,9,102,102);% The final density matrix of the DMS corresponding to the 9 input variables 
Xgrid_region = NaN(9,9,102,102); % The x matrix when plotting, corresponding to the input variable 
Ygrid_region = NaN(9,9,102,102); % The y matrix when plotting, corresponding to DMS 
DMS_value_region_rand = NaN(9,9,102,7); % Statistics of DMS output. The 4th dimension:
% mean, std, prctile([50 25 75 2.5 97.5])

%%
for r = 1:9
    para_limit = para_region{r}(7:8,:); % The thresholds of input variables for PDP in different oceanic regions
    index_region = find(grid(:,6)==r);
    w = (ones(366,1)*grid(index_region,3)')';
    index = (1:length(index_region)*366)';
    for i = 1:9
        index_temp = randsample(index,800000,true,w(:));
        para = parameters(:,index_region,i)';
        para_temp = para(index_temp);
        
        % Excluding samples with outliers or void values
        index_out = find(or(or(para_temp<para_limit(1,i),para_temp>para_limit(2,i)),isnan(para_temp)));
        para_temp(index_out) = [];
        input_sample(:,i) = para_temp(1:2e5);
    end
    
    for i=1:102
        Ygrid_region(r,:,i,:)=DMS_limit(1)+DMS_interval*(i-1.5);
    end
    
    for i = 1:9
        para_interval = (para_limit(2,i)-para_limit(1,i))/100;
        input = input_sample;
        for j = 1:102
            input(:,i) = para_limit(1,i)+para_interval*(j-1); % The final input matrix
            Xgrid_region(r,i,:,j) = input(1,i)-0.5*para_interval;
            output = mymodel(input);
            for k = 1:102 % Counting
                low_limit = DMS_limit(1)+DMS_interval*(k-1.5);
                up_limit = DMS_limit(1)+DMS_interval*(k-0.5);
                index_k = find(and(output>=low_limit,output<up_limit));
                grid_count_region_rand(r,i,k,j) = length(index_k);
            end
            DMS_value_region_rand(r,i,j,:) = [mean(output) std(output) prctile(output,[50 25 75 2.5 97.5])];
            disp(['Region ',num2str(r),', Para ',num2str(i),', Step ',num2str(j),' has been completed. ',datestr(now,0)]);
        end
    end
    grid_count_region_rand(grid_count_region_rand==0) = NaN;
    
    % Density plotting
    grid_height = zeros(102,102);
    
    figure(r+1);
    set(gcf,'position',[100 0 720 640]);
    
    row=3; col=3;
    left_margin=0.06; right_margin=0.14;
    top_margin=0.02; bottom_margin=0.08;
    width=0.22; height=0.24;
    gap_h=(1-left_margin-right_margin-width*col)/(col-1);
    gap_v=(1-top_margin-bottom_margin-height*row)/(row-1);
    
    for i=1:9
        row_number=floor((i-0.5)/col)+1;
        col_number=i-(row_number-1)*col;
        h(i)=axes('Position',[left_margin + (width+gap_h) * (col_number-1),1 - top_margin - height*row_number - gap_v*(row_number-1),width,height]);
        surface(squeeze(Xgrid_region(r,i,:,:)),squeeze(Ygrid_region(r,i,:,:)),grid_height,squeeze(grid_count_region_rand(r,i,:,:)),'EdgeColor','none');
        axis([para_limit(1,i) para_limit(2,i) -1 2])
        box on
        colormap jet
        caxis([0 15000]);
        xlabel(titletemp{i}); % titletemp is the name of each input variable
        ylabel('log10(DMS (nM))');
    end
    axes('position', [0.68, 0.3, 0.3, 0.4]);
    axis off;
    h=colorbar('v');
    caxis([0 20000]);
    set(h,'FontSize',12)
end
