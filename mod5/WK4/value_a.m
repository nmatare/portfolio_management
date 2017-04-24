clear all
clc
 
N = 10;                 % number of B/M-sorted portfolios: 3, 5, or 10
W = 10;                  % window (years) over which moving averages are computed
period = 1927:2016;     % time period between 1927 and 2016
%period = 1927:1981;     % time period between 1927 and 2016
%period = 1982:2016;     % time period between 1927 and 2016
%period = 1990:1999;     % time period between 1927 and 2016
%period = 2000:2016;     % time period between 1927 and 2016
pick_figures = [1 2 3 4 5];

x = load('value_1927_2016.txt');     % load returns on B/M-sorted portfolios
years = x(:,1);
ret3 = x(:,3:5);        % 3 portfolios: lo30%, med40%, hi30%
ret5 = x(:,6:10);       % 5 portfolios: quintiles
ret10 = x(:,11:20);     % 10 portfolios: deciles
eval(['ret = ret' int2str(N) ';'])    % pick the relevant returns matrix

yrs = find(ismember(years,intersect(period,years)));
r = ret(yrs,:);         % pick the subperiod specified in 'period'
T = size(r,1);          % number of years

means = mean(r)
stds = std(r);
dif = r(:,end) - r(:,1);    % last minus first portfolio returns
mdif = mean(dif)           % average return
sdif = std(dif)/sqrt(T);    % standard error
tdif = mdif/sdif           % t-stat

%disp([int2str(period(1)) '-' int2str(period(end))]);
%fprintf(['\n']) % insert an empty line
%disp('Average portfolio returns (Growth to Value)');
%disp(means)
%disp('Value-Growth average return:')
%disp(mdif)
%disp('t-statistic')
%disp(tdif)
%fprintf(['\n']) % insert an empty line
%fprintf(['\n']) % insert an empty line

if ismember(1,pick_figures)    
    % Plot average returns across portfolios
    figure(1)      
    bar(means)
    set(gca,'FontSize',10)
    set(gca,'XLabel',text(0,0,'B / M   P o r t f o l i o  ( G r o w t h   t o   V a l u e )'))
    set(gca,'YLabel',text(0,0,'A v e r a g e   A n n u a l   R e t u r n  ( % )'))
    set(gca,'XLim',[0 N+1])
    figname = ['value_a_means_' int2str(period(1)) '_' int2str(period(end))];
    set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
    eval(['print -deps2 ' figname]); 
end

if ismember(2,pick_figures)    
    % Plot standard deviations across portfolios
    figure(2)      
    bar(stds)
    set(gca,'FontSize',10)
    set(gca,'XLabel',text(0,0,'B / M   P o r t f o l i o  ( G r o w t h   t o   V a l u e )'))
    set(gca,'YLabel',text(0,0,'S t a n d a r d   D e v i a t i o n  ( % )'))
    set(gca,'XLim',[0 N+1])
    figname = ['value_a_stds_' int2str(period(1)) '_' int2str(period(end))];
    set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
    eval(['print -deps2 ' figname]); 
end

% Compute CAPM alphas and betas
x = load('ff_factors_1927_2016.txt');   % load FF factors
mkt = x(yrs,2);    % excess market rets; pick the subperiod specified in 'period'
smb = x(yrs,3);
hml = x(yrs,4);
rf = x(yrs,5);

Y = r - rf*ones(1,N);       % TxN; excess portfolio returns
Y = [Y Y(:,1)-Y(:,end)];    % add top minus bottom portfolio; Tx(N+1)
X = [ones(T,1) mkt];        % Tx2
Bhat = X\Y;                  % 2x(N+1), regression estimates
alphas = Bhat(1,:);
betas = Bhat(2,:);
% Compute standard errors for alpha
Sigmahat = (1/T)*(Y - X*Bhat)'*(Y - X*Bhat);    % (N+1)x(N+1)
xtxi = inv(X'*X);                             % 2x2
serrs = sqrt(diag(kron(Sigmahat,xtxi)));        % (2*(N+1))x1
bhat = reshape(Bhat,2*(N+1),1);          % (2*(N+1))x1  
tstats = bhat./serrs;                % (2*(N+1))x1 
t_alpha = tstats(1:2:end)';
    
if ismember(3,pick_figures)    
    % Plot betas across portfolios
    figure(3)      
    bar(betas(1:N))
    set(gca,'FontSize',10)
    set(gca,'XLabel',text(0,0,'B / M   P o r t f o l i o  ( G r o w t h   t o   V a l u e )'))
    set(gca,'YLabel',text(0,0,'M a r k e t   B e t a'))
    set(gca,'XLim',[0 N+1])
    figname = ['value_a_cm_betas_' int2str(period(1)) '_' int2str(period(end))];
    set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
    eval(['print -deps2 ' figname]); 
end

if ismember(4,pick_figures)    
    % Plot alphas across portfolios
    figure(4)      
    bar(alphas(1:N))
    set(gca,'FontSize',10)
    set(gca,'XLabel',text(0,0,'B / M   P o r t f o l i o  ( G r o w t h   t o   V a l u e )'))
    set(gca,'YLabel',text(0,0,'C A P M   A l p h a  (%  p e r  y e a r)'))
    set(gca,'XLim',[0 N+1])
    figname = ['value_a_cm_alphas_' int2str(period(1)) '_' int2str(period(end))];
    set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
    eval(['print -deps2 ' figname]); 
end

if ismember(5,pick_figures)    
    % Plot moving averages of the H-L difference
    mov_avg_dif = nan*ones(T,1);
    for t=1+W:T
       mov_avg_dif(t) = mean(dif(t-W:t));  % dif is Tx1
    end
    figure(5)
    plot(1:T,mov_avg_dif,'-',1:T,zeros(T,1),'-');
    set(gca,'FontSize',10)
    set(gca,'XLabel',text(0,0,'Y e a r'))
    set(gca,'YLabel',text(0,0,'V a l u e   P r e m i u m   ( %  p e r  y e a r )'))
    set(gca,'XLim',[9 T])
    %set(gca,'YLim',[0 ytop])
    v = [4:10:T];
    set(gca,'XTick',v);
    set(gca,'XTickLabel',period(v));
    figname = ['value_a_movavg_' int2str(period(1)) '_' int2str(period(end))];
    set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
    eval(['print -deps2 ' figname]); 
end