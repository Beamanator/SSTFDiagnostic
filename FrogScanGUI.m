function[] = FrogScanGUI
%
%
%
%

%--- Things to Add/Try
% Fast readout command is for focus mode try using that for faster data
% acquisition (done 1.24.09)

%--- constants
speed_of_light = 0.000299792458; % mm/fs

%--- create Main Figure Window
Main_Figure = figure('color',[0.9255    0.9137    0.8471],...
                     'resize','off',...
                     'renderer','opengl',...
                     'dockcontrols','off',...
                     'integerhandle','off',...
                     'menubar','none',...
                     'name','FrogScanGUI',...
                     'numbertitle','off',...
                     'toolbar','figure',...
                     'position',[10 50 900 600],...
                     'deletefcn',@MF_DeleteFcn);

%--- Create data structure to pass around FrogScanGUI.
%--- Data holds all object handles in data.handles, see FS_OpeningFcn
data.Main_Figure = Main_Figure;
%--- Set data as guidata for FrogScanGUI.
guidata(Main_Figure,data);

%--- initial calibration
data.lambda = csvread('C:\Documents and Settings\ufokhz\My Documents\MATLAB2\Calibration Files\WaveLengthCalibration_400nm.txt');

%-----------------------------------------------------------------%
%%%                             Main                            %%%
%-----------------------------------------------------------------%
tlb = findall(Main_Figure,'type','uitoolbar'); % find the toolbar
    % find and delete unwanted toolbar buttons
    tlb_cld = allchild(tlb); delete(tlb_cld([1:4,10:14]));


if ishandle(Main_Figure), FS_OpeningFcn; end



