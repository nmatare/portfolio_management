% Modify this program as necessary to produce the desired solutions to Part B of Assignment 5.
clear all
clc
raus = load('australia.txt');
rfra = load('france.txt');
rger = load('germany.txt');
rita = load('italy.txt');
rjap = load('japan.txt');
rbri = load('uk.txt');
months = rbri(:,1);
years = floor(months/100);
T = size(months,1);
aus_hml = raus(:,3)-raus(:,4);
fra_hml = rfra(:,3)-rfra(:,4);
ger_hml = rger(:,3)-rger(:,4);
ita_hml = rita(:,3)-rita(:,4);
jap_hml = rjap(:,3)-rjap(:,4);
bri_hml = rbri(:,3)-rbri(:,4);
int_hml = [aus_hml fra_hml ger_hml ita_hml jap_hml bri_hml]/100;
m_int_hml = mean(int_hml)*100;
s_int_hml = std(int_hml)*100;
t1_int_hml = sqrt(T)*m_int_hml./s_int_hml;
t2_int_hml = m_int_hml./(s_int_hml*sqrt(T));
W = 5;      % is this right?               
mov_avg = nan*ones(T,6);
for t=1+W:T
    mov_avg(t,:) = mean(int_hml(t-W:t,:));  
end
countries = ['AUS';'FRA';'GER';'ITA';'JAP';'BRI'];
%figure(1)
%for i=1:6
%    subplot(3,2,i)
%    plot(1:T,mov_avg(:,i),'-',1:T,zeros(T,1),'-');
%    set(gca,'XLim',[60 T+1])
%    set(gca,'YLim',[-1.5 2.5]/100)
%    v = [61:60:T];
%    set(gca,'XTick',v);
%    set(gca,'XTickLabel',years(v));
%    title(countries(i,:));
%end
%figname = ['int_mov_avg'];
%set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
%eval(['print -deps2 ' figname]); 
x = load('ff_factors_192607_201612.txt');
months_ff = x(:,1);
id = find(ismember(months_ff,intersect(months,months_ff)));
mkt = x(id,2)/100;
hml = x(id,4)/100;
rf = x(id,5)/100;
assets1 = [hml int_hml];
C1 = corrcoef(assets1);
V1 = cov(assets1);
w1 = inv(V1)*ones(7,1)/(ones(1,7)*inv(V1)*ones(7,1));
VP1 = w1'*V1*w1;
std_hml = std(hml);
g1 = mean(mkt)/var(mkt);
g2 = var(mkt)/mean(mkt);
assets2 = [mkt hml];
E2 = mean(assets2)';
V2 = cov(assets2);
w2 = inv(V2)*E2/g1;
SR1 = mean(mkt)/std(mkt);
SR2 = w2'*E2/sqrt(w2'*V2*w2);
y = hml;
x = [ones(T,1) mkt];
b = x\y;
alpha = b(1);
e = y - x*b;
se = std(e);
IR1 = alpha*se;
IR2 = alpha/se;
assets3 = [mkt hml int_hml];
E3 = mean(assets3)';
V3 = cov(assets3);
w3 = inv(V3)*E3/g1;
SR3 = w3'*E3/sqrt(w3'*V3*w3);