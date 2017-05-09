% Modify this program as necessary to produce the desired solutions to Part B of Assignment 7.

clear    
clc

frequency = 756; % Gap between dates on x-axis, in days (~252 trading days per year). 
fontsiz = 8;

%% Basic info on the LETFs.
% Index: SP500 / 1xSPY / -1xSH / 2xSSO /-2xSDS (not used: 3xSPXL / -3xSPXS)
% Index: Dow Jones U.S. Financial index (DJUSFN) / 1xIYF / -1xSEF / 2xUYG /-2xSKF
% Index: Dow Jones U.S. Real Estate index (DJUSRE) / 1xIYR / -1xREK / 2xURE /-2xSRS
% Index: Russell 2000 / 1xIWM / -1xRWM / 2xUWM / -2xTWM

%% Load Data.   
load LETF.txt;
load SP500.txt;

%%%%%  Compare S&P500 Index with 1xSPY. 

% Extract SPY. 
dates_SPY=LETF(:,1);
return_SPY=LETF(:,2);
date_min=min(dates_SPY); % ETF starts later than the underlying index.
SP500_short=SP500(SP500(:,1)>=date_min,:);
T=length(dates_SPY(:,1));
Return_compare=ones(T+1,2);
for t=1:T
    Return_compare(t+1,1)=Return_compare(t,1)*(1+SP500(t,2)); % index
    Return_compare(t+1,2)=Return_compare(t,2)*(1+return_SPY(t,1)); % 1xETF
end

figure(1)   
set(gca,'fontsize',fontsiz);
%plot((1:1:T+1)',Return_compare(:,1),'-',(1:1:T+1)',Return_compare(:,2),'--');    
title('Cumulative Returns from S&P500 index and 1xETF (SPY)','FontSize', fontsiz);   
legend('S&P500 Index','S&P500 1x ETF','Location','Southeast');    
% Put dates on to x-axis.
dates=dates_SPY;
year=floor(dates/1E4);
month=floor((dates-1E4*year)/1E2);
day=dates-1E4*year-1E2*month;
datevec=[year month day];
datenumber=datenum(datevec);
num_year=floor(length(datenumber)/frequency); % help determine how many dates to put on x-axis.
datenumber=datenumber(1:frequency:1+frequency*num_year);
xtick=1:frequency:1+frequency*num_year;
x_labels=datestr(datenumber);
set(gca,'xtick',xtick,'xticklabel',x_labels);

print -deps2 h7_Fig_1

%%%%% Analysis on LETF. 

SP500_Mat=LETF(:,1:5);  % the 4 ETFs based on S&P500 index. 
output1=analysis_h7(SP500_Mat,frequency);
DJUSFN_Mat=LETF(:,[1,6:9]);  % the 4 ETFs based on DJUSFN index. 
output2=analysis_h7(DJUSFN_Mat,frequency);
DJUSRE_Mat=LETF(:,[1,10:13]);  % the 4 ETFs based on DJUSRE index. 
output3=analysis_h7(DJUSRE_Mat,frequency);
Russell2000_Mat=LETF(:,[1,14:17]);  % the 4 ETFs based on Russell 2000 index. 
output4=analysis_h7(Russell2000_Mat,frequency);

%% Compare various levered 1x vs. 2x cumulative returns. 
figure(2)   
subplot(2,2,1);   
%plot((1:1:length(output1.Return_Compare_1v2(:,1)))',output1.Return_Compare_1v2(:,1),'-',(1:1:length(output1.Return_Compare_1v2(:,1)))',output1.Return_Compare_1v2(:,2),'--');  
title('2 times 1xETF vs. 2xLETF cumulative return ~ S&P500','FontSize', fontsiz);   
legend('2 times 1xETF','2xLETF');
set(gca,'xtick',output1.xtick_1vs2,'xticklabel',output1.x_labels_1vs2);
set(gca,'fontsize',fontsiz);
subplot(2,2,2);
%plot((1:1:length(output2.Return_Compare_1v2(:,1)))',output2.Return_Compare_1v2(:,1),'-',(1:1:length(output2.Return_Compare_1v2(:,1)))',output2.Return_Compare_1v2(:,2),'--');  
title('2 times 1xETF vs. 2xLETF cumulative return ~ DJUSFN','FontSize', fontsiz);   
legend('2 times 1xETF','2xLETF');
set(gca,'xtick',output2.xtick_1vs2,'xticklabel',output2.x_labels_1vs2);
set(gca,'fontsize',fontsiz);
subplot(2,2,3);
%plot((1:1:length(output3.Return_Compare_1v2(:,1)))',output3.Return_Compare_1v2(:,1),'-',(1:1:length(output3.Return_Compare_1v2(:,1)))',output3.Return_Compare_1v2(:,2),'--');  
title('2 times 1xETF vs. 2xLETF cumulative return ~ DJUSRE','FontSize', fontsiz);   
legend('2 times 1xETF','2xLETF');
set(gca,'xtick',output3.xtick_1vs2,'xticklabel',output3.x_labels_1vs2);
set(gca,'fontsize',fontsiz);
subplot(2,2,4);
%plot((1:1:length(output4.Return_Compare_1v2(:,1)))',output4.Return_Compare_1v2(:,1),'-',(1:1:length(output4.Return_Compare_1v2(:,2)))',output4.Return_Compare_1v2(:,2),'--');  
title('2 times 1xETF vs. 2xLETF cumulative return ~ Russell 2000','FontSize', fontsiz);   
legend('2 times 1xETF','2xLETF');
set(gca,'xtick',output4.xtick_1vs2,'xticklabel',output4.x_labels_1vs2);
set(gca,'fontsize',fontsiz);

