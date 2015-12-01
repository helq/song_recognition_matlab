function Spectrogram(a, f)
% SPECTROGRAM MATLAB code for Spectrogram.fig
%      SPECTROGRAM, by itself, creates a new SPECTROGRAM or raises the existing
%      singleton*.
%
%      H = SPECTROGRAM returns the handle to a new SPECTROGRAM or the handle to
%      the existing singleton*.
%
%      SPECTROGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTROGRAM.M with the given input arguments.
%
%      SPECTROGRAM('Property','Value',...) creates a new SPECTROGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Spectrogram_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Spectrogram_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Spectrogram

% Last Modified by GUIDE v2.5 30-Nov-2015 23:26:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Spectrogram_OpeningFcn, ...
                   'gui_OutputFcn',  @Spectrogram_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);

global audio;
global fs;
audio = a;
fs = f;

%if nargin && ischar(varargin{1})
%    gui_State.gui_Callback = str2func(varargin{1});
%end
%
%if nargout
%    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
%else
    gui_mainfcn(gui_State, {});
%end
% End initialization code - DO NOT EDIT


% --- Executes just before Spectrogram is made visible.
function Spectrogram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Spectrogram (see VARARGIN)

% Choose default command line output for Spectrogram
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global audio;
global fs;

% plot muestra
t = 0 : 1/fs : length(audio)/fs;
t = t(1:length(audio));

plot(handles.muestra_axes, t, audio);

% plot huella
h = huella();

intervalo_frecuencia = 5;
[y, ~, t] = h.spectrogram(audio, fs, intervalo_frecuencia);
song_h = h.get_huella(y, intervalo_frecuencia);

for i=1:size(song_h,1) % por cada nivel de frecuencias
    scatter(handles.cancion_axes, t, song_h(i,:), '.');
    if i ~= size(song_h,1)
        hold on;
    end
end
axis([0 t(end) -inf inf]);
xlabel('Tiempo (segs)');
ylabel('Frecuencia (KHz)');
grid on;
hold off;

% UIWAIT makes Spectrogram wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Spectrogram_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in back_spectogram_button.
function back_spectogram_button_Callback(hObject, eventdata, handles)
% hObject    handle to back_spectogram_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(Spectrogram);
Interface;
