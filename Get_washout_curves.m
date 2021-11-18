%{
    This program deals with the images taken from the vegetation-induced 
    hyporheic exchange experiment conducted in Ecoflume of St. Anthony Falls Laboratory on 2021.

    The pictures are the top view of the flume. After the fluorescent dye
    was injected into the sediment, the flow was started and the pictures were
    taken in an interval of 5 minutes for about 16 hours.

    In each picture, there are dowels, meshes and sediment with dye. The goal of
    this program is to get the averaged image intensity of the sediment with dye varies with time. 

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
%% Start of the program
% Move the floder and take the information of files
% cd 'Test run' % move floder
file_name = dir('*1024*.tiff');
%%
file_length = 4; % Total number of processed photos

rect_center = [565   397   332   258]; % Define the interested area

P0 = imread(file_name(1).name);

% Mark the interested area
figure
imshow(P0)
rectangle('Position',rect_center,...
  'Curvature',[0,0],...
  'EdgeColor', 'w',...
  'LineWidth', 1.5,...
  'LineStyle','-');
set(gca, 'position', [0 0 1 1 ])

% Check whether the fluorescent intensity saturated in the first photo
P0_center = imcrop(P0,rect_center);
P0_center_double = im2double(P0_center(:,:,2))*255; 
P0_center_double_line = P0_center_double(:);

P0_filtered = P0_center;
P0_filtered(P0_filtered==255) = 0;

figure
imagesc(P0_filtered(:,:,2))
colorbar
caxis([0 250])
%%
%_ Step 1. Build up the mask to block the pixels of dowels 

i = 13; % The index to show the location of particular mask 

Dowel_locations = [
9	24.5915 % 1
59.6745 19.2574 % 2
104.1786 16.2330 %3
160.5180 13.6529 %4
207.7242 12.1036 %5
240.8608 11.7152 %6
286.4892 14.1886 %7
327.4384 25.2128 %8
6.2523 65.5181   %9
49.2456 63.5623  %10
86.8187 51.2057  %11
123.3589 55.4101 % 12
173.9331 63.0775 % 13
226.2769 60.9162 % 14
280.1737 57.2885;% % 15
317.9103 56.3064 % 16
21.8998 101.7854; % 17
60.0702 106.5608 % 18
121.2178 104.4168 % 19
160.3212 94.0380 % 20
206.8349 94.3079 % 21
249.7866 98.1512 % 22
297.5055 103.9723 % 23
327.5387 109.3054
5.6049 154.0324 % 25
46.1392 144.4116 %26
92.8666 147.5030 % 27
136.1226 134.5624 % 28
183.2810 138.4694
234.0007 138.8366% 30
275.7587 146.5258 % 31
320.1754 148.5129 % 32
26.8453 193.4106 % 33
74.8653 194.2808
111.8869 183.6439 % 35
162.3646 177.4309 % 36
210.3116 180.5124 % 37
248.5345 185.1929 % 38
301.7775 179.5296 % 39
326.8267 187.1309
8.8424 236.2643 % 
45.6539 236.2567 % 42
90.9263 228.7948 % 43
143.1921 237.2588 % 44
194.0266 235.7042 % 45
234.5503 237.2285 % 46
282.2565 234.0714 % 47
315.2511 225.8645 % 48
51.9640 210.6338
];

dowel_simiaxis = [
    10 35;
    15 21.7718;
    15.9699 22.2139;
    14.1494 17.0373;
    13.2829 16.9377;
    11.9294 16.1329;
    26.3346 10.5713;
    18.1934 9.8667
    7.7200 13.7489; % 9
    12.9122 20.2800;
    13.7709 20.9428;
    14.5544 18.5289;
    13.7117 18.8259;
    15.0960 25.7545; % 14
    14.2386 26.0995; % 15
    13.3538 17.8625;
    13.1514 22.9057; % 17
    17.1960 17.5059;
    18.2859 18.7567;
    17.0874 16.1397; % 20
    16.4697 20.8247;
    15.2836 15.2310;
    22.4722 13.2432;
    9.3059 12.1123;
    9 14.7009;
    17.6280 16.2526;
    14.3851 14.8651;
    12.1755 16.6864;
    14.5763 16.5870;
    13.2411 28.1144; % 30
    15.5536 13.9078;
    30.1657 14.2611; % 32
    18.7474 13.6656;
    14.9357 16.9034;
    16.2923 14.2268;
    15.2111 17.1107;
    17.9887 13.3091;
    16.6521 16.6770;
    21.4582 13.5785;
    9.1499 6.6622;
    13.1061 7.7576; 
    11.9598 19.1578;
    16.9248 18.8100;
    17.6517 17.1958;
    11.8634 16.7386;
    11.4717 19.0672;
    21.7179 12.2564; 
    22.0561 11.7976;
    10 9.8258;
];
dowel_angle = [
    50;
    44.4221;
    226.3396;
    0;
    333.4937;
    319.5875;
    48.0515;
    42.7433;
    1.6433; % 9
    31.6963;
    21.8607; % 11
    0;
    16.4254; % 13
    324.4151;
    313.8485; % 15
    317.2738;
    50.8612; % 17
    0;
    0.4523;
    0; % 20
    337.6490;
    0;
    23.6349;
    323.7519;
    359.7375;
    0;
    0;
    23.7745;
    0;
    300.6889 % 30
    32.0029;
    23.8429; % 32
    357.5064;
    345.3854;
    0;
    345.0876;
    32.4163; % 37
    354.1290;
    12.6509;
    86.7442;
    50.8571;
    314.0022;
    0;
    0;
    39.2173;
    49.6758;
    347.8362;
    356.5656;
    50;
    ];

% Show the area of particular mask (by setting i in the beginning of this section)
figure
imshow(P0_center)
dowel_one = images.roi.Ellipse(gca,'Center',Dowel_locations(i,:), ...
    'Semiaxes',dowel_simiaxis(i,:), 'RotationAngle', dowel_angle(i));

%%% ---- Uncomment this line if the location of mask need to be adjusted

dowel_Mask = createMask(dowel_one);
for i = 1:length(Dowel_locations)
dowel_one = images.roi.Ellipse(gca,'Center',Dowel_locations(i,:), ...
    'Semiaxes',dowel_simiaxis(i,:), 'RotationAngle', dowel_angle(i));
BW = createMask(dowel_one);
dowel_Mask(BW == 1) = 1;
end

% Check the mask
P0_filtered = P0_center(:,:,2);
P0_filtered(dowel_Mask == 1) = NaN;
imAlpha=ones(size(P0_filtered));
imAlpha(dowel_Mask == 1)=0;

figure
imagesc(P0_filtered,'AlphaData',imAlpha)
set(gca,'color',0*[1 1 1]);
xlabel('Pixels')
ylabel('Pixels')
c = colorbar;
caxis([0 255])
ylabel(c, 'Green channel', 'FontName', 'Times New Roman')
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',14,'linewidth',1)%,'fontweight','bold');
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])
box on

