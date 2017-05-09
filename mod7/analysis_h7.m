% This function is called by the main program, hwk7_solutions.m
% Place this file in the same directory as hwk7_solutions.m.

function output=analysis_h7(Return_Mat,frequency)

% Extract relevant returns. 
dates=Return_Mat(:,1);
Return_1=Return_Mat(:,2);
Return_1x=[dates(Return_1~=-99) Return_1(Return_1~=-99)];  % selects the valid dates and returns. 
Return_m1=Return_Mat(:,3);
Return_m1x=[dates(Return_m1~=-99) Return_m1(Return_m1~=-99)];  % selects the valid dates and returns. 
Return_2=Return_Mat(:,4);
Return_2x=[dates(Return_2~=-99) Return_2(Return_2~=-99)];  % selects the valid dates and returns. 
Return_m2=Return_Mat(:,5);
Return_m2x=[dates(Return_m2~=-99) Return_m2(Return_m2~=-99)];  % selects the valid dates and returns. 

% Compare 1x vs 2x cumulative returns.
date_initial=max([min(Return_1x(:,1)),min(Return_2x(:,1))]);
Return_1x_A=Return_1x(Return_1x(:,1)>=date_initial,:);
Return_2x_A=Return_2x(Return_2x(:,1)>=date_initial,:);
% create useful variables for graphs. 
dates=Return_1x_A(:,1);
year=floor(dates/1E4);
month=floor((dates-1E4*year)/1E2);
day=dates-1E4*year-1E2*month;
datevec=[year month day];
datenumber=datenum(datevec);
num_year=floor(length(datenumber)/frequency); % help determine how many dates to put on x-axis.
datenumber=datenumber(1:frequency:1+frequency*num_year);
output.xtick_1vs2=1:frequency:1+frequency*num_year;
output.x_labels_1vs2=datestr(datenumber);

Return_Compare_1v2=ones(length(Return_1x_A(:,1))+1,2);
for t=1:length(Return_1x_A(:,1))
    Return_Compare_1v2(t+1,1)=Return_Compare_1v2(t,1)*(1+2*Return_1x_A(t,2)); 
    Return_Compare_1v2(t+1,2)=Return_Compare_1v2(t,2)*(1+Return_2x_A(t,2));
end
output.Return_Compare_1v2=Return_Compare_1v2;

% Compare mirror images of 1x/-1x, 2x/-2x cumulative return series.
% 1x/-1x.
date_initial=max([min(Return_1x(:,1)),min(Return_m1x(:,1))]);
Return_1x_pos=Return_1x(Return_1x(:,1)>=date_initial,:);
Return_1x_neg=Return_m1x(Return_m1x(:,1)>=date_initial,:);
dates=Return_1x_pos(:,1);
year=floor(dates/1E4);
month=floor((dates-1E4*year)/1E2);
day=dates-1E4*year-1E2*month;
datevec=[year month day];
datenumber=datenum(datevec);
num_year=floor(length(datenumber)/frequency); % help determine how many dates to put on x-axis.
datenumber=datenumber(1:frequency:1+frequency*num_year);
output.xtick_mirror1=1:frequency:1+frequency*num_year;
output.x_labels_mirror1=datestr(datenumber);
Return_Mirror_1x=ones(length(Return_1x_pos(:,1))+1,2);
for t=1:length(Return_1x_pos(:,1))
    Return_Mirror_1x(t+1,1)=Return_Mirror_1x(t,1)*(1+Return_1x_pos(t,2));
    Return_Mirror_1x(t+1,2)=Return_Mirror_1x(t,2)*(1-Return_1x_neg(t,2));
end
output.Return_Mirror_1x=Return_Mirror_1x;
% 2x/-2x.
date_initial=max([min(Return_2x(:,1)),min(Return_m2x(:,1))]);
Return_2x_pos=Return_2x(Return_2x(:,1)>=date_initial,:);
Return_2x_neg=Return_m2x(Return_m2x(:,1)>=date_initial,:);
dates=Return_2x_pos(:,1);
year=floor(dates/1E4);
month=floor((dates-1E4*year)/1E2);
day=dates-1E4*year-1E2*month;
datevec=[year month day];
datenumber=datenum(datevec);
num_year=floor(length(datenumber)/frequency); % help determine how many dates to put on x-axis.
datenumber=datenumber(1:frequency:1+frequency*num_year);
output.xtick_mirror2=1:frequency:1+frequency*num_year;
output.x_labels_mirror2=datestr(datenumber);
Return_Mirror_2x=ones(length(Return_2x_pos(:,1))+1,2);
for t=1:length(Return_2x_pos(:,1))
    Return_Mirror_2x(t+1,1)=Return_Mirror_2x(t,1)*(1+Return_2x_pos(t,2));
    Return_Mirror_2x(t+1,2)=Return_Mirror_2x(t,2)*(1-Return_2x_neg(t,2));
end
output.Return_Mirror_2x=Return_Mirror_2x;

% Long-pair strategies.
% 2x/-2x
Return_Pair_2x=ones(length(Return_2x_pos(:,1))+1,2)*0.5;
for t=1:length(Return_2x_pos(:,1))
    Return_Pair_2x(t+1,1)=Return_Pair_2x(t,1)*(1+Return_2x_pos(t,2));
    Return_Pair_2x(t+1,2)=Return_Pair_2x(t,2)*(1+Return_2x_neg(t,2));
end
output.Return_Pair_2x=Return_Pair_2x;


