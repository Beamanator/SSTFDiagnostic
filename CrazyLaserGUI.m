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
        data.Parameters.stepValue = 0.0;
        data.Parameters.StepSize = '1/8';
        
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
        %----- Static text (stext):
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

        %--- Editable text (etext):
        Test_etext = uicontrol(...
            'parent',Example_panel,...
            'units','normalized',...
            'style','edit',...
            'string','0.0',...
            'backgroundcolor','w',...
            'position',[0.05 0.85 0.2 0.1],...
            'callback',@ButtonCallback...
        );

        %----- Buttons:
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
            'Enable','on',...
            'string','Move Motor!',...
            'position',[0.85 0.2 0.1 0.3],...
            'callback',@ButtonCallback...
        );
        Test_step = uicontrol(...
            'parent',Example_panel,...
            'units','normalized',...
            'style','pushbutton',...
            'Enable','off',...
            'string','TestMove',...
            'position',[0.05 0.7 0.2 0.1],...
            'callback',@ButtonCallback...
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
        
            %removed 'Enable','off',...
        StepSize_menu = uimenu(...
            'parent', Main_Figure,...
            'label','Step Size'...
        );
            FullStep = uimenu(...
                'parent', StepSize_menu,...
                'label','Full (1)',...
                'separator','off',...
                'callback',@MenuCallback...
            );
            HalfStep = uimenu(...
                'parent', StepSize_menu,...
                'label','Half (1/2)',...
                'separator','off',...
                'callback',@MenuCallback...
            );
            QuarterStep = uimenu(...
                'parent', StepSize_menu,...
                'label','Quarter (1/4)',...
                'separator','off',...
                'callback',@MenuCallback...
            );
            EighthStep = uimenu(...
                'parent', StepSize_menu,...
                'label','Eighth (1/8)',...
                'separator','off',...
                'Checked','on',...
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
        data.handles.Example_panel = Example_panel;
        
        %--- static text
        data.handles.Example_stext = Example_stext;
        
        %--- edit text
        data.handles.Test_etext = Test_etext;
        
        %--- button handles
        data.handles.Example_button = Example_button;
        data.handles.TestMove_button = TestMove_button;
        data.handles.Test_step = Test_step;
        
        %--- menu handles
        data.handles.ExitProgram = ExitProgram;
        data.handles.StartArduino = StartArduino;
        data.handles.StartInductionSensor = StartInductionSensor;
        
        data.handles.StepSize_menu = StepSize_menu;
        data.handles.FullStep = FullStep;
        data.handles.HalfStep = HalfStep;
        data.handles.QuarterStep = QuarterStep;
        data.handles.EighthStep = EighthStep;
        
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
                if isfield(data.Hardware, 'Arduino')
                    set(handles.TestMove_button, 'Enable', 'on');
                    set(handles.StartArduino, 'Checked', 'on');
                    set(handles.StartArduino, 'Enable', 'off');
                end
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
            % These can be simplified - not calling unCheckStep 4 times!
            case handles.FullStep
                setStepSize('1');
                set(handles.FullStep, 'Checked','on');
            case handles.HalfStep
                setStepSize('1/2');
                set(handles.HalfStep, 'Checked','on');
            case handles.QuarterStep
                setStepSize('1/4');
                set(handles.QuarterStep, 'Checked','on');
            case handles.EighthStep
                SetStepSize('1/8');
                set(handles.EighthStep, 'Checked','on');
        end
        % Maybe call UpdateDisplay if we want?
    end

    %--- ButtonCallback is the same as menuCallback, but with buttons!
    function ButtonCallback(srv,evnt)
        handles = data.handles;
        stepValue = data.Parameters.stepValue;
        
        switch gcbo
            case handles.Example_button
                data.Parameters.ExampleValue = data.Parameters.ExampleValue + 0.5;
                set(handles.Example_stext,'string',num2str(data.Parameters.ExampleValue));
                
            case handles.TestMove_button
               % Move('F',400);
               % pause(5);
               % Move('B',400);
                Move('F',stepValue);
                pause(5);
                Move('B',stepValue);
                
            case handles.Test_etext
                stepValue = get(handles.Test_etext,'string');
                if isempty(stepValue) %is something
                    set(handles.Test_step, 'Enable', 'off');
                    data.Parameters.stepValue = 0.0;
                elseif not(isnan(str2double(stepValue)))
                    set(handles.Test_step, 'Enable', 'on');
                    data.Parameters.stepValue = str2double(stepValue);
                elseif isnan(str2double(stepValue))
                    disp(stepValue);
                end
                
                disp(data.Parameters.stepValue);
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
        if exist('data.Hardware.Arduino','var') && isa(data.Hardware.Arduino,'arduino') && isvalid(data.Hardware.Arduino),
            % already connected, so nothing to do here.
        else
            % Arduino is not connected yet, so set up connection.
            data.Hardware.Arduino = arduino('COM4');
        end

        a = data.Hardware.Arduino;
        
        a.pinMode(2, 'OUTPUT'); % direction pin
        a.pinMode(3, 'OUTPUT'); % step pin
        a.pinMode(4, 'OUTPUT'); % MS1
        a.pinMode(5, 'OUTPUT'); % MS2
        
        % digitalWrite(a, b): a = pin #, b = high (1) or low (0)
        a.digitalWrite(2, 1); % 1 = Forward ( AWAY from motor )
        a.digitalWrite(3, 0);
        
        SetStepSize('1/8');
        
        % Enable stepping menu:
        set(data.handles.StepSize_menu, 'Enable', 'on');
    end

    %--- Sets step size for stepper motor according to this table:
    % Microstepping Table:
        %   MS1 (4)      MS2 (5)     resolution
        %    0            0          full step
        %    1            0          1/2  step
        %    0            1          1/4  step
        %    1            1          1/8  step
    function SetStepSize(stepsize)
        MS1_pin = 4; MS1_V = 0;
        MS2_pin = 5; MS2_V = 0;
        
        if exist('data.Hardware.Arduino','var') && isa(data.Hardware.Arduino,'arduino') && isvalid(data.Hardware.Arduino),
            a = data.Hardware.Arduino;
            data.Parameters.StepSize = stepsize;
            
            unCheckStep();
            
            if (strcmp(stepsize, '1'))
                % Already on this state
            elseif (strcmp(stepsize, '1/2'))
                MS1_V = 1;
                MS2_V = 0;
            elseif (strcmp(stepsize, '1/4'))
                MS1_V = 0;
                MS2_V = 1;
            elseif (strcmp(stepsize, '1/8'))
                MS1_V = 1;
                MS2_V = 1;
            end
            
            a.digitalWrite(MS1_pin, MS1_V);
            a.digitalWrite(MS2_pin, MS2_V);
        else
            % Arduino is not connected yet.
            disp('Must connect Arduino before setting its step size!');
        end
    end

    %--- Moves Arduino a given direction and # of steps.
    %- if dir is 'F', will move stage AWAY from motor [forward]
    %- if dir is 'B', will move stage TOWARDS motor [backward]
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
            pause(0.001); % - should be ~ 1 millisecond pause but ISN'T
            a.digitalWrite(3, 0);
            pause(0.001);
        end
    end

    %--- un-checks the step menu item that is alerady checked.
    %- Should be deleted if we change this to be inside the main GUI
    %section
    function unCheckStep()
        handles = data.handles;
        
        Full = get(handles.FullStep, 'Checked');
        Half = get(handles.HalfStep, 'Checked');
        Quarter = get(handles.QuarterStep, 'Checked');
        Eighth = get(handles.EighthStep, 'Checked');
        
        if (strcmp(Full, 'on'))
            set(handles.FullStep, 'Checked', 'off');
        elseif (strcmp(Half, 'on'))
            set(handles.HalfStep, 'Checked', 'off');
        elseif (strcmp(Quarter, 'on'))
            set(handles.QuarterStep, 'Checked', 'off');
        elseif (strcmp(Eighth, 'on'))
            set(handles.EighthStep, 'Checked', 'off');
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