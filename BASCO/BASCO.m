function varargout = BASCO(varargin)
% BetA-Series COrrelation
% 1) ROI-based whole brain network analysis (ROI-ROI correlation)
% 2) seed based functional connectivity, i.e. ROI-voxel correlation (Rissmann)
% 3) voxel degree centrality maps

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BASCO_OpeningFcn, ...
    'gui_OutputFcn',  @BASCO_OutputFcn, ...
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

end