print -deps2 h7_Fig_2a

%% Compare mirror images of 1x/-1x cumulative return series.
figure(3)   
subplot(2,2,1);
%plot((1:1:length(output1.Return_Mirror_1x(:,1)))',output1.Return_Mirror_1x(:,1),'-',(1:1:length(output1.Return_Mirror_1x(:,1)))',output1.Return_Mirror_1x(:,2),'--');  
title('1xETF vs. negative of -1xETF cumulative return ~ S&P500','FontSize', fontsiz);   
legend('1xETF','negative of -1xETF','Location','Southeast');
set(gca,'xtick',output1.xtick_mirror1,'xticklabel',output1.x_labels_mirror1);
set(gca,'fontsize',fontsiz);
subplot(2,2,2);
%plot((1:1:length(output2.Return_Mirror_1x(:,1)))',output2.Return_Mirror_1x(:,1),'-',(1:1:length(output2.Return_Mirror_1x(:,1)))',output2.Return_Mirror_1x(:,2),'--');  
title('1xETF vs. negative of -1xETF cumulative return ~ DJUSFN','FontSize', fontsiz);   
legend('1xETF','negative of -1xETF','Location','Southeast');
set(gca,'xtick',output2.xtick_mirror1,'xticklabel',output2.x_labels_mirror1);
set(gca,'fontsize',fontsiz);
subplot(2,2,3);
%plot((1:1:length(output3.Return_Mirror_1x(:,1)))',output3.Return_Mirror_1x(:,1),'-',(1:1:length(output3.Return_Mirror_1x(:,1)))',output3.Return_Mirror_1x(:,2),'--');  
title('1xETF vs. negative of -1xETF cumulative return ~ DJUSRE','FontSize', fontsiz);   
legend('1xETF','negative of -1xETF','Location','Southeast');
set(gca,'xtick',output3.xtick_mirror1,'xticklabel',output3.x_labels_mirror1);
set(gca,'fontsize',fontsiz);
subplot(2,2,4);
%plot((1:1:length(output4.Return_Mirror_1x(:,1)))',output4.Return_Mirror_1x(:,1),'-',(1:1:length(output4.Return_Mirror_1x(:,1)))',output4.Return_Mirror_1x(:,2),'--');  
title('1xETF vs. negative of -1xETF cumulative return ~ Russell 2000','FontSize', fontsiz);   
legend('1xETF','negative of -1xETF','Location','Southeast');
set(gca,'xtick',output4.xtick_mirror1,'xticklabel',output4.x_labels_mirror1);
set(gca,'fontsize',fontsiz);

print -deps2 h7_Fig_2b_i

%% Compare mirror images of 2x/-2x cumulative return series.
figure(4)   
subplot(2,2,1);
%plot((1:1:length(output1.Return_Mirror_2x(:,1)))',output1.Return_Mirror_2x(:,1),'-',(1:1:length(output1.Return_Mirror_2x(:,1)))',output1.Return_Mirror_2x(:,2),'--');  
title('2xLETF vs. negative of -2xLETF cumulative return ~ S&P500','FontSize', fontsiz);   
legend('2xLETF','negative of -2xLETF');
set(gca,'xtick',output1.xtick_mirror2,'xticklabel',output1.x_labels_mirror2);
set(gca,'fontsize',fontsiz);
subplot(2,2,2);
%plot((1:1:length(output2.Return_Mirror_2x(:,1)))',output2.Return_Mirror_2x(:,1),'-',(1:1:length(output2.Return_Mirror_2x(:,1)))',output2.Return_Mirror_2x(:,2),'--');  
title('2xLETF vs. negative of -2xLETF cumulative return ~ DJUSFN','FontSize', fontsiz);   
legend('2xLETF','negative of -2xLETF');
set(gca,'xtick',output2.xtick_mirror2,'xticklabel',output2.x_labels_mirror2);
set(gca,'fontsize',fontsiz);
subplot(2,2,3);
%plot((1:1:length(output3.Return_Mirror_2x(:,1)))',output3.Return_Mirror_2x(:,1),'-',(1:1:length(output3.Return_Mirror_2x(:,1)))',output3.Return_Mirror_2x(:,2),'--');  
title('2xLETF vs. negative of -2xLETF cumulative return ~ DJUSRE','FontSize', fontsiz);   
legend('2xLETF','negative of -2xLETF');
set(gca,'xtick',output3.xtick_mirror2,'xticklabel',output3.x_labels_mirror2);
set(gca,'fontsize',fontsiz);
subplot(2,2,4);
%plot((1:1:length(output4.Return_Mirror_2x(:,1)))',output4.Return_Mirror_2x(:,1),'-',(1:1:length(output4.Return_Mirror_2x(:,1)))',output4.Return_Mirror_2x(:,2),'--');  
title('2xLETF vs. negative of -2xLETF cumulative return ~ Russell 2000','FontSize', fontsiz);   
legend('2xLETF','negative of -2xLETF');
set(gca,'xtick',output4.xtick_mirror2,'xticklabel',output4.x_labels_mirror2);
set(gca,'fontsize',fontsiz);

