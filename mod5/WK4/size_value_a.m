clear all
clc
 
period = 1927:2016;     % time period between 1927 and 2016
%period = 1980:2016;     % time period between 1927 and 2016

x = load('ff25_1927_2016.txt');     % load returns on B/M-sorted portfolios
years = x(:,1);
ret = x(:,2:26);        % 5x5=25 portfolios

yrs = find(ismember(years,intersect(period,years)));
r = ret(yrs,:);         % pick the subperiod specified in 'period'
T = size(r,1);          % number of years

r2 = [r r(:,5)-r(:,1) r(:,10)-r(:,6) r(:,15)-r(:,11) r(:,20)-r(:,16) r(:,25)-r(:,21)];
r2 = [r2 r(:,1)-r(:,21) r(:,2)-r(:,22) r(:,3)-r(:,23) r(:,4)-r(:,24) r(:,5)-r(:,25)];

means = mean(r2);
stds = std(r2);
ts = sqrt(T)*means./stds;        % t-stat

means25 = reshape(means(1:25),5,5);
means25 = [means25 [means(31); means(32); means(33); means(34); means(35)]; ...
    [means(26) means(27) means(28) means(29) means(30) -99]];

fprintf(1,'means25 \n')
for j=1:6
    fprintf(1,'%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\n',means25(j,:)) 
end

ts25 = reshape(ts(1:25),5,5);
ts25 = [ts25 [ts(31); ts(32); ts(33); ts(34); ts(35)]; [ts(26) ts(27) ts(28) ts(29) ts(30) -99]];

fprintf(1,'ts25 \n')
for j=1:6
    fprintf(1,'%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\n',ts25(j,:)) 
end

% Load FF factors
x = load('ff_factors_1927_2016.txt');   
mkt = x(yrs,2);    % excess market rets; pick the subperiod specified in 'period'
smb = x(yrs,3);
hml = x(yrs,4);
rf = x(yrs,5);

Y = r - rf*ones(1,25);       % Tx25; excess portfolio returns
Y = [Y r2(:,26:35)];         % Tx35
N = size(Y,2);

% Compute CAPM alphas and betas
X = [ones(T,1) mkt];         % Tx2
k = size(X,2);               % k=2
Bhat = X\Y;                  % 2x35, regression estimates
alphas_cm = Bhat(1,:);
betas_cm = Bhat(2,:);
% Compute standard errors for alpha
Sigmahat = (1/T)*(Y - X*Bhat)'*(Y - X*Bhat);    
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));        
bhat = reshape(Bhat,k*N,1);          
tstats = bhat./serrs;                
t_alphas_cm = tstats(1:k:end)';

alphas_cm25 = reshape(alphas_cm(1:25),5,5);
alphas_cm25 = [alphas_cm25 [alphas_cm(31); alphas_cm(32); alphas_cm(33); alphas_cm(34); alphas_cm(35)]; ...
 [alphas_cm(26) alphas_cm(27) alphas_cm(28) alphas_cm(29) alphas_cm(30) -99]];

fprintf(1,'alphas_cm25 \n')
for j=1:6
    fprintf(1,'%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\n',alphas_cm25(j,:)) 
end

t_alphas_cm25 = reshape(t_alphas_cm(1:25),5,5);
t_alphas_cm25 = [t_alphas_cm25 [t_alphas_cm(31); t_alphas_cm(32); t_alphas_cm(33); t_alphas_cm(34); t_alphas_cm(35)]; ...
 [t_alphas_cm(26) t_alphas_cm(27) t_alphas_cm(28) t_alphas_cm(29) t_alphas_cm(30) -99]];

fprintf(1,'t_alphas_cm25 \n')
for j=1:6
    fprintf(1,'%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\n',t_alphas_cm25(j,:)) 
end

% Compute FF alphas and betas
X = [ones(T,1) mkt smb hml];         % Tx4
k = size(X,2);                      % k=4
Bhat = X\Y;                  % 4x35, regression estimates
alphas_ff = Bhat(1,:);
betas_ff = Bhat(2,:);
% Compute standard errors for alpha
Sigmahat = (1/T)*(Y - X*Bhat)'*(Y - X*Bhat);    
xtxi = inv(X'*X);                             
serrs = sqrt(diag(kron(Sigmahat,xtxi)));        
bhat = reshape(Bhat,k*N,1);          
tstats = bhat./serrs;                
t_alphas_ff = tstats(1:k:end)';

alphas_ff25 = reshape(alphas_ff(1:25),5,5);
alphas_ff25 = [alphas_ff25 [alphas_ff(31); alphas_ff(32); alphas_ff(33); alphas_ff(34); alphas_ff(35)]; ...
 [alphas_ff(26) alphas_ff(27) alphas_ff(28) alphas_ff(29) alphas_ff(30) -99]];

fprintf(1,'alphas_ff25 \n')
for j=1:6
    fprintf(1,'%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\n',alphas_ff25(j,:)) 
end

t_alphas_ff25 = reshape(t_alphas_ff(1:25),5,5);
t_alphas_ff25 = [t_alphas_ff25 [t_alphas_ff(31); t_alphas_ff(32); t_alphas_ff(33); t_alphas_ff(34); t_alphas_ff(35)]; ...
 [t_alphas_ff(26) t_alphas_ff(27) t_alphas_ff(28) t_alphas_ff(29) t_alphas_ff(30) -99]];

fprintf(1,'t_alphas_ff25 \n')
for j=1:6
    fprintf(1,'%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\n',t_alphas_ff25(j,:)) 
end

% The GRS tests
[g1 p1]=grs_test(Y,mkt);    % test CAPM
disp(p1)
[g2 p2]=grs_test(Y,[mkt smb hml]);  % test FF
disp(p2)


