%> @file  LDC1000_close.m
%> @brief Close serial port 
%======================================================================
%> @brief Close serial port 
%>
%> Close and free the serial port for access by other programs.
%> 
%> Example: 
%> @code
%> ret=LDC1000_close(sport);
%> @endcode
%>
%> @param sport the serial port object to close
%>
%> @retval 1 if success
%>
%> @remarks
%> The serial port object is removed from the workspace and 
%> deallocated from memory.  This function does not handle errors.
%>
%> @sa LDC1000_open()
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ ret ] = LDC1000_close( sport )

%% close object
%sport.Status
fclose(sport);
delete(sport);
clear sport
ret=1;
end
