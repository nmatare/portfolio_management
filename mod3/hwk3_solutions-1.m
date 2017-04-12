% Modify this program as necessary to produce the desired solutions to Part B of Assignment 3.
% This program may take almost a minute to run!
% For this program to run properly, the data files need to be in the same directory as this program!

clear all   % clear all variables from memory
close all   % close all graph windows
clc         % clear the screen

N=10000;
c=0.02;

x=load('VWMKT_26_16.txt');
dte=x(:,1); 
rm=x(:,2); 
T=length(rm);
x=load('TB_26_16.txt');
rf=x(:,2); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f=rm>rf;
res1 = 100*sum(f)/T;

hrm=prod(1+rm);
hrf=prod(1+rf);

avgretmkt = mean(rm);
Sm = mean(rm-rf)/std(rm-rf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rperfect=rf; 
rperfect(f)=rm(f); 
hrperfect=prod(1+rperfect);
avgretperf = mean(rperfect);
srperf = mean(rperfect-rf)/std(rperfect-rf);

out1=[];
for j=1:N
    f1=rand(T,1)>0.5;
    r=rf;r(f1)=rm(f1);
    out1=[out1 r];
end;

ravg1=mean(out1);
Sr1=mean(out1-rf*ones(1,N))./std(out1-rf*ones(1,N));

%figure(1) 
%subplot(2,1,1); 
%hist(ravg1,20); 
%hold on 
%plot([mean(rm) mean(rm)],[0 1500],'r-')
%xlabel('Avg returns, complete randomization') 
%subplot(2,1,2); 
%hist(Sr1,20);
%hold on 
%plot([Sm Sm],[0 1500],'r-')
%xlabel('Sharpe ratios, complete randomization') 
%set(gcf,'Name','Random market timing')
%set(gcf,'NumberTitle','off')
%print -deps2 hwk3fig1

meanravg1 = mean(ravg1);
meansr1 = mean(Sr1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rnever=rm;
rnever(f)=rf(f);

out2=[];
for j=1:N
    f1=rand(T,1)<=0.6;
    r=rnever; 
    r(f1)=rperfect(f1);
    out2=[out2 r];
end;

ravg2=mean(out2);
Sr2=mean(out2-rf*ones(1,N))./std(out2-rf*ones(1,N));

%figure(2)
%subplot(2,1,1);
%hist(ravg2,20);
%hold on 
%plot([mean(rm) mean(rm)],[0 2000],'r-')
%xlabel('Avg returns, 60% accuracy')
%subplot(2,1,2);
%hist(Sr2,20);
%hold on
%plot([Sm Sm],[0 2000],'r-')
%xlabel('Sharpe ratios, 60% accuracy')
%set(gcf,'Name','60% market timing')
%set(gcf,'NumberTitle','off')
%print -deps2 hwk3fig2

meanravg2 = mean(ravg2);
meansr2 = mean(Sr2);
Sr3 = mean(out2-rf*ones(1,N)-c)./std(out2-rf*ones(1,N));
meanravg2c = mean(ravg2-c);
meansr3 = mean(Sr3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

acc_lev=0.25:0.01:0.95;

exp_ret=[]; 
sha_rat=[];
sha_rat1=[];

v=rand(T,N);

r1=rperfect*ones(1,N);
r0=rnever*ones(1,N);
rf1=rf*ones(1,N);

for j=1:length(acc_lev)
    r11=r1;
    f = (v>=acc_lev(j));
    r11(f)=r0(f);
    exp_ret=[exp_ret mean(mean(r11))];
    sha_rat=[sha_rat mean(mean(r11-rf1)./std(r11-rf1))];
    sha_rat1=[sha_rat1 mean(mean(r11-rf1-c)./std(r11-rf1))];
end;

%figure(3)
%subplot(2,1,1)
%plot(acc_lev,exp_ret,'k-',acc_lev,mean(rm)*ones(size(acc_lev)),'r:')
%xlabel('Accuracy vs. expected returns, no fees')
%subplot(2,1,2)
%plot(acc_lev,sha_rat,'k-',acc_lev,Sm*ones(size(acc_lev)),'r:')
%xlabel('Accuracy vs. expected Sharpe ratios, no fees')
%set(gcf,'Name','Accuracy vs performance, no fees')
%set(gcf,'NumberTitle','off')
%print -deps2 hwk3fig3

%figure(4)
%subplot(2,1,1)
%plot(acc_lev,exp_ret-c,'k-',acc_lev,mean(rm)*ones(size(acc_lev)),'r:')
%xlabel(['Accuracy vs. expected returns, fees of ',num2str(c)])
%subplot(2,1,2)
%plot(acc_lev,sha_rat1,'k-',acc_lev,Sm*ones(size(acc_lev)),'r:')
%xlabel(['Accuracy vs. expected Sharpe ratios, fees of ',num2str(c)])
%set(gcf,'Name','Accuracy vs performance, with fees')
%set(gcf,'NumberTitle','off')
%print -deps2 hwk3fig4
