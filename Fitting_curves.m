%{
    This program uses a 1D diffusion model to fit the washout curves gain from the vegetation-induced 
    hyporheic exchange experiment conducted in Ecoflume of St. Anthony Falls Laboratory on 2021.

    Final reivse date: 2021/11/17

    Lead author:
	Name: Shih-Hsun Huang
	Institution: Saint Anthony Falls Laboratory, University of Minnesota
	Address: 2 SE 3rd Ave, Minneapolis, MN 55455
	Email: huan2171@umn.edu
	ORCID: https://orcid.org/0000-0002-2958-3559


    Corresponding author:
    Name: Judy Yang
    Institution: Saint Anthony Falls Laboratory, University of Minnesota
    Address: 2 SE 3rd Ave, Minneapolis, MN 55455
    Email: judyyang@umn.edu
	ORCID: https://orcid.org/0000-0001-6272-1266
%}
%% Step 1. Load washout curves
load('Oct19_LSWO_SV_V560_1_washout_curve.mat')
curve_SV_V560_1 = t_mu_std_p_sp_auto;

% Plot washour curves
figure
plot(curve_SV_V560_1(:,1)/60,curve_SV_V560_1(:,2),'kx','linewidth',1.5)
xlabel('Time (hours)')
ylabel('Image intensity')
axis([0 20 0 120])
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',12,'linewidth',1)%,'fontweight','bold');
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])
box on
%% Setup parameters
Dlth = 3.25e-11; % (m^2/s) Initial guass of the mixing coefficient 
Based_level0 = 48; % Initial guass on the background intensity
Start_step = 3; % The first involved data points

AC_curve = curve_SV_V560_1(:,1:2); 
V = 1.2268e+03; % mL (g) amount of injected dye
A = 43*44*0.99; % cm2 injection area
Slop = 0; % Consider the decay of fluorescent dye

%% Fit the washout curves by 1D model
D_fit_Based_line = fminsearch(@(D0_B)washout_fit_fun(AC_curve,Start_step,V,A,D0_B),[Dlth,Based_level0]);

Based_level = D_fit_Based_line(2);
D_fit = D_fit_Based_line(1);

AC_curve_new = AC_curve;
decay_amount = (AC_curve(1:end,1)-AC_curve(1,1))*Slop;
AC_curve_new(:,2) = AC_curve(:,2)-decay_amount; % C (mg/L)

t_sample = AC_curve_new(:,1);

%% Analysis the results (1D diffusion model)
% Parameters of model
V_injection_region = V/1000000; % (m^3) test section with dye
V_flume = 2829.74/1000; % (m^3) the volume of other parts (not including remaininng of the test section
Alth = A/10000; % (m^2) the injection area

dlth = 0.56/1000; % (m) the diffusion length scale (sediment diameter)
klth = D_fit/dlth; % (m/s) the mixing coefficient (D_SWI) between surface water and subsurface water

% Parameter of numerical schieme
delt = 5; % (s) time step
t = 0:delt:(t_sample(end)*60+60); % (s) simulation time

C_bed = zeros(length(t),1); % (mg/L) concentration of dye in the sediment bed (subsurface).
C_flume = zeros(length(t),1); % (mg/L) concentration of dye in the surface water.

C_bed(1,1) = AC_curve_new(Start_step,2)-Based_level;
for i = 1:length(t)-1
    C_bed(i+1) = C_bed(i) - (klth*Alth/V_injection_region)*(C_bed(i)-C_flume(i))*delt; ... 
    C_flume(i+1) = C_flume(i) - (klth*Alth/V_flume)*(C_flume(i)-C_bed(i))*delt;
end

%% Results
% Interpolate the simulated data and check the fitting results
inter_fit = interp1((t/60+AC_curve_new(Start_step,1))/60,C_bed,AC_curve_new(Start_step:end,1)/60);
RMSE = sqrt((mean((inter_fit - (AC_curve_new(Start_step:end,2) - Based_level)).^2)))
R2 = 1 - sum((inter_fit - (AC_curve_new(Start_step:end,2) - Based_level)).^2)/(length(AC_curve_new(Start_step:end,2))-1)/var(AC_curve_new(Start_step:end,2))

figure
hold on
plot(AC_curve_new(:,1)/60,AC_curve_new(:,2)-Based_level,'kx','linewidth',1.5)
plot((t/60+AC_curve_new(Start_step,1))/60,C_bed,'k-','linewidth',1)
plot(AC_curve_new(Start_step,1)/60,AC_curve_new(Start_step,2)-Based_level,'ok','linewidth',2)

text(2, 80, ['RMSE = ',sprintf('%.2f',RMSE)])

legend('Original curve (Shifted)','Diffusion equation','Point start fitting')
xlabel('Time (hours)')
ylabel('Image intensity')
title(['D_{fit} = ',sprintf('%.2e',D_fit),'(m^2/s)',', Slop: ',sprintf('%.2e',Slop),', Baseline: ',sprintf('%.0f',Based_level)])

axis([-0.2 12 -5 120])
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',12,'linewidth',1)%,'fontweight','bold');
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])
box on