% Global sensitivity analysis
% Calculating the first-order Sobol' indices of 9 input variables that are
% used to simulate DMS concentration.
% Created by SQ Zhou.

FO_Sobol_random = cell(1,9);

global netS
netS=netSet; % netSet is the cell array containing the trained neural networks
for i=1:9
    % Creating two independent input matrixes by area-weighted random
    % sampling.
    input_sample1=NaN(2e5,9);
    input_sample2=NaN(2e5,9);
    % "grid" contains the information of 42947 grids covering the global
    % ocean, and the column 1 to 6 refers to latitude, longtitude, area,
    % and index of Longhurst province, biome, and biomes further divided
    % into 9 oceanic regions
    w = ones(366,1)*grid(grid(:,6)==i,3)';
    FO_Sobol_random{i} = NaN(50,9);
    for t=1:50
        for j=1:9
             % "parameters" is the input dataset of the year 2008
            temp = parameters(:,grid(:,6)==i,j);
            y1 = randsample(temp(:),500000,true,w(:));
            y2 = randsample(temp(:),500000,true,w(:));
            
            % exclude the samples with empty elements or outliers
            y1(isnan(y1))=[];
            y2(isnan(y2))=[];
            y1(or(y1<para_region{i}(7,j),y1>para_region{i}(8,j)))=[];
            y2(or(y2<para_region{i}(7,j),y2>para_region{i}(8,j)))=[];
            
            input_sample1(:,j) = y1(1:200000);
            input_sample2(:,j) = y2(1:200000);
        end
        FO_Sobol_random{i}(t,:) = Sen_FirstOrder_Sobol_07(input_sample1, input_sample2, @mymodel);
        % The function Sen_FirstOrder_Sobol_07 is created by Chenzhao Li
        % and can be downloaded from https://github.com/VandyChris/Global-Sensitivity-Analysis
        
        disp(['Region ',num2str(i),', times ',num2str(t),' has been completed. ',datestr(now,0)]);
    end
end