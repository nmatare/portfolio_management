clear all
clc

exhibit = 6;        % reproduce Exhibit 5 or 6
targetE = 0.065;    % target expected return (e.g., 0.065, 0.0675, or 0.07)

%%%%%%%%%% Assumed moments of returns from Exhibit 4 %%%%%%%%%%
E = (1/100)*[6.5 6.5 8.5 9.5 5.5 5.5 4.5 5.5 4.3 4.3 4.0 3.5]';    % assumed average real returns, 12x1
sig = (1/100)*[16 17 20 22 12 12 12 12 7 8 3 1]';                  % assumed standard deviations, 12x1
rho = [1 .50 .40 .40 .60 .55 -.05 .20 .40 .15 .10 .10;             % assumed correlations, 12x12
          0 1 .35 .30 .50 .35 -.05 .15 .25 .40 -.05 .05;
          0 0 1 .25 .30 .35 .00 .15 .15 .10 .00 .00;
          0 0 0 1 .30 .20 -.10 .15 .20 .10 .10 .05;
          0 0 0 0 1 .40 .00 .15 .30 .20 .20 .10;
          0 0 0 0 0 1 .10 .10 .45 .15 .30 .10;
          0 0 0 0 0 0 1 .00 -.15 -.10 .20 -.05;
          0 0 0 0 0 0 0 1 .20 .10 .20 .15;
          0 0 0 0 0 0 0 0 1 .40 .50 .15;
          0 0 0 0 0 0 0 0 0 1 .10 .10;
          0 0 0 0 0 0 0 0 0 0 1 -.10;
          0 0 0 0 0 0 0 0 0 0 0 1];
rho = rho + rho' - eye(size(rho));      % assumed correlation matrix
V = rho.*(sig*sig');                    % assumed covariance matrix

if exhibit==5
    % Choose lower and upper bounds as in Exhibit 5
    LB = [zeros(11,1); -0.5];   % lower bound: 0, except -50% for cash
    UB = ones(12,1);            % upper bound: 100%
elseif exhibit==6
    % Choose lower and upper bounds as in Exhibit 6
    % Can't deviate from old policy portfolio by more than 10%
    w_PP_old = (1/100)*[32 15 9 15 4 2 5 7 11 5 0 -5]'; % old Policy Portfolio weights, 12x1 (Exh.1); 11 is TIPS
    LB = w_PP_old - 0.10;  
    UB = w_PP_old + 0.10;   
    LB(11) = 0;             % TIPS lower bound: 0
    UB(11) = 1;             % TIPS upper bound: 100%
end

% Optimal portfolio weights
H = V;
C = [E'; ones(1,12)];
d = [targetE; 1];
X = quadprog(H,[],[],[],C,d,LB,UB);
X1 = round(1000*X)/10;    

% Portfolio statistics
EP = X'*E;
SP = sqrt(X'*V*X);
Sharpe = (EP-E(end))/SP;

% Print results
names3={'Domestic Equity ';'Foreign Equity ';'Emerging Markets ';...
    'Private Equity ';'Absolute Return ';'High Yield ';'Commodities ';...
    'Real Estate ';'Domestic Bonds ';'Foreign Bonds ';'TIPS ';'Cash '};
stats={'Expected Real Return ';'Standard Deviation ';'Sharpe ratio '};
str = ['Weights in the optimal portfolio (Exhibit ' int2str(exhibit) '):'];
disp(str)
fprintf(['\n']) % insert an empty line
disp([char(names3) num2str(X1)])
fprintf(['\n']) % insert an empty line   
EP2 = round(10000*EP)/100;
SP2 = round(10000*SP)/100;    
Sharpe2 = round(100*Sharpe)/100;    
disp([char(stats) num2str([EP2; SP2; Sharpe2])])
fprintf(['\n']) % insert an empty line   

