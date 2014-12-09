function hFigure = initfig(h,visible)
%INITIALIZEFIGURE Summary of this function goes here
%   Detailed explanation goes here

import reports.composite.*;

% Create figure window
hFigure = figure(h);
set(hFigure,'Visible',visible);

% Define paper properties
paperOrientation = 'landscape'; % 'portrait' or 'landscape'
set(hFigure,'PaperOrientation',paperOrientation);

paperType = 'usletter';
set(hFigure,'PaperType',paperType);

paperUnits = 'inches'; % Paper units
set(hFigure,'PaperUnits',paperUnits);

paperSize = get(hFigure,'PaperSize'); % [width,height]

% Define useable area to print in
margin = 0.5; % inches
width  = paperSize(1)-2*margin;
height = paperSize(2)-2*margin;
paperPosition = [margin,margin,width,height]; % [left,bottom,width,height]
set(hFigure,'PaperPosition',paperPosition);
set(hFigure,'PaperPositionMode','auto');

% Define figure window properties
set(hFigure,'Units','normalized');
position = get(hFigure,'Position');
position(1) = 1;
position(2) = 0;
set(hFigure,'Position',position);

set(hFigure,'Units','inches');

position = get(hFigure,'Position');
position(1) = position(1) + 1;
position(2) = position(2) + 1;
position(3) = width;
position(4) = height;
set(hFigure,'Position',position);
set(hFigure,'Units','normalized');

% Limit user's ability to change figure
% dockControls = 'off';
% set(hFigure,'DockControls',dockControls);

resize = 'off';
set(hFigure,'Resize',resize);

end

