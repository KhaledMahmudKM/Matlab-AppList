classdef SinewaveTimeFreqApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        cKhaledMahmud2023Label        matlab.ui.control.Label
        Image                         matlab.ui.control.Image
        SineWaveTimeandFrequencyViewLabel  matlab.ui.control.Label
        SignalParametersPanel         matlab.ui.container.Panel
        PhaseSlider                   matlab.ui.control.Slider
        PhaseLabel                    matlab.ui.control.Label
        SamplepercycleEditField       matlab.ui.control.NumericEditField
        SamplepercycleEditFieldLabel  matlab.ui.control.Label
        DurationsecEditField          matlab.ui.control.NumericEditField
        DurationsecEditFieldLabel     matlab.ui.control.Label
        FrequencySlider               matlab.ui.control.Slider
        FrequencySliderLabel          matlab.ui.control.Label
        AmplitudeSlider               matlab.ui.control.Slider
        AmplitudeSliderLabel          matlab.ui.control.Label
        UIAxesFreq                    matlab.ui.control.UIAxes
        UIAxesTime                    matlab.ui.control.UIAxes
    end

    
    methods (Access = private)
        
        function updateplot(app)
            %Read the parameters from GUI
            amp = round(app.AmplitudeSlider.Value); %Read Amplitude, round to integer
            app.AmplitudeSlider.Value=amp;          %setting back the rounded value
            app.AmplitudeSliderLabel.Text="Amplitude: "+string(amp);

            fc = round(app.FrequencySlider.Value);  %Read Freq, round to integer
            app.FrequencySlider.Value=fc;           %setting back the rounded value
            app.FrequencySliderLabel.Text="Frequency (Hz): "+string(fc);

            ph=round(app.PhaseSlider.Value);
            app.PhaseSlider.Value=ph;
            app.PhaseLabel.Text="Phase (deg): "+ string(ph);



            samplepercylce=app.SamplepercycleEditField.Value;
            duration=app.DurationsecEditField.Value;
            
            fs=fc*samplepercylce;
            
            %Create time signal             
            t = 0:(1/fs):(duration-1/fs);           %Time vector (X-axis)
            SRef = amp*sin(2*pi*fc*t); 
            S = amp*sin(2*pi*fc*t+ph*pi/180);                 %Amplitude vector of sine wave (Y-axis)
            
            %Create Frequency sprectrum of the time signal above
            n = length(S);                          %No of time samples
            X = fft(S);                             
            Y = fftshift(X);                        %zero-centered spectrum
            fshift = (-n/2:n/2-1)*(fs/n);           % zero-centered frequency range (X-axis)
            powershift = (abs(Y).^2/n)/n;           % zero-centered power (Y-axis)
            
            %app.UIAxesTime.LineStyleOrder = {':'};
            hold(app.UIAxesTime, 'off');
            plot(app.UIAxesTime, t, SRef);             %Time Domain plot
            
            hold(app.UIAxesTime, 'on');
            plot(app.UIAxesTime, t, S);             %Time Domain plot

            plot(app.UIAxesFreq, fshift,powershift);%Frequency domain plot
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            updateplot(app);
        end

        % Value changed function: AmplitudeSlider
        function AmplitudeSliderValueChanged(app, event)
            %Read Amplitude value, round to integer, set the Amplitude label
            
            updateplot(app);
            
        end

        % Value changed function: FrequencySlider
        function FrequencySliderValueChanged(app, event)
            %Read Freq value, round to integer, set the Frequency label 
            
            updateplot(app);
            
        end

        % Value changed function: DurationsecEditField
        function DurationsecEditFieldValueChanged(app, event)
             updateplot(app);
            
        end

        % Value changed function: SamplepercycleEditField
        function SamplepercycleEditFieldValueChanged(app, event)
             updateplot(app);
            
        end

        % Value changed function: PhaseSlider
        function PhaseSliderValueChanged(app, event)
            
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
            app.UIFigure.Position = [100 100 812 809];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesTime
            app.UIAxesTime = uiaxes(app.UIFigure);
            title(app.UIAxesTime, 'Time Domain')
            xlabel(app.UIAxesTime, 'Time, sec')
            ylabel(app.UIAxesTime, 'Amplitude (V)')
            zlabel(app.UIAxesTime, 'Z')
            app.UIAxesTime.AmbientLightColor = [0.902 0.902 0.902];
            app.UIAxesTime.Color = [0.9412 0.949 0.8941];
            app.UIAxesTime.XGrid = 'on';
            app.UIAxesTime.YGrid = 'on';
            app.UIAxesTime.LineStyleOrder = {':'; '-'};
            app.UIAxesTime.LineStyleCyclingMethod = 'withcolor';
            app.UIAxesTime.NextPlot = 'add';
            app.UIAxesTime.Position = [35 252 710 234];

            % Create UIAxesFreq
            app.UIAxesFreq = uiaxes(app.UIFigure);
            title(app.UIAxesFreq, 'Frequency Domain')
            xlabel(app.UIAxesFreq, 'Frequency (Hz)')
            ylabel(app.UIAxesFreq, 'Power (W)')
            zlabel(app.UIAxesFreq, 'Z')
            app.UIAxesFreq.Color = [0.9412 0.9804 0.9725];
            app.UIAxesFreq.XGrid = 'on';
            app.UIAxesFreq.YGrid = 'on';
            app.UIAxesFreq.Position = [40 4 705 232];

            % Create SignalParametersPanel
            app.SignalParametersPanel = uipanel(app.UIFigure);
            app.SignalParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.SignalParametersPanel.Title = 'Signal Parameters';
            app.SignalParametersPanel.FontWeight = 'bold';
            app.SignalParametersPanel.Position = [77 505 656 233];

            % Create AmplitudeSliderLabel
            app.AmplitudeSliderLabel = uilabel(app.SignalParametersPanel);
            app.AmplitudeSliderLabel.HorizontalAlignment = 'right';
            app.AmplitudeSliderLabel.Position = [12 178 116 22];
            app.AmplitudeSliderLabel.Text = 'Amplitude';

            % Create AmplitudeSlider
            app.AmplitudeSlider = uislider(app.SignalParametersPanel);
            app.AmplitudeSlider.Limits = [1 100];
            app.AmplitudeSlider.MajorTicks = [1 10 20 30 40 50 60 70 80 90 100];
            app.AmplitudeSlider.ValueChangedFcn = createCallbackFcn(app, @AmplitudeSliderValueChanged, true);
            app.AmplitudeSlider.MinorTicks = [];
            app.AmplitudeSlider.Position = [140 197 498 3];
            app.AmplitudeSlider.Value = 1;

            % Create FrequencySliderLabel
            app.FrequencySliderLabel = uilabel(app.SignalParametersPanel);
            app.FrequencySliderLabel.HorizontalAlignment = 'right';
            app.FrequencySliderLabel.Position = [8 125 124 22];
            app.FrequencySliderLabel.Text = 'Frequency';

            % Create FrequencySlider
            app.FrequencySlider = uislider(app.SignalParametersPanel);
            app.FrequencySlider.Limits = [1 100];
            app.FrequencySlider.MajorTicks = [1 10 20 30 40 50 60 70 80 90 100];
            app.FrequencySlider.ValueChangedFcn = createCallbackFcn(app, @FrequencySliderValueChanged, true);
            app.FrequencySlider.MinorTicks = [];
            app.FrequencySlider.Position = [140 144 498 3];
            app.FrequencySlider.Value = 1;

            % Create DurationsecEditFieldLabel
            app.DurationsecEditFieldLabel = uilabel(app.SignalParametersPanel);
            app.DurationsecEditFieldLabel.HorizontalAlignment = 'right';
            app.DurationsecEditFieldLabel.Position = [508 15 76 22];
            app.DurationsecEditFieldLabel.Text = 'Duration, sec';

            % Create DurationsecEditField
            app.DurationsecEditField = uieditfield(app.SignalParametersPanel, 'numeric');
            app.DurationsecEditField.Limits = [1 10];
            app.DurationsecEditField.ValueChangedFcn = createCallbackFcn(app, @DurationsecEditFieldValueChanged, true);
            app.DurationsecEditField.Position = [591 15 48 22];
            app.DurationsecEditField.Value = 5;

            % Create SamplepercycleEditFieldLabel
            app.SamplepercycleEditFieldLabel = uilabel(app.SignalParametersPanel);
            app.SamplepercycleEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplepercycleEditFieldLabel.Position = [336 15 98 22];
            app.SamplepercycleEditFieldLabel.Text = 'Sample per cycle';

            % Create SamplepercycleEditField
            app.SamplepercycleEditField = uieditfield(app.SignalParametersPanel, 'numeric');
            app.SamplepercycleEditField.Limits = [2 100];
            app.SamplepercycleEditField.ValueChangedFcn = createCallbackFcn(app, @SamplepercycleEditFieldValueChanged, true);
            app.SamplepercycleEditField.Position = [449 15 46 22];
            app.SamplepercycleEditField.Value = 20;

            % Create PhaseLabel
            app.PhaseLabel = uilabel(app.SignalParametersPanel);
            app.PhaseLabel.HorizontalAlignment = 'right';
            app.PhaseLabel.Position = [8 65 120 22];
            app.PhaseLabel.Text = 'Phase';

            % Create PhaseSlider
            app.PhaseSlider = uislider(app.SignalParametersPanel);
            app.PhaseSlider.Limits = [0 360];
            app.PhaseSlider.MajorTicks = [0 30 60 90 120 150 180 210 240 270 300 330 360];
            app.PhaseSlider.ValueChangedFcn = createCallbackFcn(app, @PhaseSliderValueChanged, true);
            app.PhaseSlider.MinorTicks = [];
            app.PhaseSlider.Position = [142 84 496 3];

            % Create SineWaveTimeandFrequencyViewLabel
            app.SineWaveTimeandFrequencyViewLabel = uilabel(app.UIFigure);
            app.SineWaveTimeandFrequencyViewLabel.FontSize = 16;
            app.SineWaveTimeandFrequencyViewLabel.FontWeight = 'bold';
            app.SineWaveTimeandFrequencyViewLabel.FontColor = [0.6353 0.0784 0.1843];
            app.SineWaveTimeandFrequencyViewLabel.Position = [76 780 294 22];
            app.SineWaveTimeandFrequencyViewLabel.Text = 'Sine Wave: Time and Frequency View';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [78 753 667 23];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [30 1 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SinewaveTimeFreqApp

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