%-----------------------------------------------------------------%
%%%                         Functions                           %%%
%-----------------------------------------------------------------%
    % Create all GUI components and initialize handles structure to pass to
    % all other functions in FrogScanGUI
    function  FS_OpeningFcn

        bkc = [0.9255 0.9137 0.8471];
        %-----------------------------------------------------------------%
        %%%                             Axes                            %%%
        %-----------------------------------------------------------------%
        Axes1 = axes('parent',Main_Figure,...
                     'box','on',...
                     'units','normalized',...
                     'position',[0.054 0.459 0.438 0.462]);
                 
        Axes2 = axes('parent',Main_Figure,...
                   'position',[0.054 0.459 0.438 0.462],...
                   'yaxislocation','right',...
                   'xaxislocation','top',...
                   'xtick',[],...
                   'ytick',[],...
                   'color','none');
        
        %-----------------------------------------------------------------%
        %%%                       ini File Parameters                   %%%
        %-----------------------------------------------------------------%
        
        data.Parameters = load('frogscan.mat');
        data.Parameters.BinX1 = 0;
        data.Parameters.BinX2 = 1024;
        data.Parameters.BinY1 = 51;
        data.Parameters.BinY2 = 71;
        data.Parameters.SetTemp = 0;
                 
        %-----------------------------------------------------------------%
        %%%                            Panels                           %%%
        %-----------------------------------------------------------------%
        Focus_panel = uipanel('parent',Main_Figure,...
                              'title','',...
                              'units','normalized',...
                              'backgroundcolor',bkc,...
                              'position',[0.0534 0.0444 0.4373 0.1516]);
                          
        Camera_panel = uipanel('parent',Main_Figure,...
                               'title','Camera','fontsize',14,...
                               'units','normalized',...
                               'backgroundcolor',bkc,...
                               'position',[0.5289 0.2282 0.4526 0.3369]);
                           
            SetTemperature_panel = uipanel('parent',Camera_panel,...
                                           'title','',...
                                           'units','normalized',...
                                           'backgroundcolor',bkc,...
                                           'position',[0.852 0.459 0.124 0.515]);
                           
            CameraStatus_panel = uipanel('parent',Camera_panel,...
                                         'title','',...
                                         'units','normalized',...
                                         'backgroundcolor',bkc,...
                                         'position',[0.032 0.052 0.642 0.34]);
                                     
            TakeExposure_panel = uipanel('parent',Camera_panel,...
                                         'title','',...
                                         'units','normalized',...
                                         'backgroundcolor',bkc,...
                                         'position',[0.689 0.052 0.292 0.34]);
                                     
            Temp_panel = uipanel('parent',Camera_panel,...
                                 'title','','fontsize',14,...
                                 'units','normalized',...
                                 'backgroundcolor',bkc,...
                                 'position',[0.852 0.459 0.124 0.515]);

        Stage_panel = uipanel('parent',Main_Figure,...
                              'title','Stage','fontsize',14,...
                              'units','normalized',...
                              'backgroundcolor',bkc,...
                              'position',[0.6347 0.6110 0.3468 0.3247]);

            MoveStage_panel = uipanel('parent',Stage_panel,...
                                      'title','',...
                                      'units','normalized',...
                                      'backgroundcolor',bkc,...
                                      'position',[0.79 0.409 0.162 0.538]);
                                  
            StageStatus_panel = uipanel('parent',Stage_panel,...
                                        'title','',...
                                        'units','normalized',...
                                        'backgroundcolor',bkc,...
                                        'position',[0.051 0.065 0.904 0.263]);                                  
                                     
        Start_panel = uipanel('parent',Main_Figure,...
                              'title','','fontsize',14,...
                              'units','normalized',...
                              'backgroundcolor',bkc,...
                              'position',[0.5322 0.0429 0.4493 0.1531]);
        
        Auto_panel = uipanel('parent',Main_Figure,...
                             'title','','fontsize',14,...
                             'units','normalized',...
                             'backgroundcolor',bkc,...
                             'position',[0.5289 0.6095 0.0905 0.3078]);
                         
        PlotBinning_panel = uipanel('parent',Main_Figure,...
                                    'title','Plotting & Binning','fontsize',14,...
                                    'units','normalized',...
                                    'backgroundcolor',bkc,...
                                    'position',[0.054 0.229 0.438 0.178]);
                                
            Binning_panel = uipanel('parent',PlotBinning_panel,...
                                    'title','Binning','fontsize',8,...
                                    'units','normalized',...
                                    'backgroundcolor',bkc,...
                                    'position',[0.501 0.12 0.463 0.88]);
        %-----------------------------------------------------------------%
        %%%                       Buttons & Text                        %%%
        %-----------------------------------------------------------------%
        %---------------------------- Main Figure ------------------------%
        Intensity_stext = uicontrol('parent',Main_Figure,...
                          'units','normalized',...
                          'style','text',...
                          'string','Intensity:',...
                          'HorizontalAlignment','left',...
                          'position',[0.06 0.92 0.05 0.03]);
                      
        Intensity_Disp_stext = uicontrol('parent',Main_Figure,...
                          'units','normalized',...
                          'style','text',...
                          'string','0.0',...
                          'fontsize',14,...
                          'fontweight','bold',...
                          'HorizontalAlignment','left',...
                          'position',[0.11 0.93 0.08 0.03]);
                              
        %---------------------------- Focus Panel ------------------------%
        Focus_button = uicontrol('parent',Focus_panel,...
                                 'units','normalized',...
                                 'style','toggle',...
                                 'string','Focus',...
                                 'position',[0.0327 0.1340 0.3451 0.7113],...
                                 'callback',@ButtonCallback,...
                                 'enable','off');
                             
        Find0_button = uicontrol('parent',Focus_panel,...
                                 'units','normalized',...
                                 'style','pushbutton',...
                                 'string','Find 0',...
                                 'position',[0.5970 0.1340 0.3451 0.7113],...
                                 'callback',@ButtonCallback,...
                                 'enable','off');
        
        %---------------------------- Start Panel ------------------------%
        Start_button = uicontrol('parent',Start_panel,...
                                 'units','normalized',...
                                 'style','pushbutton',...
                                 'string','Start Scan',...
                                 'position',[0.0490 0.1531 0.3358 0.7041],...
                                 'callback',@ButtonCallback);
        
        Stop_button = uicontrol('parent',Start_panel,...
                                'units','normalized',...
                                'style','pushbutton',...
                                'string','Stop Scan',...
                                'position',[0.6324 0.1531 0.3358 0.7041],...
                                'callback',@ButtonCallback);

        %---------------------------- AUTO Panel -------------------------%
        Auto_button = uicontrol('parent',Auto_panel,...
                                'units','normalized',...
                                'style','pushbutton',...
                                'string','AUTO',...
                                'position',[0.1899 0.6834 0.6456 0.2563],...
                                'callback',@ButtonCallback);
                             
        Full_button = uicontrol('parent',Auto_panel,...
                                'units','normalized',...
                                'style','pushbutton',...
                                'string','FULL',...
                                'position',[0.1899 0.1206 0.6456 0.2563],...
                                'callback',@ButtonCallback);
                            
        %---------------------------- Temp Panel -------------------------%
        TUP_button = uicontrol('parent',Temp_panel,...
                               'units','normalized',...
                               'style','pushbutton',...
                               'string','<html>&#8593</html>',...
                               'position',[0.1702 0.6577 0.6596 0.2685],...
                               'callback',@ButtonCallback);
                             
        TDN_button = uicontrol('parent',Temp_panel,...
                               'units','normalized',...
                               'style','pushbutton',...
                               'string','<html>&#8595</html>',...
                               'position',[0.1702 0.1141 0.6596 0.2685],...
                               'callback',@ButtonCallback);

        %-------------------------- Camera Panel -------------------------%
        
        %--- buttons
        TakeExposure_button = uicontrol('parent',TakeExposure_panel,...
                                      'units','normalized',...
                                      'style','pushbutton',...
                                      'string','Take Exposure',...
                                      'position',[0.112 0.547 0.793 0.359],...
                                      'callback',@ButtonCallback);
                             
        SetTemperature_button = uicontrol('parent',TakeExposure_panel,...
                                          'units','normalized',...
                                          'style','pushbutton',...
                                          'string','Set Temperature',...
                                          'position',[0.112 0.109 0.793 0.359],...
                                          'callback',@ButtonCallback);
        
                            
        %--- static text
        SetTemp_stext = uicontrol('parent',Camera_panel,...
                                  'units','normalized',...
                                  'style','text',...
                                  'string','Set Temperature :',...
                                  'fontsize',10,...
                                  'fontweight','bold',...
                                  'position',[0.063 0.753 0.297 0.129]);
                             
        Temp_stext = uicontrol('parent',Camera_panel,...
                               'units','normalized',...
                               'style','text',...
                               'string','Temperature :',...
                               'fontsize',10,...
                               'fontweight','bold',...
                               'position',[0.058 0.459 0.246 0.124]);
                           
        CameraStatus_stext = uicontrol('parent',CameraStatus_panel,...
                                       'units','normalized',...
                                       'style','text',...
                                       'string','Camera Status:',...
                                       'horizontalalignment','left',...
                                       'position',[0.05 0.609 0.285 0.234]);
                           
        CoolerMode_stext = uicontrol('parent',CameraStatus_panel,...
                                     'units','normalized',...
                                     'style','text',...
                                     'string','Cooler Mode:',...
                                     'horizontalalignment','left',...
                                     'position',[0.05 0.188 0.245 0.234]);
                                 
        CameraStatus_Disp_stext = uicontrol('parent',CameraStatus_panel,...
                                            'units','normalized',...
                                            'style','text',...
                                            'string','Camera_Idle',...
                                            'horizontalalignment','left',...
                                            'position',[0.369 0.609 0.581 0.234]);
                           
        CoolerMode_Disp_stext = uicontrol('parent',CameraStatus_panel,...
                                     'units','normalized',...
                                     'style','text',...
                                     'string','Cooler_At_Ambient',...
                                     'horizontalalignment','left',...
                                     'position',[0.327 0.188 0.645 0.234]);
        %--- edit text
        SetTemp_etext = uicontrol('parent',Camera_panel,...
                                  'units','normalized',...
                                  'style','edit',...
                                  'string',num2str(data.Parameters.SetTemp),...
                                  'backgroundcolor','w',...
                                  'position',[0.431 0.753 0.243 0.211],...
                                  'callback',@EditCallback);
                             
        Temp_etext = uicontrol('parent',Camera_panel,...
                               'units','normalized',...
                               'style','edit',...
                               'string','Temperature',...
                               'enable','off',...
                               'position',[0.428 0.459 0.246 0.216]);
        
        %-------------------------- Stage Panel --------------------------%
        
        %--- buttons
        MUP_button = uicontrol('parent',MoveStage_panel,...
                                'units','normalized',...
                                'style','pushbutton',...
                                'string','<html>&#8593</html>',...
                                'position',[0.17 0.602 0.681 0.286],...
                                'callback',@ButtonCallback);
                             
        MDN_button = uicontrol('parent',MoveStage_panel,...
                                'units','normalized',...
                                'style','pushbutton',...
                                'string','<html>&#8595</html>',...
                                'position',[0.17 0.143 0.681 0.286],...
                                'callback',@ButtonCallback);
                            
        %--- static text
        Increment_stext = uicontrol('parent',Stage_panel,...
                                    'units','normalized',...
                                    'style','text',...
                                    'string','Increment :',...
                                    'fontsize',10,...
                                    'fontweight','bold',...
                                    'horizontalalignment','left',...
                                    'position',[0.051 0.72 0.322 0.129]);
                             
        FullRange_stext = uicontrol('parent',Stage_panel,...
                                    'units','normalized',...
                                    'style','text',...
                                    'string','Full Range :',...
                                    'fontsize',10,...
                                    'fontweight','bold',...
                                    'horizontalalignment','left',...
                                    'position',[0.051 0.409 0.322 0.129]);
                                
        StageStatus_stext = uicontrol('parent',StageStatus_panel,...
                                      'units','normalized',...
                                      'style','text',...
                                      'string','Stage Status:',...
                                      'horizontalalignment','left',...
                                      'position',[0.025 0.489 0.243 0.362]);
                                 
        StageStatus_Disp_stext = uicontrol('parent',StageStatus_panel,...
                                           'units','normalized',...
                                           'style','text',...
                                           'string','Warming Up',...
                                           'horizontalalignment','left',...
                                           'position',[0.282 0.489 0.264 0.362]);
                                       
        StagePosition_stext = uicontrol('parent',StageStatus_panel,...
                                         'units','normalized',...
                                         'style','text',...
                                         'string','Stage Position:',...
                                         'horizontalalignment','left',...
                                         'position',[0.025 0.085 0.264 0.362]);
                                 
        StagePosition_Disp_stext = uicontrol('parent',StageStatus_panel,...
                                           'units','normalized',...
                                           'style','text',...
                                           'string','0',...
                                           'horizontalalignment','left',...
                                           'position',[0.307 0.085 0.096 0.362]);
                                       
        JogIncrement_stext = uicontrol('parent',StageStatus_panel,...
                                       'units','normalized',...
                                       'style','text',...
                                       'string','Jog Increment:',...
                                       'horizontalalignment','left',...
                                       'position',[0.461 0.085 0.264 0.362]);
                                 
        JogIncrement_Disp_stext = uicontrol('parent',StageStatus_panel,...
                                            'units','normalized',...
                                            'style','text',...
                                            'string','0.01',...
                                            'horizontalalignment','left',...
                                            'position',[0.743 0.085 0.096 0.362]);

                                       
        %--- edit text
        Increment_etext = uicontrol('parent',Stage_panel,...
                                    'units','normalized',...
                                    'style','edit',...
                                    'string',num2str(data.Parameters.Increment),...
                                    'backgroundcolor','w',...
                                    'position',[0.369 0.72 0.318 0.22],...
                                    'callback',@EditCallback);
                             
        FullRange_etext = uicontrol('parent',Stage_panel,...
                                    'units','normalized',...
                                    'style','edit',...
                                    'string',num2str(data.Parameters.FullRange),...
                                    'backgroundcolor','w',...
                                    'position',[0.369 0.409 0.318 0.22],...
                                    'callback',@EditCallback);
                                
        %------------------- Plotting & Binning Panel --------------------%
        strarr = {'Image','Line'};
        PlotWhat_popupmenu = uicontrol('parent',PlotBinning_panel,...
                                       'units','normalized',...
                                       'style','popupmenu',...
                                       'string',strarr,...
                                       'backgroundcolor','w',...
                                       'position',[0.033 0.63 0.249 0.2]);
                                   
        %--------------------------- Binning Panel -----------------------%
        xm = 0.055;
        ym = 0.025;
        %%% static text
        data.handles.Biny_stext = uicontrol('parent',Binning_panel,...
                               'units','normalized',...
                               'style','text',...
                               'string','Bin Y:',...
                               'position',[0.07 0.569 0.183 0.208]);
                                   
        data.handles.Binx_stext = uicontrol('parent',Binning_panel,...
                               'units','normalized',...
                               'style','text',...
                               'string','Bin X:',...
                               'position',[0.07 0.111 0.178 0.208]);
                                   
        data.handles.BinY1_stext = uicontrol('parent',Binning_panel,...
                                  'units','normalized',...
                                  'style','text',...
                                  'string','y1',...
                                  'position',[0.294-xm 0.569 0.183 0.208]);
                                   
        data.handles.BinY2_stext = uicontrol('parent',Binning_panel,...
                                  'units','normalized',...
                                  'style','text',...
                                  'string','y2',...
                                  'position',[0.65-0.03 0.569 0.122 0.208]);
        
        data.handles.BinX1_stext = uicontrol('parent',Binning_panel,...
                                  'units','normalized',...
                                  'style','text',...
                                  'string','x1',...
                                  'position',[0.294-xm 0.111 0.178 0.208]);
                                   
        data.handles.BinX2_stext = uicontrol('parent',Binning_panel,...
                                  'units','normalized',...
                                  'style','text',...
                                  'string','x2',...
                                  'position',[0.65-0.01 0.111 0.089 0.208]);
        %%% edit text
        data.handles.BinY1_etext = uicontrol('parent',Binning_panel,...
                                  'units','normalized',...
                                  'style','edit',...
                                  'string',num2str(data.Parameters.BinY1),...
                                  'backgroundcolor','w',...
                                  'position',[0.378 0.625-ym 0.211 0.292],...
                                  'callback',@EditCallback);
                                   
        data.handles.BinY2_etext = uicontrol('parent',Binning_panel,...
                                  'units','normalized',...
                                  'style','edit',...
                                  'string',num2str(data.Parameters.BinY2),...
                                  'backgroundcolor','w',...
                                  'position',[0.739 0.625-ym 0.211 0.292],...
                                  'callback',@EditCallback);
        
        data.handles.BinX1_etext = uicontrol('parent',Binning_panel,...
                                  'units','normalized',...
                                  'style','edit',...
                                  'string',num2str(data.Parameters.BinX1),...
                                  'backgroundcolor','w',...
                                  'position',[0.378 0.153-ym 0.211 0.292],...
                                  'callback',@EditCallback);
                                   
        data.handles.BinX2_etext = uicontrol('parent',Binning_panel,...
                                  'units','normalized',...
                                  'style','edit',...
                                  'string',num2str(data.Parameters.BinX2),...
                                  'backgroundcolor','w',...
                                  'position',[0.739 0.153-ym 0.211 0.292],...
                                  'callback',@EditCallback);
        %-----------------------------------------------------------------%
        %%%                         Menu Bar                            %%%
        %-----------------------------------------------------------------%
            File_menu    = uimenu(Main_Figure,'label','File');
            
                SaveFrogData = uimenu(File_menu,...
                                       'label','Save Frogscan Data',...
                                       'enable','off',...
                                       'callback',@MenuCallback);
                                   
                SaveAutoData = uimenu(File_menu,...
                                       'label','Save Auto Data',...
                                       'enable','off',...
                                       'callback',@MenuCallback);
                                   
                SaveCurrData = uimenu(File_menu,...
                                       'label','Save Displayed Data',...
                                       'enable','off',...
                                       'callback',@MenuCallback);
                                   
                LoadData = uimenu(File_menu,...
                                       'label','Load Data',...
                                       'callback',@MenuCallback);
                                   
                LoadCalData = uimenu(File_menu,...
                                       'label','Load Calibration Data',...
                                       'callback',@MenuCallback);
                                   
                SaveParameters = uimenu(File_menu,...
                                       'label','Save Parameters',...
                                       'callback',@MenuCallback);
                                   
                LoadParameters = uimenu(File_menu,...
                                       'label','Load Parameters',...
                                       'callback',@MenuCallback);
                                   
                ExitProgram = uimenu(File_menu,...
                                       'label','Exit',...
                                       'separator','on',...
                                       'callback',@MenuCallback);
                                   

            Devices_menu = uimenu(Main_Figure,'label','Devices');
            
                ActivateDevices = uimenu(Devices_menu,...
                                       'label','Activate Devices',...
                                       'callback',@MenuCallback);
                                   
                DeactivateDevices = uimenu(Devices_menu,...
                                       'label','Deactivate Devices',...
                                       'callback',@MenuCallback,...
                                       'enable','off');
                                   
                Properties = uimenu(Devices_menu,...
                                       'label','Properties',...
                                       'separator','on',...
                                       'callback',@MenuCallback);
                                   
                    StageProperties = uimenu(Properties,...
                                           'label','Stage Properties',...
                                           'callback',@MenuCallback);
                                       
                        GoToZero   = uimenu(StageProperties,...
                                               'label','Go to Zero',...
                                               'callback',@MenuCallback);
                                       
                        SetAsZero   = uimenu(StageProperties,...
                                               'label','Set Current Position as Zero',...
                                               'callback',@MenuCallback);
                                           
                    CameraProperties = uimenu(Properties,...
                                           'label','Camera Properties',...
                                           'callback',@MenuCallback);
                                       
                        OpenShutter = uimenu(CameraProperties,...
                                               'label','Open\Close Shutter',...
                                               'checked','off',...
                                               'callback',@MenuCallback);
                                           
            PCGP_menu = uimenu(Main_Figure,'label','SHG-PCGP');
            
                    launchPcgp = uimenu(PCGP_menu,...
                                           'label','Launch Pcgp',...
                                           'callback',@MenuCallback);
                                       
                    saveFundamental = uimenu(PCGP_menu,...
                                               'label','Save Fundamental',...
                                               'callback',@MenuCallback);
        %-----------------------------------------------------------------%
        %%%                       Timer Objects                         %%%
        %-----------------------------------------------------------------%                                   
                   % Create timer object for Camera update
                   CameraTimer = timer('Period', 1,...
                                       'executionmode', 'fixeddelay',...
                                       'timerfcn',@UpdateDisplay,...
                                       'busymode', 'drop');
                                   
        %-----------------------------------------------------------------%
        %%%                       Data Array                            %%%
        %-----------------------------------------------------------------%
        %--- Most of the things in the data array do not have to be there
        %--- for completeness I have included all objects in the GUI.
                          %%% axes handles
                          data.handles.Axes1 = Axes1;
                          data.handles.Axes2 = Axes2;
                          data.handles.PlotWhat_popupmenu = PlotWhat_popupmenu;
                          
                          %%% panel handles
                          data.handles.Focus_panel  = Focus_panel;
                          data.handles.Camera_panel = Camera_panel;
                          data.handles.Stage_panel  = Stage_panel;
                          data.handles.Start_panel  = Start_panel;
                          data.handles.Auto_panel   = Auto_panel;
                          data.handles.Auto_panel   = Auto_panel;
                          data.handles.Temp_panel   = Temp_panel;
                          data.handles.SetTemperature_panel = SetTemperature_panel;
                          data.handles.StageStatus_panel = StageStatus_panel;
                          
                          %%% button handles
                          data.handles.Focus_button = Focus_button;
                          data.handles.Find0_button = Find0_button;
                          data.handles.Start_button = Start_button;
                          data.handles.Stop_button  = Stop_button;
                          data.handles.Auto_button  = Auto_button;
                          data.handles.Full_button  = Full_button;
                          data.handles.TUP_button   = TUP_button;
                          data.handles.TDN_button   = TDN_button;
                          data.handles.TakeExposure_button = TakeExposure_button;
                          data.handles.SetTemperature_button = SetTemperature_button;
                          data.handles.MUP_button = MUP_button;
                          data.handles.MDN_button = MDN_button;                          
                          
                          %%% text handles
                            %%% static text
                          data.handles.SetTemp_stext = SetTemp_stext;
                          data.handles.Temp_stext = Temp_stext;
                          data.handles.Increment_stext = Increment_stext;
                          data.handles.FullRange_stext = FullRange_stext;
                          data.handles.CameraStatus_stext = CameraStatus_stext;
                          data.handles.CoolerMode_stext = CoolerMode_stext;
                          data.handles.CameraStatus_Disp_stext = CameraStatus_Disp_stext;
                          data.handles.CoolerMode_Disp_stext = CoolerMode_Disp_stext;
                          data.handles.StageStatus_stext = StageStatus_stext;
                          data.handles.StageStatus_Disp_stext = StageStatus_Disp_stext;
                          data.handles.StagePosition_stext = StagePosition_stext;
                          data.handles.StagePosition_Disp_stext = StagePosition_Disp_stext;
                          data.handles.JogIncrement_stext = JogIncrement_stext;
                          data.handles.JogIncrement_Disp_stext = JogIncrement_Disp_stext;
                          data.handles.Intensity_Disp_stext = Intensity_Disp_stext;
                          data.handles.Intensity_stext = Intensity_stext;
                          
                            %%% edit text
                          data.handles.SetTemp_etext = SetTemp_etext;
                          data.handles.Temp_etext = Temp_etext;
                          data.handles.Increment_etext = Increment_etext;
                          data.handles.FullRange_etext = FullRange_etext;

                          %%% Menu handles
                          data.handles.SaveParameters = SaveParameters;
                          data.handles.LoadParameters = LoadParameters;
                          data.handles.ActivateDevices = ActivateDevices;
                          data.handles.DeactivateDevices = DeactivateDevices;
                          data.handles.ExitProgram = ExitProgram;
                          data.handles.StageProperties = StageProperties;
                          data.handles.CameraProperties = CameraProperties;
                          data.handles.SaveFrogData = SaveFrogData;
                          data.handles.SaveAutoData = SaveAutoData;
                          data.handles.SaveCurrData = SaveCurrData;
                          data.handles.LoadData = LoadData;
                          data.handles.LoadCalData = LoadCalData;
                          data.handles.GoToZero = GoToZero;
                          data.handles.SetAsZero = SetAsZero;
                          data.handles.OpenShutter = OpenShutter;
                          data.handles.launchPcgp = launchPcgp;
                          data.handles.saveFundamental = saveFundamental;
                          
                          %%% Timer Objects
                          data.Timers.CameraTimer = CameraTimer;
                          
                          %--- update data as guidata for Main_Figure
                          guidata(Main_Figure,data);
    end

