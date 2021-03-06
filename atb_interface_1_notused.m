function varargout = atb_interface_1(varargin)
% ATB_INTERFACE_1 MATLAB code for atb_interface_1.fig
%      ATB_INTERFACE_1, by itself, creates a new ATB_INTERFACE_1 or raises the existing
%      singleton*.
%
%      H = ATB_INTERFACE_1 returns the handle to a new ATB_INTERFACE_1 or the handle to
%      the existing singleton*.
%
%      ATB_INTERFACE_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ATB_INTERFACE_1.M with the given input arguments.
%
%      ATB_INTERFACE_1('Property','Value',...) creates a new ATB_INTERFACE_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before atb_interface_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to atb_interface_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help atb_interface_1

% Last Modified by GUIDE v2.5 01-Jun-2022 15:36:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @atb_interface_1_OpeningFcn, ...
                   'gui_OutputFcn',  @atb_interface_1_OutputFcn, ...
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

function update_ui(handles)
%% UI Update Function
% Updates the figure and table for any user action
% To add new actions, append a new case with the matching command string. A
% new row will be added to the table with text defined in "string". Append
% XYZ positions after x_pos, y_pos, and z_pos to add a new line element in
% the figure.
% To add text to the figure, add the command to the "if ismember..."
% statement.
num_rows = size(handles.cmd_list);  % Get the number of commands
num_rows = num_rows(1);

tab_text = cell(num_rows, 1);       % Initialize the cell array for table
x_pos = 0;  % Initial X position
y_pos = 0;  % Initial Y position
z_pos = 0;  % Initial Z position

x_text = [];    % Initialize X position for text
y_text = [];    % Initialize Y position for text
z_text = [];    % Initialize Z position for text
fig_text = {};  % Cell array for text

fr_xpos = 0;
fr_ypos = 0;
fr_zpos = 0;
all_x = 0;
all_y = 0;
all_z = 0;

% Iterate through all actions/rows

for i = 1:num_rows
    data = handles.cmd_list{i,2};   % Command data is stored in 2nd column
    
    % Add actions to the switch-case below:
    switch handles.cmd_list{i, 1}   % command name is stored in 1st column
        case 'MOVETO'
            string = sprintf('Move to X%.2f Y%.2f Z%.2f at %.2f mm/s', ...
                data.x, data.y, data.z, data.f);
            x_pos = [x_pos; data.x];
            y_pos = [y_pos; data.y];
            z_pos = [z_pos; data.z];
  
            fr_xpos = data.x;
            fr_ypos = data.y;
            fr_zpos = data.z;
            all_x = [all_x,data.x];
            all_y = [all_y,data.y];
            all_z = [all_z,data.z];

        case 'INC'
            string = sprintf('Increment by X%.2f Y%.2f Z%.2f at %.2f mm/s', ...
                data.x, data.y, data.z, data.f);
            x_pos = [x_pos; x_pos(end)+data.x];
            y_pos = [y_pos; y_pos(end)+data.y];
            z_pos = [z_pos; z_pos(end)+data.z];
         
            all_x = [all_x,all_x(end)+data.x];
            all_y = [all_y,all_y(end)+data.y];
            all_z = [all_z,all_z(end)+data.z];
            fr_xpos = all_x(end);
            fr_ypos = all_y(end);
            fr_zpos = all_z(end);
        
        case 'WAIT'
            string = sprintf('Wait for %.2f s', data.duration);
        case 'START_SAVE'
            string = 'Start save';
        case 'SAVE_NEWNAME'
            string = 'Start save with new name';
        case 'STOP_SAVE'
            string = 'Stop save';
        case 'ZERO'
            string = 'Zero DTB at current location';
        case 'WAITUSER'
            string = 'Wait for user (Press "Continue" to resume)';
    end
    
    if fr_xpos <= -3
        errordlg('Error! Command brings samples out of bounds on x value, please adjust command accordingly');
    elseif fr_ypos >= 3
        errordlg('Error! Command brings samples out of bounds on y value, please adjust command accordingly');
    elseif fr_zpos <= -3
        errordlg('Error! Command brings samples out of bounds on x value, please adjust command accordingly');
    end
    

    % Add action names to this if statement for text on figure:
    if ismember(handles.cmd_list{i, 1}, {'WAIT', 'WAIT_MOVE', ...
            'START_SAVE', 'STOP_SAVE'})
        x_text = [x_text; x_pos(end)];
        y_text = [y_text; y_pos(end)];
        z_text = [z_text; z_pos(end)];
        fig_text = [fig_text; ['   ' string]];
    end
    tab_text{i} = string;

end
set(handles.uitable1, 'Data', tab_text);    % Display text on table