print -deps2 h7_Fig_2b_ii

%% A particular comparison on Russell-2000 (L)ETFs. 
frequency=100;
Return_1x=Russell2000_Mat(:,[1 2]);
Return_2x=Russell2000_Mat(:,[1 4]);
Return_m2x=Russell2000_Mat(:,[1 5]);
date_initial=20070531;
date_end=20100531;
Return_1x=Return_1x(Return_1x(:,1)>=date_initial & Return_1x(:,1)<=date_end,:);
Return_2x=Return_2x(Return_2x(:,1)>=date_initial & Return_2x(:,1)<=date_end,:);
Return_m2x=Return_m2x(Return_m2x(:,1)>=date_initial & Return_m2x(:,1)<=date_end,:);

Return_Compare_russell=ones(length(Return_1x(:,1))+1,3);
for t=1:length(Return_1x(:,1))
    Return_Compare_russell(t+1,1)=Return_Compare_russell(t,1)*(1+Return_1x(t,2)); 
    Return_Compare_russell(t+1,2)=Return_Compare_russell(t,2)*(1+Return_2x(t,2));
    Return_Compare_russell(t+1,3)=Return_Compare_russell(t,3)*(1+Return_m2x(t,2));
end
% Produce date labels for x-axis.
dates=Return_1x(:,1);
year=floor(dates/1E4);
month=floor((dates-1E4*year)/1E2);
day=dates-1E4*year-1E2*month;
datevec=[year month day];
datenumber=datenum(datevec);
num_year=floor(length(datenumber)/frequency); % help determine how many dates to put on x-axis.
datenumber=datenumber(1:frequency:1+frequency*num_year);
xtick_russell=1:frequency:1+frequency*num_year;
x_labels_russell=datestr(datenumber);

figure(5)   
%plot((1:1:length(Return_Compare_russell(:,1)))',Return_Compare_russell(:,1),'-',(1:1:length(Return_Compare_russell(:,1)))',Return_Compare_russell(:,2),'--',...
%    (1:1:length(Return_Compare_russell(:,1)))',Return_Compare_russell(:,3),'-.');  
title('1xETF vs. 2xLETF vs. -2xLETF cumulative return ~ Russell 2000','FontSize', fontsiz);   
legend('1xETF','2xLETF','-2xLETF');
set(gca,'xtick',xtick_russell,'xticklabel',x_labels_russell);
set(gca,'fontsize',fontsiz);

print -deps2 h7_Fig_2c

%% Long-pair strategies.
figure(6)   
subplot(2,2,1);
%plot(sum(output1.Return_Pair_2x,2));  title('2xLETF Paired with -2xLETF cumulative return ~ S&P500','FontSize', fontsiz);   
ylim([0 1.5]);
set(gca,'xtick',output1.xtick_mirror2,'xticklabel',output1.x_labels_mirror2);
set(gca,'fontsize',fontsiz);
subplot(2,2,2);
%plot(sum(output2.Return_Pair_2x,2));  title('2xLETF Paired with -2xLETF cumulative return ~ DJUSFN','FontSize', fontsiz);   
ylim([0 2]);
set(gca,'xtick',output2.xtick_mirror2,'xticklabel',output2.x_labels_mirror2);
set(gca,'fontsize',fontsiz);
subplot(2,2,3);
%plot(sum(output3.Return_Pair_2x,2));  title('2xLETF Paired with -2xLETF cumulative return ~ DJUSRE','FontSize', fontsiz);   
ylim([0 2]);
set(gca,'xtick',output3.xtick_mirror2,'xticklabel',output3.x_labels_mirror2);
set(gca,'fontsize',fontsiz);
subplot(2,2,4);
%plot(sum(output4.Return_Pair_2x,2));  title('2xLETF Paired with -2xLETF cumulative return ~ Russell 2000','FontSize', fontsiz);   
ylim([0 1.5]);
set(gca,'xtick',output4.xtick_mirror2,'xticklabel',output4.x_labels_mirror2);
set(gca,'fontsize',fontsiz);

print -deps2 h7_Fig_3

