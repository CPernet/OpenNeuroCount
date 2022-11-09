% dependency on rst_toolbox https://github.com/CPernet/Robust_Statistical_Toolbox/tree/dev

datain  = jsondecode(fileread("combined_by_ds.json"));
ds      = fieldnames(datain);
sizes   = jsondecode(fileread("sizes.json"));
keep    = fieldnames(sizes);
dataout = NaN(size(ds,1),36);

for  d = 1:size(ds,1)
    if contains(ds{d},keep)
        dsstruct = datain.(ds{d});
        size_index = contains(keep,ds{d});

        if isfield(dsstruct,'x2020')
            for c=1:12
                if isfield(dsstruct.x2020, ['x' num2str(c)])
                    dataout(d,c) = dsstruct.x2020.(['x' num2str(c)])/ sizes.(keep{size_index});
                end
            end
        end

        if isfield(dsstruct,'x2021')
            for c=1:12
                if isfield(dsstruct.x2021, ['x' num2str(c)])
                    dataout(d,c+12) = dsstruct.x2021.(['x' num2str(c)])/ sizes.(keep{size_index});
                end
            end
        end

        if isfield(dsstruct,'x2022')
            for c=1:12
                if isfield(dsstruct.x2022, ['x' num2str(c)])
                    dataout(d,c+24) = dsstruct.x2022.(['x' num2str(c)])/ sizes.(keep{size_index});
                end
            end
        end
    end
end
clean = find(nansum(dataout,2) == 0);
dataout(clean,:) = []; 
clean = find(nansum(dataout,1) == 0);
dataout(:,clean) = []; 

total = nansum(dataout,2);
[~,~,outliers]=rst_data_plot(total,'estimator','trimmed mean','kernel','off'); close gcf
dataout(outliers,:) = []; 

for d=size(dataout,2):-1:1    
    [ql(d),qu(d)]=rst_idealf(dataout(:,d));
end

figure; subplot(1,3,1:2)
plot(1:size(dataout,2),nanmedian(dataout),'LineWidth',2); axis tight; grid on; box on; hold on
xticks([1 13 25]); xticklabels({'2020','2021','2022'}); xlabel('months')
ylabel('download estimate (bytes/size)'); title('1st and 4th quartile with median download count since 2020')
fillhandle = patch([1:size(dataout,2) fliplr(1:size(dataout,2))], [ql,fliplr(qu)], [0 1 0]);
set(fillhandle,'EdgeColor',[0 1 0],'FaceAlpha',0.2,'EdgeAlpha',0.8,'LineWidth',2);%set edge color
subplot(1,3,3); [~]= rst_data_plot(nansum(dataout,2),'estimator','median','newfig','no'); 
title('median total download with 95% HDI','FontSize',12)

%% what we really want, is not based on date but based from time it is available

realigned_data = NaN(size(dataout,1),size(dataout,2));
for d=size(dataout,1):-1:1
    check = isnan(dataout(d,:));
    if check(1) 
        tmp = dataout(d,~isnan(dataout(d,:)));
        realigned_data(d,1:length(tmp)) = tmp;
    else
        realigned_data(d,:) = dataout(d,:);
    end
end

% redo the total, this time to split data into 3 groups
total = nansum(realigned_data,2);
figure, subplot(4,3,[3 6 9]);
[est,HDI,outliers]=rst_data_plot(total,'estimator','mean','newfig','no');
title('average total download with 95% HDI','FontSize',12)

% gp1 = realigned_data(total<HDI(1),:);
% gp2 = realigned_data(((total<HDI(1))+(total>HDI(2)))==0,:);
% gp3 = realigned_data(total>HDI(2),:);

lt = mean(total)-prctile(total,25);
gp1 = realigned_data(total<lt,:);
gp2 = realigned_data(((total=<HDI(1))+(total>=HDI(2)))==0,:);
gp3 = realigned_data(outliers,:); % equivalent to ht = mean(total)+prctile(total,75);

subplot(4,3,[1 2 4 5 7 8]); 
ft = fittype( 'poly2' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'Bisquare';
x = 1:size(realigned_data,2);
fitresult = fit(x', nanmean(gp1)', ft, opts); 
plot(x,nanmean(gp1),'--ob'); axis tight; grid on; box on; hold on
plot(polyval([fitresult.p1 fitresult.p2 fitresult.p3 ],x),'b','LineWidth',2)

fitresult = fit(x', nanmean(gp2)', ft, opts); 
plot(x,nanmean(gp2),'--og'); axis tight; grid on; box on; hold on
plot(polyval([fitresult.p1 fitresult.p2 fitresult.p3 ],x),'g','LineWidth',2)

fitresult = fit(x', nanmean(gp3)', ft, opts); 
plot(x,nanmean(gp3),'--or'); axis tight; grid on; box on; hold on
plot(polyval([fitresult.p1 fitresult.p2 fitresult.p3 ],x),'r','LineWidth',2)

xticks([1 13 25]); xticklabels({'1','13','24'}); 
ylabel('download estimate (bytes/size)'); title('mean download count per months for high/medium/low accessed dataset')

subplot(4,3,[10 11]); 
bar(x,sum(~isnan(realigned_data)),'FaceColor',[0.5 0.5 1]);
axis tight; ylabel('data set count'); grid on; box on
xticks([1 13 25]); xticklabels({'1','13','24'}); xlabel('months')

fprintf('smaller time period %g months\n',min(sum(~isnan(realigned_data),2)))
fprintf('longer time period %g months\n',max(sum(~isnan(realigned_data),2)))
fprintf('%g of datasets have above 2 years duration \n',...
    sum(sum(~isnan(realigned_data),2) >=24)/size(realigned_data,1)*100)
fprintf('%g of datasets have ~%g downloads, totalizing %g of all downloads \n',...
    sum(outliers)/size(realigned_data,1)*100,mean(total(outliers)),sum(total(outliers))/sum(total)*100)
