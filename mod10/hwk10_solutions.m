% Modify this program as necesary to generate solutions for Assignment 10 for Portfolio Management. 
clear all
close all
clc
beg_date = 19940301;
beg_capital = 50;
moneyness = 0.8;
target_ret = 0.04;
tb_ret = 0.0001;

load sp500_daily.txt
dates = sp500_daily(:,1);
sp_rets = sp500_daily(:,2);
sp_prices = sp500_daily(:,3);
year = floor(dates/10000);
month = floor((dates-year*10000)/100);
day = mod(dates,100);
sigma = std(sp_rets);
last_day_of_month = [diff(month); -99]~=0;
frst_day_of_year = [-99; diff(year)]~=0;


%%%%% What happens on the day the hedge fund is started %%%%%
idate = find(dates==beg_date);
if isempty(idate)
    fprintf(['\n'])
    disp('You picked a starting date on which the stock market was closed.')
    disp('Please pick a different starting date (beg_date).')
    break    
end
S = sp_prices(idate);    
K = S*moneyness;
T = 60;
d1 = ( log(S/K) + (tb_ret + (sigma^2)/2)*T ) / (sigma*sqrt(T));
d2 = d1 - sigma*sqrt(T);    
bs_call = S*normcdf(d1) - K*exp(-T*tb_ret)*normcdf(d2);     % Black-Scholes
bs_put = bs_call + K*exp(-T*tb_ret) - S;                     % Put-call parity
capital = beg_capital;
N = target_ret*capital/bs_put;
capital = capital*(1+target_ret);
bs_put_old = bs_put;

%%%%%% What happens on each following day %%%%%
capitals_d = capital;
capitals_m = capital;
compens_m = 0;
sp_m = S;
ret_m = [];
ret_sp_m = [];
thedate = dates(idate);
while capital>0 & thedate<=20151229
    idate = idate + 1;
    thedate = dates(idate);   
    S = sp_prices(idate); 
    capital = capital*(1+tb_ret);
    
    if last_day_of_month(idate)   
        % Buy back your one-month-old options to close out your position
        T = 30;
        d1 = ( log(S/K) + (tb_ret + (sigma^2)/2)*T ) / (sigma*sqrt(T));
        d2 = d1 - sigma*sqrt(T);    
        bs_call = S*normcdf(d1) - K*exp(-T*tb_ret)*normcdf(d2);    
        bs_put_new = bs_call + K*exp(-T*tb_ret) - S;                 
        put_cost = N*bs_put_new;
        capital = capital - put_cost;      
       
        % Write new options
        K = S*moneyness;
        T = 60;
        d1 = ( log(S/K) + (tb_ret + (sigma^2)/2)*T ) / (sigma*sqrt(T));
        d2 = d1 - sigma*sqrt(T);    
        bs_call = S*normcdf(d1) - K*exp(-T*tb_ret)*normcdf(d2);    
        bs_put = bs_call + K*exp(-T*tb_ret) - S;                     
        N = target_ret*capital/bs_put;
        capital = capital*(1+target_ret);

        if capital>0 
            % Compute monthly returns, compensation
            old_cap = capitals_m(end);
            new_cap = capital;
            ret = (new_cap-old_cap)/old_cap;
            compens = (0.02/12 + 0.2*max(ret-21*tb_ret,0))*old_cap;
            ret_m = [ret_m; ret];
            compens_m = [compens_m; compens];    
            capital = capital - compens;
            capitals_m = [capitals_m; capital];
            old_sp = sp_m(end);
            new_sp = S;
            ret = (new_sp-old_sp)/old_sp;
            ret_sp_m = [ret_sp_m; ret];
            sp_m = [sp_m; S];   
        end
    end
    capitals_d = [capitals_d; capital];
end
pos = sum(ret_m>0)/sum(ret_m>-inf);
sr_riteput = mean(ret_m-21*tb_ret)/std(ret_m);
sr_sp = mean(ret_sp_m-21*tb_ret)/std(ret_sp_m);
tot_comp = sum(compens_m);
%figure(1)
%subplot(2,1,1)
%end_date = thedate;
%alive = find(dates>=beg_date & dates<=end_date);
%plot(alive,capitals_d,'-',alive,zeros(size(alive)),'--');
%set(gca,'XLim',[alive(1)-20 alive(end)+30])
%set(gca,'YLim',[-10 max(capitals_d)+20])
%f1 = find(frst_day_of_year);
%v = f1(f1>=alive(1) & f1<=alive(end));
%set(gca,'XTick',v);
%set(gca,'XTickLabel',year(v));
%title(['Riteput''s capital']);
%subplot(2,1,2)
%tt = 1:size(compens_m,1);
%plot(tt,compens_m,'-');
%set(gca,'XLim',[tt(1)-1 tt(end)+1])
%set(gca,'XTick',[]);
%set(gca,'XTickLabel',[]);
%title(['Your monthly compensation ($ million)']);
%figname = ['riteput_' int2str(beg_date) '_' int2str(100*moneyness)];
%set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
%eval(['print -deps2 ' figname]); 
