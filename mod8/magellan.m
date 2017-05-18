% This program analyzes the performance of Fidelity Magellan

clear all
close all
clc

show_alpha_CAPM_FF = 1;
show_corr = 0;
show_timing = 0;
show_betas = 0;
show_alphas = 0;
show_r2s = 0;
show_rets = 0;
show_tna = 0;

%begperiod = 196306;    % Magellan born
%endperiod = 197704;    % just before Lynch took over
    begperiod = 197705;     % Peter Lynch begins
    endperiod = 199005;     % Peter Lynch ends
    %begperiod = 199006;    % since Peter Lynch quit
    %endperiod = 200612;    % until end of sample
    %begperiod = 200101;    % last 6 years begins
    %endperiod = 200612;    % last 6 years ends
%begperiod = 199207;    % Jeff Vinik begins
%endperiod = 199605;    % Jeff Vinik ends
%begperiod = 199606;    % Bob Stansky begins
%endperiod = 200509;    % Bob Stansky ends
%begperiod = 200510;    % Harry Lange begins
%endperiod = 200612;    % Harry Lange ends

% Load data
load magellan_ret_tna.txt               % 523x3, 6/1963-12/2006
load ff_factors_192607_200612.txt
load momentum_192701_200612.txt

%%%%% Pick data for the selected subperiod

months_ma = kron((1963:2006)',ones(12,1))*100 + kron(ones(2006-1963+1,1),(1:12)');
months_ma = months_ma(6:end);               % 196306:200612
months_ff = ff_factors_192607_200612(:,1);  % 192607:200612
months_mo = momentum_192701_200612(:,1);    % 192701:200612

beg_ma = find(months_ma==begperiod);
end_ma = find(months_ma==endperiod);
rmag = magellan_ret_tna(beg_ma:end_ma,2);   
tna_mag = magellan_ret_tna(beg_ma:end_ma,3);   
mon_mag = months_ma(beg_ma:end_ma,1);   

beg_ff = find(months_ff==begperiod);
end_ff = find(months_ff==endperiod);
mkt = ff_factors_192607_200612(beg_ff:end_ff,2)/100;    
smb = ff_factors_192607_200612(beg_ff:end_ff,3)/100;    
hml = ff_factors_192607_200612(beg_ff:end_ff,4)/100;    
rfr = ff_factors_192607_200612(beg_ff:end_ff,5)/100;    

beg_mo = find(months_mo==begperiod);
end_mo = find(months_mo==endperiod);
wml = momentum_192701_200612(beg_mo:end_mo,2)/100;    

% Magellan's average return, std deviation
T = size(rmag,1);                     
avgret_mag = mean(rmag);
std_mag = std(rmag);
t_avgret_mag = sqrt(T)*mean(rmag)/std(rmag);

%%%%% Compute alphas and betas

Y = rmag - rfr;

% CAPM
X = [ones(T,1) mkt];        
Bhat = X\Y;                  
alpha_cm = Bhat(1);
betas_cm = Bhat(2);
e = Y - X*Bhat;
r2_cm = 1 - var(e)/var(Y);
Sigmahat = (1/T)*e'*e;   
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));      
%bhat = reshape(Bhat,2,1);                      
tstats = Bhat./serrs;                         
t_alpha_cm = tstats(1);
t_betas_cm = tstats(2);

% FF
X = [ones(T,1) mkt smb hml];        
Bhat = X\Y;                  
alpha_ff = Bhat(1);
betas_ff = Bhat(2:4);
e = Y - X*Bhat;
r2_ff = 1 - var(e)/var(Y);
Sigmahat = (1/T)*e'*e;   
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));      
tstats = Bhat./serrs;                         
t_alpha_ff = tstats(1);
t_betas_ff = tstats(2:4);

