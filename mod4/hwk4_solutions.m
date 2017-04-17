% Modify this program as necessary to produce the desired solutions to Part B of Assignment 4.
clear all
x = load('TB_7301_1612.txt');
dte = x(:,1); 
rf = x(:,2); 
x = load('STOCK_RETS.txt');  
dte1 = x(:,1); 
r = x(:,2:end);
re = r - rf*ones(1,5);
ER1 = mean(re)';      
ER11 = round(ER1*100)/100;
ER2 = [0.6; 0.7; 1.2; 0.9; 1.2]*0.005;
ER3 = 0.5*ER1+0.5*ER2;
V1 = cov(r);    
avgsig2 = mean(diag(V1));
V3 = 0.5*V1+0.5*avgsig2*eye(size(V1));
w0 = (inv(V1)*ones(5,1))/(ones(1,5)*inv(V1)*ones(5,1));
w1 = (inv(V1)*ER1)/sum(inv(V1)*ER1);    
w2 = (inv(V1)*ER2)/sum(inv(V1)*ER2);
w3 = ER1/sum(ER1);
w4 = inv(V3)*ER3/sum(inv(V3)*ER3);
w11 = (inv(V1)*ER11)/sum(inv(V1)*ER11);
w31 = ER11/sum(ER11);
E_1 = w1'*ER1;
E_0 = w0'*ER1;
V_1 = w1'*V1*w1;
V_0 = w0'*V1*w0;
m = floor(dte/100) - floor(floor(dte/100)/100)*100;
f1 = find(m==1);
f1 = f1(f1>=find(dte==19780131));
out1 = []; out2 = []; out3 = []; out4 = [];
for t=1:length(f1)             
    r1 = r(1:f1(t)-1,:);
    re1 = re(1:f1(t)-1,:);
    ER1o = mean(re1)';
    ER2o = ER2;
    ER3o = 0.5*ER1o+0.5*ER2o;
    V1o = cov(r1);
    avgsig2 = mean(diag(V1o));
    V3o = 0.5*V1o+0.5*avgsig2*eye(size(V1o));    
    w1o = inv(V1o)*ER1o/sum(inv(V1o)*ER1o);
    w2o = inv(V1o)*ER2o/sum(inv(V1o)*ER2o);
    w3o = ER1o/sum(ER1o);
    w4o = inv(V3o)*ER3o/sum(inv(V3o)*ER3o);
    d = dte(f1(t):f1(t)+11);
    r2 = r(f1(t):(f1(t)+11),:);
    re2 = re(f1(t):(f1(t)+11),:);
    out1 = [out1; [d r2*w1o re2*w1o]];
    out2 = [out2; [d r2*w2o re2*w2o]];
    out3 = [out3; [d r2*w3o re2*w3o]];
    out4 = [out4; [d r2*w4o re2*w4o]];
end
we1 = cumprod(out1(:,2)+1)-1;
we2 = cumprod(out2(:,2)+1)-1;
we3 = cumprod(out3(:,2)+1)-1;
we4 = cumprod(out4(:,2)+1)-1;
d = floor(out1(:,1)/100); 
d = floor(d/100)+(d-floor(d/100)*100)/13;
figure(1)
%plot(d,we1,':',d,we2,'-.',d,we3,'--',d,we4,'-');
legend('?','??','???','????',2) % replace the ?s by labels that briefly describe the corresponding strategies!
set(gca,'FontSize',10)
set(gca,'XLabel',text(0,0,'Year'))
set(gca,'YLabel',text(0,0,'Cumulative Return'))
set(gcf,'PaperPosition',[0.25,2.5,8,7.5])
eval(['print -deps2 fig_h4']); 
avgrets = [mean(out1(:,2)) mean(out2(:,2)) mean(out3(:,2)) mean(out4(:,2))];
sharpes = [mean(out1(:,3))/std(out1(:,2)) mean(out2(:,3))/std(out2(:,2)) mean(out3(:,3))/std(out3(:,2)) mean(out4(:,3))/std(out4(:,2))];