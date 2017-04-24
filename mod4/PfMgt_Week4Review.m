% Chuck Boyer
% University of Chicago
% Spring 2017
%
% Portfolio Management
% Review Session Week 4: Matrix Algebra

clear   %Clears all data
clc     %Clears command window
cd 'C:\Users\Chuck\Dropbox\Classes\Teaching\PM_Spring17\ReviewSessions\Week4'
        %Set file path, all files save here, data loaded from here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MVP and Optimal Portfolio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define inputs
e1=0.13;
e2=0.10;
s1=0.15;
s2=0.12;
s12=-0.05;
rf=0.03;
% Create Covar Matrix
V=[s1^2 s12; s12 s2^2];

% Create inverse
Vinv=V^-1;

% Solve for MVP
i=[1; 1];
wmvp=Vinv*i/(i'*Vinv*i)

% Solve for TP
Evec=[e1-rf; e2-rf];
mtp=Vinv*Evec/(i'*Vinv*Evec)

% Solve quadratic programming
barE=0.09; %Expected  return
LB=[0;0]; %Short sale constraint
w=quadprog(V,[],[],[],[Evec';ones(1,2)],[barE;1],LB,[])

% What if we have portfolio constraints on 1 and 2?
UB=[0.7;0.6];
w=quadprog(V,[],[],[],[Evec';ones(1,2)],[barE;1],LB,UB)