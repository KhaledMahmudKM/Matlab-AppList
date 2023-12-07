classdef AudioTimeFreqApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        cKhaledMahmud2023Label     matlab.ui.control.Label
        Image                      matlab.ui.control.Image
        FreqScaleSlider            matlab.ui.control.Slider
        FreqScaleLabel             matlab.ui.control.Label
        PlayButton                 matlab.ui.control.Button
        RecordAudioViewinTimeandFrequencyDomainLabel  matlab.ui.control.Label
        RecordButton               matlab.ui.control.Button
        DurationsecEditField       matlab.ui.control.NumericEditField
        DurationsecEditFieldLabel  matlab.ui.control.Label
        UIAxesFreq                 matlab.ui.control.UIAxes
        UIAxesTime                 matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        recorderObj % Description
        fs % Sampling rate
    end
    
    methods (Access = private)
        
        function updateplot(app)
            %Read the parameters from GUI
            %samplepercylce=app.SamplepercycleEditField.Value;
            duration=app.DurationsecEditField.Value;
            %fc = round(app.FrequencySlider.Value);  %Read Freq, round to integer
            %app.FrequencySlider.Value=fc;           %setting back the rounded value
            %amp = round(app.AmplitudeSlider.Value); %Read Amplitude, round to integer
            %app.AmplitudeSlider.Value=amp;          %setting back the rounded value       
            %fs=fc*samplepercylce;
            
            x=getaudiodata(app.recorderObj);
            app.fs=8000;                                %Sampling rate, default value for audiorecorder
            t = 0:(1/app.fs):(duration-1/app.fs);
            
            %Create Frequency sprectrum of the time signal above
            n = length(x);                          %No of time samples
            Y = fft(x);                             
            Y = fftshift(Y);                        %zero-centered spectrum
            fshift = (-n/2:n/2-1)*(app.fs/n);           %zero-centered frequency range (X-axis)
            Y = (abs(Y))/n;                         %Y-axis
            
            plot(app.UIAxesTime, t, x);             %Time Domain plot
            plot(app.UIAxesFreq, fshift(n/2+1:n), Y(n/2+1:n));%Frequency domain plot, only +ve freq
            app.UIAxesFreq.XLim=[0 3000];
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.recorderObj = audiorecorder;
            %updateplot(app);
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

        % Value changed function: DurationsecEditField
        function DurationsecEditFieldValueChanged(app, event)
             updateplot(app);
            
        end

        % Callback function
        function SamplepercycleEditFieldValueChanged(app, event)
             updateplot(app);
            
        end

        % Button pushed function: RecordButton
        function RecordButtonPushed(app, event)
            app.RecordButton.Text="Recording";
            app.RecordButton.Enable=false;
            duration=app.DurationsecEditField.Value;
            recordblocking(app.recorderObj, duration);
            app.RecordButton.Text="Record";
            app.RecordButton.Enable=true;
            updateplot(app);
            
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            %app.PlayButton.Enable=false;
            %play(app.recorderObj);
            audioSampleData=getaudiodata(app.recorderObj);
            Fs=8000;
            sound(audioSampleData, Fs);
            %app.PlayButton.Enable=true;
        end

        % Value changed function: FreqScaleSlider
        function FreqScaleSliderValueChanged(app, event)
            value = app.FreqScaleSlider.Value*app.fs/2/100;
            %Adjust the Spectrum limit to this value 
            app.UIAxesFreq.XLim=[0,value];
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
            app.UIFigure.Position = [100 100 801 738];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesTime
            app.UIAxesTime = uiaxes(app.UIFigure);
            title(app.UIAxesTime, 'Time Domain')
            xlabel(app.UIAxesTime, 'Time, sec')
            ylabel(app.UIAxesTime, 'Amplitude (V)')
            zlabel(app.UIAxesTime, 'Z')
            app.UIAxesTime.XGrid = 'on';
            app.UIAxesTime.YGrid = 'on';
            app.UIAxesTime.Position = [30 370 720 230];

            % Create UIAxesFreq
            app.UIAxesFreq = uiaxes(app.UIFigure);
            title(app.UIAxesFreq, 'Frequency Domain')
            xlabel(app.UIAxesFreq, 'Frequency (Hz)')
            ylabel(app.UIAxesFreq, 'Power (W)')
            zlabel(app.UIAxesFreq, 'Z')
            app.UIAxesFreq.XGrid = 'on';
            app.UIAxesFreq.YGrid = 'on';
            app.UIAxesFreq.Position = [30 120 720 230];

            % Create DurationsecEditFieldLabel
            app.DurationsecEditFieldLabel = uilabel(app.UIFigure);
            app.DurationsecEditFieldLabel.HorizontalAlignment = 'right';
            app.DurationsecEditFieldLabel.Position = [54 632 76 22];
            app.DurationsecEditFieldLabel.Text = 'Duration, sec';

            % Create DurationsecEditField
            app.DurationsecEditField = uieditfield(app.UIFigure, 'numeric');
            app.DurationsecEditField.Limits = [1 10];
            app.DurationsecEditField.ValueChangedFcn = createCallbackFcn(app, @DurationsecEditFieldValueChanged, true);
            app.DurationsecEditField.Position = [145 632 33 22];
            app.DurationsecEditField.Value = 5;

            % Create RecordButton
            app.RecordButton = uibutton(app.UIFigure, 'push');
            app.RecordButton.ButtonPushedFcn = createCallbackFcn(app, @RecordButtonPushed, true);
            app.RecordButton.FontWeight = 'bold';
            app.RecordButton.FontColor = [0 0.4471 0.7412];
            app.RecordButton.Position = [202 632 124 22];
            app.RecordButton.Text = 'Record';

            % Create RecordAudioViewinTimeandFrequencyDomainLabel
            app.RecordAudioViewinTimeandFrequencyDomainLabel = uilabel(app.UIFigure);
            app.RecordAudioViewinTimeandFrequencyDomainLabel.FontSize = 16;
            app.RecordAudioViewinTimeandFrequencyDomainLabel.FontWeight = 'bold';
            app.RecordAudioViewinTimeandFrequencyDomainLabel.FontColor = [0.6353 0.0784 0.1843];
            app.RecordAudioViewinTimeandFrequencyDomainLabel.Position = [42 689 404 22];
            app.RecordAudioViewinTimeandFrequencyDomainLabel.Text = 'Record Audio, View in Time and Frequency Domain';

            % Create PlayButton
            app.PlayButton = uibutton(app.UIFigure, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.FontWeight = 'bold';
            app.PlayButton.FontColor = [0 0.4471 0.7412];
            app.PlayButton.Position = [352 632 100 22];
            app.PlayButton.Text = 'Play';

            % Create FreqScaleLabel
            app.FreqScaleLabel = uilabel(app.UIFigure);
            app.FreqScaleLabel.HorizontalAlignment = 'right';
            app.FreqScaleLabel.Position = [86 91 86 21];
            app.FreqScaleLabel.Text = 'Freq Scale (%)';

            % Create FreqScaleSlider
            app.FreqScaleSlider = uislider(app.UIFigure);
            app.FreqScaleSlider.MajorTicks = [1 10 20 30 40 50 60 70 80 90 100];
            app.FreqScaleSlider.ValueChangedFcn = createCallbackFcn(app, @FreqScaleSliderValueChanged, true);
            app.FreqScaleSlider.MinorTicks = [];
            app.FreqScaleSlider.Position = [86 77 651 7];
            app.FreqScaleSlider.Value = 100;

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [25 666 704 21];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [25 1 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AudioTimeFreqApp

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