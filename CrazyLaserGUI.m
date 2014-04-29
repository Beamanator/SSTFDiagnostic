function[] = CrazyLaserGUI
% We can name this whatever we want...
% I chose CrazyLaserGUI for no apparent reason.

    %--- This is how I like to debug code. Throw this in and we can see where
    %- the function was called and errthang.
    %disp('X');

    %--- create Main Figure Window
    %- color: [red% green% blue%]
    %- resize: 'off' = can't resize GUI window
    %- renderer: 'opengl' =  IDK - came from FrogScan code.
    %- dockcontrols: 'off' = prevents GUI from being able to be put into
    %MATLAB console window.
    %- integerhandle: 'off' = IDK - came from FrogScan code.
    %- menubar: 'none' = disables automatic menu bar so we can create
    %exactly what we need.
    %- name: 'CrazyLaserGUI' = text that goes on window bar - title of GUI
    %- numbertitle: 'off' = gets rid of crazy long number placed before
    %'name' on title of GUI.
    %- toolbar: 'figure' = if we want a toolbar in our GUI.
    %- position: [x, y, Wx, Wy]; x, y = from bottom-left; Wx, Wy = Widths
    %- deletefcn: callback Function called when Main_Figure is deleted / exited.
    Main_Figure = figure(...
        'color',[0.9255 0.9137 0.8471],...
        'resize','off',...
        'renderer','opengl',...
        'dockcontrols','off',...
        'integerhandle','off',...
        'menubar','none',...
        'name','CrazyLaserGUI',...
        'numbertitle','off',...
        'toolbar','figure',...
        'position',[10 50 900 600],... %10 50 is about square from where windows toolbar starts
        'deletefcn',@MF_DeleteFn...
    );

    %--- Create data structure to pass around CrazyLaserGUI.
    %--- 'data' holds all object handles in data.handles, see OpeningFn
    data.Main_Figure = Main_Figure;

    %--- Set data as guidata for CrazyLaserGUI.
    guidata(Main_Figure, data);

    %-----------------------------------------------------------------%
    %%%                             Main        (Main_Figure)       %%%
    %-----------------------------------------------------------------%

     tlb = findall(Main_Figure,'type','uitoolbar'); % find the toolbar
         % find and delete unwanted toolbar buttons
         %- We will most likely want to edit this at some point!!
         tlb_cld = allchild(tlb); delete(tlb_cld([1:4,10:14]));

    if ishandle(Main_Figure), OpeningFn; end

    %-----------------------------------------------------------------%
    %%%                          Functions       (Main_Figure)      %%%
    %-----------------------------------------------------------------%

    % Create all GUI components and initialize handles structure to pass to
    % all other functions in FrogScanGUI
    function OpeningFn
        % Clears console:
        clc;

        % Background color for GUI [red% green% blue%]:
        bkc = [0.9255 0.9137 0.8471]; 
        
        %-----------------------------------------------------------------%
        %%%                       ini File Parameters                   %%%
        %-----------------------------------------------------------------%
        
        %data.Parameters = load('frogscan.mat'); % - how FrogScan starts
        %--- Parameters:
        data.Parameters.ExampleValue = 0.0;
        data.Parameters.RpPosition = 0.0;
        data.Parameters.TpPosition = 0.0;
        
        data.Parameters.xSteps = 100;
        data.Parameters.zSteps = 100;
        data.Parameters.xDirection = 'F';
        data.Parameters.zDirection = 'B';
        data.Parameters.xPoints = 1;
        data.Parameters.zScans = 1;
        
        %-----------------------------------------------------------------%
        %%%                            Panels        (Main_Figure)      %%%
        %-----------------------------------------------------------------%

        %- parent: Main_Figure = Panel to inherit location from
        %- title: 'Motor Parameters' = Name to go inside box line surrounding panel
        %- units: 'normalized' = idk
        %- backgroundcolor: bkc = color defined above
        %- position: [x y Wx Wy] - in percentages of parent panel
        MotorParameters_panel = uipanel(...
            'parent',Main_Figure,...
            'title','Motor Parameters',...
            'units','normalized',...
            'backgroundcolor',bkc,...
            'position',[0.02 1/5 .29 .78]...
        );
        RunScans_panel = uipanel(...
            'parent',Main_Figure,...
            'title','Run Scans',...
            'units','normalized',...
            'backgroundcolor',bkc,...
            'position',[0.02 0.03 .623 .15]...
        );
        Constants_panel = uipanel(...
            'parent',Main_Figure,...
            'title','Constants',...
            'units','normalized',...
            'backgroundcolor',bkc,...
            'position',[1/3 .47 .31 .51]...
        );
        Spectrometer_panel = uipanel(...
            'parent',Main_Figure,...
            'title','Spectrometer',...
            'units','normalized',...
            'backgroundcolor',bkc,...
            'position',[2/3 .77 .31 .21]...
        );
        OtherActions_panel = uipanel(...
            'parent',Main_Figure,...
            'title','Other Actions',...
            'units','normalized',...
            'backgroundcolor',bkc,...
            'position',[2/3 0.47 .31 .28]...
        );
        Position_panel = uipanel(...
            'parent',Main_Figure,...
            'title','Position',...
            'units','normalized',...
            'backgroundcolor',bkc,...
            'position',[1/3 1/5 .31 1/4]...
        );
        Delays_panel = uipanel(...
            'parent',Main_Figure,...
            'title','Delays',...
            'units','normalized',...
            'backgroundcolor',bkc,...
            'position',[2/3 0.03 .31 .42]...
        );

    
        %-----------------------------------------------------------------%
        %%%                       Buttons & Text     (Main_Figure)      %%%
        %-----------------------------------------------------------------%
        
        %---------------------------- Main Figure ------------------------%
        %- uicontrol properties website guide:
        %- http://www.mathworks.com/help/matlab/ref/uicontrol_props.html

        %---------------- Static text (stext): -----------------
        
        %--- Constants Panel stext:
        XMotorPin_stext = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'string',' X Motor Pin:',...
            'fontsize',14,...
            'backgroundcolor',bkc,...
            'fontweight','bold',...
            'HorizontalAlignment','left',...
            'position',[0.06 .8 .5 0.085]...
        );
        ZMotorPin_stext = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'string',' Z Motor Pin:',...
            'fontsize',14,...
            'backgroundcolor',bkc,...
            'fontweight','bold',...
            'HorizontalAlignment','left',...
            'position',[0.06 .63 .5 0.085]...
        );
        XDirPin_stext = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'string',' X Direction Pin:',...
            'fontsize',14,...
            'backgroundcolor',bkc,...
            'fontweight','bold',...
            'HorizontalAlignment','left',...
            'position',[0.06 .37 .6 0.085]...
        );
        ZDirPin_stext = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'string',' Z Direction Pin:',...
            'fontsize',14,...
            'backgroundcolor',bkc,...
            'fontweight','bold',...
            'HorizontalAlignment','left',...
            'position',[0.06 .2 .6 0.085]...
        );
        XMotorPinValue_stext = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'string','6',...
            'fontsize',14,...
            'backgroundcolor',bkc,...
            'fontweight','bold',...
            'HorizontalAlignment','center',...
            'position',[0.8 .8 .085 0.085]...
        );
        ZMotorPinValue_stext = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'string','8',...
            'fontsize',14,...
            'backgroundcolor',bkc,...
            'fontweight','bold',...
            'HorizontalAlignment','center',...
            'position',[0.8 .6 .085 0.085]...
        );
        XDirPinValue_stext = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'string','11',...
            'fontsize',14,...
            'backgroundcolor',bkc,...
            'fontweight','bold',...
            'HorizontalAlignment','center',...
            'position',[0.8 .4 .085 0.085]...
        );
        ZDirPinValue_stext = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'string','13',...
            'fontsize',14,...
            'backgroundcolor',bkc,...
            'fontweight','bold',...
            'HorizontalAlignment','center',...
            'position',[0.8 .2 .085 0.085]...
        );
    
        %--- Motor Parameters stext:
        XSteps_stext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'string',' X Steps:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.06 .895 .4 0.06]...
        );
        ZSteps_stext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'string',' Z Steps:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.06 .79 .4 0.06]...
        );
        XDirection_stext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'string',' X Direction:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.06 .67 .5 0.06]...
        );
        ZDirection_stext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'string',' Z Direction:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.06 .56 .5 0.06]...
        );
        xSpectraCount_stext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'string',' # of X Spectra:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.06 .44 .55 0.06]...
        );
        zScanCount_stext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'string',' # of Z Scans:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.06 .33 .5 0.06]...
        );
        TotalMeasurementsText_stext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'string',' # Triggers:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'horizontalAlignment','left',...
            'position',[0.06 0.04 0.5 0.06]...
        );
        TotalMeasurementsValue_stext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'string','0',...
            'value',0,...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'horizontalAlignment','center',...
            'position',[0.704 0.04 0.18 0.06]...
        );
    
        LastScan_stext = uicontrol(...
            'parent',RunScans_panel,...
            'units','normalized',...
            'style','text',...
            'string','Full',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','center',...
            'position',[0.87 0.35 0.10 0.35]...
        );
    
        %--- Position panel:
        StartPositionText_stext = uicontrol(...
            'parent',Position_panel,...
            'units','normalized',...
            'style','text',...
            'string',' Last Start:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.06 .7 .39 0.18]...
        );
        StartPositionValue_stext = uicontrol(...
            'parent',Position_panel,...
            'units','normalized',...
            'style','text',...
            'string','-',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','center',...
            'position',[0.58 .7 .3 0.18]...
        );
        CurrentPosition_stext = uicontrol(...
            'parent',Position_panel,...
            'units','normalized',...
            'style','text',...
            'string','-',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','center',...
            'position',[.58 .24 .3 .2]...
        );
    
        SpectrumType_stext = uicontrol(...
            'parent',Spectrometer_panel,...
            'units','normalized',...
            'style','text',...
            'string','Avaspec 3048',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','center',...
            'position',[0.1 .6 .8 0.28]...
        );
    
        SpectrumDelayText_stext = uicontrol(...
            'parent',Delays_panel,...
            'units','normalized',...
            'style','text',...
            'string',' Spectrum Pulse:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.07 0.8 0.59 0.12]...
        );
        DriverDelayText_stext = uicontrol(...
            'parent',Delays_panel,...
            'units','normalized',...
            'style','text',...
            'string',' Driver Pulse:',...
            'fontsize',14,...
            'fontweight','bold',...
            'backgroundcolor',bkc,...
            'HorizontalAlignment','left',...
            'position',[0.07 0.6 0.59 0.12]...
        );

        %---------------- Editable text (etext): -----------------
        
        %--- Motor Parameters panel:
        XSteps_etext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','edit',...
            'string','0',...
            'fontsize',12,...
            'backgroundcolor','w',...
            'position',[0.7 .877 .2 0.06],...
            'callback',@EditCallback...
        );
        ZSteps_etext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','edit',...
            'string','0',...
            'fontsize',12,...
            'backgroundcolor','w',...
            'position',[0.7 .79 .2 0.06],...
            'callback',@EditCallback...
        );
        XDirection_etext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','edit',...
            'string','0',...
            'fontsize',12,...
            'backgroundcolor','w',...
            'position',[0.7 .67 .2 0.06],...
            'callback',@EditCallback...
        );
        ZDirection_etext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','edit',...
            'string','0',...
            'fontsize',12,...
            'backgroundcolor','w',...
            'position',[0.7 .56 .2 0.06],...
            'callback',@EditCallback...
        );
        xSpectraCount_etext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','edit',...
            'string','1',...
            'fontsize',12,...
            'backgroundcolor','w',...
            'position',[0.7 .44 .2 0.06],...
            'callback',@EditCallback...
        );
        zScanCount_etext = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','edit',...
            'string','1',...
            'fontsize',12,...
            'backgroundcolor','w',...
            'position',[0.7 .33 .2 0.06],...
            'callback',@EditCallback...
        );
    
        SpectrumDelayValue_etext = uicontrol(...
            'parent',Delays_panel,...
            'units','normalized',...
            'style','edit',...
            'string','0',...
            'value',100,...
            'fontsize',12,...
            'backgroundcolor','w',...
            'position',[0.73 0.8 0.2 0.12],...
            'callback',@EditCallback...
        );
        DriverDelayValue_etext = uicontrol(...
            'parent',Delays_panel,...
            'units','normalized',...
            'style','edit',...
            'string','10',...
            'value',10,...
            'fontsize',12,...
            'backgroundcolor','w',...
            'position',[0.73 0.6 0.2 0.12],...
            'callback',@EditCallback...
        );

        %----------------------- Buttons ------------------------
        
        %--- Run Scans panel buttons:
        XScan_button = uicontrol(...
            'parent',RunScans_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'fontsize',10,...
            'Enable','off',...
            'fontweight','bold',...
            'string','X Only',...
            'position',[0.05 0.2 0.15 0.65],...
            'callback',@ButtonCallback...
        );
        ZScan_button = uicontrol(...
            'parent',RunScans_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'fontsize',10,...
            'Enable','off',...
            'fontweight','bold',...
            'string','Z Only',...
            'position',[0.25 0.2 0.15 0.65],...
            'callback',@ButtonCallback...
        );
        FullScan_button = uicontrol(...
            'parent',RunScans_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'fontsize',10,...
            'Enable','off',...
            'fontweight','bold',...
            'string','Full',...
            'position',[0.45 0.2 0.15 0.65],...
            'callback',@ButtonCallback...
        );
        RepeatScan_button = uicontrol(...
            'parent',RunScans_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'fontsize',10,...
            'enable','off',...
            'fontweight','bold',...
            'string','Repeat',...
            'position',[0.69 0.2 0.15 0.65],...
            'callback',@ButtonCallback...
        );
    
        MotorParametersSave_button = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'fontsize',10,...
            'enable','off',...
            'fontweight','bold',...
            'string','Save',...
            'position',[1/3 0.19 1/3 0.1],...
            'callback',@ButtonCallback...
        );
    
        TakeSpectrum_button = uicontrol(...
            'parent',Spectrometer_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'string','Take Spectrum',...
            'fontsize',10,...
            'enable','off',...
            'fontweight','bold',...
            'HorizontalAlignment','center',...
            'position',[0.25 .15 .5 0.3],...
            'callback',@ButtonCallback...
        );
    
        DelaysSave_button = uicontrol(...
            'parent',Delays_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'string','Save',...
            'fontsize',10,...
            'enable','off',...
            'fontweight','bold',...
            'HorizontalAlignment','center',...
            'position',[1/3 0.1 1/3 0.2],...
            'callback',@ButtonCallback...
        );
    
        GetPosition_button = uicontrol(...
            'parent',Position_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'string','Get Position:',...
            'fontsize',10,...
            'enable','off',...
            'fontweight','bold',...
            'HorizontalAlignment','center',...
            'position',[.1 0.2 2/5 0.3],...
            'callback',@ButtonCallback...
        );
   
        %--------------------- Solid Lines: ---------------------
        ConstantsLine = uicontrol(...
            'parent',Constants_panel,...
            'units','normalized',...
            'style','text',...
            'backgroundcolor',[0 0 0],...
            'position',[0.25 .54 .5 .01]...
        );
    
        RunScansLine = uicontrol(...
            'parent',RunScans_panel,...
            'units','normalized',...
            'style','text',...
            'backgroundcolor',[0 0 0],...
            'position',[0.643 0.35 0.005 0.35]...
        );
    
        MotorParametersLine1 = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'backgroundcolor',[0 0 0],...
            'position',[0.25 0.76 0.5 0.007]...
        );
        MotorParametersLine2 = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'backgroundcolor',[0 0 0],...
            'position',[0.25 0.53 0.5 0.006]...
        );
        MotorParametersLine3 = uicontrol(...
            'parent',MotorParameters_panel,...
            'units','normalized',...
            'style','text',...
            'backgroundcolor',[0 0 0],...
            'position',[0.25 0.14 0.5 0.006]...
        );

        %-----------------------------------------------------------------%
        %%%                         Menu Bar       (Main_Figure)        %%%
        %-----------------------------------------------------------------%
        
        %--- This is how you make a lable on the top bar of the GUI.
        %- Main_Figure = which uipanel to put it on.
        %- label: 'File' = text to appear on menu to click on.
        File_menu = uimenu(...
            'parent', Main_Figure,...
            'label','File'...
        );
            ExitProgram = uimenu(...
                'parent',File_menu,...
                'label','Exit',...
                'separator','on',...
                'callback',@MenuCallback...
            );
        
        Run_menu = uimenu(...
            'parent', Main_Figure,...
            'label','Run'...
        );
            StartArduino = uimenu(...
                'parent', Run_menu,...
                'label','Arduino',...
                'separator','off',...
                'callback',@MenuCallback...
            );
            StartInductionSensor = uimenu(...
                'parent', Run_menu,...
                'label','Induction Sensor',...
                'separator','on',...
                'callback',@MenuCallback...
            );
        
        Test_menu = uimenu(...
            'parent', Main_Figure,...
            'label','Test',...
            'callback',@MenuCallback...
        );
            Test2_menu = uimenu(...
                'parent',Test_menu,...
                'label','Test2',...
                'Checked','off',...
                'callback',@MenuCallback...
            );
        
        %-----------------------------------------------------------------%
        %%%                       Data Array       (Main_Figure)        %%%
        %-----------------------------------------------------------------%

        %- HANDLES are used for events - button pressing, text changing, etc.
        %--- panel handles
        data.handles.MotorParameters_panel = MotorParameters_panel;
        data.handles.RunScans_panel = RunScans_panel;
        data.handles.Constants_panel = Constants_panel;
        data.handles.Position_panel = Position_panel;
        data.handles.OtherActions_panel = OtherActions_panel;
        data.handles.Spectrometer_panel = Spectrometer_panel;
        data.handles.Delays_panel = Delays_panel;
        
        %--- static text
        data.handles.XMotorPin_stext = XMotorPin_stext;
        data.handles.ZMotorPin_stext = ZMotorPin_stext;
        data.handles.XDirPin_stext = XDirPin_stext;
        data.handles.ZDirPin_stext = ZDirPin_stext;
        data.handles.XMotorPinValue_stext = XMotorPinValue_stext;
        data.handles.ZMotorPinValue_stext = ZMotorPinValue_stext;
        data.handles.XDirPinValue_stext = XDirPinValue_stext;
        data.handles.ZDirPinValue_stext = ZDirPinValue_stext;
        data.handles.SpectrumType_stext = SpectrumType_stext;
        data.handles.LastScan_stext = LastScan_stext;
        data.handles.SpectrumDelayText_stext = SpectrumDelayText_stext;
        data.handles.StartPositionText_stext = StartPositionText_stext;
        data.handles.StartPositionValue_stext = StartPositionValue_stext;
        data.handles.DriverDelayText_stext = DriverDelayText_stext;
        data.handles.XSteps_stext = XSteps_stext;
        data.handles.ZSteps_stext = ZSteps_stext;
        data.handles.XDirection_stext = XDirection_stext;
        data.handles.ZDirection_stext = ZDirection_stext;
        data.handles.xSpectraCount_stext = xSpectraCount_stext;
        data.handles.zScanCount_stext = zScanCount_stext;
        data.handles.CurrentPosition_stext = CurrentPosition_stext;
        data.handles.TotalMeasurementsValue_stext = TotalMeasurementsValue_stext;
        data.handles.TotalMeasurementsText_stext = TotalMeasurementsText_stext;
        
        %--- edit text
        data.handles.XSteps_etext = XSteps_etext;
        data.handles.ZSteps_etext = ZSteps_etext;
        data.handles.XDirection_etext = XDirection_etext;
        data.handles.ZDirection_etext = ZDirection_etext;
        data.handles.xSpectraCount_etext = xSpectraCount_etext;
        data.handles.zScanCount_etext = zScanCount_etext;
        data.handles.SpectrumDelayValue_etext = SpectrumDelayValue_etext;
        data.handles.DriverDelayValue_etext = DriverDelayValue_etext;
        
        %--- button handles
        data.handles.XScan_button = XScan_button;
        data.handles.ZScan_button = ZScan_button;
        data.handles.FullScan_button = FullScan_button;
        data.handles.RepeatScan_button = RepeatScan_button;
        data.handles.MotorParametersSave_button = MotorParametersSave_button;
        data.handles.TakeSpectrum_button = TakeSpectrum_button;
        data.handles.DelaysSave_button = DelaysSave_button;
        data.handles.GetPosition_button = GetPosition_button;
        
        %--- menu handles
        data.handles.ExitProgram = ExitProgram;
        data.handles.StartArduino = StartArduino;
        data.handles.StartInductionSensor = StartInductionSensor;
        
        data.handles.Test_menu = Test_menu;
        data.handles.Test2_menu = Test2_menu;
        
        UpdateDisplay();
        
    end

    %-----------------------------------------------------------------%
    %%%                   Callbacks      (Main_Figure)              %%%
    %-----------------------------------------------------------------%

    %--- MenuCallback function takes srv and evnt as automatically passed
    %- in variables. These do not need to be used, they are just here. Each
    %- handle is in the data array, so we will search through the handles
    %- using 'switch gcbo' and figure out which handle was called, and
    %- execute code accordingly.
    function MenuCallback(srv,evnt)
        handles = data.handles; % just to limit code below
        
        % switch on object whos callback is being executed (gcbo)
        switch gcbo
            case handles.ExitProgram
                %MF_DeleteFn; %this line may be unnecessary.
                delete(Main_Figure);

            case handles.StartArduino
                StartArduino();
                if isfield(data.Hardware, 'Arduino')
                    set(handles.StartArduino, 'Checked', 'on');
                    set(handles.StartArduino, 'Enable', 'off');
                end

            case handles.StartInductionSensor
                % Must click 'Change Folder' on Loadup for this to work.
                addpath([pwd '\Matlab']);
                data.Hardware.Inductor = LDC1000_script();

            case handles.Test_menu
                %disp('Test function.');               
                %bob = data.Hardware.Inductor;
                %if exist('bob', 'var')
                %    disp('available');
                %else
                %    disp('nope');
                %end

            case handles.Test2_menu                
                %box = handles.Test2_menu;

                %checked = get(box, 'Checked');
                %if strcmp(checked,'off');
                %    set(box, 'Checked', 'on');
                %else
                %    set(box, 'Checked', 'off');
                %end
                disp('Testing roundTrip(42)');
                if isfield(data.Hardware, 'Arduino')
                    data.Hardware.Arduino.roundTrip(42);
                end
        end
        % Maybe call UpdateDisplay if we want?
    end

    %--- EditCallback is the same as menuCallback, but for editable text boxes!
    function EditCallback(srv,evnt)
        p = data.Parameters;
        handles = data.handles;

        % - NOT TESTED YET!!!
        % - SHOULD WORK FOR EVERY BOX SINCE NOTHING NEEDS STRINGS!
        % check to make sure values are NOT strings:
        str = get(srv,'String');
        if isempty(str2num(str))
            set(srv,'String','0');
            warndlg('Input must be numerical');
        else
            %disp('Here maybe set data.Parameters value?');
            %disp('Depends on how well we can use srv variable!!');
        end
        
        switch gcbo
            case handles.XSteps_etext
                disp('xSteps text box changed');

            case handles.ZSteps_etext
                disp('zSteps text box changed');

            case handles.ZDirection_etext
                disp('xDirection text box changed');

            case handles.ZDirection_etext
                disp('zDirection text box changed');

            case handles.xSpectraCount_etext
                disp('xDataPoints / Spectra Count text box changed');

            case handles.zScanCount_etext
                disp('zScans / Scan Count text box changed');

            case SpectrumDelayValue_etext
                disp('Spectrum delay value text box changed');

            case DriverDelayValue_etext
                disp('Driver delay value text box changed');
                
        end
        
        UpdateDisplay();
    end

    %--- ButtonCallback is the same as menuCallback, but with buttons!
    function ButtonCallback(srv,evnt)
        handles = data.handles;
        
        switch gcbo
            case handles.TakeSpectrum_button
                % Not tested yet!
                a = data.Parameters.Arduino;
                a.roundTrip(22);

            case handles.MotorParametersSave_button
                % Not tested yet:
                p = data.Parameters;
                p.xStep = str2double(get(handles.XSteps_etext, 'String'));
                p.zStep = str2double(get(handles.ZSteps_etext, 'String'));
                p.xDirection = str2double(get(handles.XDirection_etext, 'String'));
                p.zDirection = str2double(get(handles.ZDirection_etext, 'String'));
                p.xPoints = str2double(get(handles.SpectraCount_etext, 'String'));
                p.zScans = str2double(get(handles.ScanCount_etext, 'String'));

                sendArduinoVariables(['xStep' xStep]);
                
            case handles.GetPosition_button
                disp('position button pressed.');
                % Runs pre-written code. A modified version should probably be
                % written for our stuff.
                addpath([pwd '\Matlab']);
                [Rp_vars, Tp_vars] = LDC1000_script();
                
                avgRp = mean(Rp_vars);
                avgTp = mean(Tp_vars);

                set(handles.CurrentPosition_stext,'string',num2str(avgRp) );

                data.Parameters.RpPosition = avgRp;
                data.Parameters.TpPosition = avgTp;
                %disp(vars);

            % case handles.Test_etext
                % stepValue = get(handles.Test_etext,'string');
                % if isempty(stepValue) %is something
                    % set(handles.Test_step, 'Enable', 'off');
                    % data.Parameters.stepValue = 0.0;
                % elseif not(isnan(str2double(stepValue)))
                    % set(handles.Test_step, 'Enable', 'on');
                    % data.Parameters.stepValue = str2double(stepValue);
                % elseif isnan(str2double(stepValue))
                    % disp(stepValue);
                % end
                
                % disp(data.Parameters.stepValue);
        end
        % Maybe call UpdateDisplay if we want?
    end

    %--- src and evnt are two variables automatically passed into this
    %- delete function.
    %- src is a double - on windows it seems to be 18.003 and counting...
    %- evnt seems to be an empty variable.
    %--- in any case, src and evnt need to be accepted, no need to use 'em.
    function MF_DeleteFn(src,evnt)
        %- This works, but we'll try the other way.
        %if strcmp(get(data.handles.TestMove_button, 'Enable'),'on')%TestMove_button not available anymore.
        %    delete(data.Hardware.Arduino);
        %    disp('Arduino disconnected');
        %elseif strcmp(get(data.handles.TestMove_button, 'Enable'),'off')
        %    disp('arduino already off');
        %end
        %- New way:     
        
        if exist('data.Hardware.Arduino', 'var')
            delete(data.Hardware.Arduino);
        else
            disp('Arduino already off');
        end
        disp('Here we will kill all other events - spectrometer, etc.!');
    end

    %--- Initialize Arduino.
    %- connect to correct COM port,
    %- create Arduino variable, set correct pins to correct values.
    %- [Only called ONCE - when starting CrazyLaserGUI]
    function StartArduino()
        if exist('data.Hardware.Arduino','var') && isa(data.Hardware.Arduino,'arduino') && isvalid(data.Hardware.Arduino),
            % already connected, so nothing to do here.
            disp('no need to connect arduino again.');
        else
            % Arduino is not connected yet, so set up connection.
            data.Hardware.Arduino = arduino('COM4');

            handles = data.handles;

            % Enable Arduino-function buttons:
            set(handles.XScan_button, 'Enable', 'on');
            set(handles.ZScan_button, 'Enable', 'on');
            set(handles.FullScan_button, 'Enable', 'on');
            set(handles.RepeatScan_button, 'Enable', 'on');
            set(handles.MotorParametersSave_button, 'Enable', 'on');
            set(handles.TakeSpectrum_button, 'Enable', 'on');
            set(handles.DelaysSave_button, 'Enable', 'on');
        end

        %TODO: either get rid of this line or use variable 'a' in rest of program.
        a = data.Hardware.Arduino;
    end

    %------ NOT TESTED YET:
    %--- sendArduinoVariables is a function that sends variables to the Arduino.
    %- uses roundTrip() function.
    %- param array = what to send to Arduino.
    %- array[0] = variable name,
    %- array[1] = value of variable to send.
    function sendArduinoVariables(array)
        a = data.Hardware.Arduino;

        name = array(1);
        nameVar = 0;
        value = array(2);

        switch name
            case 'xStep'
                nameVar = 11;
            case 'zStep'
                nameVar = 12;
            case 'xDirection'
                nameVar = 13;
            case 'zDirection'
                nameVar = 14;
            case 'xDataPoints'
                nameVar = 15;
            case 'zScans'
                nameVar = 16;
            case 'SpectrumDelay'
                nameVar = 17;
            case 'DriverDelay'
                nameVar = 18;
        end

        % not exactly sure if this will work:
        if (a == 0)
            disp('Hmm, wrong code sent to sendArduinoVariables somewhere');
        else
            a.roundTrip(nameVar);
            pause(0.1);
            a.roundTrip(value);
            pause(0.1);
        end
    end

    %--- Moves Arduino a given direction and # of steps.
    %- if dir is 'F', will move stage AWAY from motor [forward]
    %- if dir is 'B', will move stage TOWARDS motor [backward]
    % function Move(dir, steps)
    %     a = data.Hardware.Arduino;
    %     switch dir
    %         case 'F'
    %             disp('Forward')
    %             a.digitalWrite(2, 1);
    %         case 'B'
    %             disp('Backward')
    %             a.digitalWrite(2, 0);
    %     end
    %     disp(steps);
    %     for m = 1:steps
    %         a.digitalWrite(3, 1);
    %         pause(0.001); % - should be ~ 1 millisecond pause but ISN'T
    %         a.digitalWrite(3, 0);
    %         pause(0.001);
    %     end
    % end

    %--- Updates the display to conform with private parameter values.
    function UpdateDisplay()
        h = data.handles;
        
        %--- Update # of triggers needed for spectrometer:
        xPoints = str2double(get(h.xSpectraCount_etext, 'String'));
        zScans = str2double(get(h.zScanCount_etext, 'String'));
        
        total = zScans * xPoints;
        set(h.TotalMeasurementsValue_stext, 'string', num2str(total));
    end
end