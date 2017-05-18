% Modify this program as necessary to generate solutions for Assignment 8 in Portfolio Management. 
clear all
close all
clc
percentiles = [.10:.10:1];
n = size(percentiles,2);
load rets_hwk7
load flows_hwk7
% Initialize variables
nyears = size(rets,2)-1;
avgrets = -99*ones(n,nyears-1);
avgflows = -99*ones(n,nyears-1);
coefs = -99*ones(3,nyears-1);
tcoefs = -99*ones(3,nyears-1);
fitvals = -99*ones(n,nyears-1);
% Loop over years, 1992-2001
for yr = 2:nyears    
    rs = rets(2:end,yr);
    fs = flows(2:end,yr+1);    
    f = find(rs>-1 & fs>-1);
    rs = rs(f);
    fs = fs(f);
    % Sort funds into deciles by their returns in this year
    dec = zeros(size(rs));
    N = size(rs,1);
    [srs,irs] = sort(rs);
    begmark = 1;
    for ips = 1:n
        endmark = round(N*percentiles(ips));
        dec(irs(begmark:endmark)) = ips;
        begmark = round(N*percentiles(ips))+1;
    end    
    % Compute average returns and flows for each decile in this year
    avgret = -99*ones(n,1);
    avgflow = -99*ones(n,1);
    for j=1:n
        f = find(dec==j);
        avgret(j) = mean(rs(f));
        avgflow(j) = mean(fs(f));
    end;
    % Regression
    y = avgflow;
    x = [ones(n,1) avgret avgret.^2];
    coef = x\y;
    fitval = x*coef;
    e = y-fitval;
    se = sqrt(diag(inv(x'*x)*(e'*e)/(n-3)));
    tcoef = coef./se;
    % Record results
    coefs(:,yr-1) = coef;
    tcoefs(:,yr-1) = tcoef;
    fitvals(:,yr-1) = fitval;
    avgrets(:,yr-1) = avgret;
    avgflows(:,yr-1) = avgflow;
end
% Averages across years
avgavgrets = (mean(avgrets'))';
avgavgflows = (mean(avgflows'))';
fm_c = (mean(coefs'))';                 
fm_t = sqrt(n)*fm_c./(std(coefs')');    
avgfitvals = mean(fitvals')';
% Figures
%figure(1)
%plot(1:10,avgflows(:,end),'k-',1:10,fitvals(:,end),'r:')
%xlabel('Return Decile')
%ylabel('Net Flows')
%title('2002 Fund Flows As a Function of 2001 Return Deciles');
%figname = ['perf_flow_1'];
%set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
%eval(['print -deps2 ' figname]); 
%figure(2)
%plot(1:10,avgavgflows,'k-',1:10,avgfitvals,'r:')
%xlabel('Return Decile')
%ylabel('Net Flows')
%title('Fund Flows As a Function of Return Deciles - Averages Across Years');
%figname = ['perf_flow_2'];
%set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
%eval(['print -deps2 ' figname]); 
% Choosing between investments A and B
rA = 0.01;
rB1 = -0.35;    % is this right?
rB2 = 0.25;     % is this right?
p = 0.5;        % is this right?
exp_flow_A = fm_c(1) + fm_c(2)*rA + fm_c(3)*rA^2;     
exp_flow_B1 = fm_c(1) + fm_c(2)*rB1 + fm_c(3)*rB1^2;
exp_flow_B2 = fm_c(1) + fm_c(2)*rB2 + fm_c(3)*rB2^2;
exp_fund_size_A = 100*(1+rA)*(1+exp_flow_A); 
exp_fund_size_B = 100*( p*(1+rB1)*(1+exp_flow_B1) + (1-p)*(1+rB2)*(1+exp_flow_B2) );
exp_comp_A = 0.01*exp_fund_size_A;
exp_comp_B = 0.01*exp_fund_size_B;