%% Step 2. Find the washout curve
cut_mu_std = zeros(length(1:file_length),2);

t_mu_std_p_sp_auto = zeros(length(1:file_length),5); % Washout curves
%%
if_check = 0; % (0 or 1) Check the results to filter out the pixels of mesh
if_see_pdf = 0; % (0 or 1) Check the pdfs used to classify to filter out the pixels of mesh

pixel_propotion = 40; % The % of sediment with dye in whole pictures
% Parameters to shift the pdf
addmu = 8;% 
timestd = 0.8; % 

for i = 1:file_length
% Crop the interested area
P0 = imread(file_name(i).name);
P0_center = imcrop(P0,rect_center);
P0_center_double = im2double(P0_center(:,:,2))*255; 
P0_center_double_line = P0_center_double(:);

% Check the number of saturated pixel
saturated_pixel_number = length(find(P0_center_double(~dowel_Mask)==255));

% Fitting the distribution
sig_try(1,1,1:2) = [20,20];

RI_v_m_d(1,1) = 20;
RI_v_m_d(1,2) = 40;
S = struct('mu',RI_v_m_d(1:2)','Sigma',sig_try(1,1,1:2),'ComponentProportion',[0.7,0.3]');
pdf_fit_ce = fitgmdist(P0_center_double_line(P0_center_double_line<255 & dowel_Mask(:) == 0),2,'Start',S);

%_the pdf is shifted here_____________________________
a = pdf_fit_ce.mu(1);
b = sqrt(pdf_fit_ce.Sigma(1));
count = 0;
count_pixel = 0;
count_decent = 1;

while count_pixel ~= pixel_propotion

c = pdf_fit_ce.mu(2)+addmu;
d = sqrt(pdf_fit_ce.Sigma(2))*timestd;

%_Filter the pixel within the range of the second pdf (no upper boundary)
P_double_filtered = P0_center_double;
P_double_filtered(P0_center_double<c-2*d | P0_center_double == 255 | dowel_Mask == 1) = 0;

P_double_filtered_line = P0_center_double_line;
P_double_filtered_line(P0_center_double_line<c-2*d | P0_center_double_line == 255 | dowel_Mask(:) == 1) = 0;

