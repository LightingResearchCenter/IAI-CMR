%% Clear out workspace
close all
clear
clc

%% Prepare data
% load('millerNurses.mat');

label1 = 'Circadian Stimulus (CS)';
label2 = 'Activity Index (AI)';
label3 = 'Idealized CS Curve';

MillerNurses = millernurses; % This function is slow to run

millerTime = MillerNurses.time;

cs = MillerNurses.cs;
ai = MillerNurses.activity;

outputFileName = ['idealizedCScurve',datestr(now,'_yyyy-mm-dd_HHMM')];

%% Construct idealized CS curve
% idxPlateau = millerTime.hours >= 10.5 & millerTime.hours < 16.5;
idxPlateau = millerTime.hours >= 10 & millerTime.hours < 16.5;
% plateauMean = mean(cs(idxPlateau));
plateau = 0.225;

% idxRise = millerTime.hours >= 6.5 & millerTime.hours < 9;
idxRise = millerTime.hours >= 6 & millerTime.hours < 10;
% riseFit = fit(millerTime.hours(idxRise),cs(idxRise),'poly1');
% riseCoeff = coeffvalues(riseFit);
riseCoeff = [0.05625 -0.3375];
rise = riseCoeff(1)*millerTime.hours + riseCoeff(2);

% Fall A
idxFallA = millerTime.hours >= 16.5 & millerTime.hours < 20.5;
% fallAFit = fit(millerTime.hours(idxFallA),cs(idxFallA),'poly1');
% fallACoeff = coeffvalues(fallAFit);
a = (0.06 - 0.225)/(20.5-16.5);
b = 0.225 - a*16.5;
fallACoeff = [a b];
fallA = fallACoeff(1)*millerTime.hours + fallACoeff(2);

% Fall B
idxFallB = millerTime.hours >= 20.5 & millerTime.hours < 24;
% fallBFit = fit(millerTime.hours(idxFallB),cs(idxFallB),'poly1');
% fallBCoeff = coeffvalues(fallBFit);
a = -.06/(24 - 20.5);
b = -a*24;
fallBCoeff = [a b];
fallB = fallBCoeff(1)*millerTime.hours + fallBCoeff(2);

% Compose ideal curve
idealPiecewise = zeros(size(cs));
idealPiecewise(idxRise) = rise(idxRise);
idealPiecewise(idxPlateau) = plateau;
idealPiecewise(idxFallA) = fallA(idxFallA);
idealPiecewise(idxFallB) = fallB(idxFallB);

phi = 3.75;
t2 = millerTime;
t2.hours = mod(t2.hours - phi,24);
options = fitoptions('Method','SmoothingSpline','SmoothingParam',0.5);
[splineFit,gof,out] = fit(t2.hours,idealPiecewise,'smoothingspline',options);
idealSpline = feval(splineFit,t2.hours);
idealSpline(idealSpline<0) = 0;

%% Reorder data
[t2.hours,sortIdx] = sort(t2.hours);
cs = cs(sortIdx);
ai = ai(sortIdx);
idealSpline = idealSpline(sortIdx);

%% Export formula
coefficients = coeffvalues(splineFit);
save([outputFileName,'_formula.mat'],'splineFit','coefficients');

%% Export data
outputStruct = struct;
outputStruct.minutes_from_reference_phi = t2.minutes(:);
outputStruct.reference_CS = idealSpline(:);
outputCell = dataset2cell(struct2dataset(outputStruct));
xlswrite([outputFileName,'_numeric.xlsx'],outputCell);

%% Execute plot
hFigure = initfig(1,'on');
hAxes = custommiller(t2,label1,cs,label2,ai,label3,idealSpline);
title('Day-Shift Nurses, n = 45');

%% Save plot to file
saveas(hFigure,[outputFileName,'_plot.pdf']);



