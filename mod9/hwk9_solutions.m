% Modify this program as necesary to generate solutions for Assignment 9 for Portfolio Management. 
clear all
close all
clc
Ts = 1:40;
Tfigs = [5 10 20];
pickT = 20;
rhos = 0:0.05:1;
pickrho = 0.3;
rhoLM = 0.02;
EL = 0.01;
SL = 0.05;
w = 0.5;
ford = load('ford.txt');
ff = load('ff_factors_192607_201612.txt');
    ff = ff(358:end-1,:)/100;
rmrf = ff(:,2);  
rf = ff(:,end);  
rm = rmrf + rf; 
rg = ford(:,2);
rm = log(1+rm);
rf = log(1+rf);
rg = log(1+rg);
Em = mean(rm);
Ef = mean(rf);
Eg = mean(rg);
Sm = std(rm);
Sf = std(rf);
Sg = std(rg);
nTs = size(Ts,2);
nrhos = size(rhos,2);
d1 = -99*ones(nTs,1);
d2 = -99*ones(nTs,nrhos);
for i=1:nTs
   T = Ts(i)*12;   
   EmT = T*Em;
   EfT = T*Ef;
   EgT = T*Eg;   
   SmT = sqrt(T)*Sm;
   SgT = sqrt(T)*Sg;
   if T==pickT*12
       SRmT = (EmT-EfT)/SmT;
       SRgT = (EgT-EfT)/SgT;
   end
   EminT = EfT + (SgT/SmT)*(EmT-EfT);  % I would like you to explain where this is coming from;
   d1(i,1) = 1 - exp(EgT-EminT);       % grab a pen and solve this problem algebraically   
   for j=1:nrhos
      rho = rhos(j); 
      E1 = w*EL + (1-w)*Em;
      E2 = w*EL + (1-w)*Eg;
      S1 = sqrt( (w^2)*(SL^2) + ((1-w)^2)*(Sm^2) + 2*w*(1-w)*SL*Sm*rhoLM );
      S2 = sqrt( (w^2)*(SL^2) + ((1-w)^2)*(Sg^2) + 2*w*(1-w)*SL*Sg*rho );
      E1T = T*E1;
      E2T = T*E2;
      S1T = sqrt(T)*S1;
      S2T = sqrt(T)*S2;
      E2minT = EfT + (S2T/S1T)*(E1T-EfT);
      EGminT = (E2minT - w*T*EL)/(1-w);
      d2(i,j) = 1 - exp(EgT-EGminT);
   end                                
end
%figure(1)
%plot(Ts,d1)
%xlabel('Years to Retirement')
%ylabel('Required Discount')
%set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
%print -deps2 fig_discount_1; 
%figure(2)
%plot(rhos,d2(Tfigs(1),:),':',rhos,d2(Tfigs(2),:),'-.',rhos,d2(Tfigs(3),:),'-')
%xlabel('Correlation (Labor Income, Own Company Stock Return)')
%ylabel('Required Discount')
%legend(['T=' int2str(Tfigs(1))],['T=' int2str(Tfigs(2))],['T=' int2str(Tfigs(3))],'Location','NorthWest');
%set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
%print -deps2 fig_discount_2; 