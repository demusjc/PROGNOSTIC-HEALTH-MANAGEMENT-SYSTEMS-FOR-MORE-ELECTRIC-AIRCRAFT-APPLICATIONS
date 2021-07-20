%% %%% =|>- %%%%% MIAMI UNIVERSITY POWER ELECTRONICS LABORATORY %%%%%%%%%%%
%  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  PURPOSE:  Configures Plots for Publication in a Paper.
%
%  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  NOTES:       Based on chppeplot.  Created to deal with multiple colors.
%
%  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  - DATE -    VER  - AUTHOR        - ACTION
%  2018-12-29  1.0  - Mark Scott    - Created code
%  2019-03-13  1.1  - Mark Scott    - Added Type
%  2019-06-14  1.2  - Mark Scott    - Added Extra Formating for LaTeX
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function fMUPEL_PLOT(Title, Xlabel, Ylabel, Type, PrintFileName)
if nargin < 3
    Ylabel = {};
    Type = 'Preliminary';
    PrintFileName = '';
elseif nargin < 4
    Type = 'Preliminary';
    PrintFileName = '';
elseif nargin < 5
    PrintFileName = '';
end

%% APPEARANCE PARAMETERS %%
if(strcmpi(Type, 'Preliminary'))
    % Font Sizes:
    AxisFontSize        = 12;
    XlabelFontSize      = 12;
    YlabelFontSize      = 14;
    TitleLabelFontSize  = 14;
    % Figure Properties:
    ImageSize           = [0 0 5 5]; % Width x Height
    
elseif(strcmpi(Type, 'Presentation'))
    % Font Sizes:
    AxisFontSize        = 16;
    XlabelFontSize      = 18;
    YlabelFontSize      = 18;
    TitleLabelFontSize  = 20;
    % Figure Properties:
    ImageSize           = [0 0 6.25 5]; % Width x Height
    
elseif(strcmpi(Type, 'Poster'))
    % Font Sizes:
    AxisFontSize        = 20;
    XlabelFontSize      = 24;
    YlabelFontSize      = 24;
    TitleLabelFontSize  = 28;
    % Figure Properties:
    ImageSize           = [0 0 8 5]; % Width x Height
    
elseif(strcmpi(Type, 'Poster_Wide'))
    % Font Sizes:
    AxisFontSize        = 20;
    XlabelFontSize      = 24;
    YlabelFontSize      = 24;
    TitleLabelFontSize  = 28;
    % Figure Properties:
    ImageSize           = [0 0 11 5]; % Width x Height
    
elseif(strcmpi(Type, 'LaTeX'))
    % Font Sizes:
    AxisFontSize        = 6;
    XlabelFontSize      = 7;
    YlabelFontSize      = 7;
    TitleLabelFontSize  = 7.6;
    % Figure Properties:
    ImageSize           = [0 0 3 2]; % Width x Height
    ImageSize           = [0 0 3.5 3]; % Width x Height
    LineWidth           = 1;
    
elseif(strcmpi(Type, 'LaTeX_2'))
    % Font Sizes:
    AxisFontSize        = 7;
    XlabelFontSize      = 8;
    YlabelFontSize      = 8;
    TitleLabelFontSize  = 8.5;
    % Figure Properties:
    ImageSize           = [0 0 3 2]; % Width x Height
    ImageSize           = [0 0 3.5 3]; % Width x Height
    LineWidth           = 1;
    
elseif(strcmpi(Type, 'LaTeX-Will'))
    % For Will's Latex - Tiks
    % Font Sizes:
    AxisFontSize        = 8;
    XlabelFontSize      = 8;
    YlabelFontSize      = 16;
    TitleLabelFontSize  = 9.6;
    % Figure Properties:
    ImageSize           = [0 0 3 2]; % Width x Height
    ImageSize           = [0 0 3.5 2]; % Width x Height
    LineWidth           = 1.3;
    
    %set(gcf, 'Position',ImageSize)
    
elseif(strcmpi(Type, 'WiPDA'))
    % Font Sizes:
    AxisFontSize        = 8;
    XlabelFontSize      = 8;
    YlabelFontSize      = 8;
    TitleLabelFontSize  = 9;
    % Figure Properties:
    ImageSize           = [0 0 7 4.5]; % Width x Height
    LineWidth           = 1;
    
    %set(gcf, 'Position',ImageSize)
    
elseif(strcmpi(Type, 'Paper'))
    % Font Sizes:
    AxisFontSize        = 12;
    XlabelFontSize      = 12;
    YlabelFontSize      = 14;
    TitleLabelFontSize  = 14;
    % Figure Properties:
    ImageSize           = [0 0 3.7 3.7]; % Width x Height
    LineWidth           = 1;
    MarkerSize          = 3;
    
elseif(strcmpi(Type, 'Paper2'))
    % Font Sizes:
    AxisFontSize        = 12;
    XlabelFontSize      = 12;
    YlabelFontSize      = 14;
    TitleLabelFontSize  = 14;
    % Figure Properties:
    ImageSize           = [0 0 3.7 3.7]; % Width x Height
    LineWidth           = 1;
    MarkerSize          = 3;
    
else
    % Font Sizes:
    AxisFontSize        = 7;
    XlabelFontSize      = 7;
    YlabelFontSize      = 7;
    TitleLabelFontSize  = 8;
    % Figure Properties:
    ImageSize           = [0 0 3.2 2.6]; % Width x Height
    
end

PlotLineWidth       = 1.25;
BorderGridLineWidth = 0.5;

%% ALTER PLOT APPEARANCE

set(gca,'fontsize', AxisFontSize, ...
    'fontweight', 'bold',...
    'FontName','Times',...
    'LineWidth',BorderGridLineWidth,...
    'XGrid','on', ...
    'YGrid','on');

set(gcf,'PaperUnits', 'inches',...
    'PaperPosition', ImageSize);

% CREATE TITLE AND AXIS LABELS
title(Title,  'fontsize', TitleLabelFontSize ,'fontweight','bold');
xlabel(Xlabel,'fontsize', XlabelFontSize, 'fontweight', 'bold');
if(nargin >=3 && Ylabel ~= "" )
    ylabel(Ylabel,'fontsize', YlabelFontSize, 'fontweight', 'bold');
end

if(nargin == 5)
    
    if(strcmpi(Type, 'LaTeX') || strcmpi(Type, 'LaTeX-2'))
        filename = strcat(PrintFileName,'.eps')
        print(filename,'-depsc','-r600');
    else
        filename = strcat(PrintFileName,'.png')
        print(filename,'-dpng','-r600');
    end
end
end