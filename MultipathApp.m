classdef MultipathApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        cKhaledMahmud2023Label      matlab.ui.control.Label
        Image                       matlab.ui.control.Image
        DelayedSinewaveMultipathTimeandFrequencyViewLabel  matlab.ui.control.Label
        DisplayParametersPanel      matlab.ui.container.Panel
        FreqEditField               matlab.ui.control.NumericEditField
        FreqEditFieldLabel          matlab.ui.control.Label
        DurationEditField           matlab.ui.control.NumericEditField
        DurationEditFieldLabel      matlab.ui.control.Label
        SamplingRateEditField       matlab.ui.control.NumericEditField
        SamplingRateEditFieldLabel  matlab.ui.control.Label
        WavesPanel                  matlab.ui.container.Panel
        PhasedegLabel               matlab.ui.control.Label
        AmplitudeLabel              matlab.ui.control.Label
        MultipathComponentsLabel    matlab.ui.control.Label
        Shows3CheckBox              matlab.ui.control.CheckBox
        a3Spinner                   matlab.ui.control.Spinner
        a3SpinnerLabel              matlab.ui.control.Label
        ph3Spinner                  matlab.ui.control.Spinner
        ph3SpinnerLabel             matlab.ui.control.Label
        Shows2CheckBox              matlab.ui.control.CheckBox
        Shows1LOSCheckBox           matlab.ui.control.CheckBox
        ph2Spinner                  matlab.ui.control.Spinner
        ph2SpinnerLabel             matlab.ui.control.Label
        ph1Spinner                  matlab.ui.control.Spinner
        ph1SpinnerLabel             matlab.ui.control.Label
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
            freq = app.FreqEditField.Value;
            fs=app.SamplingRateEditField.Value;          
            duration=app.DurationEditField.Value;
            
            % Read signal parameters
            a1=app.a1Spinner.Value;
            %ph1=app.ph1Spinner.Value; %Reference
            shows1=app.Shows1LOSCheckBox.Value;
            
             % Read signal parameters
            a2=app.a2Spinner.Value;
            ph2=app.ph2Spinner.Value;
            shows2=app.Shows2CheckBox.Value;
            
            % Read signal parameters
            a3=app.a3Spinner.Value;
            ph3=app.ph3Spinner.Value;
            shows3=app.Shows3CheckBox.Value;            
            
            %Create time signals            
            t = 0:(1/fs):(duration-1/fs);           %Time vector (X-axis)
            
            s1 = a1*sin(2*pi*freq*t)*shows1;          %Amplitude vector of sine wave (Y-axis)
            s2 = a2*sin(2*pi*freq*t-ph2*pi/180)*shows2;
            s3 = a3*sin(2*pi*freq*t-ph3*pi/180)*shows3;
            sSum=s1+s2+s3;
            
            %Create Frequency sprectrum of the time signal above
            n = length(sSum);                          %No of time samples
            Y = fft(sSum);                             
            Y = fftshift(Y);                        %zero-centered spectrum
            fScale = (-n/2:n/2-1)*(fs/n);              % zero-centered frequency range (X-axis)
            P = (abs(Y).^2/n)/n;                    % zero-centered power (Y-axis)
            
            %Time Domain plot
            hold(app.UIAxesTime,"off" );
            app.UIAxesTime.YLim=[-2*a1, 2*a1];
            plot(app.UIAxesTime, t, s1);
            hold(app.UIAxesTime,"on" );
            plot(app.UIAxesTime, t, s2);
            plot(app.UIAxesTime, t, s3);
            plot(app.UIAxesTime, t, sSum, "LineWidth",2);  
            legend(app.UIAxesTime, "s1", "s2", "s3", "Combined");

            
            %Frequency domain plot
            plot(app.UIAxesFreq, fScale(n/2+1:n),P(n/2+1:n));
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
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

        % Value changed function: ph1Spinner
        function ph1SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: ph2Spinner
        function ph2SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: ph3Spinner
        function ph3SpinnerValueChanged(app, event)
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

        % Value changed function: Shows1LOSCheckBox
        function Shows1LOSCheckBoxValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: Shows2CheckBox
        function Shows2CheckBoxValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: Shows3CheckBox
        function Shows3CheckBoxValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: FreqEditField
        function FreqEditFieldValueChanged(app, event)
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
            app.UIFigure.Position = [100 100 748 835];
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
            app.UIAxesTime.Position = [32 268 692 314];

            % Create UIAxesFreq
            app.UIAxesFreq = uiaxes(app.UIFigure);
            title(app.UIAxesFreq, 'Frequency Domain')
            xlabel(app.UIAxesFreq, 'Frequency (Hz)')
            ylabel(app.UIAxesFreq, 'Power (W)')
            zlabel(app.UIAxesFreq, 'Z')
            app.UIAxesFreq.XGrid = 'on';
            app.UIAxesFreq.YGrid = 'on';
            app.UIAxesFreq.Position = [31 14 693 232];

            % Create WavesPanel
            app.WavesPanel = uipanel(app.UIFigure);
            app.WavesPanel.ForegroundColor = [0 0.4471 0.7412];
            app.WavesPanel.Title = 'Waves';
            app.WavesPanel.FontWeight = 'bold';
            app.WavesPanel.Position = [75 606 398 152];

            % Create a1SpinnerLabel
            app.a1SpinnerLabel = uilabel(app.WavesPanel);
            app.a1SpinnerLabel.HorizontalAlignment = 'right';
            app.a1SpinnerLabel.Position = [147 76 25 22];
            app.a1SpinnerLabel.Text = 'a1';

            % Create a1Spinner
            app.a1Spinner = uispinner(app.WavesPanel);
            app.a1Spinner.Limits = [1 100];
            app.a1Spinner.ValueChangedFcn = createCallbackFcn(app, @a1SpinnerValueChanged, true);
            app.a1Spinner.Enable = 'off';
            app.a1Spinner.Position = [178 76 68 22];
            app.a1Spinner.Value = 10;

            % Create a2SpinnerLabel
            app.a2SpinnerLabel = uilabel(app.WavesPanel);
            app.a2SpinnerLabel.HorizontalAlignment = 'right';
            app.a2SpinnerLabel.Position = [149 48 25 22];
            app.a2SpinnerLabel.Text = 'a2';

            % Create a2Spinner
            app.a2Spinner = uispinner(app.WavesPanel);
            app.a2Spinner.Limits = [1 9];
            app.a2Spinner.ValueChangedFcn = createCallbackFcn(app, @a2SpinnerValueChanged, true);
            app.a2Spinner.Position = [179 48 67 22];
            app.a2Spinner.Value = 7;

            % Create ph1SpinnerLabel
            app.ph1SpinnerLabel = uilabel(app.WavesPanel);
            app.ph1SpinnerLabel.HorizontalAlignment = 'right';
            app.ph1SpinnerLabel.Enable = 'off';
            app.ph1SpinnerLabel.Position = [274 76 26 22];
            app.ph1SpinnerLabel.Text = 'ph1';

            % Create ph1Spinner
            app.ph1Spinner = uispinner(app.WavesPanel);
            app.ph1Spinner.Limits = [0 100];
            app.ph1Spinner.RoundFractionalValues = 'on';
            app.ph1Spinner.ValueChangedFcn = createCallbackFcn(app, @ph1SpinnerValueChanged, true);
            app.ph1Spinner.Editable = 'off';
            app.ph1Spinner.Enable = 'off';
            app.ph1Spinner.Position = [305 76 68 22];

            % Create ph2SpinnerLabel
            app.ph2SpinnerLabel = uilabel(app.WavesPanel);
            app.ph2SpinnerLabel.HorizontalAlignment = 'right';
            app.ph2SpinnerLabel.Position = [274 48 26 22];
            app.ph2SpinnerLabel.Text = 'ph2';

            % Create ph2Spinner
            app.ph2Spinner = uispinner(app.WavesPanel);
            app.ph2Spinner.Step = 10;
            app.ph2Spinner.Limits = [0 359];
            app.ph2Spinner.ValueChangedFcn = createCallbackFcn(app, @ph2SpinnerValueChanged, true);
            app.ph2Spinner.Position = [305 48 68 22];
            app.ph2Spinner.Value = 90;

            % Create Shows1LOSCheckBox
            app.Shows1LOSCheckBox = uicheckbox(app.WavesPanel);
            app.Shows1LOSCheckBox.ValueChangedFcn = createCallbackFcn(app, @Shows1LOSCheckBoxValueChanged, true);
            app.Shows1LOSCheckBox.Text = 'Show s1 (LOS)';
            app.Shows1LOSCheckBox.Position = [14 76 103 22];
            app.Shows1LOSCheckBox.Value = true;

            % Create Shows2CheckBox
            app.Shows2CheckBox = uicheckbox(app.WavesPanel);
            app.Shows2CheckBox.ValueChangedFcn = createCallbackFcn(app, @Shows2CheckBoxValueChanged, true);
            app.Shows2CheckBox.Text = 'Show s2';
            app.Shows2CheckBox.Position = [14 48 68 22];

            % Create ph3SpinnerLabel
            app.ph3SpinnerLabel = uilabel(app.WavesPanel);
            app.ph3SpinnerLabel.HorizontalAlignment = 'right';
            app.ph3SpinnerLabel.Position = [274 18 26 22];
            app.ph3SpinnerLabel.Text = 'ph3';

            % Create ph3Spinner
            app.ph3Spinner = uispinner(app.WavesPanel);
            app.ph3Spinner.Step = 10;
            app.ph3Spinner.Limits = [0 359];
            app.ph3Spinner.ValueChangedFcn = createCallbackFcn(app, @ph3SpinnerValueChanged, true);
            app.ph3Spinner.Position = [305 18 68 22];
            app.ph3Spinner.Value = 180;

            % Create a3SpinnerLabel
            app.a3SpinnerLabel = uilabel(app.WavesPanel);
            app.a3SpinnerLabel.HorizontalAlignment = 'right';
            app.a3SpinnerLabel.Position = [149 18 25 22];
            app.a3SpinnerLabel.Text = 'a3';

            % Create a3Spinner
            app.a3Spinner = uispinner(app.WavesPanel);
            app.a3Spinner.Limits = [1 9];
            app.a3Spinner.ValueChangedFcn = createCallbackFcn(app, @a3SpinnerValueChanged, true);
            app.a3Spinner.Position = [179 18 67 22];
            app.a3Spinner.Value = 4;

            % Create Shows3CheckBox
            app.Shows3CheckBox = uicheckbox(app.WavesPanel);
            app.Shows3CheckBox.ValueChangedFcn = createCallbackFcn(app, @Shows3CheckBoxValueChanged, true);
            app.Shows3CheckBox.Text = 'Show s3';
            app.Shows3CheckBox.Position = [14 18 83 22];

            % Create MultipathComponentsLabel
            app.MultipathComponentsLabel = uilabel(app.WavesPanel);
            app.MultipathComponentsLabel.FontWeight = 'bold';
            app.MultipathComponentsLabel.Position = [15 103 135 22];
            app.MultipathComponentsLabel.Text = 'Multipath Components';

            % Create AmplitudeLabel
            app.AmplitudeLabel = uilabel(app.WavesPanel);
            app.AmplitudeLabel.FontWeight = 'bold';
            app.AmplitudeLabel.Position = [185 103 94 22];
            app.AmplitudeLabel.Text = 'Amplitude';

            % Create PhasedegLabel
            app.PhasedegLabel = uilabel(app.WavesPanel);
            app.PhasedegLabel.FontWeight = 'bold';
            app.PhasedegLabel.Position = [303 101 74 24];
            app.PhasedegLabel.Text = 'Phase (deg)';

            % Create DisplayParametersPanel
            app.DisplayParametersPanel = uipanel(app.UIFigure);
            app.DisplayParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.DisplayParametersPanel.Title = 'Display Parameters';
            app.DisplayParametersPanel.FontWeight = 'bold';
            app.DisplayParametersPanel.Position = [480 606 244 152];

            % Create SamplingRateEditFieldLabel
            app.SamplingRateEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.SamplingRateEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingRateEditFieldLabel.Position = [21 27 84 22];
            app.SamplingRateEditFieldLabel.Text = 'Sampling Rate';

            % Create SamplingRateEditField
            app.SamplingRateEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.SamplingRateEditField.Limits = [10 1000];
            app.SamplingRateEditField.RoundFractionalValues = 'on';
            app.SamplingRateEditField.ValueChangedFcn = createCallbackFcn(app, @SamplingRateEditFieldValueChanged, true);
            app.SamplingRateEditField.Position = [110 27 46 22];
            app.SamplingRateEditField.Value = 20;

            % Create DurationEditFieldLabel
            app.DurationEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.DurationEditFieldLabel.HorizontalAlignment = 'right';
            app.DurationEditFieldLabel.Position = [20 65 51 22];
            app.DurationEditFieldLabel.Text = 'Duration';

            % Create DurationEditField
            app.DurationEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.DurationEditField.Limits = [1 10];
            app.DurationEditField.ValueChangedFcn = createCallbackFcn(app, @DurationEditFieldValueChanged, true);
            app.DurationEditField.Position = [109 65 46 22];
            app.DurationEditField.Value = 5;

            % Create FreqEditFieldLabel
            app.FreqEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.FreqEditFieldLabel.HorizontalAlignment = 'right';
            app.FreqEditFieldLabel.Position = [19 97 30 22];
            app.FreqEditFieldLabel.Text = 'Freq';

            % Create FreqEditField
            app.FreqEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.FreqEditField.Limits = [1 10];
            app.FreqEditField.ValueChangedFcn = createCallbackFcn(app, @FreqEditFieldValueChanged, true);
            app.FreqEditField.Position = [108 97 46 22];
            app.FreqEditField.Value = 1;

            % Create DelayedSinewaveMultipathTimeandFrequencyViewLabel
            app.DelayedSinewaveMultipathTimeandFrequencyViewLabel = uilabel(app.UIFigure);
            app.DelayedSinewaveMultipathTimeandFrequencyViewLabel.FontSize = 16;
            app.DelayedSinewaveMultipathTimeandFrequencyViewLabel.FontWeight = 'bold';
            app.DelayedSinewaveMultipathTimeandFrequencyViewLabel.FontColor = [0.6353 0.0784 0.1843];
            app.DelayedSinewaveMultipathTimeandFrequencyViewLabel.Position = [52 797 434 22];
            app.DelayedSinewaveMultipathTimeandFrequencyViewLabel.Text = 'Delayed Sinewave-Multipath: Time and Frequency View';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [49 757 700 28];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [17 1 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MultipathApp

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