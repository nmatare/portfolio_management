clear all
clc
 
W = 10;                 % window (years) over which moving averages are computed
period = 1927:2016;     % time period between 1927 and 2016

x = load('momentum_1927_2016.txt');     
years = x(:,1);
yrs = find(ismember(years,intersect(period,years)));
wml = x(yrs,2);        
T = size(wml,1);         

means = mean(wml);
stds = std(wml);
sder = stds/sqrt(T);        
tmom = means/sder;          

disp([int2str(period(1)) '-' int2str(period(end))]);
fprintf(['\n']) % insert an empty line
disp('Average momentum return (Winners Minus Losers)');
disp(means)
disp('Std dev of momentum returns (Winners Minus Losers)');
disp(stds)
disp('t-statistic')
disp(tmom)
fprintf(['\n']) % insert an empty line
fprintf(['\n']) % insert an empty line

% Compute alphas and betas
x = load('ff_factors_1927_2016.txt');   % load FF factors
mkt = x(yrs,2);    % excess market rets; pick the subperiod specified in 'period'
smb = x(yrs,3);
hml = x(yrs,4);
rf = x(yrs,5);

% CAPM
Y = wml;
X = [ones(T,1) mkt];        % Tx2
Bhat = X\Y;                 % 2x1
alpha_cm = Bhat(1,1)
beta_cm = Bhat(2,1)
% Compute standard errors for alpha
Sigmahat = (1/T)*(Y - X*Bhat)'*(Y - X*Bhat);    
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));        
bhat = reshape(Bhat,2,1);          
tstats = bhat./serrs;                
t_alpha_cm = tstats(1)
    
% FF
X = [ones(T,1) mkt smb hml];        % Tx4
Bhat = X\Y;                         % 4x1
alpha_ff = Bhat(1,1)
beta_ff = Bhat(2:4,1)
% Compute standard errors for alpha
Sigmahat = (1/T)*(Y - X*Bhat)'*(Y - X*Bhat);    
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));        
bhat = reshape(Bhat,4,1);          
tstats = bhat./serrs;                
t_alpha_ff = tstats(1)
    
% Plot moving averages of WML
mov_avg_wml = nan*ones(T,1);
for t=1+W:T
    mov_avg_wml(t) = mean(wml(t-W+1:t)); 
end
figure(1)
plot(1:T,mov_avg_wml,'-',1:T,zeros(T,1),'-');
set(gca,'FontSize',10)
set(gca,'XLabel',text(0,0,'Y e a r'))
set(gca,'YLabel',text(0,0,'M o m e n t u m   ( %  p e r  y e a r )'))
set(gca,'XLim',[9 T])
%set(gca,'YLim',[0 ytop])
v = [4:10:T];
set(gca,'XTick',v);
set(gca,'XTickLabel',period(v));
figname = ['mom_a_movavg_' int2str(period(1)) '_' int2str(period(end)) '_' int2str(W)];
set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
eval(['print -deps2 ' figname]); 