%---------------------------- Callbacks --------------------------%
    % All callback functions for menu items
    function MenuCallback(srv,evnt)
        handles = data.handles;
        
        % switch on object whos callback is being executed (gcbo)
        switch gcbo
            case handles.SaveParameters
                disp('Saving Parameters');
                SaveParameters;
            case handles.LoadParameters
                disp('Loading Parameters');
                LoadParameters;
            case handles.SaveFrogData
                SaveFrogData;
            case handles.SaveAutoData
                SaveAutoData;
            case handles.SaveCurrData
                SaveCurrData;
            case handles.LoadData
                LoadCurrData;
            case handles.LoadCalData
                LoadCalData;
            case handles.ActivateDevices
                ActivateDevices;
            case handles.DeactivateDevices
                DeactivateDevices;
            case handles.ExitProgram
                MF_DeleteFcn;
                delete(Main_Figure);
                
            % Moves motor to zero position
            case handles.GoToZero
                if isfield(data,'Devices'),
                    Motor = data.Devices.Motor;
                    
                    % get current stage position
                    Stage_Position = Motor.GetPosition_Position(0);
                    zero_pos = -Stage_Position - data.Parameters.Offset;
                    
                    % Move Motor to zero position
                    MoveStage({1,-Stage_Position});
                end
                
            % Set current motor position as 0.
            case handles.SetAsZero
                if isfield(data,'Devices'),
                    Motor = data.Devices.Motor;
                    
                    % get current stage position
                    Stage_Position = Motor.GetPosition_Position(0);
                    data.Parameters.Offset = data.Parameters.Offset-Stage_Position;
                    Motor.invoke('SetPositionOffset',0,data.Parameters.Offset);
                end
                
            % Forces shutter open    
            case handles.OpenShutter
%                 opn_cls = get(handles.OpenShutter,'checked');
%                 if strcmp(opn_cls,'off'), 
%                     set(handles.OpenShutter,'checked','on');
%                     if isfield(data,'Devices'),
%                         set(data.Devices.Camera,'ForceShutterOpen',1);
%                     end
%                 elseif strcmp(opn_cls,'on'), 
%                     set(handles.OpenShutter,'checked','off');
%                     if isfield(data,'Devices'),
%                         set(data.Devices.Camera,'ForceShutterOpen',0);
%                     end                    
%                 end
                
            case handles.saveFundamental
                
            case handles.launchPcgp

                if isfield(data,'FrogData'),
                    
                        % get header information
                        headerTmp = data.FrogData(1,:);
                        header = headerTmp(headerTmp>0);                    % remove zeros
                        
                        frogData = {header,data.FrogData};
                        
                        frog.header = header;
                        frog.frogData = frogData;
                        
                        frogFilter(frog);
                        
                        set(Main_Figure,'visible','off','hittest','off');
                end
                
        end
        % end switch
    end
    
    % All callback functions Edit text boxes
    function EditCallback(srv,event)
        % Updates variables controlled by editable text boxes.
        handles = data.handles;
        
        if isfield(data,'Devices'),
            Motor = data.Devices.Motor;
            
            switch gcbo
            
                case handles.Increment_etext
                
                    data.Parameters.Increment = str2double(get(data.handles.Increment_etext,'string'));                    
                        % Retrieve SSu then calculate SSp
                        SSu = data.Parameters.Increment; % [fs]
                        SSp = speed_of_light*SSu/2; % [mm]

                        % set the Jog_Step_Size parameter for the Motor
                        Motor.SetJogStepSize(0,SSp);
                    
                case handles.FullRange_etext
                
                    data.Parameters.FullRange = str2double(get(data.handles.FullRange_etext,'string'));
            
                case handles.SetTemp_etext
                
                    data.Parameters.SetTemp = str2double(get(data.handles.SetTemp_etext,'string'));
            
                case handles.BinX1_etext
                
                    data.Parameters.BinX1 = str2double(get(data.handles.BinX1_etext,'string'));
            
                case handles.BinX2_etext
                
                    data.Parameters.BinX2 = str2double(get(data.handles.BinX2_etext,'string'));
            
                case handles.BinY1_etext
                
                    data.Parameters.BinY1 = str2double(get(data.handles.BinY1_etext,'string'));
            
                case handles.BinY2_etext
                
                    data.Parameters.BinY2 = str2double(get(data.handles.BinY2_etext,'string'));
                    
            end
                
        % Display all new values.
        guidata(Main_Figure,data);
        UpdateDisplay;
        
        end
        
    end
    
    % All callback functions for buttons
    function ButtonCallback(srv,evnt)
        handles = data.handles;
        if isfield(data,'Devices') && isfield(data.Devices,'Motor'),
                % get devices
                Camera = data.Devices.Camera;
                Motor = data.Devices.Motor;
                
                % Retrieve FRu and SSu then calculate FRp and SSp
                SSu = data.Parameters.Increment; % [fs]
                SSp = speed_of_light*SSu/2;
                
                % set the Jog_Step_Size parameter for the Motor
                JogStep = SSp;
            
                % set the Jog_Step_Size parameter for the Motor
                Motor.SetJogStepSize(0,SSp);
            
            % switch on gcbo
            switch gcbo
                
                % Take an Exposure
                case handles.TakeExposure_button
                    
                    % plot line or image data from drop-down box
                    plotwhat = get(handles.PlotWhat_popupmenu,'value');
                    switch plotwhat
                        
                        % plot image
                        case 1
                            set(handles.TakeExposure_button,'enable','off');
