%> @file  LDC1000_startstream.m
%> @brief Start Streaming 
%======================================================================
%> @brief Start Streaming 
%>
%> Sends command to initiate streaming.
%>
%> Example: 
%> @code
%> [ data ] = LDC1000_startstream(sport );
%> @endcode
%> Start streaming.
%>
%> @param sport serial port object
%>
%> @retval Dummy data (ignored / not used)
%>
%> @remarks
%> The serial port object is removed from the workspace and 
%> deallocated from memory.  This function does not handle errors.
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ data ] = LDC1000_startstream(sport )

%% flush the pipe
c=sport.BytesAvailable;
if (c>0)
    d=fread(sport,c);
end
    
%% Issue start cmd
cmd='06';
regs=dec2hex(33,2);
str=[cmd regs '0000'];
fwrite(sport,str);

c=sport.BytesAvailable;
while(c<32)
    c=sport.BytesAvailable;
end
d=fread(sport,c);
data=d(9);
%yd=ascii2num_ag(data)
end