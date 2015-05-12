function varargout = assignment_GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @assignment_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @assignment_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before assignment_GUI is made visible.
function assignment_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
%disable button
set(handles.btn_replay,'enable','off');
set(handles.btnFilter,'enable','off');
set(handles.btnPlaybackFilterSound,'enable','off');
    

handles.output = hObject;
handles.state = 0;
handles.Fs = 8192;
handles.lowBound = 300
handles.highBound = 3800
global nBits;
nBits = 16;
global recObj;
recObj = audiorecorder(handles.Fs,nBits,1);
set(recObj,'TimerPeriod',0.05,'TimerFcn',{@audioTimerCallback,handles});

xlabel(handles.axeTimeDomain,'Time');
ylabel(handles.axeTimeDomain, 'Amplitude');
xlabel(handles.axesFrequency,'Frequency(Hz)');
ylabel(handles.axesFrequency,'|Y(f)|')
xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
ylabel(handles.axesFrequencyFilter,'|Y(f)|')

% Update handles structure
guidata(hObject, handles);


function audioTimerCallback(hObject,event,handles)
if(isempty(hObject))
    return;
end
signal = getaudiodata(hObject);
plot(handles.axeTimeDomain, signal);

%fft
nfft = 2^nextpow2(length(signal));
fftRecord = fft(signal,nfft);
% f = handles.Fs/2*linspace(0,1,nfft/2+1);
plot(handles.axesFrequency,abs(fftRecord(1:nfft)));


% --- Outputs from this function are returned to the command line.
function varargout = assignment_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnRecord.
function btnRecord_Callback(hObject, eventdata, handles)
%prepare parameter
global recObj;


if handles.state == 0 
    disp('start recording')
    set(hObject,'String','Pause');
    record(recObj);
    handles.state =1 ;
    %disable button
    set(handles.btn_replay,'enable','off');
    set(handles.btnFilter,'enable','off');
    set(handles.btnPlaybackFilterSound,'enable','off');
else
    disp('stop recording')
    set(hObject,'String','Record');
    stop(recObj);
    handles.state = 0;
    
    %enable button
    set(handles.btn_replay,'enable','on');
    set(handles.btnFilter,'enable','on');
    set(handles.btnPlaybackFilterSound,'enable','on');
    xlabel(handles.axeTimeDomain,'Time');
    ylabel(handles.axeTimeDomain, 'Amplitude');
    xlabel(handles.axesFrequency,'Frequency(Hz)');
    ylabel(handles.axesFrequency,'|Y(f)|')
end

guidata(hObject,handles)


% --- Executes on button press in btn_stoprecord.
function btn_stoprecord_Callback(hObject, eventdata, handles)
disp('stop recording')
global recordFlag;
recordFlag = 0;
% global recObj
% stop(recObj);

% --- Executes on button press in btn_replay.
function btn_replay_Callback(hObject, eventdata, handles)

global recObj;
global nBits;
sig = getaudiodata(recObj);
[n m] = size(sig)
load gong.mat;
soundsc(sig, handles.Fs, nBits);
% hObject    handle to btn_replay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnFilter.
function btnFilter_Callback(hObject, eventdata, handles)
global recObj;
sig = getaudiodata(recObj);

lowFreq = 2*(handles.lowBound)/handles.Fs
highFreq = 2*(handles.highBound)/ handles.Fs
n = 10
% [n, Wn] = buttord(3800*2*pi, 4200*2*pi, 3, 55, 'bandpass');
win = fir1(n,[lowFreq highFreq]);
global fOut
fOut = filter(win,1,sig);

%fft
nfft = 2^nextpow2(length(fOut));
fftRecord = fft(fOut,nfft);

plot(handles.axesFrequencyFilter, abs(fftRecord(1:nfft)));
xlabel(handles.axesFrequencyFilter,'Frequency(Hz)');
ylabel(handles.axesFrequencyFilter,'|Y(f)|')

% --- Executes on button press in btnPlaybackFilterSound.
function btnPlaybackFilterSound_Callback(hObject, eventdata, handles)
global fOut
global nBits
load gong.mat;
soundsc(fOut, handles.Fs, nBits);


% --- Executes on button press in btnExit.
function btnExit_Callback(hObject, eventdata, handles)
cl = questdlg('Do you want to EXIT?','EXIT',...
            'Yes','No','No');
switch cl
    case 'Yes'
        close();
        clear all;
        return;
    case 'No'
        quit cancel;
end 


% --- Executes on button press in btnDenoise.
function btnDenoise_Callback(hObject, eventdata, handles)

global recObj;
global nBits;
sig = getaudiodata(recObj);
M = 10;
lambda = (M-1)/M;
h = (1-lambda)*lambda.^(0:100);
filterSound = conv(sig,h,'valid');
load gong.mat;
soundsc(filterSound, handles.Fs, nBits);

plot(handles.axeTimeDomain, sig);
xLim(handles.axeTimeDomain,[1 1000]);

plot(handles.axesFrequency, filterSound);
xLim(handles.axesFrequency,[1 1000]);


% --- Executes on button press in btnPlayDenoise.
function btnPlayDenoise_Callback(hObject, eventdata, handles)
% hObject    handle to btnPlayDenoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
