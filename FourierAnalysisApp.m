classdef FourierAnalysisApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        Image2                         matlab.ui.control.Image
        cKhaledMahmud2023Label         matlab.ui.control.Label
        Image                          matlab.ui.control.Image
        FreqScaleSlider                matlab.ui.control.Slider
        FreqScaleSliderLabel           matlab.ui.control.Label
        PeriodicSignalTypeButtonGroup  matlab.ui.container.ButtonGroup
        SawtoothButton                 matlab.ui.control.RadioButton
        TriangularButton               matlab.ui.control.RadioButton
        RectangularButton              matlab.ui.control.RadioButton
        FourierAnalysisPeriodicSignalsLabel  matlab.ui.control.Label
        DisplayParametersPanel         matlab.ui.container.Panel
        NoofHarmonicsSpinner           matlab.ui.control.Spinner
        NoofHarmonicsSpinnerLabel      matlab.ui.control.Label
        DurationEditField              matlab.ui.control.NumericEditField
        DurationEditFieldLabel         matlab.ui.control.Label
        SamplingRateEditField          matlab.ui.control.NumericEditField
        SamplingRateEditFieldLabel     matlab.ui.control.Label
        UIAxesComponents               matlab.ui.control.UIAxes
        UIAxesFreq                     matlab.ui.control.UIAxes
        UIAxesTime                     matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        fs % Sampling rate
    end
    
    methods (Access = private)
        
        
        function updateplot(app)
            %Read dispaly parameters
            app.fs=app.SamplingRateEditField.Value;          
            duration=app.DurationEditField.Value;
            noofharmonics=app.NoofHarmonicsSpinner.Value;
            
            %Create time signals            
            t = 0:(1/app.fs):(duration-1/app.fs);           %Time vector (X-axis)
            totalsamples = length(t);
            f1=1;                                   %Fundamental freq
            a=[];
            b=[];
            sSum=zeros(1,totalsamples);
            T=1/f1;         %Pulse Period
            D=0.5;          %Pulse duty cycle
            A=1;            %Amplitude
            a0=0;

            selectedButton = app.PeriodicSignalTypeButtonGroup.SelectedObject;
            %Calculate Fourier coefficients
            switch selectedButton.Text
                case "Rectangular" 
                    a0=A*D;
                    a=zeros(1,noofharmonics);
                    for n=1:noofharmonics
                        %a=[a, A*sin(2*pi*D)/(pi*n)];
                        b=[b, 2*A*((sin(pi*n*D))^2)/(pi*n)];
                    end
                case "Triangular"
                    a0=0;
                    b=zeros(1,noofharmonics);
                    for n=1:noofharmonics
                        if rem(n,2) == 1
                            a=[a, 4*A*(1-(-1)^n)/(pi*pi*n*n)];
                        else
                            a=[a, 0];
                        end
                    end
                    
                case "Sawtooth"
                    a0=A;
                    a=zeros(1,noofharmonics);
                    for n=1:noofharmonics
                        b=[b, -A/n/pi];
                    end
            end
            
            sSum=sSum+a0;
             
            for n=1: noofharmonics
                
                x(n,:)=a(n)*cos(2*pi*n*t)+b(n)*sin(2*pi*n*t);
                sSum=sSum+x(n,:);
                %plot(app.UIAxesTime, t, x(n,:));
            end
            
            Y = fft(sSum);                             
            Y = fftshift(Y);                        %zero-centered spectrum
            fScale = (-totalsamples/2:totalsamples/2-1)*(app.fs/totalsamples);              % zero-centered frequency range (X-axis)
            P = abs(Y)/totalsamples;
            
            
            cla(app.UIAxesComponents);
            hold(app.UIAxesComponents, 'on');
             for n=1: noofharmonics
                  plot(app.UIAxesComponents, t, x(n,:));
             end
            plot(app.UIAxesTime, t, sSum); 
            
            plot(app.UIAxesFreq, fScale(totalsamples/2+1:totalsamples),P(totalsamples/2+1:totalsamples));
            
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

        % Callback function
        function f1SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function f2SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function f3SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function a1SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function a2SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function a3SpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function Showf1CheckBoxValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function Showf2CheckBoxValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function Showf3CheckBoxValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: NoofHarmonicsSpinner
        function NoofHarmonicsSpinnerValueChanged(app, event)
            updateplot(app);
            
        end

        % Selection changed function: PeriodicSignalTypeButtonGroup
        function PeriodicSignalTypeButtonGroupSelectionChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: FreqScaleSlider
        function FreqScaleSliderValueChanged(app, event)
            %value = app.FreqScaleSlider.Value;
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
            app.UIFigure.Position = [100 100 1017 860];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesTime
            app.UIAxesTime = uiaxes(app.UIFigure);
            title(app.UIAxesTime, 'Combined Signal')
            xlabel(app.UIAxesTime, 'Time, sec')
            ylabel(app.UIAxesTime, 'Amplitude (V)')
            zlabel(app.UIAxesTime, 'Z')
            app.UIAxesTime.Color = [0.9882 1 0.8784];
            app.UIAxesTime.GridColor = [0.502 0.502 0.502];
            app.UIAxesTime.XGrid = 'on';
            app.UIAxesTime.YGrid = 'on';
            app.UIAxesTime.Position = [280 300 700 240];

            % Create UIAxesFreq
            app.UIAxesFreq = uiaxes(app.UIFigure);
            title(app.UIAxesFreq, 'Frequency Domain')
            xlabel(app.UIAxesFreq, 'Frequency (Hz)')
            ylabel(app.UIAxesFreq, 'Amplitude (V)')
            zlabel(app.UIAxesFreq, 'Z')
            app.UIAxesFreq.XGrid = 'on';
            app.UIAxesFreq.YGrid = 'on';
            app.UIAxesFreq.Position = [280 60 700 210];

            % Create UIAxesComponents
            app.UIAxesComponents = uiaxes(app.UIFigure);
            title(app.UIAxesComponents, 'Component Signals')
            xlabel(app.UIAxesComponents, 'Time, sec')
            ylabel(app.UIAxesComponents, 'Amplitude (V)')
            zlabel(app.UIAxesComponents, 'Z')
            app.UIAxesComponents.Color = [1 1 0.949];
            app.UIAxesComponents.XGrid = 'on';
            app.UIAxesComponents.YGrid = 'on';
            app.UIAxesComponents.Position = [280 560 700 240];

            % Create DisplayParametersPanel
            app.DisplayParametersPanel = uipanel(app.UIFigure);
            app.DisplayParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.DisplayParametersPanel.Title = 'Display Parameters';
            app.DisplayParametersPanel.FontWeight = 'bold';
            app.DisplayParametersPanel.Position = [23 520 213 127];

            % Create SamplingRateEditFieldLabel
            app.SamplingRateEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.SamplingRateEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingRateEditFieldLabel.Position = [6 75 84 22];
            app.SamplingRateEditFieldLabel.Text = 'Sampling Rate';

            % Create SamplingRateEditField
            app.SamplingRateEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.SamplingRateEditField.Limits = [10 1000];
            app.SamplingRateEditField.RoundFractionalValues = 'on';
            app.SamplingRateEditField.ValueChangedFcn = createCallbackFcn(app, @SamplingRateEditFieldValueChanged, true);
            app.SamplingRateEditField.Position = [113 75 46 22];
            app.SamplingRateEditField.Value = 100;

            % Create DurationEditFieldLabel
            app.DurationEditFieldLabel = uilabel(app.DisplayParametersPanel);
            app.DurationEditFieldLabel.HorizontalAlignment = 'right';
            app.DurationEditFieldLabel.Position = [7 44 51 22];
            app.DurationEditFieldLabel.Text = 'Duration';

            % Create DurationEditField
            app.DurationEditField = uieditfield(app.DisplayParametersPanel, 'numeric');
            app.DurationEditField.Limits = [1 10];
            app.DurationEditField.ValueChangedFcn = createCallbackFcn(app, @DurationEditFieldValueChanged, true);
            app.DurationEditField.Position = [114 44 46 22];
            app.DurationEditField.Value = 5;

            % Create NoofHarmonicsSpinnerLabel
            app.NoofHarmonicsSpinnerLabel = uilabel(app.DisplayParametersPanel);
            app.NoofHarmonicsSpinnerLabel.HorizontalAlignment = 'right';
            app.NoofHarmonicsSpinnerLabel.Position = [4 16 95 22];
            app.NoofHarmonicsSpinnerLabel.Text = 'No of Harmonics';

            % Create NoofHarmonicsSpinner
            app.NoofHarmonicsSpinner = uispinner(app.DisplayParametersPanel);
            app.NoofHarmonicsSpinner.Limits = [1 20];
            app.NoofHarmonicsSpinner.ValueChangedFcn = createCallbackFcn(app, @NoofHarmonicsSpinnerValueChanged, true);
            app.NoofHarmonicsSpinner.Position = [113 16 55 22];
            app.NoofHarmonicsSpinner.Value = 3;

            % Create FourierAnalysisPeriodicSignalsLabel
            app.FourierAnalysisPeriodicSignalsLabel = uilabel(app.UIFigure);
            app.FourierAnalysisPeriodicSignalsLabel.FontSize = 16;
            app.FourierAnalysisPeriodicSignalsLabel.FontWeight = 'bold';
            app.FourierAnalysisPeriodicSignalsLabel.FontColor = [0.6353 0.0784 0.1843];
            app.FourierAnalysisPeriodicSignalsLabel.Position = [24 824 267 22];
            app.FourierAnalysisPeriodicSignalsLabel.Text = 'Fourier Analysis, Periodic Signals';

            % Create PeriodicSignalTypeButtonGroup
            app.PeriodicSignalTypeButtonGroup = uibuttongroup(app.UIFigure);
            app.PeriodicSignalTypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @PeriodicSignalTypeButtonGroupSelectionChanged, true);
            app.PeriodicSignalTypeButtonGroup.ForegroundColor = [0 0.4471 0.7412];
            app.PeriodicSignalTypeButtonGroup.Title = 'Periodic Signal Type';
            app.PeriodicSignalTypeButtonGroup.FontWeight = 'bold';
            app.PeriodicSignalTypeButtonGroup.Scrollable = 'on';
            app.PeriodicSignalTypeButtonGroup.Position = [23 686 213 98];

            % Create RectangularButton
            app.RectangularButton = uiradiobutton(app.PeriodicSignalTypeButtonGroup);
            app.RectangularButton.Text = 'Rectangular';
            app.RectangularButton.Position = [11 52 87 22];
            app.RectangularButton.Value = true;

            % Create TriangularButton
            app.TriangularButton = uiradiobutton(app.PeriodicSignalTypeButtonGroup);
            app.TriangularButton.Text = 'Triangular';
            app.TriangularButton.Position = [11 30 76 22];

            % Create SawtoothButton
            app.SawtoothButton = uiradiobutton(app.PeriodicSignalTypeButtonGroup);
            app.SawtoothButton.Text = 'Sawtooth';
            app.SawtoothButton.Position = [11 8 72 22];

            % Create FreqScaleSliderLabel
            app.FreqScaleSliderLabel = uilabel(app.UIFigure);
            app.FreqScaleSliderLabel.HorizontalAlignment = 'right';
            app.FreqScaleSliderLabel.Position = [335 48 86 22];
            app.FreqScaleSliderLabel.Text = 'Freq Scale (%)';

            % Create FreqScaleSlider
            app.FreqScaleSlider = uislider(app.UIFigure);
            app.FreqScaleSlider.Limits = [1 100];
            app.FreqScaleSlider.MajorTicks = [1 10 20 30 40 50 60 70 80 90 100];
            app.FreqScaleSlider.ValueChangedFcn = createCallbackFcn(app, @FreqScaleSliderValueChanged, true);
            app.FreqScaleSlider.MinorTicks = [];
            app.FreqScaleSlider.Position = [335 36 640 3];
            app.FreqScaleSlider.Value = 100;

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [244 15 42 774];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'img', 'vline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [18 15 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [13 796 994 33];
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = FourierAnalysisApp

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