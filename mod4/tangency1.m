clear all
clc

N = 30;                     % number of assets
T = 120000;                     % number of months
rho = 0.6;                  % return correlation across assets
e = 0.01;                   % expected excess returns, monthly
sigma = 0.01;               % standard deviation of returns, monthly

% Construct true E and V
E = e*ones(N,1);
V = sigma^2*(eye(N) + ones(N,N)*rho - diag(ones(N,1))*rho);  

% True tangency portfolio weights
w_TP_true = inv(V)*E/(ones(1,N)*inv(V)*E);

% MVP
(inv(V) * ones(N, 1)) / (ones(1,N) * inv(V) * ones(N, 1))

% Simulate excess returns on N assets in T periods, R~N(E,V)
R = e + randn(T,N)*chol(V);    

% Sample estimates, Ehat and Vhat
Ehat = mean(R)';
Vhat = cov(R);

% Estimated tangency portfolio weights
w_TP_estim = inv(Vhat)*Ehat/(ones(1,N)*inv(Vhat)*Ehat);

% Print results
disp('[True TP weights  Estimated TP weights]')
fprintf(['\n'])
disp([w_TP_true w_TP_estim])
fprintf(['\n'])
