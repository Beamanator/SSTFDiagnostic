%> @file  LDC1000_version.m
%> @brief Read firmware version 
%======================================================================
%> @brief Read firmware version 
%>
%> Read the firmware version of the EVM.
%>
%> @n Example: 
%> @code
%> V=LDC1000_version(sport);
%> @endcode
%>
%> @param sport serial port object
%>
%> @retval firmware version array [A B C D]
%>
%> @remarks
%> The serial port object is removed from the workspace and 
%> deallocated from memory.  This function does not handle errors.
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ V ] = LDC1000_version(sport)

cmd='09';
regs=dec2hex(0,2);
str=[cmd regs '0000'];
fwrite(sport,str);

c=sport.BytesAvailable;
while(c<32)
    c=sport.BytesAvailable;
end
d=fread(sport,c);
V=[d(8) d(9) d(10) d(11)];
end