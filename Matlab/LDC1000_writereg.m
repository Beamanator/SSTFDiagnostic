%> @file  LDC1000_writereg.m
%> @brief Write register 
%======================================================================
%> @brief Write register 
%>
%> Write the contents of a register
%>
%> Example: 
%> @code
%> data=LDC1000_writereg(sport,11,0); 
%> @endcode
%> write register 11 with 0, data is data written (expect 0)
%>
%> @param sport serial port object
%> @param reg register address in decimal
%> @param wdata data to write in decimal
%>
%> @retval data written in decimal 
%>
%> @remarks
%> The serial port object is removed from the workspace and 
%> deallocated from memory.  This function does not handle errors.
%>
%> @sa LDC1000_readreg()
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ data ] = LDC1000_writereg(sport, reg, wdata )

cmd='02';
regs=dec2hex(reg,2);
datastr=dec2hex(wdata,2);
str=[cmd regs datastr '00'];
fwrite(sport,str,'uchar');

c=sport.BytesAvailable;
while(c<32)
    c=sport.BytesAvailable;
end
d=fread(sport,c);
data=d(9);
end

