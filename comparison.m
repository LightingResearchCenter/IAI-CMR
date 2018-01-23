function comparison
%COMPARISON Summary of this function goes here
%   Detailed explanation goes here

%% Enable dependencies
[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
legendflexDir = fullfile(pwd,'legendflex');
addpath(circadianDir,legendflexDir);
import daysimeter12.*
import shared.*

%% Set the creationDate
creationDate = datestr(now,'yyyy-mm-dd_HHMM');

%% Map folders and files
projectDir = '\\root\programs\Light-and-Health\IAI_CircadianMonitoringAndRegulation\PrototypeEvaluation\watch';
download3Dir = fullfile(projectDir,'download3');
downloadFinalDir = fullfile(projectDir,'downloadFinal');
plotsDir = fullfile(projectDir,'plots');

txtFile = fullfile(download3Dir,'DaysiLog.txt');
cdfFile = fullfile(downloadFinalDir,'0025-2015-01-21-14-16-53.cdf');
outFile = fullfile(plotsDir,['DaysiWatchComparison_',creationDate]);

%% Import data

[absTimeIAI,lightIAI,activityIAI] = convertLog(txtFile);
cdfData = daysimeter12.readcdf(cdfFile);
[absTimeLRC,~,~,lightLRC,activityLRC,~,~,~] = daysimeter12.convertcdf(cdfData);

timeIAI = datetime(absTimeIAI.localDateVec);
timeLRC = datetime(absTimeLRC.localDateVec);

csIAI = lightIAI.cs;
csLRC = lightLRC.cs;

close all;
h = figure;
h.PaperType = '<custom>';
h.PaperSize = [6.5,4.75];
h.PaperPosition = [0,0,6.5,4.75];
h.Units = 'inches';
h.Position = [1,1,6.5,4.75];


hAxes1 = axes;
hAxes1.Units = 'inches';
hAxes1.Position = [0.5,2.875,5.625,1.5]; % x, y, width, height
hCS = plot(timeIAI,csIAI,'x',timeLRC,csLRC,'o');
hCS(1).MarkerSize = 3;
hCS(2).MarkerSize = 3;
datetick(hAxes1,'x','HH:MM');
hAxes1.YLim = [0,0.7];
hAxes1.YTick = 0:0.1:0.7;
ylabel('CS');
title({'Circadian Stimulus (CS)';'with 10 point (~5 mins) gaussian filter'})


hAxes2 = axes;
hAxes2.Units = 'inches';
hAxes2.Position = [0.5,0.625,5.625,1.5]; % x, y, width, height
hAI = plot(timeIAI,activityIAI,'x',timeLRC,activityLRC,'o');
hAI(1).MarkerSize = 3;
hAI(2).MarkerSize = 3;
datetick(hAxes2,'x','HH:MM');
ylabel('AI');
title({'Activity Index (AI)';'with 10 point (~5 mins) gaussian filter'})

lbl = {'DaysiMeter App','USB Direct Download'};
legendflex(hAxes2, lbl, 'ref', hAxes2,...
           'anchor', [6 2], ...
           'buffer', [  0 -30], ...
           'ncol', 2, ...
           'padding', [0 0 10]);

saveas(h,[outFile,'.pdf']);
saveas(h,[outFile,'.png']);

end


function [absTime,light,activity] = convertLog(filePath)
import lightcalc.*
import daysimeter12.*

% #17
% rCal = 1.3495;
% gCal = 1.6747;
% bCal = 3.3902;

% #25
rCal = 1.0840;
gCal = 1.4343;
bCal = 2.5357;

[time1,red1,blue1,green1,activity1,~,~] = importDaysiLog(filePath);

red2 = red1(:).*rCal;
green2 = green1(:).*gCal;
blue2 = blue1(:).*bCal;

absTime = absolutetime(time1,'datevec',false,-5,'hours');
cla = daysimeter12.rgb2cla(red2,green2,blue2);
cla = filter5min(cla,30);
illuminance = daysimeter12.rgb2lux(red2,green2,blue2);
chromaticity = daysimeter12.rgb2chrom(red2,green2,blue2);
light = lightmetrics('illuminance',illuminance,...
    'cla',cla,'chromaticity',chromaticity);
activity2 = (sqrt(activity1(:)))*.0039*4;
activity = filter5min(activity2,30);
end

function data = filter5min(data,epoch)
%FILTER5MIN Lowpass filter data series with zero phase delay,
%   moving average window.
%   epoch = sampling epoch in seconds
minutes = 5; % length of filter (minutes)
Srate = 1/epoch; % sampling rate in hertz
windowSize = floor(minutes*60*Srate);
b = ones(1,windowSize)/windowSize;

if epoch <= 150
    data = filtfilt(b,1,data);
end
    

end
