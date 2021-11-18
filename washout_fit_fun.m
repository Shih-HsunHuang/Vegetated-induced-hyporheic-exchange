function RMSE = washout_fit_fun(AC_curve,Start_step,V,A,Dlth_B)

Based = Dlth_B(2);

basic_step = length(AC_curve);

V_injection_area = V/1000000; % (m^3) test section with dye
% V_flume =  (2829.74+60*150*18/1000*0.3)/1000-V_injection_area; % (m^3) the volume of other parts (not including remaininng of the test section
V_flume =  (2829.74)/1000; % (m^3) the volume of other parts (not including remaininng of the test section
Alth = A/10000; % (m^2) the injection area
dlth = 0.56/1000; % (m) thickness of the mesh
klth = Dlth_B(1)/dlth; % (m/s) the mass transfer coefficient between test section and other parts

% simulation sitting
delt = 5; % (s) time step
t = 0:delt:(AC_curve(end,1)*60+60); % (s) simulation time

C_test_section = zeros(length(t),1); % (mg/L) concentration of carbaryl in the epilimnion of the stacked lake.
C_flume = zeros(length(t),1); % (mg/L) concentration of carbaryl in the hypolimnion of the stacked lake.

C_test_section(1,1) = AC_curve(Start_step,2)-Based; % Image intensity of dye
for i = 1:length(t)-1
    C_test_section(i+1) = C_test_section(i) - (klth*Alth/V_injection_area)*(C_test_section(i)-C_flume(i))*delt; ... % inflow and mass exchange across thermocline       
    C_flume(i+1) = C_flume(i) - (klth*Alth/V_flume)*(C_flume(i)-C_test_section(i))*delt;
end

inter_fit = interp1((t/60+AC_curve(Start_step,1))/60,C_test_section,AC_curve(Start_step:basic_step,1)/60);
RMSE = sqrt((mean((inter_fit - (AC_curve(Start_step:basic_step,2) - Based)).^2)));