cla(handles.axes1);         % Clear the figure
[Z, Y, X] = cylinder(2.5);  % 2.5mm diameter cylinder for vessel representation
surf(handles.axes1, X.*100,Y,Z, 'FaceColor', 'r', 'FaceAlpha', 0.7)
axis(handles.axes1, 'equal')    % Make axis aspect ratios equal
xlabel(handles.axes1, 'X (mm)')
ylabel(handles.axes1, 'Z (mm)')
zlabel(handles.axes1, 'Y (mm)')
set (handles.axes1, 'xdir', 'reverse')  % Draw X in reverse to match DTB
hold(handles.axes1, 'on')

plot3(x_pos, z_pos, y_pos, '-ok', 'LineWidth', 2);  % Plot lines

text(x_text, z_text, y_text, fig_text); % Add text

function add_cmd(cmd, data, hObject, handles)
%% Add command function
% Adds a command to the appropriate spot in the command list

if ~isempty(handles.cmd_list)   % If the list is not empty
    current_row = handles.uitable1.UserData.SelectedRow(end);   % Find the current selected row in the table
    num_rows = size(handles.cmd_list);  % Find the total number of rows
    num_rows = num_rows(1);
    if current_row == -1 || current_row == num_rows     % If no rows are selected, or the last row is selected
        handles.cmd_list(end+1,:) = {cmd, data};        % Append the new command to the end of the table
    else
        handles.cmd_list(current_row+2:end+1, :) = ...  % Otherwise, shift all rows below the selected row down by 1
            handles.cmd_list(current_row+1:end, :);     % and insert the new command in the middle
        handles.cmd_list(current_row+1, :) = {cmd, data};
    end
else
        handles.cmd_list = {cmd, data}; % Initialize the command list if it is empty
end
update_ui(handles)          % Update the UI
guidata(hObject, handles)   % Update handles

% --- Executes just before atb_interface_1 is made visible.
function atb_interface_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to atb_interface_1 (see VARARGIN)

% Choose default command line output for atb_interface_1
%handles.output = hObject;
main_fig = varargin{1};

% Update handles structure
guidata(hObject, handles);

% Initialize the outputs, command list, and UI
handles.output = [];
handles.cmd_list = [];
update_ui(handles);

% Initialize the UDP port for the DTB
%% update for raspberry pi
handles.dtb = udp('192.168.1.93', 65494);
handles.dtb.OutputBufferSize = 16192;
handles.dtb.OutputDatagramPacketSize = 16192;
fopen(handles.dtb);

% Initialize keyboard enable state
handles.keyboard_enabled = 0;

% Initialize the jog step size
handles.step = 0;
set(handles.step_text, 'String', sprintf('Step Size: %.2f', handles.step));

handles.update_timer = timer('TimerFcn', {@coords_update,handles,main_fig}, 'ExecutionMode', 'fixedDelay', 'Period', 0.5);
handles.update_timer.start()
% Update handles structure
guidata(hObject, handles);
uiwait(hObject);

% UIWAIT makes atb_interface_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = atb_interface_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject, handles)
delete(hObject);

% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Data', cell(0));
hObject.Units = 'pixels';
hObject.ColumnWidth{1} = hObject.Position(3)-25;
hObject.UserData.SelectedRow = -1;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
%% Popup menu selection callback
% Handles what happens when a user selects a command. Add the response to a
% selection/ any additional info gathering here.


% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

contents = cellstr(get(hObject,'String'));
selection = contents{get(hObject,'Value')};