%                             idat = SnapShot([0,122,0,1024],1);
%                             set(handles.TakeExposure_button,'enable','on');
%                             plotdata({data.lambda,1:122,idat'},1); % 1 is image data
                            

                            [idat,data.lambda]=SnapShot([0,122,0,1024],1);
                            
                            set(handles.TakeExposure_button,'enable','on');
%                             plotdata({data.lambda,ldat},2);
                            plotdata({data.lambda,idat},2);
                            
                        % plot line
                        case 2
                            
                            % Take a SnapShot
                            set(handles.TakeExposure_button,'enable','off');
%                             idat = SnapShot([51,71,0,1024],1);
%                             ldat = sum(idat,2)/(71-51);

                            [idat,data.lambda]=SnapShot([0,122,0,1024],1);
                            
                            set(handles.TakeExposure_button,'enable','on');
%                             plotdata({data.lambda,ldat},2);
                            plotdata({data.lambda,idat},2);
                    end

                case handles.SetTemperature_button
                    % get Cooler Set Point string and then set it in Camera
%                     settemp = data.Parameters.SetTemp;
%                     set(Camera,'CoolerSetPoint',settemp);

                case handles.TUP_button
                    % set Cooler Set Point 1 deg C up
                    data.Parameters.SetTemp = data.Parameters.SetTemp+1;
                    set(Camera,'CoolerSetPoint',data.Parameters.SetTemp);

                case handles.TDN_button
                    % set Cooler Set Point 1 deg C down
                    data.Parameters.SetTemp = data.Parameters.SetTemp-1;
                    set(Camera,'CoolerSetPoint',data.Parameters.SetTemp);
                    
                case handles.MUP_button
                    MoveStage({2,1});
                case handles.MDN_button
                    MoveStage({2,2});                     
                case handles.Focus_button
                    set(handles.Start_button,'enable','off');
%                     set(handles.Find0_button,'enable','off');
                    set(handles.TakeExposure_button,'enable','off');
                    set(handles.DeactivateDevices,'enable','off');
                    
                     focus_value = get(handles.Focus_button,'value');
                     plotwhat = get(handles.PlotWhat_popupmenu,'value');
                     
                     % Focus toggle_button was depressed
                     if focus_value == 1,

                         switch plotwhat
                             % plot image
                             case 1
                                 while get(handles.Focus_button,'value') == 1
%                                          idat = SnapShot([0,122,0,1024],1);
%                                          plotdata({data.lambda,1:122,idat'},1);
                                         
                                    % Take a SnapShot
                                     set(handles.TakeExposure_button,'enable','off');
                                     [idat,data.lambda]=SnapShot([0,122,0,1024],1);                            
                                     set(handles.TakeExposure_button,'enable','on');
                                     plotdata({data.lambda,idat},2);
                                     pause(0.2);
                                 end
                             % plot line
                             case 2
                                 while get(handles.Focus_button,'value') == 1
                                     % take a SnapShot
%                                      idat = SnapShot([51,71,0,1024],1);
%                                      Camera.Reset; Camera.Flush;
%                                      ldat = sum(idat,2)/(71-51);
%                                      plotdata({data.lambda,ldat},2);

                                    % Take a SnapShot
                                     set(handles.TakeExposure_button,'enable','off');
                                     [idat,data.lambda]=SnapShot([0,122,0,1024],1);                            
                                     set(handles.TakeExposure_button,'enable','on');
                                     plotdata({data.lambda,idat},2);
                                     pause(0.2);
                                 end
                                 
                         end

                     elseif focus_value == 0,
                         % enable Expose Button
                         set(handles.TakeExposure_button,'enable','on');
                         % set the camera for regular readout
%                          set(Camera,'FastReadout',0);
                     end
                     
                    set(handles.TakeExposure_button,'enable','on');
                    set(handles.Start_button,'enable','on');
                    set(handles.DeactivateDevices,'enable','on');
%                     set(handles.Find0_button,'enable','on');
                    
                case handles.Find0_button
                    if isfield(data,'FrogData');
                        FindZero;
                    end
                        
                % Start a Frog Scan
                case handles.Start_button
                    FrogScan;
                % Abort a running Frog Scan
                case handles.Stop_button
                    set(handles.Start_button,'userdata',0);
                % Plot at a collected auto-correlation
                case handles.Auto_button
                    if isfield(data,'AutoData');
                        Nmax = data.numsteps;
                        dt = data.dt;
                        
                        tmax = Nmax*dt;
                        t = -tmax/2:dt:tmax/2-dt;
                        
                        ind = ~isnan(data.AutoData);
                        ldat = data.AutoData(ind);
                        pdat = {t(ind),ldat};
                        
                        plotdata(pdat,2);
                    end
                % Plot a collected Frog Scan
                case handles.Full_button
                    if isfield(data,'FrogData');
                        Nmax = data.numsteps;
                        dt = data.dt;
                        
                        tmax = Nmax*dt;
                        t = -tmax/2:dt:tmax/2-dt;
                        
                        frogData = data.FrogData;
                        frogData = frogData(2:end,:);                       % remove header
                        
                        pdat = {t,data.lambda,sqrt(frogData)};
                        
                        plotdata(pdat,1);
                    end            
            end
        % Display correct values.
        UpdateDisplay;
        end
    end
%---------------------------- Callbacks --------------------------%


    % Initialize all devices
    function ActivateDevices
                %--- Activate Stage
                Stage_Figure = Stageini;
                
                    % get Stage Control Commands Stored in Stage_Figure
                    % user data
                    SF_userdata = get(Stage_Figure,'userdata');
                    Motor = SF_userdata.Motor;
                    
                    % Identify Motor
                    Motor.Identify;
                    set(data.handles.StageStatus_Disp_stext,'string','Ready');
                    Motor.invoke('SetPositionOffset',0,data.Parameters.Offset);
                    
%                 %--- Activate Camera
%                 % if camera has already been initialized once, don't do it
%                 % agian, just turn the cooler back on
%                 if ~isfield(data,'Devices'),
%                     [Cam_Server, Camera] = Cameraini('C:\Program Files\Common Files\System\sph5p.ini');
%                 else
%                     Cam_Server = data.Devices.Cam_Server;
%                     Camera = data.Devices.Camera;
%                     % Reset the camera to an idle state then flush the ccd
%                     % before shutting down the Cooler and then restarting
%                     Camera.Reset; Camera.Flush;
%                     set(Camera,'CoolerMode',0); pause(2); % give the camera time to turn off
%                                                           % then turn it back on
%                     set(Camera,'CoolerMode',1);
%                 end
%                    
%                    % Set initial cooler set point
%                    data.Parameters.SetTemp = Camera.CoolerSetPoint;
%                    
%                 %--- add devices to data structure
                    %%% stage
                    data.Devices.StageFigure = Stage_Figure;
                    data.Devices.Motor = Motor;
%                     %%% Camera
%                     data.Devices.Cam_Server = Cam_Server;
%                     data.Devices.Camera = Camera;

                [libr,h] = avsInit;
                data.Devices.Camera.Library=libr;
                data.Devices.Camera.Handle=h;
                
                %--- update guidata
                set(data.handles.ActivateDevices,'enable','off');
                set(data.handles.DeactivateDevices,'enable','on');
                set(data.handles.Focus_button,'enable','on');
                guidata(Main_Figure,data);
                UpdateDisplay;

                   % Retrieve CameraTimer and start updating Camera
                   % parameters. Must do this after updating guidata so 
                   % that the timerfcn can access data.Timers.CameraTimer
                   CameraTimer = data.Timers.CameraTimer;
                   if strcmp(get(CameraTimer,'Running'),'off'),
                       % issue start command to start timer
                       start(CameraTimer);
                   end
                
    end

    % Turn off all devices
    function DeactivateDevices
            % To Deactivate Stages Simply Destroy ActiveX Containing
            % Figure Window
            if isfield(data,'Devices'),
                % deactivate stage
                disp('SHUTTING OFF MOTOR');
                % this step necessary to prevent segfault in UpdateDisplay.
                % by removing the "Motor" field in the Devices structure
                % the timer object no longer queries the motor position
                if isfield(data.Devices,'Motor')
                    data.Devices = rmfield(data.Devices,'Motor');
                end
                
                if ishandle(data.Devices.StageFigure),
                    delete(data.Devices.StageFigure);
                end
                

                % deactivate camera
                if isfield(data.Devices,'Camera'),
                    % To Deactivate Camera Set cooler mode = 2
                    % Ramp_To_Ambient.  The figure delete function
                    % "MF_DeleteFcn" releases the actxserver for the
                    % Camera, and does the final clean up.
%                     Camera = data.Devices.Camera;
%                     set(Camera,'CoolerMode',2);
                disp('SHUTTING OFF SPECTROMETER');
                    libr=data.Devices.Camera.Library;
                    avsClose(libr);
                end
                set(data.handles.ActivateDevices,'enable','on');
                set(data.handles.DeactivateDevices,'enable','off');
                set(data.handles.Focus_button,'enable','off');
                
                disp('FINISHED');
            end
    end

    % Save collected Frog Data
    function SaveFrogData
        if isfield(data,'FrogData'),
            [filename, pathname] = uiputfile('*.txt','Save Data');
                if ~isequal(filename,0) || ~isequal(pathname,0),
                    % get header information
%                     Increment = data.Parameters.Increment;
%                     FullRange = data.Parameters.FullRange;
                    
                    % header parameters for FemtoSoft frog phase extraction
                    % program
%                     npt = round(FullRange/Increment); % number temporal points
%                     lambda = data.lambda; % wavelength calibration
%                     npl = length(lambda); % number wavelength points
%                     dlam = (lambda(end) - lambda(1))/(npl-1); % lambda increment
%                     cen_lam = lambda(round(npl/2)); % center wavelength value of lambda array
                    
%                     % write header
%                     dlmwrite([pathname,'\',filename], [npt, npl, Increment, dlam, cen_lam],'delimiter',' ','newline', 'pc');
                    % append data
%                     dlmwrite([pathname,'\',filename],data.FrogData,'delimiter',' ','-append');

                    dlmwrite([pathname,'\',filename],data.FrogData,' ');
                end
        else
            msgbox('No FrogScan data found!','Cannot Save Data');
        end

    end

    % Save collected autocorrelation data.
    function SaveAutoData
        if isfield(data,'AutoData'),
            [filename, pathname] = uiputfile('*.txt','Save Data');
                if ~isequal(filename,0) || ~isequal(pathname,0)
                    csvwrite([pathname,'\',filename],data.AutoData);
                end
        else
            msgbox('No Autocorrelation data found!','Cannot Save Data');
        end

    end

    % Save collected current plot's data.
    function SaveCurrData
        ax = data.handles.Axes1;
        axchild = get(ax,'child');
        if ~isscalar(axchild)
            msgbox('No plot data found!','Cannot Save Data');
        else
            switch get(axchild,'type')
                case 'line'
                    [filename, pathname] = uiputfile('*.txt','Save Data');
                    if ~isequal(filename,0) || ~isequal(pathname,0)
                        csvwrite([pathname,'\',filename],get(axchild,'YData'));
                    end
                case 'image'
                    [filename, pathname] = uiputfile('*.txt','Save Data');
                    if ~isequal(filename,0) || ~isequal(pathname,0)
                        csvwrite([pathname,'\',filename],get(axchild,'CData'));
                    end
                otherwise
                    msgbox('Plot data not recognized.','Cannot Save Data');
            end
        end

    end

    % Save current parameters to file.
    function SaveParameters

         [filename, pathname] = uiputfile('*.mat','Save Parameters');
             if ~isequal(filename,0) || ~isequal(pathname,0)
                 Parameters = data.Parameters;
                 save([pathname,'\',filename],'Parameters');
             end

    end

    % Load saved parameters from file.
    function LoadParameters

         [filename, pathname] = uigetfile('*.mat','Load Parameters');
             if ~isequal(filename,0) || ~isequal(pathname,0)
                 Parameters.SetTemp = -20;
                 load([pathname,'\',filename]);
                 data.Parameters = Parameters;
             end

    end

    % Load previously collected Frog Data
    function LoadCurrData
        [filename, pathname] = uigetfile('*.txt','Load Data');
        if ~isequal(filename,0) || ~isequal(pathname,0)
            CurrData = dlmread([pathname,'\',filename],' ');
            if isvector(CurrData)
                plotdata(CurrData,2);
            else
                [m,n] = size(CurrData);
                plotdata({1:m,data.lambda,CurrData(2:end,:)},1);  % <== Don't plot the header
                data.FrogData = CurrData;
            end
        end
    end

    % Load a calibration file
    function LoadCalData
        [filename, pathname] = uigetfile('*.txt','Load Calibration Data');
        if ~isequal(filename,0) || ~isequal(pathname,0)
            data.lambda = csvread([pathname,'\',filename]);
            guidata(Main_Figure,data);
        end
    end

    % This function takes a picture with the spectrometer camera with input
    % parameters bin and FRM.  bin is a 4-element vecotor composed of
    % starty, endy, startx, endx; these values specify the beginning and
    % end rows/columns for binning.  FRM is a scalar that defines the "Fast
    % Redout Mode" of the camera.
    function[idat,lambda] = SnapShot(bin, FRM)
        % form for bin is y1, y2, x1, x2
        starty = bin(1);
        endy   = bin(2);
        
        startx = bin(3);
        endx   = bin(4);
        
        nothing = FRM;
        
%         if isfield(data,'Devices'),
%             Camera = data.Devices.Camera;
%             
%             Camera.Reset; Camera.Flush;
%             % set binning parameters and fast readout mode
%             set(Camera,'starty',starty);
%             set(Camera,'numy', abs(endy - starty) );
%             
%             set(Camera,'startx',startx);
%             set(Camera,'numx', abs(endx - startx) );
%             
%             set(Camera,'FastReadout',FRM);
%             try
%                 % Call Expose with 0.01 (minimum) exposer time
%                 % logical 1 indicates shutter open mode
%                 % Example: Camera.Expose(exposureTime, shutterOpen)
%                 Camera.Expose(0.01,1);
%                 
%                 itr = 0;
%                 while ~strcmp(Camera.Status,'Camera_Status_ImageReady'),
%                     itr = itr+1;
%                     if itr > 100, break; end
%                 end
%                 % when the camera is ready, download data
%                 % and return it
%                 idat = Camera.Image;
%                 
%                 % update intensity static text
%                 max_val = max(idat(:));
%                 set(data.handles.Intensity_Disp_stext,'string',num2str(max_val));
%             catch
%                 % get last error
%                 err = lasterror;
%                 msg = err.message; % message field from error structure
%                 error('Error:SNAPSHOT', msg); % display error
%                 idat = NaN; % assign output for SnapShot
%                 
%             end % end try
%             
%             % Re-set binning parameters and fast readout mode
%             set(Camera,'starty',0);
%             set(Camera,'numy', 122 );
%             
%             set(Camera,'startx',0);
%             set(Camera,'numx', 1024 );
%             
%             set(Camera,'FastReadout',0);
%             
%         end % end if
        
        if isfield(data,'Devices'),
            libr=data.Devices.Camera.Library;
            h=data.Devices.Camera.Handle;
            [idat,lambda]=avsGetData(libr,h);
            
            
                % update intensity static text
                max_val = max(idat(:));
                set(data.handles.Intensity_Disp_stext,'string',num2str(max_val));
            
        end

    end

    % This function moves the stage with input paramters that depend on the
    % type of move "move_type."  "move_type" is a 2-element cell:
    % with the first element an integer, 1 or 2, indicating a relative or 
    % jogstep type move, respectively.  The second element in "move_type" 
    % is either the distance to move, for a relative move, or the direction
    % to move, for a jogstep type move.  The jogstep increment is set by
    % the edit text box callback and does not need to be set anywhere else
    function MoveStage(move_type)
        
        if isfield(data,'Devices'),
            Motor = data.Devices.Motor;
            
                % Retrieve SSu then calculate SSp
                SSu = data.Parameters.Increment; % [fs]
                SSp = speed_of_light*SSu/2; % [mm]

            type = move_type{1};
            opt = move_type{2};
            switch type
                case 1 % relative
                    prevpos = Motor.GetPosition_Position(0);
                    prevjog = Motor.GetJogStepSize_StepSize(0);
                    % set the Jog_Step_Size parameter for the Motor
                    Motor.SetJogStepSize(0,abs(opt));
                    if opt > 0
                        direction = 1;
                    else
                        direction = 2;
                    end
                    Motor.MoveJog(0, direction);
                    while Motor.GetPosition_Position(0) ~= prevpos
                        prevpos = Motor.GetPosition_Position(0);
                    end
                    Motor.SetJogStepSize(0,prevjog);
                    
                case 2 % jogstep
                    
                    prevpos = Motor.GetPosition_Position(0);
                    direction = opt;
                    Motor.MoveJog(0, direction);
                    while Motor.GetPosition_Position(0) ~= prevpos
                        prevpos = Motor.GetPosition_Position(0);
                    end
                    
                otherwise
            end
        end
        
    end

    % This is the Main FrogScanning function.  It uses SnapShot to take
    % pictures and Motor commands to move the stage.
    function FrogScan
                % finds the exponent and mantissa of SSp
                %     sgn = sign(SSp);
                %     expnt = fix(log10(abs(SSp)));
                %     mant = sgn * 10^(log10(abs(SSp))-expnt);
        
        % get handles
        handles = data.handles;
        Parameters = data.Parameters;
        
        set(handles.Start_button,'userdata',1);
        set(handles.DeactivateDevices,'enable','off');
        set(handles.ActivateDevices,'enable','off');
        set(data.handles.Find0_button,'enable','off');
        set(handles.MUP_button,'enable','off');
        set(handles.MDN_button,'enable','off');
        
        % get devices
        Motor = data.Devices.Motor;
        Camera = data.Devices.Camera;
        % initialize position of stage and Camera Settings
        % Variables: FRu = Full Range input by user
        %            FRp = Full Range calculated by program
        %            SSu = Step size input by user
        %            SSp = Step size calculated by program
        
        % Retrieve FRu and SSu then calculate FRp and SSp
        FRu = Parameters.FullRange; % [fs]
        SSu = Parameters.Increment; % [fs]
        
        FRp = speed_of_light*FRu/2; % [mm]
        SSp = speed_of_light*SSu/2; % [mm]
            % calculate number of steps
            numsteps = round(FRp/SSp); 
        
        Stage_Position = Motor.GetPosition_Position(0);
        MoveStage({1,-Stage_Position});

        % Move stage to FRp/2
        MoveStage({1,FRp/2}); pause(0.5);
        
        % Initialize FrogData
        bins = [Parameters.BinY1,Parameters.BinY2,Parameters.BinX1,Parameters.BinX2];
        [idat,data.lambda] = SnapShot(bins,0); ldat = idat; % ldat = sum(idat,2);

        len = length(ldat);
        FrogData = zeros(len,numsteps);
        trap_int = nan(1,numsteps);
        
        set(handles.TakeExposure_button,'enable','off');
        set(handles.Focus_button,'enable','off');
        
%         cam_stat = Camera.Status;
        
        % Initialization finished, start scanning
            for ii=1:numsteps                
                % Take a snapshot
                idat = SnapShot(bins,0);
%                 ldat = sum(idat,2); % binning manually
                ldat=idat;
%                 Camera.Reset; Camera.Flush;
                
                % Integrate using trapezoid rule
                trap_int(ii) = trapz(ldat);
                trap_tmp = (trap_int/max(trap_int(isfinite(trap_int))));
                Frog_tmp = ldat - min(ldat);
%                 Frog_tmp = Frog_tmp/max(Frog_tmp);
                
                % Plot data
                plotdata({Frog_tmp,trap_tmp},3);
                % Store the data
                FrogData(:,ii) = ldat;

                % move the stage
                MoveStage({2,2});
                
                % get the position and update the text field
                UpdateDisplay;
                
                % User can terminate FrogScan by pressing Stop Scan
                if get(handles.Start_button,'userdata') == 0, break; end
            end

        % Move Motor to zero position        
        Stage_Position = Motor.GetPosition_Position(0);
        MoveStage({1,-Stage_Position});
        Stage_Position = Motor.GetPosition_Position(0);
        MoveStage({1,-Stage_Position});
        
        
                    lambda = data.lambda; % wavelength calibration
                    % chop frog trace around 400nm
                    dlambda = sum(diff(lambda))/(length(lambda)-1);
                    ds = round( (400-lambda(1))/dlambda );
                    lambda = lambda(1:2*ds);
                    data.lambda=lambda;
                    FrogData = FrogData(1:2*ds,:);
                    
                    npt = numsteps; % number temporal points
                    npl = length(lambda); % number wavelength points
                    dlam = (lambda(end) - lambda(1))/(npl-1); % lambda increment
                    cen_lam = lambda(round(npl/2)); % center wavelength value of lambda array

                    
                    
        header = [npt, npl, Parameters.Increment, dlam, cen_lam, zeros(1, length(FrogData(1,:))-5 ) ]';
        frogDataTmp = zeros( 1+size(FrogData,1), size(FrogData,2) );
        
        frogDataTmp(1,:) = header;
        frogDataTmp(2:end,:) = FrogData;
        
        data.FrogData = frogDataTmp;
        data.AutoData = trap_int;
        data.numsteps = numsteps;
        data.firstlim = FRp/2;
        data.dt = SSu;
        
        % Update gui + display
%         if get(handles.Start_button,'userdata') == 0
            set(data.handles.Find0_button,'enable','on');
%         end
        set(handles.DeactivateDevices,'enable','on');
        set(handles.TakeExposure_button,'enable','on');
        set(handles.Focus_button,'enable','on');
        set(handles.MUP_button,'enable','on');
        set(handles.MDN_button,'enable','on');
        
        guidata(Main_Figure,data);
        UpdateDisplay;
        
        % Allow saving of data.
        set(data.handles.SaveFrogData,'enable','on');
        set(data.handles.SaveAutoData,'enable','on');
        
    end

    % Finds temporal overlap of pulses
    function FindZero
        Motor = data.Devices.Motor;

        SSp = speed_of_light*data.dt/2; % [mm]        
        column = find( max(data.FrogData) == max(data.FrogData(:))  );
        zeropos = round(data.numsteps/2);
        
        Offset = (column(1)-zeropos)*SSp;
        data.Parameters.Offset = data.Parameters.Offset + Offset;
        Motor.invoke('SetPositionOffset',0,data.Parameters.Offset);
        
        % update data structure
        guidata(Main_Figure,data);

        % get current stage position
        Stage_Position = Motor.GetPosition_Position(0);
        % Move Motor to new zero position
        MoveStage({1, -Stage_Position});
        set(data.handles.Find0_button,'enable','off');
    end

    % Plots Camera data in Axes1
    function plotdata(dat, type_of_data)
        
        % switch on line or image data
        switch type_of_data
            case 1 % image data
                if ~iscell(dat),
                    ax = data.handles.Axes1;
                    axes(ax);
                    ax_pos = get(ax,'position');
%                     imagesc(dat); axis xy; colormap(usercolormap([1 1 1],jet));
                    imagesc(dat); axis xy; colormap jet;
                    set(gca,'position',ax_pos);
                else
                    xdat = dat{1};
                    ydat = dat{2};
                    mdat = dat{3};
                    pix = 1:122;
                    
                        ax = data.handles.Axes1;
                        axes(ax);
                        ax_pos = get(ax,'position');
%                         imagesc(xdat,ydat,mdat); axis xy; colormap(usercolormap([1 1 1],jet));
                        imagesc(xdat,ydat,mdat); axis xy; colormap jet;

                        set(gca,'position',ax_pos);
                end

            case 2 % line data
                
                if ~iscell(dat),
                    ax = data.handles.Axes1;
                    axes(ax);
                    ax_pos = get(ax,'position');
                    plot(dat); axis tight;
                    set(gca,'position',ax_pos);
                else
                    xdat = dat{1};
                    ydat = dat{2}; ydat = ydat - min(ydat);
                    ydat = ydat/max(ydat);
                    
                        ax = data.handles.Axes1;
                        axes(ax);
                        ax_pos = get(ax,'position');
                        plot(xdat,ydat); axis tight;
                        set(gca,'position',ax_pos);
                end
                
            case 3 % scan data
                
                ldat = dat{1};
                trap_int = dat{2};
                
                ax1 = data.handles.Axes1;
                axes(ax1);
                cla(ax1);
                hline1 = line(data.lambda,ldat,'parent',ax1,'color','r'); axis tight;
%                 plot( data.lambda, ldat,'parent',ax1,'color','r'); axis tight;
%                 set(data.handles.Axes1,'ytick',[],'color','none');
                
                ax2 = data.handles.Axes2;
                axes(ax2);
                cla(ax2);
                ax1_pos = get(ax1,'position');                       
                hline2 = line(1:length(trap_int),trap_int,'parent',ax2); axis tight;
%                 plot(1:length(trap_int),trap_int,'parent',ax2);
%                 set(ax2,'position',ax1_pos);
        end % end switch
        
        % Enable saving of current data.
        set(data.handles.SaveCurrData,'enable','on');
        
    end

    % Updates the display to conform with private parameter values.
    function UpdateDisplay(src,evnt)
        
        % Update edittable text fields.
        set(data.handles.Increment_etext,'string',num2str(data.Parameters.Increment));
        set(data.handles.FullRange_etext,'string',num2str(data.Parameters.FullRange));
        set(data.handles.SetTemp_etext,'string',num2str(data.Parameters.SetTemp));
        set(data.handles.BinX1_etext,'string',num2str(data.Parameters.BinX1));
        set(data.handles.BinX2_etext,'string',num2str(data.Parameters.BinX2));
        set(data.handles.BinY1_etext,'string',num2str(data.Parameters.BinY1));
        set(data.handles.BinY2_etext,'string',num2str(data.Parameters.BinY2));
        % Update Jog Increment
        set(data.handles.JogIncrement_Disp_stext,'string',...
            num2str(1000*speed_of_light*data.Parameters.Increment/2));
        % Update Stage Position
        if isfield(data.Devices,'Motor')
            set(data.handles.StagePosition_Disp_stext,'string',...
                num2str((data.Devices.Motor.GetPosition_Position(0))*1000));
        end
%         CameraUpdate;
    end

    % Updates Camera Parameters.  Uses a "timerfcn" from CameraTimer
    % defined in OpeningFcn
    function CameraUpdate(src, evnt)
%         try
%             if isfield(data,'Devices'),
%                     Camera = data.Devices.Camera;
%                     set(data.handles.Temp_etext,'string',num2str(Camera.Temperature));
%                     set(data.handles.CameraStatus_Disp_stext,'string',num2str(Camera.Status));
%                     set(data.handles.CoolerMode_Disp_stext,'string',num2str(Camera.CoolerMode));
%             end
%         catch
%                 error('ERROR:UPDATEcamera','Unspecified');
%         end
    end

    % Delete Main figure window, clean up all Devices, and release all
    % interfaces and system resources
    function MF_DeleteFcn(src,evnt)
                %--- Immediately Shut down Camera Cooler and release
                %--- interface
                if isfield(data,'Devices'),
%                     Cam_Server = data.Devices.Cam_Server;
%                     Camera = data.Devices.Camera;
                    
%                     opn_cls = get(Camera,'ForceShutterOpen');
%                     if opn_cls==1,
%                         set(Camera,'ForceShutterOpen',0);
%                     end
                    
%                     if iscom(Cam_Server),
%                         set(Camera,'CoolerMode',0);
%                         Camera.release;
%                         Cam_Server.release;
%                     end

                    % Turn off Timer
                    if isfield(data,'Timers'),
                        CameraTimer = data.Timers.CameraTimer;
                        stop(CameraTimer);
                    end
                    
                end
            %--- Delete Stage Figure Window, automatically shuts down
            %--- stages
            if isfield(data,'Devices'),
                if ishandle(data.Devices.StageFigure),
                    delete(data.Devices.StageFigure);
                end
                if isfield(data.Devices,'Motor')
                    data.Devices = rmfield(data.Devices,'Motor');
                end
            end
                
                Offset = data.Parameters.Offset;
                FullRange = data.Parameters.FullRange;
                Increment = data.Parameters.Increment;
                save('frogscan.mat','Offset','FullRange','Increment');
                clear all; % Just to be safe issue clear all command
    end



    function frogFilter(varargin)
%
%
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Main                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles = fFOpening;
guidata(handles.mfigure, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Functions                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % executes before frogFilter is made visible.
    % generates all components of frog filter
    function handles = fFOpening
        
        parameters = load('fFpsf.mat'); % psf - program startup file
        if ~isempty(parameters),

            handles.tmax = [];
            handles.lambda = parameters.lambda;
            handles.fFpath = parameters.fFpath;
            handles.fourierRadius = parameters.fourierRadius;
            handles.threshold = parameters.threshold;

        else % default values
            
            handles.tmax = [];
            handles.lambda = [];
            handles.fFpath = [];
            handles.fourierRadius = 5;
            handles.threshold = 1e-5;
            
        end
        
        scrnSiz = get(0,'screenSize');
        % figure and axes
        handles.mfigure = figure('resize','off',...
                                 'numbertitle','off',...
                                 'name','Frog Filter',...
                                 'toolbar','none',...
                                 'menubar','none',...
                                 'position',[scrnSiz(1)+scrnSiz(3)/10, scrnSiz(2)+scrnSiz(4)/3, 532, 320],...
                                 'Color',[0.702, 0.702, 0.702],...
                                 'deleteFcn',@fFfig_deletefcn);
                   
        handles.maxes = axes('parent',handles.mfigure,...
                             'units','normalized',...
                             'position',[0.04, 0.0826, 0.52, 0.8575]);

                         
            if isempty(varargin),
                [x,y]=meshgrid(-1:2/1023:1,-1:2/1023:1);
                arg = -x.^2-y.^2; f = exp(arg/0.125^2);

                handles.mimage = imagesc(f,'parent',handles.maxes);
                handles.frogData = f; % set handles.iData to image;

            else
                
                frog = varargin{1};
                if isstruct(varargin{1})
                    
                    header = frog.header;                    
                    npt = header(1);
                    npl = header(2);
                    dtau = header(3);
                    dLambda = header(4);
                    lambda0 = header(5);
                    
                    lMax = dLambda*(npl-1)/2;
                    lambda = lambda0 - lMax : dLambda : lambda0 + lMax;

                    handles.tmax = dtau*(npt-1);
                    handles.lambda = lambda;
                    handles.dtau = dtau;

                    frogData = frog.frogData;
                    if iscell(frogData)
                        frogData = frogData{2};
                        frogData = frogData(2:end,:);                     % <== remove header
                        
                        frogData = frogData-min(frogData(:));               % normalize
                        frogData = frogData/max(frogData(:));
                    end
                    
                end
                
                handles.mimage = imagesc( abs(sqrt(frogData)),'parent',handles.maxes);
                handles.frogData = frogData; % set handles.iData to image;
                
            end
            
        colormap hot;
        cm=colormap; cm(1,:)=[1,1,1]; colormap(cm);
        set(gca,'xtick',[],'ytick',[]); % turn off x&y ticks

        % Panels
        handles.filterPanel = uipanel(handles.mfigure,...
                                      'units','normalized',...
                                      'position',[0.5996, 0.5299, 0.359, 0.43],...
                                      'backgroundColor',[0.702, 0.702, 0.702],...
                                      'title','Filters');
        handles.okPanel = uipanel(handles.mfigure,...
                                      'units','normalized',...
                                      'backgroundColor',[0.702, 0.702, 0.702],...
                                      'position',[0.5996, 0.07977, 0.359, 0.43]);
        
        % filterPanel Buttons
        handles.fullSpecButton = uicontrol(handles.filterPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Full Spectrum',...
                                           'fontsize',8,...
                                           'position',[0.074866, 0.58088, 0.406417, 0.30147],...
                                           'callback',@buttonCallbacks);
                                       
        handles.lowestPixelButton = uicontrol(handles.filterPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Lowest Pixel',...
                                           'fontsize',8,...
                                           'position',[0.529, 0.58088, 0.406417, 0.30147],...
                                           'callback',@buttonCallbacks);
                                       
        handles.thresholdButton = uicontrol(handles.filterPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Threshold',...
                                           'fontsize',8,...
                                           'position',[0.074866, 0.1838, 0.406417, 0.30147],...
                                           'callback',@buttonCallbacks);
                                       
        handles.lpffButton = uicontrol(handles.filterPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Low Pass',...
                                           'fontsize',8,...
                                           'position',[0.5294, 0.1838, 0.406417, 0.30147],...
                                           'callback',@buttonCallbacks);

                                       
                                       
        % Ok panel buttons
        handles.gridSizeStext = uicontrol(handles.okPanel,...
                                           'style','text',...
                                           'units','normalized',...
                                           'string','Grid Size',...
                                           'fontsize',10,...
                                           'horizontalAlignment','center',...
                                           'backgroundColor',[0.702, 0.702, 0.702],...
                                           'position',[0.074866, 0.58088, 0.406417, 0.20147],...
                                           'callback',@buttonCallbacks);
        
        handles.gridSizeEtext = uicontrol(handles.okPanel,...
                                           'style','edit',...
                                           'units','normalized',...
                                           'string','128',...
                                           'fontsize',8,...
                                           'backgroundColor',[1,1,1],...
                                           'position',[0.5294, 0.68088, 0.406417, 0.20147],...
                                           'callback',@buttonCallbacks);
        
        handles.resetButton = uicontrol(handles.okPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Reset',...
                                           'fontsize',8,...
                                           'position',[0.074866, 0.3712, 0.406417, 0.25],...
                                           'callback',@buttonCallbacks);
                                       
        handles.okButton = uicontrol(handles.okPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','OK',...
                                           'fontsize',8,...
                                           'position',[0.5294, 0.3712, 0.406417, 0.25],...
                                           'callback',@buttonCallbacks);
                                       
        handles.goBackButton = uicontrol(handles.okPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Go Back',...
                                           'fontsize',8,...
                                           'position',[0.5294, 0.0838, 0.406417, 0.25],...
                                           'callback',@buttonCallbacks);
                                       
        handles.averageButton = uicontrol(handles.okPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Average',...
                                           'fontsize',8,...
                                           'position',[0.074866, 0.0838, 0.406417, 0.25],...
                                           'callback',@buttonCallbacks);
                                       
        % Menu Items
        handles.fileMenu = uimenu(handles.mfigure,...
                                    'label','File');
                                
                                handles.loadMenu = uimenu(handles.fileMenu,...
                                                            'label','Load Trace',...
                                                            'callback',@menuCallbacks);
                                                        
                                handles.loadCalMenu = uimenu(handles.fileMenu,...
                                                            'label','Load Wavelength Values',...
                                                            'callback',@menuCallbacks);
                                                        
                                handles.saveMenu = uimenu(handles.fileMenu,...
                                                            'label','Save Trace',...
                                                            'callback',@menuCallbacks);
                                                        
                                handles.exitMenu = uimenu(handles.fileMenu,...
                                                            'label','Exit',...
                                                            'callback',@menuCallbacks);
                                                        
        handles.optionsMenu = uimenu(handles.mfigure,...
                                        'label','Options');
                                 
                                handles.fourierRadiusMenu = uimenu(handles.optionsMenu,...
                                                                   'label','Set Fourier Radius',...
                                                                   'callback',@menuCallbacks);
                                                        
                                handles.thresholdMenu = uimenu(handles.optionsMenu,...
                                                              'label','Set Threshold',...
                                                              'callback',@menuCallbacks);
                                                        
                                handles.gridStyle = uimenu(handles.optionsMenu,...
                                                           'label','Grid Style');
                                                       
                                                       handles.keepTmax = uimenu(handles.gridStyle,...
                                                                                 'label','Keep T-MAX',...
                                                                                 'checked','on',...
                                                                                 'callback',@menuCallbacks);
                                                                             
                                                       handles.keepDt = uimenu(handles.gridStyle,...
                                                                               'label','Keep dt',...
                                                                               'callback',@menuCallbacks);
                                                           

    end

    function menuCallbacks(src,event)

        switch gcbo
            case handles.loadMenu
                
                if isempty(handles.fFpath),    
                    [filename, fullpath] = uigetfile('*.txt','Load Frog Trace');
                else
                    [filename, fullpath] = uigetfile('*.txt','Load Frog Trace', handles.fFpath);
                end
                if ~isequal(filename,0) || ~isequal(fullpath, 0),
                    frogDataTmp = importdata([fullpath,filename],' ',1); % import data and header
                    
                    if isstruct(frogDataTmp),

                        frogData = frogDataTmp.data;

                        header = str2num(frogDataTmp.textdata{1}); % str2num works str2double doesn't

                        tmax = header(3)*(header(1)-1);
                        
                        NLambda = header(2);
                        dLambda = header(4);
                        mxLambda = dLambda*(NLambda-1);
                        lambda0 = header(5);

                        frogData = frogData-min(frogData(:)); frogData = frogData/max(frogData(:));
                        
                        handles.tmax = tmax;
                        handles.dtau = header(3);
                        
                        handles.frogData = frogData;
                        handles.lambda = lambda0 - mxLambda/2 : dLambda : lambda0 + mxLambda/2;
                    else

                        frogData = load([fullpath,filename]);
                        
                        handles.Nt = size(frogData,2);
                        handles.tmax = size(frogData,2);
                        handles.frogData = frogData;
                        
                    end
                    
                    
                    handles.mimage = imagesc(sqrt(frogData),'parent',handles.maxes); axis xy;
                    
                    handles.fFpath = fullpath;
                    guidata(handles.mfigure,handles);
                    set(gca,'xtick',[],'ytick',[]);
                end
                
            case handles.loadCalMenu
                
                [filename, fullpath] = uigetfile('*.txt','Load Frog Trace',handles.fFpath);
                if ~isequal(filename,0) || ~isequal(fullpath, 0),
                    lambda = load([fullpath,filename]);
                    
                    handles.lambda = lambda;
                    guidata(handles.mfigure,handles);
                end
                
            case handles.saveMenu
                [filename, fullpath] = uiputfile('*.txt','Save Frog Trace');
                if ~isequal(filename,0) || ~isequal(fullpath, 0),
                    figure; imagesc(handles.frogData); colormap hot;
                    
                    csvwrite([fullpath,filename],handles.frogData);
                end
                
            case handles.exitMenu
                delete(handles.mfigure);
                
            case handles.fourierRadiusMenu
                setFourierRadius;
                
            case handles.thresholdMenu
                setThreshold;
                
            case handles.keepTmax
                
                chk = get(handles.keepTmax,'checked');
                if ~strcmp(chk,'on')
                    set(handles.keepTmax,'checked','on');
                    set(handles.keepDt,'checked','off');
                end
                
            case handles.keepDt
                
                chk = get(handles.keepDt,'checked');
                if ~strcmp(chk,'on')
                    set(handles.keepDt,'checked','on');
                    set(handles.keepTmax,'checked','off');
                end
        end

    end

    function buttonCallbacks(src, event)
        
        iData = get(handles.mimage,'cdata');        
        iData = iData.^2;
        [M,N]=size(iData); M2 = round(M/2);
                           N2 = round(N/2);
        
        switch gcbo
            case handles.fullSpecButton
                                
                fSpectrum = iData(:,1);
                for ii=1:N
                    iData(:,ii) = iData(:,ii) - fSpectrum;
                end
                    iData(iData<0)=0;
                    
                fSpectrum = iData(:,end);
                for ii=1:N
                    iData(:,end-ii+1) = iData(:,end-ii+1) - fSpectrum;
                end
                    iData(iData<0)=0;
                    
                fSpectrum = iData(1,:);
                for ii=1:M
                    iData(ii,:) = iData(ii,:) - fSpectrum;
                end
                    iData(iData<0)=0;

                fSpectrum = iData(end,:);
                for ii=1:M
                    iData(ii,:) = iData(ii,:) - fSpectrum;
                end
                    iData(iData<0)=0;
                    
            case handles.lowestPixelButton
                mn = min(min( iData(iData~=0) ));
                iData = iData - mn;
                iData(iData<handles.threshold)=0;
                
            case handles.thresholdButton

                iData(iData<handles.threshold)=0;

            case handles.lpffButton
                iData = lpff(iData,handles.fourierRadius);
                
            case handles.resetButton
                iData = handles.frogData;
                
            case handles.averageButton
                
                [xcAx,ycAx]=meshgrid(1:N,1:M);
                xCntr = sum(sum(iData.*xcAx))/sum(iData(:));
                yCntr = sum(sum(iData.*ycAx))/sum(iData(:));

                    % difference between xCnter/yCnter and n2/m2
                    xdif = round(N2-xCntr);
                    ydif = round(M2-yCntr);

                    iDataTmp = abs(circshift(iData,[ydif,xdif]));

                    iTmp = (iDataTmp(:,1:N2) + fliplr(iDataTmp(:,N2+1:end)))/2;
                    
                    % shift back after averaging
                    iData = circshift([iTmp,fliplr(iTmp)],[-ydif,-xdif]);
                
            case handles.okButton

                siz = str2double( get(handles.gridSizeEtext,'string') );
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  handles.lambda = []; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if isempty(handles.lambda)

                    lambda0 = 400;
                    Npt = 1024;
                    dLambda = 0.10293;
                    lMax = dLambda*(Npt-1)/2;
                    lambda = lambda0 - lMax : dLambda : lambda0 + lMax;
                    
                    handles.lambda = lambda;
                    
                else
                    
                    lambda = handles.lambda;

                end

                % interpolate to frequency and satisfy FFT uncertainty
                tmax = handles.tmax;
                dtau = handles.dtau;
                tau = -tmax/2:dtau:tmax/2;
                    
                if strcmp( get(handles.keepTmax,'checked'),'on'),

                    % option (1) keep tmax the same
                    % this one is good for long-chirped pulses
                    dt = tmax/(siz-1);
                    t = -tmax/2:dt:tmax/2;
                    
                else
                    
                    % option (2) keep dtau the same
                    tmax = dtau*(siz-1);
                    t = -tmax/2:dtau:tmax/2;

                    dt = dtau;
                end
                
                % create omega axis from user input wavelength values
                w  = fliplr( 2*pi*2.9972945*1e8./(lambda*1e-9) );
                lambda0 = lambda( round(numel(lambda)/2) )*1e-9;
                w0 = 2*pi*2.9972945*1e8/lambda0;
                
                % interpolate from lambda to frequency and satisfy 
                % uncertainty relation
                dw = 2*pi/((siz-1)*dt);
                wmax = 2*pi/dt;
                omega = (-wmax/2:dw:wmax/2)*1e15;
                omega = omega+w0;
                
                    % New, evenly spaced lambda axis from omega axis
                    LAMBDA = fliplr(2*pi*2.9972945*1e8./omega);

                    mnLam = min(LAMBDA);
                    mxLam = max(LAMBDA); mxLam = mxLam-mnLam;

                    dLam = sum(diff(LAMBDA))/(siz-1);

                    LAMBDA = -mxLam/2:dLam:mxLam/2;
                    LAMBDA = LAMBDA + lambda0;

                [x,y] = meshgrid(tau, w);
                [X,Y] = meshgrid(t, omega);
                
                
                pcgpData = interp2(x,y,iData,X,Y,'spline',0);               % specify that values outside the range of 
                                                                            % x & y are set to zero

                [M,N]=size(pcgpData); M2 = round(M/2);                      % new size of PCGP data
                                      N2 = round(N/2);
                                      
                % shift to w0 by centroid
                [xcAx,ycAx]=meshgrid(1:N,1:M);
                xCntr = sum(sum(pcgpData.*xcAx))/sum(pcgpData(:));
                yCntr = sum(sum(pcgpData.*ycAx))/sum(pcgpData(:));

                    % difference between xCnter/yCnter and n2/m2
                    xdif = round(N2-xCntr);
                    ydif = round(M2-yCntr);

                    % shift to t0
                    pcgpData = abs(circshift(pcgpData,[0,xdif]));
                
                % lambda0
                handles.lambda0 = lambda( round(numel(lambda)/2) );
                
                % new lambda axis
                handles.LAMBDA = LAMBDA;                
                
                % new omega axis
                handles.OMEGA = omega;
                
                % Number time points
                handles.NptsTime = N;
                
                % Max t-range
                handles.TMAX = tmax;
                
                % time axis increment
                handles.DTAU = dt;
                
                % frequency shift
                handles.YSHIFT = ydif;
                
                % update handles structure
                guidata(handles.mfigure,handles);
                
                % Open PCGP
                pcgpFrog(handles.mfigure, pcgpData);
                
                % hide FROGFILTER while PCGPFROG is active
                set(handles.mfigure,'visible','off');

            case handles.goBackButton
                set(Main_Figure,'visible','on','hittest','on');
                delete(handles.mfigure);
        end

                if ishandle(handles.mfigure),
                    set(handles.mimage,'cdata',abs(sqrt(iData)));
                    guidata(handles.mfigure,handles);
                end
    end

    % saves psf parameters
    function fFfig_deletefcn(src,event)
        
            lambda = handles.lambda;
            fFpath = handles.fFpath;
            fourierRadius = handles.fourierRadius;
            threshold = handles.threshold;
            
            save('fFpsf.mat','lambda','fFpath','fourierRadius','threshold'); % psf - program startup file
            
                set(Main_Figure,'visible','on','hittest','on');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Support Functions                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Low Pass Fourier Filter
    function B = lpff(b, cutoff)

        if nargin==1,cutoff=1; end

        [m,n] = size(b);
                m2 = round(m/2);
                n2 = round(n/2);


        if m==1||n==1

            if m>n
                x=-m2:m2-1;
                b=b.';
            else
                x=-n2:n2-1;
            end



            fb = 1/sqrt(max(size(b)))*fftshift(fft(b));

            %%--- abs and normalization
            afb = abs(fb).^2;
            afb = afb-min(afb);
            afb = afb/max(afb);

            %%--- statistics
            fwhm = numel(find(afb>0.5));
            sdv = std(afb);

            if 2*fwhm > 3*sdv,
                sig = 2*fwhm;
            else
                sig = 3*sdv;
            end

            %%--- create filter
            arg = -x.^2/2/(cutoff*sig)^2;
            h = exp(arg);
            fb = fb.*h;

            B=sqrt(max(size(b)))*ifft(fb);

        else
            fb = 1/sqrt(m*n)*fftshift(fft2(b));

            %%--- abs and normalization
            afb = abs(fb).^2;
            afb = afb-min(afb(:));
            afb = afb/max(afb(:));

            %%--- statistics
            fwhm = numel(find(afb>0.5));
            sdv = std(afb);

            if 2*fwhm > 3*sdv,
                sig = 2*fwhm;
            else
                sig = 3*sdv;
            end

            %%--- create filter
            [x,y]=meshgrid(-n2:n2-1,-m2:m2-1);

            arg = -(x.^2+y.^2)/2/(cutoff*sig)^2;
            h = exp(arg);
            fb = fb.*h;

            B=sqrt(m*n)*ifft2(fb);
        end

                if isreal(b), B = abs(B); end

    end

    % Interpolate from wavelength to frequency
    function [B,w] = intrpL2W(A, lambda)

        % Create the frequency axis with non-regular spacing from lambda
        omega = 2*pi*2.9972945*1e8./lambda;
        
        % Flip this axis to be minimum to maximum
        [m,n] = size(omega);
        if (m < n)  % the if statement allows omega to be a row or column vector
           omega = fliplr(omega);
        elseif (n < m)
           omega = flipud(omega);
        end
        
            % flip input to match omega
            A = flipud(A);
            
            % Create  regularly spaced frequency
            N = numel(omega);

            omn = min(omega);
            omx = max(omega);
            dw = abs( sum(diff(omega))/(N-1) );

            w = omn:dw:omx;
                      
            % interp1 (works on columns see 'spline')
            B = interp1(omega, A, w, 'spline');
  
    end

    % set radius for B = lpff(b, radius)
    function setFourierRadius
        mPos = get(handles.mfigure,'position');
        h = figure('color',[0.702,0.702,0.702],...
                   'numberTitle','off',...
                   'name','Fourier Radius',...
                   'windowStyle','modal',...
                   'menubar','none',...
                   'toolbar','none',...
                   'resize','off',...
                   'units','pixels',...
                   'position',[mPos(1)+ round(mPos(3)/2), mPos(2)+ round(mPos(4)/2), 210, 112],...
                   'deleteFcn',@h_deletefcn);
               
        okbutton = uicontrol(h,'style','pushbutton',...
                               'units','normalized',...
                               'string','OK',...
                               'position',[0.614, 0.0982, 0.2857, 0.267857],...
                               'callback',@h_okButton);
                           
        radiusStext = uicontrol(h,'style','text',...
                                  'units','normalized',...
                                  'string','Fourier Radius',...
                                  'position',[0.090476, 0.5089, 0.419, 0.125]);
                              
        radiusEtext = uicontrol(h,'style','edit',...
                                  'units','normalized',...
                                  'backGroundColor',[1,1,1],...
                                  'string',num2str(handles.fourierRadius),...
                                  'position',[0.6142857, 0.5446, 0.290, 0.3]);
                              
        function h_okButton(src,event)
            radius = str2double(get(radiusEtext,'string'));
            handles.fourierRadius=radius;
            
            guidata(handles.mfigure,handles);
            
            delete(h);
        end
        
        function h_deletefcn(src, event)
            radius = str2double(get(radiusEtext,'string'));
            
            handles.fourierRadius=radius;
            guidata(handles.mfigure,handles);
        end
        
    end

    % get radius for B = lpff(b, radius)
    function setThreshold
        mPos = get(handles.mfigure,'position');
        h = figure('color',[0.702,0.702,0.702],...
                   'numberTitle','off',...
                   'name','Threshold',...
                   'windowStyle','modal',...
                   'menubar','none',...
                   'toolbar','none',...
                   'resize','off',...
                   'units','pixels',...
                   'position',[mPos(1)+ round(mPos(3)/2), mPos(2)+ round(mPos(4)/2), 210, 112],...
                   'deleteFcn',@h_deletefcn);
               
        okbutton = uicontrol(h,'style','pushbutton',...
                               'units','normalized',...
                               'string','OK',...
                               'position',[0.614, 0.0982, 0.2857, 0.267857],...
                               'callback',@h_okButton);
                           
        threshStext = uicontrol(h,'style','text',...
                                  'units','normalized',...
                                  'string','Threshold',...
                                  'position',[0.090476, 0.5089, 0.419, 0.125]);
                              
        threshEtext = uicontrol(h,'style','edit',...
                                  'units','normalized',...
                                  'backGroundColor',[1,1,1],...
                                  'string',num2str(handles.threshold),...
                                  'position',[0.6142857, 0.5446, 0.290, 0.3]);
                              
        function h_okButton(src,event)
            
            thresh = str2double(get(threshEtext,'string'));
            
            handles.threshold=thresh;
            
            guidata(handles.mfigure,handles);
            
            delete(h);
        end
        
        function h_deletefcn(src, event)
            
            thresh = str2double(get(threshEtext,'string'));
            
            handles.threshold=thresh;
            guidata(handles.mfigure,handles);
        end
        
    end
    end

    function pcgpFrog(pfigure,frogTrace)
%
%
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Main                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
phandles = guidata(pfigure);
handles = pFOpening(frogTrace,phandles);



handles.pfigure = pfigure;
handles.phandles = phandles;
handles.fFpath = phandles.fFpath;

handles.NptsTime = phandles.NptsTime;

handles.lambda = phandles.LAMBDA;

handles.tmax = phandles.TMAX;
handles.omega = phandles.OMEGA;

guidata(handles.mfigure, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End Main %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             Functions                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % executes before pcgpFrog is made visible.
    % generates all components of pcgpFrog
    function handles = pFOpening(frogTrace,phandles)
        
        % figure and axes
        fFpos = get(phandles.mfigure,'position');
        handles.mfigure = figure('resize','off',...
                                 'numbertitle','off',...
                                 'name','SHG-FROG',...
                                 'toolbar','none',...
                                 'menubar','none',...
                                 'position',[fFpos(1), fFpos(2), 700, 350],...
                                 'Color',[0.702, 0.702, 0.702],...
                                 'deletefcn',@pcgpFigure_deleteFcn);
                             
                                                    
        handles.maxes1 = axes('parent',handles.mfigure,...
                              'units','normalized',...
                              'position',[0.035, 0.0875, 0.2786, 0.8156]);

                          handles.errStext = uicontrol(handles.mfigure,...
                                                        'backgroundColor',[1,1,1],...
                                                        'style','text',...
                                                        'FontName','FixedWidth',...
                                                        'string','error = 0',...
                                                        'fontsize',10,...
                                                        'horizontalAlignment','left',...
                                                        'units','normalized',...
                                                        'position',[0.68,0.84,0.2,0.05]);
                          
        handles.maxes12 = axes('parent',handles.mfigure,...
                               'color','none',...
                               'units','normalized',...
                               'position',[0.035, 0.0875, 0.2786, 0.8156]);
                           
        handles.maxes13 = axes('parent',handles.mfigure,...
                               'color','none',...
                               'units','normalized',...
                               'position',[0.035, 0.0875, 0.2786, 0.8156]);
                         
        handles.maxes2 = axes('parent',handles.mfigure,...
                             'units','normalized',...
                             'position',[0.3487, 0.0875, 0.2786, 0.8156]);
                         
        handles.maxes22 = axes('parent',handles.mfigure,...
                               'color','none',...
                               'units','normalized',...
                               'position',[0.3487, 0.0875, 0.2786, 0.8156]);
                           
        handles.maxes23 = axes('parent',handles.mfigure,...
                               'color','none',...
                               'units','normalized',...
                               'position',[0.3487, 0.0875, 0.2786, 0.8156]);
                         
        handles.maxes3 = axes('parent',handles.mfigure,...
                             'units','normalized',...
                             'position',[0.662, 0.4612, 0.2970, 0.44]);
        if isempty(frogTrace),
           
            [x,y]=meshgrid(-1:2/1023:1,-1:2/1023:1);
            arg = -x.^2-y.^2; f = exp(arg/0.125^2);

            handles.eImage = imagesc(f,'parent',handles.maxes1); axis(handles.maxes1, 'xy');
            handles.rImage = imagesc(f,'parent',handles.maxes2); axis(handles.maxes2, 'xy');
            handles.errPlot = plot(f(512,:),'parent',handles.maxes3); axis tight;
            
            handles.frogData = f; % set handles.frogData to image;
        else
           
            handles.eImage = imagesc(abs(sqrt(frogTrace)),'parent',handles.maxes1); axis(handles.maxes1, 'xy');
            handles.rImage = imagesc(rand(size(frogTrace)),'parent',handles.maxes2); axis(handles.maxes2, 'xy');
            handles.errPlot = plot(zeros(1,100),'parent',handles.maxes3); axis tight;
           
            
            handles.frogData = frogTrace; % set handles.frogData to image;
        end
        

        
        colormap hot;
        cm=colormap; cm(1,:)=[1,1,1]; colormap(cm);
                         
            set([handles.maxes1,handles.maxes2,handles.maxes3,...
                handles.maxes12,handles.maxes22,...
                handles.maxes13,handles.maxes23],'xtick',[],'ytick',[]);
        
        % Panel
        handles.controlsPanel = uipanel(handles.mfigure,...
                                        'units','normalized',...
                                        'position',[0.66236, 0.05625, 0.2970, 0.346875],...
                                        'backgroundColor',[0.702, 0.702, 0.702],...
                                        'title','Controls');
                          
        % Buttons
        handles.goBackButton = uicontrol(handles.controlsPanel,...
                                               'style','pushButton',...
                                               'units','normalized',...
                                               'string','Go Back',...
                                               'fontsize',8,...
                                               'position',[0.0573, 0.69, 0.3821656, 0.26],...
                                               'callback',@buttonCallbacks);

        handles.startButton = uicontrol(handles.controlsPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Start',...
                                           'fontsize',8,...
                                           'position',[0.0573, 0.39, 0.388535, 0.26],...
                                           'callback',@buttonCallbacks);
                                       
        handles.noiseButton = uicontrol(handles.controlsPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Noise',...
                                           'fontsize',8,...
                                           'position',[0.0573, 0.08, 0.388535, 0.26],...
                                           'callback',@buttonCallbacks);
                                       
        handles.stopButton = uicontrol(handles.controlsPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Stop',...
                                           'fontsize',8,...
                                           'position',[0.5605, 0.39, 0.388535, 0.26],...
                                           'callback',@buttonCallbacks);
                                       
        handles.restartButton = uicontrol(handles.controlsPanel,...
                                           'style','pushButton',...
                                           'units','normalized',...
                                           'string','Restart',...
                                           'fontsize',8,...
                                           'position',[0.5605, 0.08, 0.388535, 0.26],...
                                           'callback',@buttonCallbacks);
                                       
        % Text                
        handles.experimentalStext = uicontrol(handles.mfigure,'style','text',...
                                  'units','normalized',...
                                  'string','Experimental',...
                                  'fontsize',10,...
                                  'backgroundColor',[0.702, 0.702, 0.702],...
                                  'position',[0.101476, 0.90937, 0.145756, 0.04062]);
                              
        handles.reconstructedStext = uicontrol(handles.mfigure,'style','text',...
                                  'units','normalized',...
                                  'string','Reconstructed',...
                                  'fontsize',10,...
                                  'backgroundColor',[0.702, 0.702, 0.702],...
                                  'position',[0.40590, 0.909375, 0.16236, 0.04062]);
                              
        handles.timeDomainStext = uicontrol(handles.mfigure,'style','text',...
                                  'units','normalized',...
                                  'string','Time Domain',...
                                  'fontsize',10,...
                                  'backgroundColor',[0.702, 0.702, 0.702],...
                                  'position',[0.101476, 0.03, 0.145756, 0.040625]);
                              
        handles.frequencyDomainStext = uicontrol(handles.mfigure,'style','text',...
                                  'units','normalized',...
                                  'string','Frequency Domain',...
                                  'fontsize',10,...
                                  'backgroundColor',[0.702, 0.702, 0.702],...
                                  'position',[0.3819, 0.03, 0.21033, 0.04062]);
                              
        handles.errorStext = uicontrol(handles.mfigure,'style','text',...
                                  'units','normalized',...
                                  'string','Error',...
                                  'fontsize',10,...
                                  'backgroundColor',[0.702, 0.702, 0.702],...
                                  'position',[0.7638, 0.90937, 0.0940959, 0.04062]);
                              
        handles.fwhmTStext = uicontrol(handles.mfigure,'style','text',...
                                                       'backgroundColor',[1,1,1],...
                                                       'style','text',...
                                                       'FontName','FixedWidth',...
                                                       'string','fwhm = 0',...
                                                       'fontsize',10,...
                                                       'horizontalAlignment','left',...
                                                       'units','normalized',...
                                                       'visible','off',...
                                                       'position',[0.048, 0.16, 0.2,0.035]);
                              
        handles.fwhmLStext = uicontrol(handles.mfigure,'style','text',...
                                                       'backgroundColor',[1,1,1],...
                                                       'style','text',...
                                                       'FontName','FixedWidth',...
                                                       'string','fwhm = 0',...
                                                       'fontsize',10,...
                                                       'horizontalAlignment','left',...
                                                       'units','normalized',...
                                                       'visible','off',...
                                                       'position',[0.364, 0.16, 0.2,0.035]);
                                                   
        handles.mpvTStext = uicontrol(handles.mfigure,'style','text',...
                                                 'backgroundColor',[1,1,1],...
                                                 'style','text',...
                                                 'FontName','FixedWidth',...
                                                 'string','mpv = 0',...
                                                 'fontsize',10,...
                                                 'horizontalAlignment','left',...
                                                 'units','normalized',...
                                                 'visible','off',...
                                                 'position',[0.05, 0.125, 0.2,0.035]);
                              
        handles.mpvLStext = uicontrol(handles.mfigure,'style','text',...
                                                 'backgroundColor',[1,1,1],...
                                                 'style','text',...
                                                 'FontName','FixedWidth',...
                                                 'string','mpv = 0',...
                                                 'fontsize',10,...
                                                 'horizontalAlignment','left',...
                                                 'units','normalized',...
                                                 'visible','off',...
                                                 'position',[0.366, 0.125, 0.2,0.035]);
                              
        % Menu Items
        handles.fileMenu = uimenu(handles.mfigure,...
                                    'label','File');
                                
                                handles.saveMenu = uimenu(handles.fileMenu,...
                                                            'label','Save Data',...
                                                            'callback',@menuCallbacks);
                                                        
                                handles.saveInterpMenu = uimenu(handles.fileMenu,...
                                                            'label','Interpolate and Save',...
                                                            'callback',@menuCallbacks);
                                                        
                                handles.exitMenu = uimenu(handles.fileMenu,...
                                                            'label','Exit',...
                                                            'callback',@menuCallbacks);

        % Set initial values
        set(handles.stopButton,'userdata',1); % used to break pcgp loop
        set(handles.noiseButton,'userdata',0); % used to add noise in pcgp loop
        set(handles.restartButton,'userdata',0); % restart pcgp algorithm
        handles.l1=[]; handles.l2=[];
        handles.l3=[]; handles.l4=[];
        
        % Set initial values for data
        handles.err = [];
        handles.Et = [];
        handles.Ew = [];
        
            handles.interpolateDLambda = 0.1338;
            handles.interpolateNpts = 1024;
                                                        
    end
        
    function menuCallbacks(src,event)

        switch gcbo                
                
            case handles.saveMenu
                
                [filename, fullpath] = uiputfile('*.txt','Save Frog Trace', handles.fFpath);
                if ~isequal(filename,0) || ~isequal(fullpath, 0),
                    Et = handles.Et;
                    Ew = handles.Ew;
                    
                        % undo the shift from frogFilter
%                         Ew = circshift(Ew,[0,-handles.yShift]);
                    
                    err = nan(1,length(Et));
                    err(1:length(handles.err)) = handles.err;
                   
                    
                    if ~isempty(Et),
                        csvwrite([fullpath,filename], [Et;Ew;err] );
                    else
                        
                    end

                end
                
            case handles.exitMenu
                
                set(handles.pfigure,'visible','on');
                delete(handles.mfigure);
                
            case handles.saveInterpMenu
                
                        Et = handles.Et;
                        Ew = fftshift(fft(Et));
                        
                if ~isempty(Et),
                
                    saveInterpolate;
                    uiwait(gcf);

                    [filename, fullpath] = uiputfile('*.txt','Save Frog Trace', handles.fFpath);
                    if ~isequal(filename,0) || ~isequal(fullpath, 0),
                        
                        % get dLambda and number of points from user
                        N = handles.interpolateNpts;
                        n = numel(Ew);
                        
                        w = handles.omega/2;
                        dw = sum(diff(w))/(numel(w)-1)*2;
                        
                        tmax = 2*pi/dw;
                        dt = tmax/(numel(w)-1);
                        
                        tau = -tmax/2:dt:tmax/2;
                        
                        lambda = handles.lambda*2;
                        lambda0 = lambda( round(n/2) );
                        
                        dLambda = handles.interpolateDLambda*1e-9/2;
                        mxLam = dLambda*(N-1);
                        
                        LAMBDA = -mxLam/2:dLambda:mxLam/2;
                        LAMBDA = LAMBDA + lambda0;
                        
                        omega = fliplr( 2*pi*2.9972945*1e8./LAMBDA );
                        
                        dw = sum(diff(omega))/(N-1);
                        mxOmega = max(omega);
                        mnOmega = min(omega);
                        
                        omega = mnOmega:dw:mxOmega;

                        tmax = 2*pi/dw;
                        dt = tmax/(N-1);
                        
                        t = -tmax/2:dt:tmax/2;

                        
                        Aw2 = interp1(w,abs(Ew),omega,'spline',0);
                        pw2 = interp1(w,funwrap1(angle(Ew)),omega,'spline',0);
                        Ew2 = Aw2.*exp(i*pw2);
                                                
                        At2 = interp1(tau,abs(Et),t,'spline',0);
                        pt2 = interp1(tau,funwrap1(angle(Et)),t,'spline',0);
                        Et2 = At2.*exp(i*pt2);

                        % pad error to be same size as Et2 & Ew2
                        err = nan(1,length(Et2));
                        err(1:length(handles.err)) = handles.err;
                        
                            % write values to file
                            csvwrite([fullpath,filename], [Et2;Ew2;err] );
                            
                    else
                        % do nothing
                    end

                end
                
        end
    end

    function buttonCallbacks(src, event)
        
        iData = handles.frogData;
        [M,N]=size(iData);

        switch gcbo
            case handles.goBackButton
                
                set(handles.pfigure,'visible','on');
                
                if get(handles.stopButton,'userdata'),
                    set(handles.stopButton,'userdata',0);
                end
                
                delete(handles.mfigure);
                
            case handles.startButton
                
                set(handles.goBackButton,'enable','off');
                set(handles.startButton,'enable','off');

                try
                    
                    pcgp(N,iData);
                    
                catch

                end
                
                set(handles.goBackButton,'enable','on');
                set(handles.startButton,'enable','on');

                
            case handles.stopButton
                set(handles.stopButton,'userdata',0);
                
            case handles.noiseButton
                set(handles.noiseButton,'userdata',1);
                
            case handles.restartButton
                set(handles.restartButton,'userdata',1);
        end
       
    end

    function pcgpFigure_deleteFcn(src, event)
            set(handles.pfigure,'visible','on');
            delete(handles.mfigure);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Support Functions                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Principal component phase retrieval algorithm
    function [err, Et, Ew] = pcgp(N, F)
    % turn warning off
    warning off;
    
    NptsTime = handles.NptsTime;    
%     fRatio = NptsTime/N;
    fRatio=1;
    
    % turn on fwhm text
    set([handles.fwhmTStext, handles.fwhmLStext],'visible','on');
    set([handles.mpvTStext,handles.mpvLStext],'visible','on');
        
            if ishandle(handles.l1),
                delete(handles.l1,handles.l2,...
                    handles.l3,handles.l4);
            end
        
        N2=round(N/2);                                                         % Number of Samples
        F = F/max(max(abs(F)));                                                % normalize Frog Trace

        P = fftshift(guess(N));                                                % Initial guess
        
        ii=1;
        while 1,
            
            if ~get(handles.stopButton,'userdata'),
                break;
            end
            
            if get(handles.restartButton,'userdata'),
                P = fftshift(guess(N));
                set(handles.restartButton,'userdata',0);
            end
            
            P=P/max(max(abs(P)));                                              % Normalize guess

            mx = find(abs(P).^2==max(abs(P).^2));                              % Find max and shift to center
            P=circshift(P,[0,(N2-mx(1))]);

            H = P.'*P;                                                         % form outer-product

            for jj=1:N                                                         % Row Shift
                H(jj,:) = circshift(H(jj,:), [0, -(jj-1)]);
            end

            G = fftshift( fft(H, [], 1));                                      % Fourier Transform

            Gm = abs(G).^2; Gm = Gm/max( Gm(:) );                              % Normalize
            
%             err(ii) = sqrt( sum(sum( (F-Gm).^2 ))/sum(sum(F.^2)) );          % Calculate Error
            err(ii) = sqrt( mean(mean( abs(F-Gm).^2 )) );                      % Calculate RMS Error

            % set error text
            set(handles.errStext,'string',['error = ',sprintf('%0.2e',err(ii))]);

            % calculate fields for plotting                                    % Plotting                                             
            It = abs(P).^2/max(abs(P)).^2;  
            pht = funwrap1(angle(P));
            
            pht = pht*fRatio;
            zt = It>0.001;
            
            phtNan = nan(size(pht));
            phtNan(zt~=0) = pht(zt~=0);
            
            Ew = fftshift(fft(P));
            Iw = abs(Ew).^2/max(abs(Ew).^2);
            
%             It_tfl = abs( fftshift(fft(Iw)) );
%             It_tfl = It_tfl/max(It_tfl);
            
            phw = funwrap1(angle(Ew));
            
            phw = phw*fRatio;
            
            zw = Iw>0.001;            
            
            phwNan = nan(size(phw));
            phwNan(zw~=0) = phw(zw~=0);

            if ishandle(handles.l1),
                delete(handles.l1,handles.l2,...
                    handles.l3,handles.l4);
            end
            
            [fwhmT, fwhmL] = pulseStats(It, Iw);
            
            set(handles.fwhmTStext,'string',['fwhm = ',sprintf('%0.2f',fwhmT*1e15),' fs']);
            set(handles.fwhmLStext,'string',['fwhm = ',sprintf('%0.2f',fwhmL*1e9),' nm']);
            
            set(handles.mpvTStext,'string',['mpv = ',sprintf('%0.2f',abs( max(pht.*zt)-min(pht.*zt) ) ),' rad']);
            set(handles.mpvLStext,'string',['mpv = ',sprintf('%0.2f',abs( max(phw.*zw)-min(phw.*zw) )),' rad']);
            
            imagesc(abs(sqrt(F)),'parent',handles.maxes1); axis(handles.maxes1, 'xy');
            
                handles.l1=line(1:N,It,...
                    'linewidth',2,...
                    'color',[255;48;48]'/255,...
                    'parent',handles.maxes12);
                
%                 handles.l11=line(1:N,It_tfl,...
%                     'linewidth',2,...
%                     'color','k',...
%                     'parent',handles.maxes12);
                
                handles.l2=line(1:N,phtNan,...
                    'linewidth',2,...
                    'color',[0;0;255]'/255,...
                    'parent',handles.maxes13);

            imagesc(abs(sqrt(Gm)),'parent',handles.maxes2); axis(handles.maxes2, 'xy');
                handles.l3=line(1:N,Iw,...
                    'linewidth',2,...
                    'color',[255;48;48]'/255,...
                    'parent',handles.maxes22);
                
                handles.l4=line(1:N,phwNan,...
                    'linewidth',2,...
                    'color','g',...
                    'parent',handles.maxes23);
                
                axis([handles.maxes12,handles.maxes22,...
                      handles.maxes13,handles.maxes23],'tight');
                
            semilogy(err,'linewidth',2,'parent',handles.maxes3); axis tight;
            set(handles.maxes3,'fontsize',8,'yaxislocation','right');


            set([handles.maxes1,handles.maxes2,...
                handles.maxes12,handles.maxes22,...
                handles.maxes13,handles.maxes23],'xtick',[],'ytick',[]);
            drawnow;
                        
                if get(handles.noiseButton,'userdata'),
                    a = 5*rand(size(F));
                    set(handles.noiseButton,'userdata',0);
                else
                    a = 0;
                end

            Fguess = sqrt(F).*exp(i*( a + angle(G) ) );                     % Intensity Constraint
            G = ifft( ifftshift(Fguess), [], 1);                            % Inverse Fourier Transform
            for jj=1:N
                G(jj,:) = circshift( G(jj,:), [0, jj-1] );                  % Reverse row shift
            end

                [U,W,V] = svds(G,1);
                P = V(:,1)';
                
%                 % Power Method
%                 for itr = 3,                                              % change number of iterations to improve convergence
%                     Pp = (G * G.') * P.';
%                     P = Pp.';
%                 end

            ii = ii+1;

        end
                
        % reset userdata so loop can start again
        set(handles.stopButton,'userdata',1);
        
        Et = P;                                                                % Final E-field
        Ew = fftshift( fft(Et) );
            
                handles.err = err;
                handles.Et = Et;
                handles.Ew = Ew;
                
                guidata(handles.mfigure,handles);
        
        function P = guess(N)
            P = rand(1,N) .* exp(i*rand(1,N));
%             x = -N/2:N/2-1;
%             P = exp(-x.^2/(N/5)^2).*exp(i*rand(1,N));
        end
    
    warning on;
    
    end

    % 1d unwrapping algorithm
    function[unwrapped] = funwrap1(wrapped,cutoff)
        [m,n] = size(wrapped);
        if m<n,

        elseif n<m,
            wrapped = wrapped.';
        end

        if nargin ==1, cutoff = pi; end

            n = length(wrapped); n2 = round(n/2);
            for jj=1:2,
                wrapped = fliplr(wrapped);
                for ii=n2:n,

                    pt = wrapped(ii);
                    if pt ~= 0,
                        tmp = round( (pt - wrapped(ii-1))/cutoff );
                        wrapped(ii) = wrapped(ii) - tmp*pi;
                    end

                end
            end
            unwrapped = wrapped;
    
    end

    % set save and interpolate values
    function saveInterpolate
        
        mPos = get(handles.mfigure,'position');
        
        
        bClr = [0.25,0.25,0.65];
        h = figure('color',[0.702,0.702,0.702],...
                   'Color',bClr,...
                   'numberTitle','off',...
                   'name','Interpolate',...
                   'windowStyle','modal',...
                   'menubar','none',...
                   'toolbar','none',...
                   'resize','off',...
                   'units','pixels',...
                   'position',[mPos(1)+ round(mPos(3)/2), mPos(2)+ round(mPos(4)/2), 165, 105],...
                   'deleteFcn',@h_deletefcn);
               
        okbutton = uicontrol(h,'style','pushbutton',...
                               'units','normalized',...
                               'string','OK',...
                               'position',[0.61, 0.08, 0.2857, 0.25],...
                               'callback',@h_okButton);
                           
        dLambdaStext = uicontrol(h,'style','text',...
                                  'units','normalized',...
                                  'backgroundColor',bClr,...
                                  'foregroundColor',[1,1,1],...
                                  'fontname','symbol',...
                                  'string','dl',...
                                  'horizontalAlignment','left',...
                                  'position',[0.090476, 0.63, 0.419, 0.125]);
                              
        dLambdaEtext = uicontrol(h,'style','edit',...
                                  'units','normalized',...
                                  'backGroundColor',[1,1,1],...
                                  'string','0.1338',...
                                  'position',[0.6, 0.67, 0.3125, 0.23]);
                              
        nptsStext = uicontrol(h,'style','text',...
                                  'units','normalized',...
                                  'backgroundColor',bClr,...
                                  'foregroundColor',[1,1,1],...
                                  'string','Size',...
                                  'horizontalAlignment','left',...
                                  'position',[0.090476, 0.36, 0.419, 0.125]);
                              
        nptsEtext = uicontrol(h,'style','edit',...
                                  'units','normalized',...
                                  'backGroundColor',[1,1,1],...
                                  'string','1024',...
                                  'position',[0.6, 0.4, 0.3125, 0.23]);
                              
        function h_okButton(src,event)
            
            dLambda = str2double(get(dLambdaEtext,'string'));
            Npts = str2double(get(nptsEtext,'string'));
            
            handles.interpolateDLambda = dLambda;
            handles.interpolateNpts = Npts;
            
            guidata(handles.mfigure,handles);
            
            delete(h);
        end
        
        function h_deletefcn(src, event)
            dLambda = str2double(get(dLambdaEtext,'string'));
            Npts = str2double(get(nptsEtext,'string'));
            
            handles.interpolateDLambda = dLambda;
            handles.interpolateNpts = Npts;
            
            guidata(handles.mfigure,handles);
            
            delete(h);
        end

    end
    
    % calculate fwhm(t) & fwhm(lambda)
    function [fwhmT,fwhmL] = pulseStats(It,Iw)
        
        N = numel(It);

        % take the full range from the frog scan and divide by the
        % interpolated number of points to get dt
        dt = handles.tmax*1e-15/N;
        
        % calculate dLambda from second harmonic axis
        lambda = handles.lambda * 2; % <--- fundamental axis
        dLambda = sum(diff(lambda))/(N-1) * 2;
        
        % normalize intensities
        Iw = Iw-min(Iw); Iw = Iw/max(Iw);
        It = It-min(It); It = It/max(It);
        
        % calculate fwhm
        fwhmL = numel(find(Iw>0.5))*dLambda;
        fwhmT = numel(find(It>0.5))*dt;

    end

end



end