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
        %Parameters
        data.Parameters.ExampleValue = 0.0;
        
        %-----------------------------------------------------------------%
        %%%                            Panels        (Main_Figure)      %%%
        %-----------------------------------------------------------------%

        %--- Example Panel:
        %- parent: Main_Figure = Panel to inherit location from
        %- title: 'Example' = Name to go inside box line surrounding panel
        %- units: 'normalized' = idk
        %- backgroundcolor: bkc = color defined above
        %- position: [x y Wx Wy] - in percentages of parent panel
        Example_panel = uipanel(...
            'parent',Main_Figure,...
            'title','Example',...
            'units','normalized',...
            'backgroundcolor',bkc,...
            'position',[1/5 1/5 3/5 3/5]...
        );
    
        %-----------------------------------------------------------------%
        %%%                       Buttons & Text     (Main_Figure)      %%%
        %-----------------------------------------------------------------%
        
        %---------------------------- Main Figure ------------------------%
        %----- static text (stext):
        %--- Example Static Text Component:
        %- uicontrol properties website guide:
        %- http://www.mathworks.com/help/matlab/ref/uicontrol_props.html
        Example_stext = uicontrol(...
            'parent',Main_Figure,...
            'units','normalized',...
            'style','text',...
            'string','0.0',...
            'value',0,...
            'fontsize',14,...
            'fontweight','bold',...
            'HorizontalAlignment','left',...
            'position',[0.1 0.9 0.08 0.04]...
        );
        %----- buttons:
        %--- Example Button Component:
        Example_button = uicontrol(...
            'parent',Main_Figure,...
            'units','normalized',...
            'style','pushbutton',...
            'string','Add 0.5!',...
            'position',[0.85 0.5 0.1 0.3],...
            'callback',@ButtonCallback...
        );
    
        TestMove_button = uicontrol(...
            'parent',Main_Figure,...
            'units','normalized',...
            'style','pushbutton',...
            'Enable','off',...
            'string','Move Motor!',...
            'position',[0.85 0.2 0.1 0.3],...
            'callback',@ButtonCallback...
        );

        %-----------------------------------------------------------------%
        %%%                         Menu Bar       (Main_Figure)        %%%
        %-----------------------------------------------------------------%
        
        %--- This is how you make a lable on the top bar of the GUI.
        %- Main_Figure = which uipanel to put it on.
        %- label: File = text to appear on menu to click on.
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
            'parent',Main_Figure,...
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
        data.handles.Example_panel = Example_panel;
        
        %--- static text
        data.handles.Example_stext = Example_stext;
        
        %--- button handles
        data.handles.Example_button = Example_button;
        data.handles.TestMove_button = TestMove_button;
        
        %--- menu handles
        data.handles.ExitProgram = ExitProgram;
        data.handles.StartArduino = StartArduino;
        data.handles.StartInductionSensor = StartInductionSensor;
        
        data.handles.Test_menu = Test_menu;
        data.handles.Test2_menu = Test2_menu;
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
                set(handles.TestMove_button, 'Enable', 'on');
                set(handles.StartArduino, 'Checked', 'on');
                set(handles.StartArduino, 'Enable', 'off');
            case handles.StartInductionSensor
                % Must click 'Change Folder' on Loadup for this to work.
                addpath([pwd '\Matlab']);
                data.Hardware.Inductor = LDC1000_script();
            case handles.Test_menu
                disp('Test function.');
                %bob = data.Hardware.Inductor;
                %if exist('bob', 'var')
                %    disp('available');
                %else
                %    disp('nope');
                %end
            case handles.Test2_menu
                box = handles.Test2_menu;
                checked = get(box, 'Checked');
                if strcmp(checked,'off');
                    set(box, 'Checked', 'on');
                else
                    set(box, 'Checked', 'off');
                end
                
        end
        % Maybe call UpdateDisplay if we want?
    end

    %--- ButtonCallback is the same as menuCallback, but with buttons!
    function ButtonCallback(srv,evnt)
        handles = data.handles;
        
        switch gcbo
            case handles.Example_button
                data.Parameters.ExampleValue = data.Parameters.ExampleValue + 0.5;
                set(handles.Example_stext,'string',num2str(data.Parameters.ExampleValue));
                
            case handles.TestMove_button
                Move('F',400);
                pause(5);
                Move('B',400);
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
        %if strcmp(get(data.handles.TestMove_button, 'Enable'),'on')
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
        data.Hardware.Arduino = arduino('COM4');
        a = data.Hardware.Arduino;
        
        a.pinMode(2, 'OUTPUT');
        a.pinMode(3, 'OUTPUT');
        a.digitalWrite(2, 1); % 1 = digital high (5V)
        a.digitalWrite(3, 0); % 0 = digital low  (0V)
    end

    %--- Moves Arduino a given direction and # of steps.
    %- if dir is 'F', will move stage AWAY from motor [forward]
    %- if dir is 'B', will move stage TOWARDS motor [backward]
    %- 
    function Move(dir, steps)
        a = data.Hardware.Arduino;
        switch dir
            case 'F'
                disp('Forward')
                a.digitalWrite(2, 1);
            case 'B'
                disp('Backward')
                a.digitalWrite(2, 0);
        end
        disp(steps);
        for m = 1:steps
            a.digitalWrite(3, 1);
            pause(0.001); % - should be ~ 1 millisecond pause
            a.digitalWrite(3, 0);
            pause(0.001);
        end
    end

    %--- Updates the display to conform with private parameter values.
    %- May not be necessary if we use set() to update everything immediately
    %function UpdateDisplay(src,evnt)
    %    
    %    % Update editable text fields.
    %    %- Example:
    %    %set(data.handles.Increment_etext,'string',num2str(data.Parameters.Increment));
    %end
end