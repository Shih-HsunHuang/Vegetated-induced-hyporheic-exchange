function [RMSE, R2, inter_fit_return, t_fitting] = washout_fit_plot_fun(AC_curve,Start_step,V,A_SWI,End_step,V_H_B)

Background_intensity = V_H_B(2);

phi_s = 0.3; % Porosity of the sediment

V_s = V/1000000; % [m^3] test section with dye
V_w =  (2829.74)/1000; % [m^3] the volume of other parts (not including remaininng of the test section)
A = A_SWI*phi_s/10000; % [m^2] the exchange area

% delta_D = 0.56/100; % [m] the mixing length scale
delta_D = 1; % Define V_H = De/delta_D
V_H = V_H_B(1)/delta_D; % [m/s] the effective hyporheic exchange velocity

% simulation sitting
delt = 5; % (s) time step
t = 0:delt:(AC_curve(end,1)*60+60); % (s) simulation time

% Turn accumulated concentration (AC) to concentration (C)
C0 = (AC_curve(Start_step,2)-Background_intensity)/(V/phi_s/A_SWI); % (V/phi_s/A) is accumulated depth

C_s = zeros(length(t),1); % (mg/L) concentration of dye in the sediment bed (subsurface).
C_w = zeros(length(t),1); % (mg/L) concentration of dye in the surface water.

C_s(1,1) = C0;  % initial concentration
for i = 1:length(t)-1
    C_s(i+1) = C_s(i) - (V_H*A/V_s)*(C_s(i)-C_w(i))*delt;
    C_w(i+1) = C_w(i) - (V_H*A/V_w)*(C_w(i)-C_s(i))*delt;
end

% Turn C to AC
C_s = C_s*(V/phi_s/A_SWI);

% Interpolate the simulated data and check the fitting results
inter_fit = interp1((t/60+AC_curve(Start_step,1))/60,C_s,AC_curve(Start_step:End_step,1)/60);
RMSE = sqrt((mean((inter_fit - (AC_curve(Start_step:End_step,2) - Background_intensity)).^2)));
R2 = 1 - sum((inter_fit - (AC_curve(Start_step:End_step,2) - Background_intensity)).^2)/(length(AC_curve(Start_step:End_step,2))-1)/var(AC_curve(Start_step:End_step,2));

inter_fit_return = interp1((t/60+AC_curve(Start_step,1))/60,C_s,AC_curve(Start_step:end,1)/60);
t_fitting = AC_curve(Start_step:end,1);

figure
hold on
scatter(AC_curve(:,1)/60,AC_curve(:,2)-Background_intensity,'ko','MarkerEdgeAlpha',0.4)
plot(AC_curve(Start_step:End_step,1)/60,inter_fit,'k-','linewidth',1.8)
scatter(AC_curve(Start_step,1)/60,AC_curve(Start_step,2)-Background_intensity,'kx','linewidth',2)
scatter(AC_curve(End_step,1)/60,AC_curve(End_step,2)-Background_intensity,'kx','linewidth',2)

p1 = plot((t/60+AC_curve(Start_step,1))/60,C_s,'k--','linewidth',1.8);
p1.Color(4) = 0.75;
text(2, max(AC_curve(:,2))/2, ['RMSE = ',sprintf('%.2f',RMSE),', R^2 = ',sprintf('%.2f',R2)])

legend('Original curve (Shifted)','Model fit','Fitting duration')
xlabel('Time (hours)')
ylabel('Fluorescence intensity')
title(['V_H = ',sprintf('%.2e',V_H_B(1)),' (m^2/s)',', Baseline: ',sprintf('%.0f',Background_intensity)])

axis([-0.2 max(AC_curve(:,1))/60 -5 max(AC_curve(:,2))-Background_intensity+5])
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',14,'linewidth',1)
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])
box on