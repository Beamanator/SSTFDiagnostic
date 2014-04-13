%> @mainpage Documentation
%>
%> @section summary Summary
%>
%> The LDC1000 EVM communicates to the GUI using USB CDC, which shows up as a 
%> virtual serial port.
%> 
%> This application programming interface (API) defines functions to read/write 
%> LDC1000 registers and to initiate and receive data polled by the EVM microcontroller.
%> The API utilizes the MATLAB Serial Object (http://www.mathworks.com/help/matlab/ref/serial.html).
%>
%> Please see LDC1000_script.m for typical usage of these MATLAB functions.
%>
%> Open and Close Serial Port:
%> - LDC1000_open.m
%> - LDC1000_close.m
%>
%> Stream Data:
%> - LDC1000_setsamplerate.m
%> - LDC1000_startstream.m
%> - LDC1000_stopstream.m
%> - LDC1000_streamdata.m
%>
%> Read / Write Registers:
%> - LDC1000_readreg.m
%> - LDC1000_writereg.m
%> 
%> Misc:
%> - LDC1000_version.m
%>
%======================================================================
%> @file  LDC1000_script.m
%> @brief LDC1000 EVM Script
%>
%> This example demonstrates:
%> 1. reading EVM version information
%> 2. setting the sample rate
%> 3. reading and writing registers
%> 4. getting data (single shot)
%> 5. getting data (streaming)
%>
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments(R)
function [ Rp, Tp] = LDC1000_script

%% Reg Defaults - may not be same for all EVMs
regaddr=[0 1 2 3 4 5 6 7 8 9 10 11 20 21 22 23 24 25];  % Reg addresses
regdat=[1 17 59 148 23 2 80 20 192 18 2 1 0 0 0 0 0 0]; % Reg contents

%% Open serial port
sport=LDC1000_open('COM3',5); % Modify serial port as needed
V=LDC1000_version(sport); % read version info
fset=LDC1000_setsamplerate(sport,10000); % set sample rate to 10000 Hz

%% Diable conversion (standby) to enable reg writes
w1=LDC1000_writereg(sport, 11, 0);

%% read reg contents
for i=1:length(regaddr)
    rreg(i) = LDC1000_readreg(sport, regaddr(i) );
end

%% write reg contents - needed only if reg contents need to be modified
%for i=1:length(regaddr)
%    wreg(i) = LDC1000_writereg(sport, regaddr(i), regdat(i));
%end

%% Enable conversion (active)
w1=LDC1000_writereg(sport, 11, 1);

%% Get data (single shot)
%[Rp, Tp, fig]=LDC1000_streamdata(sport, 0, 2^18, 2^13); % get single shot data of 2^18 samples
[Rp, Tp]=LDC1000_streamdata(sport, 0, 2^10, 2^9);

%% Get data (continous) - press any key when plot window is highlighted to stop acquisition
%[Rp, Tp]=LDC1000_streamdata(sport, 1, 2^18, 2^13); % get data - last 2^18 samples are returned

%% Close serial port
ret=LDC1000_close(sport);

end