P_in_mu = mean(P_double_filtered_line(P_double_filtered_line>0));
P_in_std = std(P_double_filtered_line(P_double_filtered_line>0));

if saturated_pixel_number ~= 0
    disp('Is satrated.')

    P_satrated = P0_center_double;
    P_satrated(dowel_Mask == 1) = 0;
    P_satrated(dowel_Mask == 0 & P_satrated<255) = 0;

    count_pixel = round((length(find(P_double_filtered_line>0))+saturated_pixel_number)/length(P_double_filtered_line(dowel_Mask(:) == 0))*100); % here!!!!
    fprintf('%.0f %.2f %.2f %d%% saturated: %.2f%% \n', [i P_in_mu P_in_std, ... 
        count_pixel, ...
        (saturated_pixel_number)/length(find(dowel_Mask == 0))])
else

    count_pixel = round(length(find(P_double_filtered_line>0))/length(P_double_filtered_line(dowel_Mask(:) == 0))*100);
    fprintf('%.0f %.2f %.2f %d%% \n', [i P_in_mu P_in_std, count_pixel]) 
    
end

if count == 0
    if count_pixel > pixel_propotion
        addmu = addmu + 1;
        count_decent = 1;
    else
        addmu = addmu - 1;
        count_decent = 0;
    end
else
    if count_pixel > pixel_propotion && count_decent == 1
        addmu = addmu + 1;
    elseif count_pixel < pixel_propotion && count_decent == 0
        addmu = addmu - 1;
    else
        count_pixel = pixel_propotion;
    end
end
count = count + 1;

end % while end
cut_mu_std(i,1:2) = [c d];
t_mu_std_p_sp_auto(i,1) = (file_name(i).datenum - file_name(1).datenum)*24*60; % minutes
t_mu_std_p_sp_auto(i,2:4) = [P_in_mu P_in_std length(find(P_double_filtered_line>0))/length(P_double_filtered_line)];
t_mu_std_p_sp_auto(i,5) = (saturated_pixel_number)/length(find(dowel_Mask == 0));
count_pixel = 0;
count = 0;

if if_check == 1
%%{
figure
imshowpair(P0_center,P_double_filtered,'montage')
%%}

%%{
imAlpha=ones(size(P_double_filtered));
imAlpha(P_double_filtered == 0)=0;
figure
imagesc(P_double_filtered,'AlphaData',imAlpha)
set(gca,'color',0*[1 1 1]);
xlabel('Pixels')
ylabel('Pixels')
cb = colorbar;
caxis([0 255])
ylabel(cb, 'Green channel', 'FontName', 'Times New Roman')
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',14,'linewidth',1)%,'fontweight','bold');
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])
box on
%}
end

if if_see_pdf == 1
%%{
pdf_x = 0:1:255;
pdf_group_1 = pdf('Normal',pdf_x,a,b);
pdf_group_2 = pdf('Normal',pdf_x,c,d);

figure
h = histogram(P0_center_double_line(dowel_Mask(:) == 0),50,'facecolor','none','linewidth',1.5);
h.Normalization = 'probability';
hold on
plot(pdf_x,pdf_group_1,'k--','linewidth',1.5)
plot(pdf_x,pdf_group_2,'k-','linewidth',1.5)
axis([0 255 0 0.115])
xlabel('Image intensity (green channel)')
ylabel('Distribution of pixels')
    legend('Data','Data group 1','Data group 2')
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',14,'linewidth',1)%,'fontweight','bold');
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])

figure
h = histogram(P_double_filtered_line(P_double_filtered_line>0),50,'facecolor','none','linewidth',1.5);
h.Normalization = 'probability';
hold on
plot(pdf_x,pdf_group_2,'k-','linewidth',1.5)

axis([0 255 0 0.115])
xlabel('Image intensity (green)')
ylabel('Number of pixel')
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',14,'linewidth',1)%,'fontweight','bold');
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])
%}
end
end
disp('end.')

% Results

figure
hold on
plot(t_mu_std_p_sp_auto(:,1)/60,t_mu_std_p_sp_auto(:,2),'k','linewidth',1)

xlabel('Time (hours)')
ylabel('Image intensity')
set(gca, 'FontName', 'Times New Roman')
set(gca,'fontsize',14,'linewidth',1)%,'fontweight','bold');
set(gcf,'PaperPositionMode','Manual')
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[8 6])
set(gcf,'PaperPosition',[0 0 8 6])
%% Save the results
%{
 save('Oct19_LSWO_SV_V550_2_washout_curve.mat','t_mu_std_p_sp_auto','cut_mu_std')
%}