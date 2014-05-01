function[fn] = CrazyLaserGUI(data)
    %-----------------------------------------------------------------%
    %%%                          Functions       (Main_Figure)      %%%
    %-----------------------------------------------------------------%

    fn.MenuCallback = @MenuCallback;
    fn.EditCallback = @EditCallback;
    fn.CheckboxCallback = @CheckboxCallback;
    fn.ButtonCallback = @ButtonCallback;
    fn.MF_DeleteFn = @MF_DeleteFn;
    fn.UpdateDisplay = @UpdateDisplay;

    %-----------------------------------------------------------------%
    %%%                   Callbacks      (Main_Figure)              %%%
    %-----------------------------------------------------------------%

    %--- MenuCallback function takes srv and evnt as automatically passed
    %- in variables. These do not need to be used, they are just here. Each
    %- handle is in the data array, so we will search through the handles
    %- using 'switch gcbo' and figure out which handle was called, and
    %- execute code accordingly.
    function MenuCallback(srv, evnt)
        handles = data.handles; % just to limit code below
        
        % switch on object whos callback is being executed (gcbo)
        switch gcbo
            case handles.ExitProgram
                delete(data.Main_Figure);

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
        end
        % Maybe call UpdateDisplay if we want?
    end

    %--- EditCallback is the same as menuCallback, but for editable text boxes!
    function EditCallback(srv,evnt)
        p = data.Parameters;
        handles = data.handles;

        % check to make sure values are NOT strings:
        str = get(srv,'String');   %- current value
        val = get(srv,'UserData'); %- previous value
        if isempty(str2num(str))
            if isempty(val)
                set(srv,'String','0','UserData','0');
            else
                set(srv,'String',val);
            end
            warndlg('Input must be numerical');
            return % quit function early.
        else
            set(srv,'UserData',str);
            if exist('data.Hardware.Arduino','var') && isa(data.Hardware.Arduino,'arduino') && isvalid(data.Hardware.Arduino),
                set(handles.MotorParametersSave_button,'Enable','on');
            end
            %disp('Here maybe set data.Parameters value?');
            %disp('Depends on how well we can use srv variable!!');
        end
        
        switch gcbo
            case handles.XSteps_etext
                disp(['xSteps text box changed to ',get(srv,'String')]);

            case handles.ZSteps_etext
                disp(['zSteps text box changed to ',get(srv,'String')]);

            case handles.XDirection_etext
                disp(['xDirection text box changed to ',get(srv,'String')]);
                warndlg('1 = forward, 0 = backward');

            case handles.ZDirection_etext
                disp(['zDirection text box changed to ',get(srv,'String')]);
                warndlg('0 = forward, 1 = backward');

            case handles.xSpectraCount_etext
                disp(['xDataPoints / Spectra Count text box changed to ',get(srv,'String')]);

            case handles.zScanCount_etext
                disp(['zScans / Scan Count text box changed to ',get(srv,'String')]);

            case handles.SpectrumDelay_etext
                disp(['Spectrum delay value text box changed to ',get(srv,'String')]);

            case handles.DriverDelay_etext
                disp(['Driver delay value text box changed to ',get(srv,'String')]);
                
            case handles.XJogSteps_etext
                disp(['X jog steps text box changed to ',get(srv,'String')]);
                
            case handles.ZJogSteps_etext
                disp(['Z jog steps text box changed to ',get(srv,'String')]);
                
            case handles.XJogDirection_etext
                disp(['X jog direction value text box changed to ',get(srv,'String')]);
                warndlg('1 = forward, 0 = backward');

            case handles.ZJogDirection_etext
                disp(['Z jog direction value text box changed to ',get(srv,'String')]);
                warndlg('0 = forward, 1 = backward');

        end
        
        UpdateDisplay();
    end

    %--- CheckboxCallback is the same as menuCallback, but with checkboxes
    function CheckboxCallback(srv,evnt)
        handles = data.handles;
        
        switch gcbo
            case handles.XJog_checkbox
                disp('x checkbox clicked');
                
            case handles.ZJog_checkbox
                disp('z checkbox clicked');
        end
    end

    %--- ButtonCallback is the same as menuCallback, but with buttons!
    function ButtonCallback(srv,evnt)
        handles = data.handles;
        
        switch gcbo
            case handles.TakeSpectrum_button
                
                a = data.Hardware.Arduino;
                a.roundTrip(22);

            case handles.MotorParametersSave_button
                set(srv,'Enable','off');
                
                xSteps = str2double(get(handles.XSteps_etext, 'String'));
                zSteps = str2double(get(handles.ZSteps_etext, 'String'));
                xPoints = str2double(get(handles.xSpectraCount_etext, 'String'));
                zScans = str2double(get(handles.zScanCount_etext, 'String'));
                
                % TODO: test these direction handles:
                % - need to calibrate what is forward (1 or 0)
                % - [depends on orientation of setup]
                xDir = handles.XScanUp_button;
                xDirection = 0;
                if get(xDir,'Value') == get(xDir,'Max') %down
                    xDirection = 1;
                end
                
                zDir = handles.ZScanLeft_button;
                zDirection = 0;
                if get(zDir,'Value') == get(zDir,'Max') %down
                    zDirection = 1;
                end
                
                sendArduinoVariables('xSteps',xSteps);
                sendArduinoVariables('zSteps',zSteps);
                sendArduinoVariables('xDirection',xDirection);
                sendArduinoVariables('zDirection',zDirection);
                sendArduinoVariables('xDataPoints',xPoints);
                sendArduinoVariables('zScans',zScans);
                
            case handles.DelaysSave_button
                SpectrumDelay = str2double(get(handles.SpectrumDelay_etext,'String'));
                DriverDelay = str2double(get(handles.DriverDelay_etext,'String'));
                
                sendArduinoVariables('SpectrumDelay',SpectrumDelay);
                sendArduinoVariables('DriverDelay',DriverDelay);
                
            case handles.FullScan_button
                disp('Starting Full Scan');
                xSteps = get(handles.XSteps_etext, 'String');
                zSteps = get(handles.ZSteps_etext, 'String');
                xDirection = get(handles.XDirection_etext, 'String');
                zDirection = get(handles.ZDirection_etext, 'String');
                xPoints = get(handles.xSpectraCount_etext, 'String');
                zScans = get(handles.zScanCount_etext, 'String');
                
                % display params to console just for another reference.
                disp(['x steps: ' xSteps]);
                disp(['z steps: ' zSteps]);
                disp(['x direction: ' xDirection]);
                disp(['z direction: ' zDirection]);
                disp(['# x data points: ' xPoints]);
                disp(['# z Scans: ' zScans]);
                
                data.Hardware.Arduino.roundTrip(21);
                
            case handles.XScan_button
                disp('Starting X Scan');
                xSteps = get(handles.XSteps_etext, 'String');
                xDirection = get(handles.XDirection_etext, 'String');
                xPoints = get(handles.xSpectraCount_etext, 'String');

                disp(['x steps: ' xSteps]);
                disp(['x direction: ' xDirection]);
                disp(['# x data points: ' xPoints]);
                
                data.Hardware.Arduino.roundTrip(23);
                
            case handles.ZScan_button
                disp('Starting Full Scan');
                zSteps = get(handles.ZSteps_etext, 'String');
                zDirection = get(handles.ZDirection_etext, 'String');
                zScans = get(handles.zScanCount_etext, 'String');
                
                % display params to console just for another reference.
                disp(['z steps: ' zSteps]);
                disp(['z direction: ' zDirection]);
                disp(['# z Scans: ' zScans]);
                
                data.Hardware.Arduino.roundTrip(24);
                
            case handles.XScanUp_button
                State = get(srv, 'Value');
                xDown = handles.XScanDown_button;
                if State == get(srv,'Max'); % down
                    min = get(xDown,'Min');
                    set(xDown,'Value',min);
                else % up
                    max = get(xDown,'Max');
                    set(xDown,'Value',max);
                end
                
            case handles.XScanDown_button
                State = get(srv,'Value');
                xUp = handles.XScanUp_button;
                if State == get(srv,'Max'); % down
                    min = get(xUp,'Min');
                    set(xUp,'Value',min);
                else % up
                    max = get(xUp,'Max');
                    set(xUp,'Value',max);
                end
                
            case handles.ZScanRight_button
                State = get(srv,'Value');
                zLeft = handles.ZScanLeft_button;
                if State == get(srv,'Max'); % down
                    min = get(zLeft,'Min');
                    set(zLeft,'Value',min);
                else % up
                    max = get(zLeft,'Max');
                    set(zLeft,'Value',max);
                end
                
            case handles.ZScanLeft_button
                State = get(srv,'Value');
                zRight = handles.ZScanRight_button;
                if State == get(srv,'Max'); % down
                    min = get(zRight,'Min');
                    set(zRight,'Value',min);
                else % up
                    max = get(zRight,'Max');
                    set(zRight,'Value',max);
                end
                
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
                
        end
        % Maybe call UpdateDisplay if we want?
    end

    %--- MF_DeleteFn is called when the GUI is closed using the X.
    function MF_DeleteFn(src,evnt)
        if exist('data.Hardware.Arduino', 'var')
            delete(data.Hardware.Arduino);
        else
            disp('Arduino already off');
        end
    end

    %--- Initialize Arduino.
    %- connect to correct COM port,
    %- create Arduino variable, set correct pins to correct values.
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
            set(handles.Jog_button,'Enable','on');
        end
    end

    %--- sendArduinoVariables is a function that sends variables to the Arduino.
    %- uses roundTrip() function.
    %- params:
    %-  varName = name of variable to set in Arduino code
    %-  val = value to set to specified variable in Arduino code.
    function sendArduinoVariables(varName, val)
        a = data.Hardware.Arduino;
        varCode = 0;

        switch varName
            case 'xSteps'
                varCode = 11;
            case 'xDirection'
                varCode = 12;
            case 'xDataPoints'
                varCode = 13;
            case 'zSteps'
                varCode = 14;
            case 'zDirection'
                varCode = 15;
            case 'zScans'
                varCode = 16;
            case 'SpectrumDelay'
                varCode = 17;
            case 'DriverDelay'
                varCode = 18;
        end

        % not exactly what this does, but it works:
        if (a == 0)
            disp('Hmm, wrong code sent to sendArduinoVariables somewhere');
        else
            a.roundTrip(varCode);
            pause(0.1);
            a.roundTrip(val);
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