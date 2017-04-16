clear all
clc

%%%%%%%%%% Sample moments of returns from Exhibit 2 %%%%%%%%%%
Ehat = (1/100)*[13.2 10.2 4.9 17.9 8.6 7.1 1.1 1.4 6.0 5.1 3.1]';     % historical average real returns, 11x1
sighat = (1/100)*[15.2 17.4 21.2 15.2 8.6 7.3 10.7 6.4 7.8 8.7 0.9]'; % historical standard deviations, 11x1
rhohat = [1 .51 .37 .26 .86 .56 0 .06 .32 .10 .14;                    % historical correlations, 11x11
          0 1 .37 .12 .89 .35 .02 .13 .22 .40 .16;
          0 0 1 .16 .56 .39 -.05 -.08 -.09 -.07 -.06;
          0 0 0 1 .27 .06 .05 .12 -.12 -.30 .03;
          0 0 0 0 1 .50 .04 .07 .37 .40 .29;
          0 0 0 0 0 1 -.32 -.11 .31 -.01 .32;
          0 0 0 0 0 0 1 -.04 -.09 .19 -.20;
          0 0 0 0 0 0 0 1 -.06 -.15 .39;
          0 0 0 0 0 0 0 0 1 .42 .28;
          0 0 0 0 0 0 0 0 0 1 .01;
          0 0 0 0 0 0 0 0 0 0 1];
rhohat = rhohat + rhohat' - eye(size(rhohat));      % sample correlation matrix
Vhat = rhohat.*(sighat*sighat');                    % sample covariance matrix

% Tangency portfolio based on sample moments; assuming cash is riskless
Ehat2 = Ehat(1:end-1,1) - Ehat(end,1);              % expected excess returns
Vhat2 = Vhat(1:end-1,1:end-1);
w_TP_hat = inv(Vhat2)*Ehat2/(ones(1,10)*inv(Vhat2)*Ehat2);

% Print results
w2 = round(1000*w_TP_hat)/10;
names1={'Domestic Equity ';'Foreign Equity ';'Emerging Markets ';...
    'Private Equity ';'Absolute Return ';'High Yield ';'Commodities ';...
    'Real Estate ';'Domestic Bonds ';'Foreign Bonds '};
disp('Weights in the tangency portfolio based on historical estimates Ehat and Vhat:')
fprintf(['\n']) % insert an empty line
disp([char(names1) num2str(w2)])
fprintf(['\n']) % insert an empty line

