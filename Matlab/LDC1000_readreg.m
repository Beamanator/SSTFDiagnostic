%> @file  LDC1000_readreg.m
%> @brief Read register 
%======================================================================
%> @brief Read the contents of a register
%>
%> Example: 
%> @code
%> data=LDC1000_readreg(sport,3);
%> @endcode
%> read the contents of register 3
%>
%> @param sport serial port object
%> @param reg register address in decimal
%>
%> @retval data read in decimal
%>
%> @remarks
%> The serial port object is removed from the workspace and 
%> deallocated from memory.  This function does not handle errors.
%>
%> @sa LDC1000_writereg()
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ data ] = LDC1000_readreg( sport, reg )

cmd='03';
regs=dec2hex(reg,2);
str=[cmd regs '0000'];
fwrite(sport,str);

c=sport.BytesAvailable;
while(c<32)
    c=sport.BytesAvailable;
end
d=fread(sport,c);
data=d(9);
end

