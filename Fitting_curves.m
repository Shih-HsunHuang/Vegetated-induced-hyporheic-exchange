%{
    This program uses a pair of first order equations to fit the washout 
    curves gained from the vegetation-induced  hyporheic exchange experiment 
    conducted in Ecoflume of St. Anthony Falls Laboratory on 2021.

    The experiment data can be found at: https://doi.org/10.13020/W282-JJ11

    last revision: 2021/03/25

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
load('DV_V595_2.mat')

% Divided analysis to 4 subregions
curves = zeros(size(pixel_gs,3), 4);
t = t_mu_std_p_sp_auto(:,1);
for i = 1:size(pixel_gs,3)
    temp_p = pixel_gs(1:129,1:166,i);
    temp_p(temp_p == 0) = NaN;
    curves(i,1) = mean(temp_p,'all','omitnan');
    
    temp_p = pixel_gs(1:129,167:333,i);
    temp_p(temp_p == 0) = NaN;
    curves(i,2) = mean(temp_p,'all','omitnan');
    
    temp_p = pixel_gs(130:259,1:166,i);
    temp_p(temp_p == 0) = NaN;
    curves(i,3) = mean(temp_p,'all','omitnan');
    
    temp_p = pixel_gs(130:259,167:333,i);
    temp_p(temp_p == 0) = NaN;
    curves(i,4) = mean(temp_p,'all','omitnan');
end
%%
% Plot washour curves
figure
hold on
plot(t/60,curves(:,1),'x','linewidth',1)
plot(t/60,curves(:,2),'o','linewidth',1)
plot(t/60,curves(:,3),'^','linewidth',1)
plot(t/60,curves(:,4),'s','linewidth',1)

xlabel('Time (hours)')
ylabel('Image intensity')
axis([0 20 0 90])
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',12,'linewidth',1)
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])
box on
%% Setup parameters
VH_0 = 3.25e-6; % (m^2/s) Initial guass of the coefficient 
Based_level0 = 35; % Initial guass of the background image intensity

Start_step_0 = 4; % The first involved data for whole region

% Assign the fitting interval
Start_step = 11; % The start of model fit
End_step = 27; % The end of model fit

V = 1195.8; % mL (g) amount of injected dye
A = 43*44*0.95; % cm2 injection area *0.95 for DV
%% ___Fit the washout curves ___
%% Fit the washout curves gained from the 4 subregions of analyzed region
D_fit_all = zeros(4,4); % Include all the data [V_H Background_intensity RMSE R2]
D_fit_part = zeros(4,4); % Fit the model to the data within the fitting interval [V_H Background_intensity RMSE R2]
for i = 1:4
% Fit background intensity
AC_curve = [t,curves(:,i)];
D_fit_all(i,1:2) = fminsearch(@(D0_B)washout_fit_part_fun(AC_curve,Start_step_0,V,A,length(AC_curve),D0_B),[VH_0,Based_level0]);
[D_fit_all(i,3), D_fit_all(i,4), ~, ~] = washout_fit_plot_fun(AC_curve,Start_step_0,V,A,length(AC_curve),D_fit_all(i,1:2));

% Fit V_H
AC_curve = [t,curves(:,i)];
D_fit_part(i,1) = fminsearch(@(D0)washout_fit_part_fun(AC_curve,Start_step,V,A,End_step,[D0,D_fit_all(i,2)]),VH_0);
D_fit_part(i,2) = D_fit_all(i,2);

[D_fit_part(i,3), D_fit_part(i,4), ~, ~] = washout_fit_plot_fun(AC_curve,Start_step,V,A,End_step,D_fit_part(i,1:2));
end