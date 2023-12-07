classdef DigitalModulationApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        Image3                         matlab.ui.control.Image
        cKhaledMahmud2023Label         matlab.ui.control.Label
        Image2                         matlab.ui.control.Image
        ParametersPanel                matlab.ui.container.Panel
        FSKHighFreqFactorSpinner       matlab.ui.control.Spinner
        FSKHighFreqFactorSpinnerLabel  matlab.ui.control.Label
        ASKLowLevelSlider              matlab.ui.control.Slider
        ASKLowLevelSliderLabel         matlab.ui.control.Label
        CalculatedValuesPanel          matlab.ui.container.Panel
        SamplingRateLabel              matlab.ui.control.Label
        SymbolRateLabel                matlab.ui.control.Label
        CarrierFreqLabel               matlab.ui.control.Label
        SpectrumScaleSlider            matlab.ui.control.Slider
        SpectrumScaleLabel             matlab.ui.control.Label
        SamplePerCycleSlider           matlab.ui.control.Slider
        SamplePerCycleSliderLabel      matlab.ui.control.Label
        ModulationLevelButtonGroup     matlab.ui.container.ButtonGroup
        aryButton                      matlab.ui.control.RadioButton
        BinaryButton                   matlab.ui.control.RadioButton
        BitRatekbpsSlider              matlab.ui.control.Slider
        BitRatekbpsSliderLabel         matlab.ui.control.Label
        CyclePerSymbolSlider           matlab.ui.control.Slider
        CyclePerBitLabel               matlab.ui.control.Label
        AmpitudeSlider_C               matlab.ui.control.Slider
        AmpitudeSlider_2Label          matlab.ui.control.Label
        TxDataButtonGroup              matlab.ui.container.ButtonGroup
        BitTextArea                    matlab.ui.control.TextArea
        BitsButton                     matlab.ui.control.RadioButton
        AsciiButton                    matlab.ui.control.RadioButton
        MessageEditField               matlab.ui.control.EditField
        DigitalModulationLabel         matlab.ui.control.Label
        UIAxesDataFreq                 matlab.ui.control.UIAxes
        UIAxesDataTime                 matlab.ui.control.UIAxes
        UIAxesFSKTime                  matlab.ui.control.UIAxes
        UIAxesPSKFreq                  matlab.ui.control.UIAxes
        UIAxesASKFreq                  matlab.ui.control.UIAxes
        UIAxesASKTime                  matlab.ui.control.UIAxes
        UIAxesFSKFreq                  matlab.ui.control.UIAxes
        UIAxesPSKTime                  matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        fs % Sampling rate
    end
    
    methods (Access = private)
        
        function updateplot(app)

            %Read the user's message
            if app.AsciiButton.Value==1    
                message = app.MessageEditField.Value; % Message in Ascii
                dataBits1 = dec2bin(message,8); %Convert characters to binary
                dataBits=reshape(dataBits1, 1, length(message)*8);
                app.BitTextArea.Value=dataBits;
            else
                dataBits=char(app.BitTextArea.Value);
            end
                
            %Read Signal display paramters

            
            %Read Carrier parameters
            ampC=app.AmpitudeSlider_C.Value;
            ampC=round(ampC);
            app.AmpitudeSlider_C.Value=ampC;
            app.AmpitudeSlider_2Label.Text="Carrier Amplitude: "+string(ampC);

            bitRate=app.BitRatekbpsSlider.Value;
            bitRate=round(bitRate);
            app.BitRatekbpsSlider.Value=bitRate;
            app.BitRatekbpsSliderLabel.Text="Bit rate (kbps): "+ string(bitRate);
       

            bitPerSymbol=1;                             %Default binary
            if app.aryButton.Value==1
                bitPerSymbol=2;
            end

            symbolRate=bitRate*bitPerSymbol;
            symbolDuration=1/symbolRate;
            app.SymbolRateLabel.Text="Symbol rate (ksps): "+string(symbolRate);

            cyclePerSymbol=app.CyclePerSymbolSlider.Value;
            cyclePerSymbol=round(cyclePerSymbol);
            app.CyclePerSymbolSlider.Value=cyclePerSymbol;
            app.CyclePerBitLabel.Text="Cycle per Symbol: "+string(cyclePerSymbol);
            
            carrierFreq=symbolRate*cyclePerSymbol;
            app.CarrierFreqLabel.Text="Carrier Freq (kHz); "+ string(carrierFreq);

            samplePerCycle=app.SamplePerCycleSlider.Value;
            samplePerCycle=round(samplePerCycle);
            app.SamplePerCycleSlider.Value=samplePerCycle;
            app.SamplePerCycleSliderLabel.Text="Sample per cycle: "+string(samplePerCycle);

            samplingRate=carrierFreq*samplePerCycle;
            app.fs=samplingRate;
            app.SamplingRateLabel.Text ="Sampling rate(ksample/sec): "+string(samplingRate);
            
            
            sampleDuration=1/samplingRate;

            %FreqC=round(carrierFreq);

            %Create time values of one symbol         
            t = 0:(sampleDuration):(symbolDuration-sampleDuration);           %Time vector (X-axis)
            %totalsamples = length(t);
            
            lineSignal=[]; %Digital line signal array
            lineSignalLow=zeros(1,length(t));
            lineSignalHigh=ones(1,length(t));            
            

            timeASK=[]; %placeholder for ASK signal
            timeFSK=[]; %placeholder for FSK signal
            timePSK=[]; %placeholder for PSK signal 

            %Read ASK parameters
            %app.ASKLowLevelSlider.Value
            ASK_Levels=[app.ASKLowLevelSlider.Value/100 1];
            ASK_low = ASK_Levels(1)*ampC*sin(2*pi*carrierFreq*t); % for binary bit 0
            ASK_high = ASK_Levels(2)*ampC*sin(2*pi*carrierFreq*t); % for binary bit 1

            %Read FSK parameters
            FSK_Frequencies=[carrierFreq carrierFreq*app.FSKHighFreqFactorSpinner.Value];
            FSK_low= ampC*sin(2*pi*FSK_Frequencies(1)*t); %for binary bit, FreqC
            FSK_high=ampC*sin(2*pi*FSK_Frequencies(2)*t); %for binary bit, FreqC*2
            
            %Read PSK parameters
            PSK_Phases=[pi 0];
            PSK_low=cos(PSK_Phases(1))*ampC*sin(2*pi*carrierFreq*t); %-180 degree phase shift  for bit 0
            PSK_high=cos(PSK_Phases(2))*ampC*sin(2*pi*carrierFreq*t); %0 degree phase shift bit 1
            
            %Modulate
            %Run loop for all the characters and converting them to Digital modulation signal
            for i=1:size(dataBits,1)
                for j=1:size(dataBits,2)
                    if(dataBits(i,j)=='1')
                        lineSignal=[lineSignal lineSignalHigh];
                        timeASK=[timeASK ASK_high]; %Fix array allocation-KM
                        timeFSK=[timeFSK FSK_high];
                        timePSK=[timePSK PSK_high];
                    elseif (dataBits(i,j)=='0')
                        lineSignal=[lineSignal lineSignalLow];
                        timeASK=[timeASK ASK_low];
                        timeFSK=[timeFSK FSK_low];
                        timePSK=[timePSK PSK_low];
                    end 
                end
            end

            totalsamples=length(lineSignal);
            t = 0:(sampleDuration):(totalsamples*sampleDuration-sampleDuration);  
            %Plot the signals in Time domain
            plot(app.UIAxesDataTime, t,lineSignal);
            plot(app.UIAxesASKTime, t,timeASK);
            plot(app.UIAxesPSKTime, t,timePSK);
            plot(app.UIAxesFSKTime, t,timeFSK);
            
            plotspectrum(app,app.UIAxesDataFreq, lineSignal, samplingRate, totalsamples);
            plotspectrum(app,app.UIAxesASKFreq, timeASK,samplingRate , totalsamples);
            
            plotspectrum(app,app.UIAxesPSKFreq, timePSK, samplingRate, totalsamples);

            plotspectrum(app,app.UIAxesFSKFreq, timeFSK, samplingRate, totalsamples);

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

        % Callback function
        function DurationEditFieldValueChanged(app, event)
             updateplot(app);
            
        end

        % Callback function
        function SampleperbitEditFieldValueChanged(app, event)
            app.SpectrumScaleSlider.Limits=[0,app.SampleperbitEditField.Value/2]; 
            updateplot(app);
            
        end

        % Callback function
        function AmpitudeSliderValueChanged(app, event)
            updateplot(app);
            
        end

        % Callback function
        function FrequencySliderValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: AmpitudeSlider_C
        function AmpitudeSlider_CValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: CyclePerSymbolSlider
        function CyclePerSymbolSliderValueChanged(app, event)
            updateplot(app);
            
        end

        % Value changed function: SpectrumScaleSlider
        function SpectrumScaleSliderValueChanged(app, event)
            value = app.SpectrumScaleSlider.Value*app.fs/2/100;            
            
            %Adjust the Spectrum limit to this value 
            app.UIAxesASKFreq.XLim=[0,value];
            app.UIAxesPSKFreq.XLim=[0,value];
            app.UIAxesFSKFreq.XLim=[0,value];
        end

        % Value changed function: BitRatekbpsSlider
        function BitRatekbpsSliderValueChanged(app, event)
            %value = app.BitRatekbpsSlider.Value;
            updateplot(app);
        end

        % Value changed function: SamplePerCycleSlider
        function SamplePerCycleSliderValueChanged(app, event)
            %value = app.SamplePerCycleSlider.Value;
            updateplot(app);
        end

        % Value changed function: MessageEditField
        function MessageEditFieldValueChanged(app, event)
            %value = app.MessageEditField.Value;
            updateplot(app);
        end

        % Selection changed function: TxDataButtonGroup
        function TxDataButtonGroupSelectionChanged(app, event)
            %selectedButton = app.TxDataButtonGroup.SelectedObject;
            updateplot(app);
        end

        % Value changed function: BitTextArea
        function BitTextAreaValueChanged(app, event)
            %value = app.BitTextArea.Value;
            updateplot(app);
        end

        % Value changed function: ASKLowLevelSlider
        function ASKLowLevelSliderValueChanged(app, event)
            %value = app.ASKLowLevelSlider.Value;
            updateplot(app);
        end

        % Value changed function: FSKHighFreqFactorSpinner
        function FSKHighFreqFactorSpinnerValueChanged(app, event)
            
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
            app.UIFigure.Position = [100 100 1110 873];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesPSKTime
            app.UIAxesPSKTime = uiaxes(app.UIFigure);
            title(app.UIAxesPSKTime, 'PSK Signal')
            xlabel(app.UIAxesPSKTime, 'Time, msec')
            ylabel(app.UIAxesPSKTime, 'Amplitude')
            zlabel(app.UIAxesPSKTime, 'Z')
            app.UIAxesPSKTime.Color = [0.949 1 0.8784];
            app.UIAxesPSKTime.GridColor = [0.502 0.502 0.502];
            app.UIAxesPSKTime.XGrid = 'on';
            app.UIAxesPSKTime.YGrid = 'on';
            app.UIAxesPSKTime.Position = [270 220 460 180];

            % Create UIAxesFSKFreq
            app.UIAxesFSKFreq = uiaxes(app.UIFigure);
            title(app.UIAxesFSKFreq, 'FSK Spectrum')
            xlabel(app.UIAxesFSKFreq, 'Frequency (kHz)')
            ylabel(app.UIAxesFSKFreq, 'Amplitude')
            zlabel(app.UIAxesFSKFreq, 'Z')
            app.UIAxesFSKFreq.Color = [1 0.902 0.902];
            app.UIAxesFSKFreq.XGrid = 'on';
            app.UIAxesFSKFreq.YGrid = 'on';
            app.UIAxesFSKFreq.Position = [750 20 350 180];

            % Create UIAxesASKTime
            app.UIAxesASKTime = uiaxes(app.UIFigure);
            title(app.UIAxesASKTime, 'ASK Signal')
            xlabel(app.UIAxesASKTime, 'Time, msec')
            ylabel(app.UIAxesASKTime, 'Amplitude')
            zlabel(app.UIAxesASKTime, 'Z')
            app.UIAxesASKTime.Color = [1 1 0.949];
            app.UIAxesASKTime.XGrid = 'on';
            app.UIAxesASKTime.YGrid = 'on';
            app.UIAxesASKTime.Position = [270 420 460 180];

            % Create UIAxesASKFreq
            app.UIAxesASKFreq = uiaxes(app.UIFigure);
            title(app.UIAxesASKFreq, 'ASK, Spectrum')
            xlabel(app.UIAxesASKFreq, 'Freq (kHz)')
            ylabel(app.UIAxesASKFreq, 'Amplitude')
            zlabel(app.UIAxesASKFreq, 'Z')
            app.UIAxesASKFreq.Color = [1 1 0.949];
            app.UIAxesASKFreq.XGrid = 'on';
            app.UIAxesASKFreq.YGrid = 'on';
            app.UIAxesASKFreq.Position = [750 420 350 180];

            % Create UIAxesPSKFreq
            app.UIAxesPSKFreq = uiaxes(app.UIFigure);
            title(app.UIAxesPSKFreq, 'PSK Spectrum')
            xlabel(app.UIAxesPSKFreq, 'Freq (kHz)')
            ylabel(app.UIAxesPSKFreq, 'Amplitude')
            zlabel(app.UIAxesPSKFreq, 'Z')
            app.UIAxesPSKFreq.Color = [0.949 1 0.8784];
            app.UIAxesPSKFreq.XGrid = 'on';
            app.UIAxesPSKFreq.YGrid = 'on';
            app.UIAxesPSKFreq.Position = [750 220 350 180];

            % Create UIAxesFSKTime
            app.UIAxesFSKTime = uiaxes(app.UIFigure);
            title(app.UIAxesFSKTime, 'FSK Signal')
            xlabel(app.UIAxesFSKTime, 'Time (msec)')
            ylabel(app.UIAxesFSKTime, 'Amplitude')
            zlabel(app.UIAxesFSKTime, 'Z')
            app.UIAxesFSKTime.Color = [1 0.902 0.902];
            app.UIAxesFSKTime.XGrid = 'on';
            app.UIAxesFSKTime.YGrid = 'on';
            app.UIAxesFSKTime.Position = [270 20 460 180];

            % Create UIAxesDataTime
            app.UIAxesDataTime = uiaxes(app.UIFigure);
            title(app.UIAxesDataTime, 'Binary Data (Baseband), Time')
            xlabel(app.UIAxesDataTime, 'Time, msec')
            ylabel(app.UIAxesDataTime, 'Amplitude')
            zlabel(app.UIAxesDataTime, 'Z')
            app.UIAxesDataTime.Color = [0.9412 0.9412 0.9608];
            app.UIAxesDataTime.XGrid = 'on';
            app.UIAxesDataTime.YGrid = 'on';
            app.UIAxesDataTime.Position = [270 620 460 180];

            % Create UIAxesDataFreq
            app.UIAxesDataFreq = uiaxes(app.UIFigure);
            title(app.UIAxesDataFreq, 'Binary Data, Spectrum')
            xlabel(app.UIAxesDataFreq, 'Freq (kHz)')
            ylabel(app.UIAxesDataFreq, 'Amplitude')
            zlabel(app.UIAxesDataFreq, 'Z')
            app.UIAxesDataFreq.Color = [0.9412 0.9412 0.9608];
            app.UIAxesDataFreq.XGrid = 'on';
            app.UIAxesDataFreq.YGrid = 'on';
            app.UIAxesDataFreq.Position = [750 620 350 180];

            % Create DigitalModulationLabel
            app.DigitalModulationLabel = uilabel(app.UIFigure);
            app.DigitalModulationLabel.FontSize = 16;
            app.DigitalModulationLabel.FontWeight = 'bold';
            app.DigitalModulationLabel.FontColor = [0.6353 0.0784 0.1843];
            app.DigitalModulationLabel.Position = [38 842 144 22];
            app.DigitalModulationLabel.Text = 'Digital Modulation';

            % Create TxDataButtonGroup
            app.TxDataButtonGroup = uibuttongroup(app.UIFigure);
            app.TxDataButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @TxDataButtonGroupSelectionChanged, true);
            app.TxDataButtonGroup.ForegroundColor = [0 0.4471 0.7412];
            app.TxDataButtonGroup.Title = 'Tx Data';
            app.TxDataButtonGroup.FontWeight = 'bold';
            app.TxDataButtonGroup.Scrollable = 'on';
            app.TxDataButtonGroup.Position = [29 707 224 108];

            % Create MessageEditField
            app.MessageEditField = uieditfield(app.TxDataButtonGroup, 'text');
            app.MessageEditField.ValueChangedFcn = createCallbackFcn(app, @MessageEditFieldValueChanged, true);
            app.MessageEditField.Position = [6 59 135 22];
            app.MessageEditField.Value = 'AB';

            % Create AsciiButton
            app.AsciiButton = uiradiobutton(app.TxDataButtonGroup);
            app.AsciiButton.Text = 'Ascii';
            app.AsciiButton.Position = [154 59 65 22];
            app.AsciiButton.Value = true;

            % Create BitsButton
            app.BitsButton = uiradiobutton(app.TxDataButtonGroup);
            app.BitsButton.Text = 'Bits';
            app.BitsButton.Position = [154 34 65 22];

            % Create BitTextArea
            app.BitTextArea = uitextarea(app.TxDataButtonGroup);
            app.BitTextArea.ValueChangedFcn = createCallbackFcn(app, @BitTextAreaValueChanged, true);
            app.BitTextArea.Position = [6 8 135 46];

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.UIFigure);
            app.ParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.ParametersPanel.Title = 'Parameters';
            app.ParametersPanel.FontWeight = 'bold';
            app.ParametersPanel.Position = [30 24 223 674];

            % Create AmpitudeSlider_2Label
            app.AmpitudeSlider_2Label = uilabel(app.ParametersPanel);
            app.AmpitudeSlider_2Label.FontWeight = 'bold';
            app.AmpitudeSlider_2Label.Position = [11 340 197 22];
            app.AmpitudeSlider_2Label.Text = 'Ampitude';

            % Create AmpitudeSlider_C
            app.AmpitudeSlider_C = uislider(app.ParametersPanel);
            app.AmpitudeSlider_C.Limits = [0 10];
            app.AmpitudeSlider_C.ValueChangedFcn = createCallbackFcn(app, @AmpitudeSlider_CValueChanged, true);
            app.AmpitudeSlider_C.MinorTicks = [];
            app.AmpitudeSlider_C.Position = [7 332 205 3];
            app.AmpitudeSlider_C.Value = 1;

            % Create CyclePerBitLabel
            app.CyclePerBitLabel = uilabel(app.ParametersPanel);
            app.CyclePerBitLabel.FontWeight = 'bold';
            app.CyclePerBitLabel.Position = [17 487 187 22];
            app.CyclePerBitLabel.Text = 'Cycle Per Symbol';

            % Create CyclePerSymbolSlider
            app.CyclePerSymbolSlider = uislider(app.ParametersPanel);
            app.CyclePerSymbolSlider.Limits = [1 5];
            app.CyclePerSymbolSlider.MajorTicks = [1 2 3 4 5];
            app.CyclePerSymbolSlider.MajorTickLabels = {'1', '2', '3', '4', '5'};
            app.CyclePerSymbolSlider.ValueChangedFcn = createCallbackFcn(app, @CyclePerSymbolSliderValueChanged, true);
            app.CyclePerSymbolSlider.MinorTicks = [];
            app.CyclePerSymbolSlider.Position = [9 481 204 3];
            app.CyclePerSymbolSlider.Value = 1;

            % Create BitRatekbpsSliderLabel
            app.BitRatekbpsSliderLabel = uilabel(app.ParametersPanel);
            app.BitRatekbpsSliderLabel.FontWeight = 'bold';
            app.BitRatekbpsSliderLabel.Position = [14 561 191 22];
            app.BitRatekbpsSliderLabel.Text = 'Bit Rate (kbps)';

            % Create BitRatekbpsSlider
            app.BitRatekbpsSlider = uislider(app.ParametersPanel);
            app.BitRatekbpsSlider.Limits = [1 10];
            app.BitRatekbpsSlider.MajorTicks = [1 2 3 4 5 6 7 8 9 10];
            app.BitRatekbpsSlider.MajorTickLabels = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'};
            app.BitRatekbpsSlider.ValueChangedFcn = createCallbackFcn(app, @BitRatekbpsSliderValueChanged, true);
            app.BitRatekbpsSlider.MinorTicks = [];
            app.BitRatekbpsSlider.Position = [8 554 204 3];
            app.BitRatekbpsSlider.Value = 1;

            % Create ModulationLevelButtonGroup
            app.ModulationLevelButtonGroup = uibuttongroup(app.ParametersPanel);
            app.ModulationLevelButtonGroup.Title = 'Modulation Level';
            app.ModulationLevelButtonGroup.Position = [1 596 223 47];

            % Create BinaryButton
            app.BinaryButton = uiradiobutton(app.ModulationLevelButtonGroup);
            app.BinaryButton.Tag = '2';
            app.BinaryButton.Text = 'Binary';
            app.BinaryButton.Position = [11 1 58 22];
            app.BinaryButton.Value = true;

            % Create aryButton
            app.aryButton = uiradiobutton(app.ModulationLevelButtonGroup);
            app.aryButton.Tag = '4';
            app.aryButton.Text = '4-ary';
            app.aryButton.Position = [81 1 65 22];

            % Create SamplePerCycleSliderLabel
            app.SamplePerCycleSliderLabel = uilabel(app.ParametersPanel);
            app.SamplePerCycleSliderLabel.FontWeight = 'bold';
            app.SamplePerCycleSliderLabel.Position = [11 417 184 22];
            app.SamplePerCycleSliderLabel.Text = 'Sample Per Cycle';

            % Create SamplePerCycleSlider
            app.SamplePerCycleSlider = uislider(app.ParametersPanel);
            app.SamplePerCycleSlider.Limits = [2 20];
            app.SamplePerCycleSlider.MajorTicks = [2 4 6 8 10 12 14 16 18 20];
            app.SamplePerCycleSlider.MajorTickLabels = {'2', '4', '6', '8', '10', '12', '14', '16', '18', '20'};
            app.SamplePerCycleSlider.ValueChangedFcn = createCallbackFcn(app, @SamplePerCycleSliderValueChanged, true);
            app.SamplePerCycleSlider.MinorTicks = [];
            app.SamplePerCycleSlider.Position = [8 409 204 3];
            app.SamplePerCycleSlider.Value = 10;

            % Create SpectrumScaleLabel
            app.SpectrumScaleLabel = uilabel(app.ParametersPanel);
            app.SpectrumScaleLabel.HorizontalAlignment = 'right';
            app.SpectrumScaleLabel.FontWeight = 'bold';
            app.SpectrumScaleLabel.Position = [8 260 117 22];
            app.SpectrumScaleLabel.Text = 'Spectrum Scale (%)';

            % Create SpectrumScaleSlider
            app.SpectrumScaleSlider = uislider(app.ParametersPanel);
            app.SpectrumScaleSlider.Limits = [1 100];
            app.SpectrumScaleSlider.MajorTicks = [1 10 20 30 40 50 60 70 80 90 100];
            app.SpectrumScaleSlider.ValueChangedFcn = createCallbackFcn(app, @SpectrumScaleSliderValueChanged, true);
            app.SpectrumScaleSlider.MinorTicks = [];
            app.SpectrumScaleSlider.Position = [8 249 200 3];
            app.SpectrumScaleSlider.Value = 100;

            % Create CalculatedValuesPanel
            app.CalculatedValuesPanel = uipanel(app.ParametersPanel);
            app.CalculatedValuesPanel.ForegroundColor = [0.549 0.2118 0.0667];
            app.CalculatedValuesPanel.Title = 'Calculated Values';
            app.CalculatedValuesPanel.FontWeight = 'bold';
            app.CalculatedValuesPanel.Position = [1 1 222 89];

            % Create CarrierFreqLabel
            app.CarrierFreqLabel = uilabel(app.CalculatedValuesPanel);
            app.CarrierFreqLabel.FontWeight = 'bold';
            app.CarrierFreqLabel.FontColor = [0.0157 0.298 0.4902];
            app.CarrierFreqLabel.Position = [0 23 218 22];
            app.CarrierFreqLabel.Text = 'Carrier Freq: ';

            % Create SymbolRateLabel
            app.SymbolRateLabel = uilabel(app.CalculatedValuesPanel);
            app.SymbolRateLabel.FontWeight = 'bold';
            app.SymbolRateLabel.FontColor = [0.0157 0.298 0.4902];
            app.SymbolRateLabel.Position = [1 44 216 22];
            app.SymbolRateLabel.Text = 'Symbol Rate: ';

            % Create SamplingRateLabel
            app.SamplingRateLabel = uilabel(app.CalculatedValuesPanel);
            app.SamplingRateLabel.FontWeight = 'bold';
            app.SamplingRateLabel.FontColor = [0.0157 0.298 0.4902];
            app.SamplingRateLabel.Position = [2 1 215 22];
            app.SamplingRateLabel.Text = 'Sampling Rate: ';

            % Create ASKLowLevelSliderLabel
            app.ASKLowLevelSliderLabel = uilabel(app.ParametersPanel);
            app.ASKLowLevelSliderLabel.HorizontalAlignment = 'right';
            app.ASKLowLevelSliderLabel.FontWeight = 'bold';
            app.ASKLowLevelSliderLabel.Position = [5 178 117 22];
            app.ASKLowLevelSliderLabel.Text = 'ASK Low  Level (%)';

            % Create ASKLowLevelSlider
            app.ASKLowLevelSlider = uislider(app.ParametersPanel);
            app.ASKLowLevelSlider.ValueChangedFcn = createCallbackFcn(app, @ASKLowLevelSliderValueChanged, true);
            app.ASKLowLevelSlider.MinorTicks = [];
            app.ASKLowLevelSlider.Position = [9 172 199 3];
            app.ASKLowLevelSlider.Value = 10;

            % Create FSKHighFreqFactorSpinnerLabel
            app.FSKHighFreqFactorSpinnerLabel = uilabel(app.ParametersPanel);
            app.FSKHighFreqFactorSpinnerLabel.HorizontalAlignment = 'right';
            app.FSKHighFreqFactorSpinnerLabel.FontWeight = 'bold';
            app.FSKHighFreqFactorSpinnerLabel.Position = [5 100 135 22];
            app.FSKHighFreqFactorSpinnerLabel.Text = 'FSK High Freq Factor';

            % Create FSKHighFreqFactorSpinner
            app.FSKHighFreqFactorSpinner = uispinner(app.ParametersPanel);
            app.FSKHighFreqFactorSpinner.Limits = [2 4];
            app.FSKHighFreqFactorSpinner.ValueChangedFcn = createCallbackFcn(app, @FSKHighFreqFactorSpinnerValueChanged, true);
            app.FSKHighFreqFactorSpinner.Position = [146 100 72 22];
            app.FSKHighFreqFactorSpinner.Value = 2;

            % Create Image2
            app.Image2 = uiimage(app.UIFigure);
            app.Image2.Position = [28 814 1079 29];
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [35 1 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Create Image3
            app.Image3 = uiimage(app.UIFigure);
            app.Image3.Position = [252 37 26 780];
            app.Image3.ImageSource = fullfile(pathToMLAPP, 'img', 'vline.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = DigitalModulationApp

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