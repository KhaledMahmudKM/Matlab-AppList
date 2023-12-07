classdef AnalogModulationApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        cKhaledMahmud2023Label         matlab.ui.control.Label
        Image2                         matlab.ui.control.Image
        Image                          matlab.ui.control.Image
        CarrierParametersPanel         matlab.ui.container.Panel
        CarrierFreqSlider              matlab.ui.control.Slider
        CarrierFreqSliderLabel         matlab.ui.control.Label
        CarrierAmpitudeSlider          matlab.ui.control.Slider
        CarrierAmpitudeSliderLabel     matlab.ui.control.Label
        ToneParametersPanel            matlab.ui.container.Panel
        ToneFreqSlider                 matlab.ui.control.Slider
        ToneFreqSliderLabel            matlab.ui.control.Label
        ToneAmpitudeSlider             matlab.ui.control.Slider
        ToneAmpitudeSliderLabel        matlab.ui.control.Label
        PeriodicSignalTypeButtonGroup  matlab.ui.container.ButtonGroup
        FrequencyModulationButton      matlab.ui.control.RadioButton
        AmplitudeModulationButton      matlab.ui.control.RadioButton
        AnalogModulationofaToneLabel   matlab.ui.control.Label
        DisplayParametersPanel         matlab.ui.container.Panel
        SpectrumScaleSlider            matlab.ui.control.Slider
        SpectrumScaleLabel             matlab.ui.control.Label
        DurationEditField              matlab.ui.control.NumericEditField
        DurationEditFieldLabel         matlab.ui.control.Label
        SamplingRateEditField          matlab.ui.control.NumericEditField
        SamplingRateEditFieldLabel     matlab.ui.control.Label
        UIAxesModulatedTime            matlab.ui.control.UIAxes
        UIAxesCarrierFreq              matlab.ui.control.UIAxes
        UIAxesToneFreq                 matlab.ui.control.UIAxes
        UIAxesToneTime                 matlab.ui.control.UIAxes
        UIAxesModulatedFreq            matlab.ui.control.UIAxes
        UIAxesCarrierTime              matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        fs % Sampling rate
    end
    
    methods (Access = private)
        
        function updateplot(app)
            app.fs=app.SamplingRateEditField.Value;          
            duration=app.DurationEditField.Value;
            
            %Read modulation parameters
            At=app.ToneAmpitudeSlider.Value;
            Ft=app.ToneFreqSlider.Value;
            Ft=round(Ft);
            app.ToneFreqSlider.Value=Ft;
            app.ToneAmpitudeSliderLabel.Text="Tone Amplitude: "+string(At);
            app.ToneFreqSliderLabel.Text="Tone Freq (Hz): "+ string(Ft);
            
            Ac=app.CarrierAmpitudeSlider.Value;
            Fc=app.CarrierFreqSlider.Value;
            Fc=round(Fc);
            app.CarrierFreqSlider.Value=Fc;
            app.CarrierAmpitudeSliderLabel.Text="Carrier Amplitude: "+string(Ac);
            app.CarrierFreqSliderLabel.Text="Carrier Freq (Hz): "+string(Fc);
  

            %Update labels
            %app.AtLabel.Text=num2str(app.ToneAmpitudeSlider.Value);
            %app.FtLabel.Text=num2str(app.ToneFreqSlider.Value);
            %app.AcLabel.Text=num2str(app.CarrierAmpitudeSlider.Value);
            %app.FcLabel.Text=num2str(app.CarrierFreqSlider.Value);
            
            %Create time signals            
            t = 0:(1/app.fs):(duration-1/app.fs);           %Time vector (X-axis)
            totalsamples = length(t);
            
            %Create Tone
            sTone=At*sin(2*pi*Ft*t);
            
            %Create Carrier signal
            sCarrier=Ac*sin(2*pi*Fc*t);
            sModulated=sTone.*sCarrier;
            %Modulate
            
            %Plot the signals in Time domain
            plot(app.UIAxesToneTime,t,sTone);
            plot(app.UIAxesCarrierTime, t, sCarrier);
            plot(app.UIAxesModulatedTime, t, sModulated);
            
            %Plot the spectrum of the signals
            %fScale = (-totalsamples/2:totalsamples/2-1)*(fs/totalsamples);  % zero-centered frequency range (X-axis)
            %YTone = fft(sTone);                             
            %YTone = fftshift(YTone);                        %zero-centered spectrum            
            %YTone = abs(YTone)/totalsamples;
            %plot(app.UIAxesToneFreq, fScale, YTone);

            plotspectrum(app,app.UIAxesToneFreq, sTone, app.fs, totalsamples);
            
            %YCarrier = fft(sCarrier);                             
            %YCarrier = fftshift(YCarrier);                        %zero-centered spectrum            
            %YCarrier = abs(YCarrier)/totalsamples;
            %plot(app.UIAxesCarrierFreq,fScale, YCarrier);
            plotspectrum(app,app.UIAxesCarrierFreq, sCarrier, app.fs, totalsamples);

            %YModulated = fft(sModulated);                             
            %YModulated = fftshift(YModulated);                        %zero-centered spectrum            
            %YModulated = abs(YModulated)/totalsamples;
            %plot(app.UIAxesModulatedFreq, fScale, YModulated);
            plotspectrum(app,app.UIAxesModulatedFreq, sModulated, app.fs, totalsamples);

        end
        
        function plotspectrum(app,targetAxis, ysignal, fs, totalsamples)
 
            fScale = (-totalsamples/2:totalsamples/2-1)*(fs/totalsamples);
            Y = fft(ysignal);                             
            Y = fftshift(Y);                        %zero-centered spectrum            
            Y = abs(Y)/totalsamples;
            plot(targetAxis, fScale(totalsamples/2+1:totalsamples), Y(totalsamples/2+1:totalsamples)); %plot only +ve Freq.
            
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
            app.SpectrumScaleSlider.Limits=[0,app.SamplingRateEditField.Value/2]; 
            updateplot(app);
            
        end

        % Value changed function: ToneAmpitudeSlider
        function ToneAmpitudeSliderValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: ToneFreqSlider
        function ToneFreqSliderValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: CarrierAmpitudeSlider
        function CarrierAmpitudeSliderValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: CarrierFreqSlider
        function CarrierFreqSliderValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: SpectrumScaleSlider
        function SpectrumScaleSliderValueChanged(app, event)
            value = app.SpectrumScaleSlider.Value*app.fs/2/100;            
            
            %Adjust the Spectrum limit to this value 
            app.UIAxesToneFreq.XLim=[0,value];
            app.UIAxesCarrierFreq.XLim=[0,value];
            app.UIAxesModulatedFreq.XLim=[0,value];
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
            app.UIFigure.Position = [100 100 1139 822];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesCarrierTime
            app.UIAxesCarrierTime = uiaxes(app.UIFigure);
            title(app.UIAxesCarrierTime, 'Carrier Signal')
            xlabel(app.UIAxesCarrierTime, 'Time, sec')
            ylabel(app.UIAxesCarrierTime, 'Amplitude')
            zlabel(app.UIAxesCarrierTime, 'Z')
            app.UIAxesCarrierTime.Color = [0.949 1 0.8784];
            app.UIAxesCarrierTime.GridColor = [0.502 0.502 0.502];
            app.UIAxesCarrierTime.XGrid = 'on';
            app.UIAxesCarrierTime.YGrid = 'on';
            app.UIAxesCarrierTime.Position = [260 271 420 240];

            % Create UIAxesModulatedFreq
            app.UIAxesModulatedFreq = uiaxes(app.UIFigure);
            title(app.UIAxesModulatedFreq, 'Spectrum of Modulated Signal')
            xlabel(app.UIAxesModulatedFreq, 'Frequency (Hz)')
            ylabel(app.UIAxesModulatedFreq, 'Amplitude')
            zlabel(app.UIAxesModulatedFreq, 'Z')
            app.UIAxesModulatedFreq.Color = [1 0.902 0.902];
            app.UIAxesModulatedFreq.XGrid = 'on';
            app.UIAxesModulatedFreq.YGrid = 'on';
            app.UIAxesModulatedFreq.Position = [690 20 420 240];

            % Create UIAxesToneTime
            app.UIAxesToneTime = uiaxes(app.UIFigure);
            title(app.UIAxesToneTime, 'Modulating Signal (Tone)')
            xlabel(app.UIAxesToneTime, 'Time, sec')
            ylabel(app.UIAxesToneTime, 'Amplitude')
            zlabel(app.UIAxesToneTime, 'Z')
            app.UIAxesToneTime.Color = [1 1 0.949];
            app.UIAxesToneTime.XGrid = 'on';
            app.UIAxesToneTime.YGrid = 'on';
            app.UIAxesToneTime.Position = [260 521 420 240];

            % Create UIAxesToneFreq
            app.UIAxesToneFreq = uiaxes(app.UIFigure);
            title(app.UIAxesToneFreq, 'Spectrum of Modulating Signal')
            xlabel(app.UIAxesToneFreq, 'Freq (Hz)')
            ylabel(app.UIAxesToneFreq, 'Amplitude')
            zlabel(app.UIAxesToneFreq, 'Z')
            app.UIAxesToneFreq.Color = [1 1 0.949];
            app.UIAxesToneFreq.XGrid = 'on';
            app.UIAxesToneFreq.YGrid = 'on';
            app.UIAxesToneFreq.Position = [690 521 420 240];

            % Create UIAxesCarrierFreq
            app.UIAxesCarrierFreq = uiaxes(app.UIFigure);
            title(app.UIAxesCarrierFreq, 'Spectrum of Carrier Signal')
            xlabel(app.UIAxesCarrierFreq, 'Freq (Hz)')
            ylabel(app.UIAxesCarrierFreq, 'Amplitude')
            zlabel(app.UIAxesCarrierFreq, 'Z')
            app.UIAxesCarrierFreq.Color = [0.949 1 0.8784];
            app.UIAxesCarrierFreq.XGrid = 'on';
            app.UIAxesCarrierFreq.YGrid = 'on';
            app.UIAxesCarrierFreq.Position = [690 271 420 240];

            % Create UIAxesModulatedTime
            app.UIAxesModulatedTime = uiaxes(app.UIFigure);
            title(app.UIAxesModulatedTime, 'Modulated Signal')
            xlabel(app.UIAxesModulatedTime, 'Time (sec)')
            ylabel(app.UIAxesModulatedTime, 'Amplitude')
            zlabel(app.UIAxesModulatedTime, 'Z')
            app.UIAxesModulatedTime.Color = [1 0.902 0.902];
            app.UIAxesModulatedTime.XGrid = 'on';
            app.UIAxesModulatedTime.YGrid = 'on';
            app.UIAxesModulatedTime.Position = [260 20 420 240];

            % Create DisplayParametersPanel
            app.DisplayParametersPanel = uipanel(app.UIFigure);
            app.DisplayParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.DisplayParametersPanel.Title = 'Display Parameters';
            app.DisplayParametersPanel.FontWeight = 'bold';
            app.DisplayParametersPanel.Position = [28 80 200 180];

            % Create SamplingRateEditFieldLabel
            app.SamplingRateEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.SamplingRateEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingRateEditFieldLabel.Position = [9 129 84 22];
            app.SamplingRateEditFieldLabel.Text = 'Sampling Rate';

            % Create SamplingRateEditField
            app.SamplingRateEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.SamplingRateEditField.Limits = [100 8000];
            app.SamplingRateEditField.RoundFractionalValues = 'on';
            app.SamplingRateEditField.ValueChangedFcn = createCallbackFcn(app, @SamplingRateEditFieldValueChanged, true);
            app.SamplingRateEditField.Position = [121 129 49 22];
            app.SamplingRateEditField.Value = 100;

            % Create DurationEditFieldLabel
            app.DurationEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.DurationEditFieldLabel.HorizontalAlignment = 'right';
            app.DurationEditFieldLabel.Position = [7 97 51 22];
            app.DurationEditFieldLabel.Text = 'Duration';

            % Create DurationEditField
            app.DurationEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.DurationEditField.Limits = [1 10];
            app.DurationEditField.ValueChangedFcn = createCallbackFcn(app, @DurationEditFieldValueChanged, true);
            app.DurationEditField.Position = [121 97 49 22];
            app.DurationEditField.Value = 5;

            % Create SpectrumScaleLabel
            app.SpectrumScaleLabel = uilabel(app.DisplayParametersPanel);
            app.SpectrumScaleLabel.HorizontalAlignment = 'right';
            app.SpectrumScaleLabel.Position = [9 55 112 22];
            app.SpectrumScaleLabel.Text = 'Spectrum Scale (%)';

            % Create SpectrumScaleSlider
            app.SpectrumScaleSlider = uislider(app.DisplayParametersPanel);
            app.SpectrumScaleSlider.Limits = [1 100];
            app.SpectrumScaleSlider.MajorTicks = [1 10 20 30 40 50 60 70 80 90 100];
            app.SpectrumScaleSlider.ValueChangedFcn = createCallbackFcn(app, @SpectrumScaleSliderValueChanged, true);
            app.SpectrumScaleSlider.MinorTicks = [];
            app.SpectrumScaleSlider.Position = [14 44 150 3];
            app.SpectrumScaleSlider.Value = 100;

            % Create AnalogModulationofaToneLabel
            app.AnalogModulationofaToneLabel = uilabel(app.UIFigure);
            app.AnalogModulationofaToneLabel.FontSize = 16;
            app.AnalogModulationofaToneLabel.FontWeight = 'bold';
            app.AnalogModulationofaToneLabel.FontColor = [0.6353 0.0784 0.1843];
            app.AnalogModulationofaToneLabel.Position = [38 791 225 22];
            app.AnalogModulationofaToneLabel.Text = 'Analog Modulation of a Tone';

            % Create PeriodicSignalTypeButtonGroup
            app.PeriodicSignalTypeButtonGroup = uibuttongroup(app.UIFigure);
            app.PeriodicSignalTypeButtonGroup.ForegroundColor = [0 0.4471 0.7412];
            app.PeriodicSignalTypeButtonGroup.Title = 'Periodic Signal Type';
            app.PeriodicSignalTypeButtonGroup.FontWeight = 'bold';
            app.PeriodicSignalTypeButtonGroup.Scrollable = 'on';
            app.PeriodicSignalTypeButtonGroup.Position = [28 672 199 77];

            % Create AmplitudeModulationButton
            app.AmplitudeModulationButton = uiradiobutton(app.PeriodicSignalTypeButtonGroup);
            app.AmplitudeModulationButton.Text = 'Amplitude Modulation';
            app.AmplitudeModulationButton.Position = [11 31 137 22];
            app.AmplitudeModulationButton.Value = true;

            % Create FrequencyModulationButton
            app.FrequencyModulationButton = uiradiobutton(app.PeriodicSignalTypeButtonGroup);
            app.FrequencyModulationButton.Enable = 'off';
            app.FrequencyModulationButton.Text = 'Frequency Modulation';
            app.FrequencyModulationButton.Position = [11 9 141 22];

            % Create ToneParametersPanel
            app.ToneParametersPanel = uipanel(app.UIFigure);
            app.ToneParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.ToneParametersPanel.Title = 'Tone Parameters';
            app.ToneParametersPanel.FontWeight = 'bold';
            app.ToneParametersPanel.Position = [27 471 200 190];

            % Create ToneAmpitudeSliderLabel
            app.ToneAmpitudeSliderLabel = uilabel(app.ToneParametersPanel);
            app.ToneAmpitudeSliderLabel.Position = [7 139 162 22];
            app.ToneAmpitudeSliderLabel.Text = 'Tone Ampitude';

            % Create ToneAmpitudeSlider
            app.ToneAmpitudeSlider = uislider(app.ToneParametersPanel);
            app.ToneAmpitudeSlider.Limits = [0 10];
            app.ToneAmpitudeSlider.ValueChangedFcn = createCallbackFcn(app, @ToneAmpitudeSliderValueChanged, true);
            app.ToneAmpitudeSlider.Position = [10 126 180 3];
            app.ToneAmpitudeSlider.Value = 1;

            % Create ToneFreqSliderLabel
            app.ToneFreqSliderLabel = uilabel(app.ToneParametersPanel);
            app.ToneFreqSliderLabel.Position = [8 60 169 22];
            app.ToneFreqSliderLabel.Text = 'Tone Freq';

            % Create ToneFreqSlider
            app.ToneFreqSlider = uislider(app.ToneParametersPanel);
            app.ToneFreqSlider.Limits = [1 11];
            app.ToneFreqSlider.ValueChangedFcn = createCallbackFcn(app, @ToneFreqSliderValueChanged, true);
            app.ToneFreqSlider.MinorTicks = [];
            app.ToneFreqSlider.Position = [12 50 176 3];
            app.ToneFreqSlider.Value = 1;

            % Create CarrierParametersPanel
            app.CarrierParametersPanel = uipanel(app.UIFigure);
            app.CarrierParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.CarrierParametersPanel.Title = 'Carrier Parameters';
            app.CarrierParametersPanel.FontWeight = 'bold';
            app.CarrierParametersPanel.Position = [28 270 200 190];

            % Create CarrierAmpitudeSliderLabel
            app.CarrierAmpitudeSliderLabel = uilabel(app.CarrierParametersPanel);
            app.CarrierAmpitudeSliderLabel.Position = [10 136 165 22];
            app.CarrierAmpitudeSliderLabel.Text = 'Carrier Ampitude';

            % Create CarrierAmpitudeSlider
            app.CarrierAmpitudeSlider = uislider(app.CarrierParametersPanel);
            app.CarrierAmpitudeSlider.Limits = [0 10];
            app.CarrierAmpitudeSlider.ValueChangedFcn = createCallbackFcn(app, @CarrierAmpitudeSliderValueChanged, true);
            app.CarrierAmpitudeSlider.Position = [12 125 174 3];
            app.CarrierAmpitudeSlider.Value = 2;

            % Create CarrierFreqSliderLabel
            app.CarrierFreqSliderLabel = uilabel(app.CarrierParametersPanel);
            app.CarrierFreqSliderLabel.Position = [5 60 185 22];
            app.CarrierFreqSliderLabel.Text = 'Carrier Freq';

            % Create CarrierFreqSlider
            app.CarrierFreqSlider = uislider(app.CarrierParametersPanel);
            app.CarrierFreqSlider.Limits = [10 110];
            app.CarrierFreqSlider.ValueChangedFcn = createCallbackFcn(app, @CarrierFreqSliderValueChanged, true);
            app.CarrierFreqSlider.Position = [12 50 175 3];
            app.CarrierFreqSlider.Value = 10;

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [242 46 19 703];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'img', 'vline.png');

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [28 763 1079 29];
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [25 12 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AnalogModulationApp

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