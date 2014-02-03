%> @file  LDC1000_open.m
%> @brief Open serial port
%======================================================================
%> @brief Open serial port
%>
%> Opens the serial port at the specified port with settings necessary 
%> to communicate with the LDC1000.
%> 
%> Example: 
%> @code
%> sport=LDC1000_open('COM24',5);
%> @endcode
%> open serial port at 'COM24' and set timeout to 5 seconds
%>
%> @param com_port serial port address
%> @param Timeout timeout in seconds
%>
%> @retval serial port object
%>
%> @sa LDC1000_close()
%====================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ sport ] = LDC1000_open( com_port, Timeout )

%% open object
sport = serial(com_port); % assigns the object s to serial port
set(sport, 'RecordDetail', 'verbose')
set(sport, 'InputBufferSize', 64*4096); % number of bytes in input buffer
set(sport, 'OutputBufferSize', 16*4096); % number of bytes in output buffer
set(sport, 'FlowControl', 'software');
set(sport, 'BaudRate', 9600);
set(sport, 'Parity', 'none');
set(sport, 'DataBits', 8);
set(sport, 'StopBit', 1);
set(sport, 'Timeout', Timeout);
set(sport, 'ReadAsyncMode', 'continuous');
%clc;

%% display serial port information 
% disp(get(sport,'Name'));
% prop(1)=(get(sport,'BaudRate'));
% prop(2)=(get(sport,'DataBits'));
% prop(3)=(get(sport,'StopBit'));
% prop(4)=(get(sport,'InputBufferSize'));
% disp(['Port Setup Done!!',num2str(prop)]);
% sport.Status

fopen(sport);           %opens the serial port
end