% 4F
X = [ones(T,1) mkt smb hml wml];        
Bhat = X\Y;                  
alpha_4f = Bhat(1);
betas_4f = Bhat(2:5);
e = Y - X*Bhat;
r2_4f = 1 - var(e)/var(Y);
Sigmahat = (1/T)*e'*e;   
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));      
tstats = Bhat./serrs;                         
t_alpha_4f = tstats(1);
t_betas_4f = tstats(2:5);

%%%%% Market timing

% Treynor-Mazuy
X = [ones(T,1) mkt mkt.^2];        
Bhat = X\Y;                  
gamma_tm = Bhat(3);
e = Y - X*Bhat;
Sigmahat = (1/T)*e'*e;   
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));      
%bhat = reshape(Bhat,2,1);                      
tstats = Bhat./serrs;                         
t_gamma_tm = tstats(3);

% Henriksson-Merton
X = [ones(T,1) mkt mkt.*(mkt>0)];     
Bhat = X\Y;                  
gamma_hm = Bhat(3);
e = Y - X*Bhat;
Sigmahat = (1/T)*e'*e;   
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));      
%bhat = reshape(Bhat,2,1);                      
tstats = Bhat./serrs;                         
t_gamma_hm = tstats(3);

%%%%% Print output

disp([int2str(begperiod) '-' int2str(endperiod)]);
fprintf(['\n']) % insert an empty line
if show_rets
    disp('Magellan''s average return');
    disp(1200*avgret_mag)
    disp('t-statistic');
    disp(t_avgret_mag)
end
if show_alpha_CAPM_FF
    disp('Magellan''s CAPM and Fama-French alphas (% per year):')
    fprintf(['\n']) 
    disp('    CAPM   Fama-French')
    disp(1200*[alpha_cm alpha_ff])
    disp('t-statistics:')
    fprintf(['\n']) 
    disp([t_alpha_cm t_alpha_ff])
    fprintf(['\n']) 
end
if show_alphas
    disp('Magellan''s alphas (% per year):')
    fprintf(['\n']) 
    disp('    CAPM   Fama-French  4-factor (FF+momentum)')
    disp(1200*[alpha_cm alpha_ff alpha_4f])
    disp('t-statistics:')
    fprintf(['\n']) 
    disp([t_alpha_cm t_alpha_ff t_alpha_4f])
    fprintf(['\n']) 
end
if show_betas
    disp('Magellan''s betas:')
    fprintf(['\n']) 
    disp('      MKT       SMB      HML       WML')
    disp(betas_4f')
    disp('t-statistics:')
    fprintf(['\n']) 
    disp(t_betas_4f')
    fprintf(['\n']) 
end
if show_r2s
    disp('R-squareds:')
    fprintf(['\n']) 
    disp([r2_cm r2_ff r2_4f])
    fprintf(['\n']) 
end
if show_corr
    disp('Correlation between Magellan''s excess returns and market''s excess returns:')
    fprintf(['\n']) 
    cormx = corrcoef([rmag-rfr mkt]);
    disp(cormx(1,2))
    fprintf(['\n']) 
end
if show_timing
    disp('Market timing coefficients (gamma):')
    fprintf(['\n']) 
    disp('Treynor-Mazuy   Henriksson-Merton')
    disp([gamma_tm gamma_hm])
    disp('t-statistics:')
    fprintf(['\n']) 
    disp([t_gamma_tm t_gamma_hm])
    fprintf(['\n']) 
end
if show_tna
    yr_mag = floor(mon_mag/100);
    figure(1)      
    plot(1:T,tna_mag,'-');
    set(gca,'FontSize',10)
    set(gca,'XLabel',text(0,0,'Y e a r'))
    set(gca,'YLabel',text(0,0,'T N A   o f   M a g e l l a n  ( $ m i l l i o n s )'))
    set(gca,'XLim',[1 T])
    %set(gca,'YLim',[0 ytop])
    v = [1:60:T];
    set(gca,'XTick',v);
    set(gca,'XTickLabel',yr_mag(v));
end

