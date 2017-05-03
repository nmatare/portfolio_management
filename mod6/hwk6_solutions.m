% Modify this program as necessary to produce the desired solutions to Part B of Assignment 6.

clear    
clc

beg_date_reg1 = 196801;
end_date_reg1 = 201512;
beg_date_reg2 = 200001;
end_date_reg2 = 201512;

load liq.txt                        % Aug 1962 -- Dec 2015
LIQ = liq(:,2);
date_LIQ = floor(liq(:,1)/100);

load vix.txt                        % Jan 1990 -- Dec 2016
VIX = vix;   
date_VIX = 100*kron((1990:2016)',ones(12,1)) + kron(ones(2016-1990+1,1),(1:12)');

load liq_vw_hist_deciles.txt        % Jan 1968 -- Dec 2015; 11 columns
R = liq_vw_hist_deciles(:,1:11);
date_R = 100*kron((1968:2015)',ones(12,1)) + kron(ones(2015-1968+1,1),(1:12)');

load ff_factors_192607_201612.txt  
fff = ff_factors_192607_201612;
MKT = fff(:,2)/100;
SMB = fff(:,3)/100;
HML = fff(:,4)/100;
RFR = fff(:,5)/100;
date_MKT = fff(:,1);

beg_date = max([min(date_LIQ) min(date_VIX)]);
end_date = min([max(date_LIQ) max(date_VIX)]);
id1 = find(date_LIQ==beg_date);
id2 = find(date_LIQ==end_date);
LIQ_sub1 = LIQ(id1:id2,1);
id1 = find(date_VIX==beg_date);
id2 = find(date_VIX==end_date);
VIX_sub1 = VIX(id1:id2,1);

aux = corrcoef([LIQ_sub1 VIX_sub1]);
Corr_LIQ_VIX = aux(1,2);

beg_date = max([min(date_LIQ) min(date_MKT)]);
end_date = min([max(date_LIQ) max(date_MKT)]);
id1 = find(date_LIQ==beg_date);
id2 = find(date_LIQ==end_date);
LIQ_sub2 = LIQ(id1:id2,1);
id1 = find(date_MKT==beg_date);
id2 = find(date_MKT==end_date);
MKT_sub2 = MKT(id1:id2,1);

aux = corrcoef([LIQ_sub2 MKT_sub2]);
Corr_LIQ_MKT = aux(1,2);

id = find(MKT_sub2<0);
LIQ_sub3 = LIQ_sub2(id,1);
MKT_sub3 = MKT_sub2(id,1);

aux = corrcoef([LIQ_sub3 MKT_sub3]);
Corr_LIQ_MKT_down = aux(1,2);

id = find(MKT_sub2>=0);
LIQ_sub4 = LIQ_sub2(id,1);
MKT_sub4 = MKT_sub2(id,1);

aux = corrcoef([LIQ_sub4 MKT_sub4]);
Corr_LIQ_MKT_up = aux(1,2);

alphas = -99*ones(2,10);
betas = -99*ones(2,10);

for i = 1:2
    
    eval(['beg_date_reg = beg_date_reg' int2str(i) ';']);
    eval(['end_date_reg = end_date_reg' int2str(i) ';']);
   
    id1 = find(date_R==beg_date_reg);
    id2 = find(date_R==end_date_reg);
    R_sub = R(id1:id2,:);
    id1 = find(date_MKT==beg_date_reg);
    id2 = find(date_MKT==end_date_reg);
    MKT_sub = MKT(id1:id2,1);
    SMB_sub = SMB(id1:id2,1);
    HML_sub = HML(id1:id2,1);
    RFR_sub = RFR(id1:id2,1);

    N = id2-id1+1;
    y = [R_sub(:,1:10) - RFR_sub*ones(1,10) R_sub(:,11)];
    x = [ones(N,1) MKT_sub SMB_sub HML_sub];
    regcoefs = x\y;                          
    u = y - x*regcoefs;
    s2 = (1/(N-4))*diag(u'*u);
    sev = sqrt(diag(kron(diag(s2),inv(x'*x))));
    se = reshape(sev,4,11);
    alpha = regcoefs(1,:)*1200;
    sealpha = se(1,:)*1200;
    talpha = alpha./sealpha;
    
    alphas(i,:) = alpha(1:10);
    
    id1 = find(date_LIQ==beg_date_reg);
    id2 = find(date_LIQ==end_date_reg);
    LIQ_sub = LIQ(id1:id2,:);

    N = id2-id1+1;
    y = [R_sub(:,1:10) - RFR_sub*ones(1,10) R_sub(:,11)];
    x = [ones(N,1) LIQ_sub MKT_sub SMB_sub HML_sub];
    regcoefs = x\y;                          
    u = y - x*regcoefs;
    s2 = (1/(N-5))*diag(u'*u);
    sev = sqrt(diag(kron(diag(s2),inv(x'*x))));
    se = reshape(sev,5,11);
    liq_beta = regcoefs(2,:);
    se_liq_beta = se(2,:);
    t_liq_beta = liq_beta./se_liq_beta;
    
    betas(i,:) = liq_beta(1:10);
    
end

figure(1)

subplot(2,1,1)

%plot(1:10,alphas(1,:),'-',1:10,alphas(2,:),'--');
set(gca,'FontSize',10)
set(gca,'XLabel',text(0,0,'Portfolios sorted by historical liquidity beta (low to high)'))
set(gca,'YLabel',text(0,0,'Fama-French alpha (% per year)'))
titstr=['Upward slope => Liquidity risk is priced']; 
title(titstr); 
legend([int2str(beg_date_reg1) '-' int2str(end_date_reg1)],[int2str(beg_date_reg2) '-' int2str(end_date_reg2)],'Location','Southeast');
   
subplot(2,1,2)

%plot(1:10,betas(1,:),'-',1:10,betas(2,:),'--');
set(gca,'FontSize',10)
set(gca,'XLabel',text(0,0,'Portfolios sorted by historical liquidity beta (low to high)'))
set(gca,'YLabel',text(0,0,'Future liquidity beta'))
titstr=['Upward slope => Historical liquidity betas predict future liquidity betas']; 
title(titstr); 
legend([int2str(beg_date_reg1) '-' int2str(end_date_reg1)],[int2str(beg_date_reg2) '-' int2str(end_date_reg2)],'Location','Southeast');
   
%eval(['print -deps2 fig_liq_alp_bet'])


