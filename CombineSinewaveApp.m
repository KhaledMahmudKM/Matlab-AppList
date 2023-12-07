classdef CombineSinewaveApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        cKhaledMahmud2023Label      matlab.ui.control.Label
        Image                       matlab.ui.control.Image
        CombiningSineWavesTimeandFrequencyViewLabel  matlab.ui.control.Label
        DisplayParametersPanel      matlab.ui.container.Panel
        DurationEditField           matlab.ui.control.NumericEditField
        DurationEditFieldLabel      matlab.ui.control.Label
        SamplingRateEditField       matlab.ui.control.NumericEditField
        SamplingRateEditFieldLabel  matlab.ui.control.Label
        WaveComponentsPanel         matlab.ui.container.Panel
        FrequencyLabel              matlab.ui.control.Label
        AmplitudeLabel              matlab.ui.control.Label
        Showf3CheckBox              matlab.ui.control.CheckBox
        a3Spinner                   matlab.ui.control.Spinner
        a3SpinnerLabel              matlab.ui.control.Label
        f3Spinner                   matlab.ui.control.Spinner
        f3SpinnerLabel              matlab.ui.control.Label
        Showf2CheckBox              matlab.ui.control.CheckBox
        Showf1CheckBox              matlab.ui.control.CheckBox
        f2Spinner                   matlab.ui.control.Spinner
        f2SpinnerLabel              matlab.ui.control.Label
        f1Spinner                   matlab.ui.control.Spinner
        f1SpinnerLabel              matlab.ui.control.Label
        a2Spinner                   matlab.ui.control.Spinner
        a2SpinnerLabel              matlab.ui.control.Label
        a1Spinner                   matlab.ui.control.Spinner
        a1SpinnerLabel              matlab.ui.control.Label
        UIAxesFreq                  matlab.ui.control.UIAxes
        UIAxesTime                  matlab.ui.control.UIAxes
    end

    
    methods (Access = private)
        
        function updateplot(app)
            %Read dispaly parameters
            
            fs=app.SamplingRateEditField.Value;          
            duration=app.DurationEditField.Value;
            
            % Read signal parameters
            a1=app.a1Spinner.Value;
            f1=app.f1Spinner.Value;
            showf1=app.Showf1CheckBox.Value;
            
             % Read signal parameters
            a2=app.a2Spinner.Value;
            f2=app.f2Spinner.Value;
            showf2=app.Showf2CheckBox.Value;
            
            % Read signal parameters
            a3=app.a3Spinner.Value;
            f3=app.f3Spinner.Value;
            showf3=app.Showf3CheckBox.Value;            
            
            %Create time signals            
            t = 0:(1/fs):(duration-1/fs);           %Time vector (X-axis)
            
            s1 = a1*sin(2*pi*f1*t)*showf1;          %Amplitude vector of sine wave (Y-axis)
            s2 = a2*sin(2*pi*f2*t)*showf2;
            s3 = a3*sin(2*pi*f3*t)*showf3;
            sSum=s1+s2+s3;
            
            %Create Frequency sprectrum of the time signal above
            n = length(sSum);                          %No of time samples
            Y = fft(sSum);                             
            Y = fftshift(Y);                        %zero-centered spectrum
            fScale = (-n/2:n/2-1)*(fs/n);              % zero-centered frequency range (X-axis)
            P = (abs(Y).^2/n)/n;                    % zero-centered power (Y-axis)
            
            plot(app.UIAxesTime, t, sSum);             %Time Domain plot
            plot(app.UIAxesFreq, fScale(n/2+1:n),P(n/2+1:n));%Frequency domain plot
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            updateplot(app);
        end

        % Callback function
        function AmplitudeSliderValueChanged(app, event)
            %Read Amplitude value, round to integer, set the Amplitude label
            app.LabelAmp.Text=num2str(round(app.AmplitudeSlider.Value));
            updateplot(app);
            
        end

        % Callback function
        function FrequencySliderValueChanged(app, event)
            %Read Freq value, round to integer, set the Frequency label 
            app.LabelFreq.Text= num2str(round(app.FrequencySlider.Value));
            updateplot(app);
            
        end

        % Value changed function: DurationEditField
        function DurationEditFieldValueChanged(app, event)
             updateplot(app);
            
        end

        % Value changed function: SamplingRateEditField
        function SamplingRateEditFieldValueChanged(app, event)
             updateplot(app);
            
        end

        % Value changed function: f1Spinner
        function f1SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: f2Spinner
        function f2SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: f3Spinner
        function f3SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: a1Spinner
        function a1SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: a2Spinner
        function a2SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: a3Spinner
        function a3SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: Showf1CheckBox
        function Showf1CheckBoxValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: Showf2CheckBox
        function Showf2CheckBoxValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: Showf3CheckBox
        function Showf3CheckBoxValueChanged(app, event)
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
            app.UIFigure.Position = [100 100 773 735];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesTime
            app.UIAxesTime = uiaxes(app.UIFigure);
            title(app.UIAxesTime, 'Combined Signals, Time Domain')
            xlabel(app.UIAxesTime, 'Time, sec')
            ylabel(app.UIAxesTime, 'Amplitude (V)')
            zlabel(app.UIAxesTime, 'Z')
            app.UIAxesTime.Color = [0.9882 1 0.8784];
            app.UIAxesTime.GridColor = [0.502 0.502 0.502];
            app.UIAxesTime.XGrid = 'on';
            app.UIAxesTime.YGrid = 'on';
            app.UIAxesTime.Position = [39 275 701 234];

            % Create UIAxesFreq
            app.UIAxesFreq = uiaxes(app.UIFigure);
            title(app.UIAxesFreq, 'Frequency Domain')
            xlabel(app.UIAxesFreq, 'Frequency (Hz)')
            ylabel(app.UIAxesFreq, 'Power (W)')
            zlabel(app.UIAxesFreq, 'Z')
            app.UIAxesFreq.XGrid = 'on';
            app.UIAxesFreq.YGrid = 'on';
            app.UIAxesFreq.Position = [41 27 693 232];

            % Create WaveComponentsPanel
            app.WaveComponentsPanel = uipanel(app.UIFigure);
            app.WaveComponentsPanel.ForegroundColor = [0 0.4471 0.7412];
            app.WaveComponentsPanel.Title = 'Wave Components';
            app.WaveComponentsPanel.FontWeight = 'bold';
            app.WaveComponentsPanel.Position = [39 528 342 142];

            % Create a1SpinnerLabel
            app.a1SpinnerLabel = uilabel(app.WaveComponentsPanel);
            app.a1SpinnerLabel.HorizontalAlignment = 'right';
            app.a1SpinnerLabel.Position = [11 70 25 22];
            app.a1SpinnerLabel.Text = 'a1';

            % Create a1Spinner
            app.a1Spinner = uispinner(app.WaveComponentsPanel);
            app.a1Spinner.Limits = [1 100];
            app.a1Spinner.ValueChangedFcn = createCallbackFcn(app, @a1SpinnerValueChanged, true);
            app.a1Spinner.Position = [39 70 68 22];
            app.a1Spinner.Value = 10;

            % Create a2SpinnerLabel
            app.a2SpinnerLabel = uilabel(app.WaveComponentsPanel);
            app.a2SpinnerLabel.HorizontalAlignment = 'right';
            app.a2SpinnerLabel.Position = [11 38 25 22];
            app.a2SpinnerLabel.Text = 'a2';

            % Create a2Spinner
            app.a2Spinner = uispinner(app.WaveComponentsPanel);
            app.a2Spinner.Limits = [1 100];
            app.a2Spinner.ValueChangedFcn = createCallbackFcn(app, @a2SpinnerValueChanged, true);
            app.a2Spinner.Position = [40 38 67 22];
            app.a2Spinner.Value = 7;

            % Create f1SpinnerLabel
            app.f1SpinnerLabel = uilabel(app.WaveComponentsPanel);
            app.f1SpinnerLabel.HorizontalAlignment = 'right';
            app.f1SpinnerLabel.Position = [122 70 25 22];
            app.f1SpinnerLabel.Text = 'f1';

            % Create f1Spinner
            app.f1Spinner = uispinner(app.WaveComponentsPanel);
            app.f1Spinner.Limits = [1 100];
            app.f1Spinner.ValueChangedFcn = createCallbackFcn(app, @f1SpinnerValueChanged, true);
            app.f1Spinner.Position = [152 70 68 22];
            app.f1Spinner.Value = 1;

            % Create f2SpinnerLabel
            app.f2SpinnerLabel = uilabel(app.WaveComponentsPanel);
            app.f2SpinnerLabel.HorizontalAlignment = 'right';
            app.f2SpinnerLabel.Position = [122 38 25 22];
            app.f2SpinnerLabel.Text = 'f2';

            % Create f2Spinner
            app.f2Spinner = uispinner(app.WaveComponentsPanel);
            app.f2Spinner.Limits = [1 100];
            app.f2Spinner.ValueChangedFcn = createCallbackFcn(app, @f2SpinnerValueChanged, true);
            app.f2Spinner.Position = [152 38 68 22];
            app.f2Spinner.Value = 2;

            % Create Showf1CheckBox
            app.Showf1CheckBox = uicheckbox(app.WaveComponentsPanel);
            app.Showf1CheckBox.ValueChangedFcn = createCallbackFcn(app, @Showf1CheckBoxValueChanged, true);
            app.Showf1CheckBox.Text = 'Show f1';
            app.Showf1CheckBox.Position = [252 69 65 22];
            app.Showf1CheckBox.Value = true;

            % Create Showf2CheckBox
            app.Showf2CheckBox = uicheckbox(app.WaveComponentsPanel);
            app.Showf2CheckBox.ValueChangedFcn = createCallbackFcn(app, @Showf2CheckBoxValueChanged, true);
            app.Showf2CheckBox.Text = 'Show f2';
            app.Showf2CheckBox.Position = [252 38 65 22];

            % Create f3SpinnerLabel
            app.f3SpinnerLabel = uilabel(app.WaveComponentsPanel);
            app.f3SpinnerLabel.HorizontalAlignment = 'right';
            app.f3SpinnerLabel.Position = [124 10 25 22];
            app.f3SpinnerLabel.Text = 'f3';

            % Create f3Spinner
            app.f3Spinner = uispinner(app.WaveComponentsPanel);
            app.f3Spinner.ValueChangedFcn = createCallbackFcn(app, @f3SpinnerValueChanged, true);
            app.f3Spinner.Position = [154 10 66 22];
            app.f3Spinner.Value = 4;

            % Create a3SpinnerLabel
            app.a3SpinnerLabel = uilabel(app.WaveComponentsPanel);
            app.a3SpinnerLabel.HorizontalAlignment = 'right';
            app.a3SpinnerLabel.Position = [11 10 25 22];
            app.a3SpinnerLabel.Text = 'a3';

            % Create a3Spinner
            app.a3Spinner = uispinner(app.WaveComponentsPanel);
            app.a3Spinner.ValueChangedFcn = createCallbackFcn(app, @a3SpinnerValueChanged, true);
            app.a3Spinner.Position = [40 10 68 22];
            app.a3Spinner.Value = 4;

            % Create Showf3CheckBox
            app.Showf3CheckBox = uicheckbox(app.WaveComponentsPanel);
            app.Showf3CheckBox.ValueChangedFcn = createCallbackFcn(app, @Showf3CheckBoxValueChanged, true);
            app.Showf3CheckBox.Text = 'Show f3';
            app.Showf3CheckBox.Position = [252 10 65 22];

            % Create AmplitudeLabel
            app.AmplitudeLabel = uilabel(app.WaveComponentsPanel);
            app.AmplitudeLabel.Position = [24 91 69 22];
            app.AmplitudeLabel.Text = 'Amplitude';

            % Create FrequencyLabel
            app.FrequencyLabel = uilabel(app.WaveComponentsPanel);
            app.FrequencyLabel.Position = [135 91 78 22];
            app.FrequencyLabel.Text = 'Frequency';

            % Create DisplayParametersPanel
            app.DisplayParametersPanel = uipanel(app.UIFigure);
            app.DisplayParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.DisplayParametersPanel.Title = 'Display Parameters';
            app.DisplayParametersPanel.FontWeight = 'bold';
            app.DisplayParametersPanel.Position = [415 580 198 90];

            % Create SamplingRateEditFieldLabel
            app.SamplingRateEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.SamplingRateEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingRateEditFieldLabel.Position = [19 39 84 22];
            app.SamplingRateEditFieldLabel.Text = 'Sampling Rate';

            % Create SamplingRateEditField
            app.SamplingRateEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.SamplingRateEditField.Limits = [10 1000];
            app.SamplingRateEditField.RoundFractionalValues = 'on';
            app.SamplingRateEditField.ValueChangedFcn = createCallbackFcn(app, @SamplingRateEditFieldValueChanged, true);
            app.SamplingRateEditField.Position = [126 39 46 22];
            app.SamplingRateEditField.Value = 20;

            % Create DurationEditFieldLabel
            app.DurationEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.DurationEditFieldLabel.HorizontalAlignment = 'right';
            app.DurationEditFieldLabel.Position = [19 7 51 22];
            app.DurationEditFieldLabel.Text = 'Duration';

            % Create DurationEditField
            app.DurationEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.DurationEditField.Limits = [1 10];
            app.DurationEditField.ValueChangedFcn = createCallbackFcn(app, @DurationEditFieldValueChanged, true);
            app.DurationEditField.Position = [126 7 46 22];
            app.DurationEditField.Value = 5;

            % Create CombiningSineWavesTimeandFrequencyViewLabel
            app.CombiningSineWavesTimeandFrequencyViewLabel = uilabel(app.UIFigure);
            app.CombiningSineWavesTimeandFrequencyViewLabel.FontSize = 16;
            app.CombiningSineWavesTimeandFrequencyViewLabel.FontWeight = 'bold';
            app.CombiningSineWavesTimeandFrequencyViewLabel.FontColor = [0.6353 0.0784 0.1843];
            app.CombiningSineWavesTimeandFrequencyViewLabel.Position = [39 700 394 22];
            app.CombiningSineWavesTimeandFrequencyViewLabel.Text = 'Combining Sine Waves: Time and Frequency View';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [39 679 710 22];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [19 4 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CombineSinewaveApp

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