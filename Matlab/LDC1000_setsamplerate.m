%> @file  LDC1000_setsamplerate.m
%> @brief Set the sample rate 
%======================================================================
%> @brief Set the sample rate 
%>
%> Actual sample rate depends on MSP430 clock and clock div factor.
%>
%> Example: 
%> @code
%> Fser=LDC1000_SetSamplerate(sport,10000);
%> @endcode
%> set sample rate to 10000 Hz
%>
%> @param sport serial port object
%> @param F Sample rate in Hz
%>
%> @retval Actual sample rate in Hz
%>
%> @remarks
%> The serial port object is removed from the workspace and 
%> deallocated from memory.  This function does not handle errors.
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ Fset ] = LDC1000_setsamplerate(sport,F)

cmd='08';
freq=dec2hex(F,4);
str_t='00';
str=[cmd freq str_t];
%str='08271000';
%disp(str);
fwrite(sport,str);

c=sport.BytesAvailable;
while(c<32)
    c=sport.BytesAvailable;
end
d=fread(sport,c);
T=256*d(9)+d(10);
Fset=24e6/T;
end