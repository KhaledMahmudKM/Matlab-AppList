classdef DSSSApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        cKhaledMahmud2023Label        matlab.ui.control.Label
        Image                         matlab.ui.control.Image
        DirectSequenceSpreadSpectrumSignalLabel  matlab.ui.control.Label
        SimulationParametersPanel     matlab.ui.container.Panel
        DataBitsEditField             matlab.ui.control.EditField
        DataBitsLabel                 matlab.ui.control.Label
        UpdatePlotsButton             matlab.ui.control.Button
        SampleperchipEditField        matlab.ui.control.NumericEditField
        SampleperchiipEditFieldLabel  matlab.ui.control.Label
        PNCodeEditField               matlab.ui.control.EditField
        PNCodeEditFieldLabel          matlab.ui.control.Label
        BitrateEditField              matlab.ui.control.NumericEditField
        BitrateEditFieldLabel         matlab.ui.control.Label
        SpectrumScaleSlider           matlab.ui.control.Slider
        SpectrumScaleSliderLabel      matlab.ui.control.Label
        UIAxesSpreadSignalFreq        matlab.ui.control.UIAxes
        UIAxesPNCodeFreq              matlab.ui.control.UIAxes
        UIAxesDataBitsFreq            matlab.ui.control.UIAxes
        UIAxesSpreadSignalTime        matlab.ui.control.UIAxes
        UIAxesPNCodeTime              matlab.ui.control.UIAxes
        UIAxesDataBitsTime            matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        samplingrate % Description
    end
    
    methods (Access = private)
        
        function digital_signal=NRZcode(app,bitarray, sampleperbit)
            %Non return to zero line code signal generator
            % +1 V means 1
            % -1 V means 1
            
            n=1:sampleperbit;
            t = 0:1/sampleperbit:1-1/sampleperbit; %time samples 
            OneLevel=ones(1,sampleperbit);   
            ZeroLevel=-ones(1,sampleperbit);
            
            digital_signal=[];
            
            for i=1:length(bitarray)
                if(bitarray(i)==1)
                    digital_signal=[digital_signal OneLevel];
                else
                    digital_signal=[digital_signal ZeroLevel];
                end
            
            end
            
        end
        
        function updateplot(app)
            %Read data bits
            %databits=[1 0 1 1 0 0 0 1 ];
            value=char(app.DataBitsEditField.Value);
            value=value';
            databits=str2num(value);
            databits=databits';
            n=length(databits);
            
            %Read PN code
            %pncode=[1 0 1 0 1 1 0 1];
            value=char(app.PNCodeEditField.Value);
            value=value';
            pncode=str2num(value);
            pncode=pncode';
            chipperbit=length(pncode);
            
            sampleperchip=app.SampleperchipEditField.Value;
            
            bitrate= app.BitrateEditField.Value;
            app.samplingrate=bitrate*chipperbit*sampleperchip;
            app.SpectrumScaleSlider.Value=100; %Reset 100%;
      
            code_signal=NRZcode(pncode, sampleperchip);
            
            pncode_all=code_signal'*ones(1,n);
            pncode_all=reshape(pncode_all,1,[]);
            
            sampleperbit=sampleperchip*chipperbit;
            data_signal=NRZcode(databits, sampleperbit);
            spread_signal=data_signal.*pncode_all;      %Just multiply
                       
            ts=1/app.samplingrate;      %Sample period
            t=[1:length(pncode_all)]*ts;    %Time scale
            
            %Plot time signals
            plot(app.UIAxesDataBitsTime,t,data_signal);
            plot(app.UIAxesPNCodeTime, t,pncode_all);
            plot(app.UIAxesSpreadSignalTime, t,spread_signal);
            
            
            %Plot Spectrum
            totalsamples=length(data_signal);
            
            plotspectrum(app,app.UIAxesDataBitsFreq, data_signal, app.samplingrate, totalsamples);
            plotspectrum(app,app.UIAxesPNCodeFreq, pncode_all, app.samplingrate, totalsamples);
            plotspectrum(app,app.UIAxesSpreadSignalFreq, spread_signal, app.samplingrate, totalsamples);
            
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

        % Button pushed function: UpdatePlotsButton
        function UpdatePlotsButtonPushed(app, event)
            updateplot(app)
        end

        % Value changed function: SpectrumScaleSlider
        function SpectrumScaleSliderValueChanged(app, event)
            value = app.SpectrumScaleSlider.Value*app.samplingrate/2/100;
            %Adjust the Spectrum limit to this value 
            app.UIAxesDataBitsFreq.XLim=[0,value];
            app.UIAxesPNCodeFreq.XLim=[0,value];
            app.UIAxesSpreadSignalFreq.XLim=[0,value];
        end

        % Value changed function: BitrateEditField
        function BitrateEditFieldValueChanged(app, event)
            
            updateplot(app)
        end

        % Value changed function: SampleperchipEditField
        function SampleperchipEditFieldValueChanged(app, event)
            updateplot(app)
            
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
            app.UIFigure.Position = [100 100 1145 790];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxesDataBitsTime
            app.UIAxesDataBitsTime = uiaxes(app.UIFigure);
            title(app.UIAxesDataBitsTime, 'Data Bits')
            xlabel(app.UIAxesDataBitsTime, 'Time, sec')
            ylabel(app.UIAxesDataBitsTime, 'Amplitude')
            zlabel(app.UIAxesDataBitsTime, 'Z')
            app.UIAxesDataBitsTime.Position = [28 423 732 185];

            % Create UIAxesPNCodeTime
            app.UIAxesPNCodeTime = uiaxes(app.UIFigure);
            title(app.UIAxesPNCodeTime, 'PN Code')
            xlabel(app.UIAxesPNCodeTime, 'Time, sec')
            ylabel(app.UIAxesPNCodeTime, 'Amplitude')
            zlabel(app.UIAxesPNCodeTime, 'Z')
            app.UIAxesPNCodeTime.Position = [24 229 732 185];

            % Create UIAxesSpreadSignalTime
            app.UIAxesSpreadSignalTime = uiaxes(app.UIFigure);
            title(app.UIAxesSpreadSignalTime, 'Spread Signal')
            xlabel(app.UIAxesSpreadSignalTime, 'Time, sec')
            ylabel(app.UIAxesSpreadSignalTime, 'Amplitude')
            zlabel(app.UIAxesSpreadSignalTime, 'Z')
            app.UIAxesSpreadSignalTime.Position = [24 34 732 185];

            % Create UIAxesDataBitsFreq
            app.UIAxesDataBitsFreq = uiaxes(app.UIFigure);
            title(app.UIAxesDataBitsFreq, 'Data Spectrum')
            xlabel(app.UIAxesDataBitsFreq, 'Freq. Hz')
            ylabel(app.UIAxesDataBitsFreq, 'Amplitude')
            zlabel(app.UIAxesDataBitsFreq, 'Z')
            app.UIAxesDataBitsFreq.Position = [759 423 375 185];

            % Create UIAxesPNCodeFreq
            app.UIAxesPNCodeFreq = uiaxes(app.UIFigure);
            title(app.UIAxesPNCodeFreq, 'PN Code Spectrum')
            xlabel(app.UIAxesPNCodeFreq, 'Freq, Hz')
            ylabel(app.UIAxesPNCodeFreq, 'Amplitude')
            zlabel(app.UIAxesPNCodeFreq, 'Z')
            app.UIAxesPNCodeFreq.PlotBoxAspectRatio = [2.50381679389313 1 1];
            app.UIAxesPNCodeFreq.Position = [755 229 379 185];

            % Create UIAxesSpreadSignalFreq
            app.UIAxesSpreadSignalFreq = uiaxes(app.UIFigure);
            title(app.UIAxesSpreadSignalFreq, 'Spread Signal Spectrum')
            xlabel(app.UIAxesSpreadSignalFreq, 'Freq, Hz')
            ylabel(app.UIAxesSpreadSignalFreq, 'Amplitude')
            zlabel(app.UIAxesSpreadSignalFreq, 'Z')
            app.UIAxesSpreadSignalFreq.Position = [755 34 375 185];

            % Create SpectrumScaleSliderLabel
            app.SpectrumScaleSliderLabel = uilabel(app.UIFigure);
            app.SpectrumScaleSliderLabel.HorizontalAlignment = 'right';
            app.SpectrumScaleSliderLabel.Position = [798 673 124 22];
            app.SpectrumScaleSliderLabel.Text = 'Spectrum Scale Slider';

            % Create SpectrumScaleSlider
            app.SpectrumScaleSlider = uislider(app.UIFigure);
            app.SpectrumScaleSlider.Limits = [1 100];
            app.SpectrumScaleSlider.MajorTicks = [0 10 20 30 40 50 60 70 80 90 100];
            app.SpectrumScaleSlider.MajorTickLabels = {'0', '10', '20', '30', '40', '50', '60', '70', '80', '90', '100'};
            app.SpectrumScaleSlider.ValueChangedFcn = createCallbackFcn(app, @SpectrumScaleSliderValueChanged, true);
            app.SpectrumScaleSlider.MinorTicks = [];
            app.SpectrumScaleSlider.Position = [809 668 310 3];
            app.SpectrumScaleSlider.Value = 100;

            % Create SimulationParametersPanel
            app.SimulationParametersPanel = uipanel(app.UIFigure);
            app.SimulationParametersPanel.ForegroundColor = [0 0.4471 0.7412];
            app.SimulationParametersPanel.Title = 'Simulation Parameters';
            app.SimulationParametersPanel.FontWeight = 'bold';
            app.SimulationParametersPanel.Position = [65 617 679 114];

            % Create BitrateEditFieldLabel
            app.BitrateEditFieldLabel = uilabel(app.SimulationParametersPanel);
            app.BitrateEditFieldLabel.HorizontalAlignment = 'right';
            app.BitrateEditFieldLabel.Position = [559 63 44 22];
            app.BitrateEditFieldLabel.Text = 'Bit rate';

            % Create BitrateEditField
            app.BitrateEditField = uieditfield(app.SimulationParametersPanel, 'numeric');
            app.BitrateEditField.ValueChangedFcn = createCallbackFcn(app, @BitrateEditFieldValueChanged, true);
            app.BitrateEditField.Position = [618 63 48 22];
            app.BitrateEditField.Value = 1000;

            % Create PNCodeEditFieldLabel
            app.PNCodeEditFieldLabel = uilabel(app.SimulationParametersPanel);
            app.PNCodeEditFieldLabel.HorizontalAlignment = 'right';
            app.PNCodeEditFieldLabel.Position = [8 63 54 22];
            app.PNCodeEditFieldLabel.Text = 'PN Code';

            % Create PNCodeEditField
            app.PNCodeEditField = uieditfield(app.SimulationParametersPanel, 'text');
            app.PNCodeEditField.Position = [77 63 315 22];
            app.PNCodeEditField.Value = '10101101';

            % Create SampleperchiipEditFieldLabel
            app.SampleperchiipEditFieldLabel = uilabel(app.SimulationParametersPanel);
            app.SampleperchiipEditFieldLabel.HorizontalAlignment = 'right';
            app.SampleperchiipEditFieldLabel.Position = [391 63 95 22];
            app.SampleperchiipEditFieldLabel.Text = 'Sample per chiip';

            % Create SampleperchipEditField
            app.SampleperchipEditField = uieditfield(app.SimulationParametersPanel, 'numeric');
            app.SampleperchipEditField.Limits = [4 20];
            app.SampleperchipEditField.ValueChangedFcn = createCallbackFcn(app, @SampleperchipEditFieldValueChanged, true);
            app.SampleperchipEditField.Position = [501 63 39 22];
            app.SampleperchipEditField.Value = 4;

            % Create UpdatePlotsButton
            app.UpdatePlotsButton = uibutton(app.SimulationParametersPanel, 'push');
            app.UpdatePlotsButton.ButtonPushedFcn = createCallbackFcn(app, @UpdatePlotsButtonPushed, true);
            app.UpdatePlotsButton.FontWeight = 'bold';
            app.UpdatePlotsButton.FontColor = [0.6353 0.0784 0.1843];
            app.UpdatePlotsButton.Position = [566 14 100 22];
            app.UpdatePlotsButton.Text = 'Update Plots';

            % Create DataBitsLabel
            app.DataBitsLabel = uilabel(app.SimulationParametersPanel);
            app.DataBitsLabel.HorizontalAlignment = 'right';
            app.DataBitsLabel.Position = [8 14 54 22];
            app.DataBitsLabel.Text = 'Data Bits';

            % Create DataBitsEditField
            app.DataBitsEditField = uieditfield(app.SimulationParametersPanel, 'text');
            app.DataBitsEditField.Position = [77 14 399 22];
            app.DataBitsEditField.Value = '10110001';

            % Create DirectSequenceSpreadSpectrumSignalLabel
            app.DirectSequenceSpreadSpectrumSignalLabel = uilabel(app.UIFigure);
            app.DirectSequenceSpreadSpectrumSignalLabel.FontSize = 16;
            app.DirectSequenceSpreadSpectrumSignalLabel.FontWeight = 'bold';
            app.DirectSequenceSpreadSpectrumSignalLabel.FontColor = [0.6353 0.0784 0.1843];
            app.DirectSequenceSpreadSpectrumSignalLabel.Position = [73 746 324 38];
            app.DirectSequenceSpreadSpectrumSignalLabel.Text = 'Direct Sequence Spread Spectrum Signal';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [65 730 691 17];
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
        function app = DSSSApp

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