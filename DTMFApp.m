classdef DTMFApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        Image2                      matlab.ui.control.Image
        cKhaledMahmud2023Label      matlab.ui.control.Label
        Image                       matlab.ui.control.Image
        KeypadPanel                 matlab.ui.container.Panel
        KeyPound                    matlab.ui.control.Button
        Key0                        matlab.ui.control.Button
        Key9                        matlab.ui.control.Button
        Key8                        matlab.ui.control.Button
        Key7                        matlab.ui.control.Button
        Key6                        matlab.ui.control.Button
        Key5                        matlab.ui.control.Button
        Key4                        matlab.ui.control.Button
        Key3                        matlab.ui.control.Button
        Key2                        matlab.ui.control.Button
        KeyAsterisk                 matlab.ui.control.Button
        Key1                        matlab.ui.control.Button
        FreqScaleSlider             matlab.ui.control.Slider
        FreqScaleLabel              matlab.ui.control.Label
        DualToneMultiFrequencyDTMFLabel  matlab.ui.control.Label
        DurationmsecEditField       matlab.ui.control.NumericEditField
        DurationmsecEditFieldLabel  matlab.ui.control.Label
        UIAxesFreq                  matlab.ui.control.UIAxes
        UIAxesTime                  matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        fs % Sampling rate
        keynum  %Selected key number
        keyIndex %Selected key index;    
    end
    
    methods (Access = private)
        
        function updateplot(app)
            %Read the parameters from GUI
            duration=app.DurationmsecEditField.Value/1000; %In msec
           
            amp=0.99;
            
            dtmfFreq=[697 1209; 697 1336; 697 1477; 770 1209; 770 1336; 770 1477; 852 1209; 852 1336; 852 1477; 941 1209; 941 1336; 941 1477; 941 1633];
            app.fs=8000;                                %Sampling rate, 

            
            t = 0:(1/app.fs):(duration-1/app.fs);
            x=amp*(sin(2*pi*dtmfFreq(app.keyIndex,1)*t)+sin(2*pi*dtmfFreq(app.keyIndex,2)*t));
            sound(x, app.fs)
            
            
            %Create Frequency sprectrum of the time signal above
            n = length(x);                          %No of time samples
            Y = fft(x);                             
            Y = fftshift(Y);                        %zero-centered spectrum
            fshift = (-n/2:n/2-1)*(app.fs/n);           %zero-centered frequency range (X-axis)
            Y = (abs(Y))/n;                         %Y-axis
            
            plot(app.UIAxesTime, t, x);             %Time Domain plot
            app.UIAxesTime.Title.String= "Time Domain, Key: "+ app.keynum;
            plot(app.UIAxesFreq, fshift(n/2+1:n), Y(n/2+1:n));%Frequency domain plot, only +ve freq
            app.UIAxesFreq.XLim=[0 app.fs/2];
        end
        
        
    end
    
    methods (Access = public)
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.fs=8000;
        end

        % Value changed function: FreqScaleSlider
        function FreqScaleSliderValueChanged(app, event)
            value = app.FreqScaleSlider.Value*app.fs/2/100;
            %Adjust the Spectrum limit to this value 
            app.UIAxesFreq.XLim=[0,value];
        end

        % Button pushed function: Key0, Key1, Key2, Key3, Key4, Key5, 
        % ...and 6 other components
        function Key1ButtonPushed(app, event)
            app.keynum=event(1).Source(1).Tag;
            app.keyIndex=str2double(app.keynum);
            updateplot(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 779 659];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesTime
            app.UIAxesTime = uiaxes(app.UIFigure);
            title(app.UIAxesTime, 'Time Domain')
            xlabel(app.UIAxesTime, 'Time, sec')
            ylabel(app.UIAxesTime, 'Amplitude (V)')
            zlabel(app.UIAxesTime, 'Z')
            app.UIAxesTime.XGrid = 'on';
            app.UIAxesTime.YGrid = 'on';
            app.UIAxesTime.Position = [190 347 570 230];

            % Create UIAxesFreq
            app.UIAxesFreq = uiaxes(app.UIFigure);
            title(app.UIAxesFreq, 'Frequency Domain')
            xlabel(app.UIAxesFreq, 'Frequency (Hz)')
            ylabel(app.UIAxesFreq, 'Power (W)')
            zlabel(app.UIAxesFreq, 'Z')
            app.UIAxesFreq.PlotBoxAspectRatio = [3.62921348314607 1 1];
            app.UIAxesFreq.XGrid = 'on';
            app.UIAxesFreq.YGrid = 'on';
            app.UIAxesFreq.Position = [190 114 570 230];

            % Create DurationmsecEditFieldLabel
            app.DurationmsecEditFieldLabel = uilabel(app.UIFigure);
            app.DurationmsecEditFieldLabel.HorizontalAlignment = 'right';
            app.DurationmsecEditFieldLabel.Position = [18 349 90 22];
            app.DurationmsecEditFieldLabel.Text = 'Duration (msec)';

            % Create DurationmsecEditField
            app.DurationmsecEditField = uieditfield(app.UIFigure, 'numeric');
            app.DurationmsecEditField.Limits = [1 250];
            app.DurationmsecEditField.Position = [117 349 41 22];
            app.DurationmsecEditField.Value = 100;

            % Create DualToneMultiFrequencyDTMFLabel
            app.DualToneMultiFrequencyDTMFLabel = uilabel(app.UIFigure);
            app.DualToneMultiFrequencyDTMFLabel.FontSize = 16;
            app.DualToneMultiFrequencyDTMFLabel.FontWeight = 'bold';
            app.DualToneMultiFrequencyDTMFLabel.FontColor = [0.6353 0.0784 0.1843];
            app.DualToneMultiFrequencyDTMFLabel.Position = [180 619 285 22];
            app.DualToneMultiFrequencyDTMFLabel.Text = 'Dual Tone Multi Frequency (DTMF)';

            % Create FreqScaleLabel
            app.FreqScaleLabel = uilabel(app.UIFigure);
            app.FreqScaleLabel.HorizontalAlignment = 'right';
            app.FreqScaleLabel.Position = [439 26 86 21];
            app.FreqScaleLabel.Text = 'Freq Scale (%)';

            % Create FreqScaleSlider
            app.FreqScaleSlider = uislider(app.UIFigure);
            app.FreqScaleSlider.MajorTicks = [1 10 20 30 40 50 60 70 80 90 100];
            app.FreqScaleSlider.ValueChangedFcn = createCallbackFcn(app, @FreqScaleSliderValueChanged, true);
            app.FreqScaleSlider.MinorTicks = [];
            app.FreqScaleSlider.Position = [235 90 504 7];
            app.FreqScaleSlider.Value = 100;

            % Create KeypadPanel
            app.KeypadPanel = uipanel(app.UIFigure);
            app.KeypadPanel.ForegroundColor = [0.0196 0.2549 0.4118];
            app.KeypadPanel.Title = 'Keypad';
            app.KeypadPanel.BackgroundColor = [0.7098 0.7333 0.7882];
            app.KeypadPanel.FontWeight = 'bold';
            app.KeypadPanel.Position = [18 383 140 184];

            % Create Key1
            app.Key1 = uibutton(app.KeypadPanel, 'push');
            app.Key1.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key1.Tag = '1';
            app.Key1.Position = [14 124 29 27];
            app.Key1.Text = '1';

            % Create KeyAsterisk
            app.KeyAsterisk = uibutton(app.KeypadPanel, 'push');
            app.KeyAsterisk.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.KeyAsterisk.Tag = '10';
            app.KeyAsterisk.Position = [14 12 29 27];
            app.KeyAsterisk.Text = '*';

            % Create Key2
            app.Key2 = uibutton(app.KeypadPanel, 'push');
            app.Key2.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key2.Tag = '2';
            app.Key2.Position = [50 124 29 27];
            app.Key2.Text = '2';

            % Create Key3
            app.Key3 = uibutton(app.KeypadPanel, 'push');
            app.Key3.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key3.Tag = '3';
            app.Key3.Position = [90 124 29 27];
            app.Key3.Text = '3';

            % Create Key4
            app.Key4 = uibutton(app.KeypadPanel, 'push');
            app.Key4.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key4.Tag = '4';
            app.Key4.Position = [14 87 29 27];
            app.Key4.Text = '4';

            % Create Key5
            app.Key5 = uibutton(app.KeypadPanel, 'push');
            app.Key5.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key5.Tag = '5';
            app.Key5.Position = [50 87 29 27];
            app.Key5.Text = '5';

            % Create Key6
            app.Key6 = uibutton(app.KeypadPanel, 'push');
            app.Key6.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key6.Tag = '6';
            app.Key6.Position = [90 87 29 27];
            app.Key6.Text = '6';

            % Create Key7
            app.Key7 = uibutton(app.KeypadPanel, 'push');
            app.Key7.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key7.Tag = '7';
            app.Key7.Position = [14 50 29 27];
            app.Key7.Text = '7';

            % Create Key8
            app.Key8 = uibutton(app.KeypadPanel, 'push');
            app.Key8.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key8.Tag = '8';
            app.Key8.Position = [50 50 29 27];
            app.Key8.Text = '8';

            % Create Key9
            app.Key9 = uibutton(app.KeypadPanel, 'push');
            app.Key9.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key9.Tag = '9';
            app.Key9.Position = [90 50 29 27];
            app.Key9.Text = '9';

            % Create Key0
            app.Key0 = uibutton(app.KeypadPanel, 'push');
            app.Key0.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.Key0.Tag = '11';
            app.Key0.Position = [50 12 29 27];
            app.Key0.Text = '0';

            % Create KeyPound
            app.KeyPound = uibutton(app.KeypadPanel, 'push');
            app.KeyPound.ButtonPushedFcn = createCallbackFcn(app, @Key1ButtonPushed, true);
            app.KeyPound.Tag = '12';
            app.KeyPound.Position = [90 12 29 27];
            app.KeyPound.Text = '#';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [171 0 24 567];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'img', 'vline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [18 14 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [18 584 753 27];
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DTMFApp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end