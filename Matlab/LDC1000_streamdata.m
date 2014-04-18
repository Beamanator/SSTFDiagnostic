%> @file  LDC1000_streamdata.m
%> @brief Read Streamed Data 
%======================================================================
%> @brief Read Streamed Data 
%> 
%> Sends command to stop streaming, then flushes the serial 
%> buffer by consuming data.
%>
%> Example: 
%> @code
%> [Rp, T]=LDC1000_streamdata(sport, 0, 2^20, 2^13);
%> @endcode
%> Acquire 2^20 samples of Rp and L. Display 2^13 samples at a time.
%>
%> @param sport serial port object
%> @param mode 1->continous  0-> single shot. If continous mode is selected, 
%>					press any key when the matlab figure (plot) window is selected. This will halt data aquisition
%> @param N number of points to acquire (decimal)
%> @param M number of points to display (decimal)
%>
%> @retval proximity data, frequency counter data
%>
%> @remarks
%> The serial port object is removed from the workspace and 
%> deallocated from memory.  This function does not handle errors.
%======================================================================
%
%   R_0_1
%   Copyright Texas Instruments, Inc
function [ Rp_buf, Tp_buf ] = LDC1000_streamdata(sport, mode, N, M)

global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;

% - removed so data collection is faster process.
%h1=figure(1);
%subplot(3,1,1)
%axis tight
%xlabel('Samples')
%ylabel('Rp')
%subplot(3,1,2)
%axis tight
%xlabel('Samples')
%ylabel('Tp')
%subplot(3,1,3)
%axis tight
%xlabel('Rp')

%ylabel('Tp')

%set(h1, 'KeyPressFcn', @Local_KeyPressFcn)
disp(N);
if(N<2048)
    N=2048; % = 2 ^ 11
end

N=512*ceil(N/512);

Rp_buf=zeros(N,1);
Tp_buf=zeros(N,1);
tmp_buf=Rp_buf;

Rp_plot_buf=zeros(M,1);
Tp_plot_buf=Rp_plot_buf;

d1 = LDC1000_startstream(sport );
dcount=0;
plot_init=1;
acq=1;
while(acq)   
    c=sport.BytesAvailable;
    while(c<1*2048)
        c=sport.BytesAvailable;
    end
    d=fread(sport,2048);
    
    d1=d(1:2:1024);
    d2=d(2:2:1024);
    Rp=d1*256+d2;
    Rp_buf([1:512]'+mod(dcount,N),:)=Rp;
    
    d1=d(1025:2:2048);
    d2=d(1026:2:2048);
    Tp=d1*256+d2;
    Tp_buf([1:512]'+mod(dcount,N),:)=Tp;
    if(plot_init==1)
        Rp_plot_buf(:)=Rp(1);
        Tp_plot_buf(:)=Tp(1);
        plot_init=0;
    end
    Rp_plot_buf(1:(end-512),:)=Rp_plot_buf(513:end,:);
    Rp_plot_buf((end-512+1):end,:)=Rp;
    
    Tp_plot_buf(1:(end-512),:)=Tp_plot_buf(513:end,:);
    Tp_plot_buf((end-512+1):end,:)=Tp;
    
    %figure(1)
    %subplot(3,1,1)
    %plot(Rp_plot_buf);
    
    %subplot(3,1,2)
    %plot(Tp_plot_buf);
    
    %figure(2)
    %subplot(3,1,3)
    %plot(Rp_plot_buf,Tp_plot_buf,'.');
   
    %drawnow;
    dcount=dcount+512;
    %disp(['count=' num2str(dcount)  ' ptr=' num2str(mod(dcount,N))]);
    
    if((mode==0) && dcount>=N)
        acq=0;
    elseif KEY_IS_PRESSED
        acq=0;
    end
end
LDC1000_stopstream(sport );
dcounts=mod(dcount,N);
if(dcounts~=0)
    tmp_buf(1:(end-dcounts),:)=Rp_buf(dcounts+1:end,:);
    tmp_buf((end-dcounts+1):end,:)=Rp_buf(1:dcounts,:);
    Rp_buf=tmp_buf;
    tmp_buf(1:(end-dcounts),:)=Tp_buf(dcounts+1:end,:);
    tmp_buf((end-dcounts+1):end,:)=Tp_buf(1:dcounts,:);
    Tp_buf=tmp_buf;
end
end

%======================================================================
%> @brief Scan for keyboard activity without interrupting event stream.
%> 
%> MATLAB does not have a function that scans for 
%> keyboard activity without interrupting the event stream. 
%>
%> However, if your program involves a figure window, you 
%> can utilize the ‘KeyPressFcn’ property. The 'KeyPressFcn' 
%> is called when a key is pressed with an active figure 
%> window. You can set this function to change the state of 
%> a flag that ends a loop. Copy the following functions to 
%> a MATLAB file, and execute the MATLAB file. 
%>
%> The code will display "looping" in the MATLAB Command 
%> Window until a key is pressed when the figure window is active
%>
%> @param hObject graphics object
%> @param event event that is called, pass in 'KeyPressFcn' for plots
%======================================================================
function Local_KeyPressFcn(hObject, event)
global KEY_IS_PRESSED
KEY_IS_PRESSED = 1;
disp('key is pressed')
end