% Add new case statements here for new commands. The case expressions are
% the dropdown list elements, indexed in order. 
switch selection
    case contents{1} % Move to
    % update to new starting position for the HSI test bed
        coords = inputdlg({'X (mm)', 'Y (mm)', 'Z (mm)', 'Speed (mm/s)'}, 'Move to...',[1,15],{'40','-62','22,','270'});%% Giselle Addition
        try
            coords = cellfun(@str2double, coords);
        catch
            errordlg('Enter numbers only')
            return
        end
        
        if isempty(coords)
            return
        end
        
        data.x = coords(1);
        data.y = coords(2);
        data.z = coords(3);
        data.f = coords(4);
        add_cmd('MOVETO', data, hObject, handles);
    case contents{2} % Increment by
        coords = inputdlg({'X (mm)', 'Y (mm)', 'Z (mm)', 'Speed (mm/s)'}, 'Increment by...',[1,15],{'0','0','0,','270'}); %% Giselle Addition
        try
            coords = cellfun(@str2double, coords);
        catch
            errordlg('Enter numbers only')
            return
        end
        
        if isempty(coords)
            return
        end
        
        data.x = coords(1);
        data.y = coords(2);
        data.z = coords(3);
        data.f = coords(4);
        add_cmd('INC', data, hObject, handles); %% calls add comd
    case contents{3} % Wait for
        duration = inputdlg({'Time to wait (s)'}, 'Wait for...');
        try
            duration = str2double(duration{1});
        catch
            if isempty(duration)
                return
            end
            errordlg('Enter numbers only')
            return
        end
        
        data.duration = duration;
        add_cmd('WAIT', data, hObject, handles);
    case contents{4} % WAITUSER
        add_cmd('WAITUSER', [], hObject, handles);
    case contents{5} % Start datasave
        add_cmd('START_SAVE', [], hObject, handles);
    case contents{6} % Save with new name
        add_cmd('SAVE_NEWNAME', [], hObject, handles);
    case contents{7} % Stop datasave
        add_cmd('STOP_SAVE', [], hObject, handles);
    case contents{8} % Zero DTB
        add_cmd('ZERO', [], hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.UserData = {'Move to...', 'Increment by...', 'Wait for...', 'Wait for user', ...
                    'Start datasave', 'Save with new name', 'Stop datasave', 'Zero DTB'};
hObject.String = hObject.UserData;


% --- Executes on button press in remove_action.
function remove_action_Callback(hObject, eventdata, handles)
% hObject    handle to remove_action (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
remove_index = handles.uitable1.UserData.SelectedRow;
handles.cmd_list(remove_index, :) = []; 
guidata(hObject, handles);
update_ui(handles);

% --- Executes on button press in duplicate_action.
function duplicate_action_Callback(hObject, eventdata, handles)
% hObject    handle to duplicate_action (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
reps = inputdlg({'Number of duplicates:'}, 'Duplicate');
try
    reps = floor(str2double(reps{1}));
catch
    errordlg('Enter integers only')
    return
end
duplicate_index = handles.uitable1.UserData.SelectedRow;
duplicates = repmat(handles.cmd_list(duplicate_index,:), reps, 1);
handles.cmd_list = [handles.cmd_list; duplicates];
guidata(hObject, handles);
update_ui(handles);

% --- Executes on button press in pushbutton3
%save button mislabled as pushbutton 3 oops

function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, dir] = uiputfile('.mat', 'Save Profile...');

if file
    data = handles.cmd_list;
    save(fullfile(dir, file), 'data')
end


% --- Executes on button press in load_profile.
function load_profile_Callback(hObject, eventdata, handles)
% hObject    handle to load_profile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, dir] = uigetfile('.mat', 'Load Profile...');

if file
    data = load(fullfile(dir, file));
    handles.cmd_list = data.data;
    try
        update_ui(handles)
        guidata(hObject, handles);
    catch
        errordlg('Not a valid profile!')
    end
end


% --- Executes on button press in run_program.
function run_program_Callback(hObject, eventdata, handles)
% hObject    handle to run_program (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
instructions.commands = handles.cmd_list(:,1);
instructions.fields = handles.cmd_list(:,2);

packet = jsonencode(instructions);
fwrite(handles.dtb, packet);


% --- Executes on button press in home_btn.
function home_btn_Callback(hObject, eventdata, handles)
% hObject    handle to home_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fwrite(handles.dtb, "HOME");

% --- Executes on button press in x_neg.
function x_neg_Callback(hObject, eventdata, handles)
% hObject    handle to x_neg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(handles.dtb, "JOG,%.2f,0,0",-handles.step);

% --- Executes on button press in x_pos.
function x_pos_Callback(hObject, eventdata, handles)
% hObject    handle to x_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(handles.dtb, "JOG,%.2f,0,0",handles.step);

% --- Executes on button press in y_pos.
function y_pos_Callback(hObject, eventdata, handles)
% hObject    handle to y_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(handles.dtb, "JOG,0,%.2f,0",handles.step);

% --- Executes on button press in y_neg.
function y_neg_Callback(hObject, eventdata, handles)
% hObject    handle to y_neg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(handles.dtb, "JOG,0,%.2f,0",-handles.step);

% --- Executes on button press in zero_btn.
function zero_btn_Callback(hObject, eventdata, handles)
% hObject    handle to zero_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fwrite(handles.dtb, "ZERO");

% --- Executes on button press in pause_btn.
function pause_btn_Callback(hObject, eventdata, handles)
% hObject    handle to pause_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fwrite(handles.dtb, "PAUSE");

% --- Executes on button press in continue_btn.
function continue_btn_Callback(hObject, eventdata, handles)
% hObject    handle to continue_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fwrite(handles.dtb, "CONTINUE");

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.step = get(hObject, 'Value');
set(handles.step_text, 'String', sprintf('Step Size: %.2f', handles.step));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in resume_btn.
function resume_btn_Callback(hObject, eventdata, handles)
% hObject    handle to resume_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fwrite(handles.dtb, "RESUME");

% --- Executes on button press in stop_btn.
function stop_btn_Callback(hObject, eventdata, handles)
% hObject    handle to stop_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fwrite(handles.dtb, "STOP");

% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
handles.remove_button.Enable = 'on';
handles.duplicate_button.Enable = 'on';

if ~isempty(eventdata.Indices)
    hObject.UserData.SelectedRow = eventdata.Indices(:,1);
else
    hObject.UserData.SelectedRow = -1;
    handles.remove_button.Enable = 'off';
    handles.duplicate_button.Enable = 'off';
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
