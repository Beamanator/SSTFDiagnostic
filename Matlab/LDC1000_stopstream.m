%> @file  LDC1000_stopstream.m
%> @brief Stop Streaming 
%======================================================================
%> @brief Stop Streaming 
%>
%> Sends command to stop streaming, then flushes the serial 
%> buffer by consuming data.
%>
%> Example: 
%> @code
%> [ dx ] = LDC1000_stopstream(sport );
%> @endcode
%> Stop streaming, delay, then flush serial buffer.
%>
%> @param sport serial port object
%>
%> @retval delay counter index
%>
%> @remarks
%> The serial port object is removed from the workspace and 
%> deallocated from memory.  This function does not handle errors.
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ dx ] = LDC1000_stopstream(sport )

cmd='07';
regs=dec2hex(33,2);
str=[cmd regs '0000'];
fwrite(sport,str);

%% flush the pipe
dx=1;
for i=1:10000
    dx=dx+1;
end
c=sport.BytesAvailable;
if (c>0)
    d=fread(sport,c);
end

end