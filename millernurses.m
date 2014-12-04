function MillerNurses = millernurses
%PLOTNURSES Summary of this function goes here
%   Detailed explanation goes here

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
circadianDir = fullfile(parentDir,'circadian');

addpath(circadianDir);
import('millerize.*');

populationName = 'Day Shift Nurses';

nursesDir = '\\ROOT\projects\DaysimeterAndDimesimeterReferenceFiles\Nurses study\raw data';

DataArray = importdaynursesdir(nursesDir);

Location = struct;
Location.name = 'Troy, NY';
Location.latitude = 42.728412;
Location.longitude = -73.691785;
Location.gmtOffset = -5;

nFile = numel(DataArray);

StructArray  = struct('time',[],'cs',[],'activity',[]);
StructArray.time.minutes = [];
TempStruct = struct('time',[],'cs',[],'activity',[]);

for i1 = 1:nFile
    timeArray = DataArray(i1).timeArray;
    % Convert the time to custom time classes
    absTime = absolutetime(timeArray(:),'datenum',false,Location.gmtOffset,'hours');
    relTime = relativetime(absTime);
    
    masks.observation = true(size(timeArray));
    csArray = DataArray(i1).csArray;
    activityArray = DataArray(i1).activityArray;
    
    [         ~,TempStruct.cs] = millerize.millerize(relTime,csArray,masks);
    [TempStruct.time,TempStruct.activity] = millerize.millerize(relTime,activityArray,masks);
    
%     plot(TempStruct.time.hours,TempStruct.cs);
    
    StructArray.time = relativetime([StructArray.time.minutes;TempStruct.time.minutes],'minutes');
    StructArray.cs = [StructArray.cs;TempStruct.cs];
    StructArray.activity = [StructArray.activity;TempStruct.activity];
    
%     pause
%     clc;
    
end
masks.observation = true(size(StructArray.time.minutes));
MillerNurses = struct('time',[],'cs',[],'activity',[]);
[         ~,MillerNurses.cs] = millerize.millerize(StructArray.time,StructArray.cs,masks);
[MillerNurses.time,MillerNurses.activity] = millerize.millerize(StructArray.time,StructArray.activity,masks);
% plot(Miller.time.hours,Miller.cs);

save('millerNurses.mat','MillerNurses');
end


function DataArray = importdaynursesdir(textDir)
%IMPORTDAYNURSESDIR Summary of this function goes here
%   Detailed explanation goes here

dayShiftNurses = {1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16, 17, 18, 19, 21, 23,...
                  26, 27, 28, 31, 32, 33, 34, 35, 37, 38, 39, 40, 41,...
                  43, 45, 46, 48, 51, 55, 56, 57, 58, 62, 94, 110, 120,...
                  123, 127, 128, 130, 131, 132, 134}';
dayShiftNurses = cellfun(@num2str,dayShiftNurses,'UniformOutput',false);

extension = repmat({'.txt'},size(dayShiftNurses));
fileNameArray = strcat(dayShiftNurses,extension);
filePathArray = fullfile(textDir,fileNameArray);

nCdf = numel(filePathArray);
DataArray  = struct('timeArray',{[]},'csArray',{[]},'activityArray',{[]});
TempStruct = struct('timeArray',{[]},'csArray',{[]},'activityArray',{[]});
for i1 = 1:nCdf
    filePath = filePathArray{i1};
    [timeArray,claArray,activityArray] = importtextfile(filePath);
    TempStruct.timeArray = timeArray + 693960;
    TempStruct.csArray = lightcalc.CSCalc_postBerlin_12Aug2011(claArray);
    TempStruct.activityArray = activityArray;
    DataArray(i1,1) = TempStruct;
end


end


