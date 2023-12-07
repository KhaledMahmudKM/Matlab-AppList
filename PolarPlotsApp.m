classdef PolarPlotsApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        cKhaledMahmud2023Label   matlab.ui.control.Label
        Image                    matlab.ui.control.Image
        SamplesDropDown          matlab.ui.control.DropDown
        SamplesDropDownLabel     matlab.ui.control.Label
        PolarPlotPanel           matlab.ui.container.Panel
        PlotPolarEquationsLabel  matlab.ui.control.Label
        PolarEquation            matlab.ui.control.EditField
        EnterPolarEquationMatlabsyntaxLabel  matlab.ui.control.Label
        UpdatePlotButton         matlab.ui.control.Button
    end

    
    properties (Access = private)
        Pax 
    end
    
    methods (Access = private)
        
        function updateplot(app)
            pEquation=app.PolarEquation.Value;
            %ezpolar(app.Pax,pEquation);
            t = 0:0.01:2*pi;
            try 
                rho=eval(pEquation);
                polarplot(app.Pax,t,rho);
            catch 
                %opts = 'modal';%struct('WindowStyle','modal', 'Interpreter','none');
                %f = errordlg('Invalid expression', 'Exp Error',opts);
                %uiwait(f);
                uialert(app.UIFigure, "Invalid Expression", "Error");
            end
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.Pax = polaraxes(app.PolarPlotPanel);
            updateplot(app);
        end

        % Button pushed function: UpdatePlotButton
        function UpdatePlotButtonPushed(app, event)
            updateplot(app);
        end

        % Value changed function: SamplesDropDown
        function SamplesDropDownValueChanged(app, event)
            value = app.SamplesDropDown.Value;
            app.PolarEquation.Value=value;
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
            app.UIFigure.Position = [100 100 693 664];
            app.UIFigure.Name = 'MATLAB App';

            % Create UpdatePlotButton
            app.UpdatePlotButton = uibutton(app.UIFigure, 'push');
            app.UpdatePlotButton.ButtonPushedFcn = createCallbackFcn(app, @UpdatePlotButtonPushed, true);
            app.UpdatePlotButton.FontWeight = 'bold';
            app.UpdatePlotButton.FontColor = [0 0.4471 0.7412];
            app.UpdatePlotButton.Position = [32 517 100 22];
            app.UpdatePlotButton.Text = 'Update Plot';

            % Create EnterPolarEquationMatlabsyntaxLabel
            app.EnterPolarEquationMatlabsyntaxLabel = uilabel(app.UIFigure);
            app.EnterPolarEquationMatlabsyntaxLabel.Position = [37 571 203 22];
            app.EnterPolarEquationMatlabsyntaxLabel.Text = 'Enter Polar Equation (Matlab syntax)';

            % Create PolarEquation
            app.PolarEquation = uieditfield(app.UIFigure, 'text');
            app.PolarEquation.Position = [32 550 640 22];
            app.PolarEquation.Value = '1+cos(t)';

            % Create PlotPolarEquationsLabel
            app.PlotPolarEquationsLabel = uilabel(app.UIFigure);
            app.PlotPolarEquationsLabel.FontSize = 16;
            app.PlotPolarEquationsLabel.FontWeight = 'bold';
            app.PlotPolarEquationsLabel.FontColor = [0.6353 0.0784 0.1843];
            app.PlotPolarEquationsLabel.Position = [32 620 168 22];
            app.PlotPolarEquationsLabel.Text = 'Plot Polar Equations';

            % Create PolarPlotPanel
            app.PolarPlotPanel = uipanel(app.UIFigure);
            app.PolarPlotPanel.ForegroundColor = [0.0392 0.3373 0.5412];
            app.PolarPlotPanel.Title = 'Polar Plot';
            app.PolarPlotPanel.FontWeight = 'bold';
            app.PolarPlotPanel.Position = [32 25 640 484];

            % Create SamplesDropDownLabel
            app.SamplesDropDownLabel = uilabel(app.UIFigure);
            app.SamplesDropDownLabel.HorizontalAlignment = 'right';
            app.SamplesDropDownLabel.Position = [328 571 56 22];
            app.SamplesDropDownLabel.Text = 'Samples';

            % Create SamplesDropDown
            app.SamplesDropDown = uidropdown(app.UIFigure);
            app.SamplesDropDown.Items = {'1+cos(t)', '1+cos(t)+cos(2*t)', '1+cos(t).^2', '1+cos(3*t).*sin(2*t)', '1+cos(t)+cos(2*t)+cos(3*t)+cos(4*t)+cos(5*t)'};
            app.SamplesDropDown.ValueChangedFcn = createCallbackFcn(app, @SamplesDropDownValueChanged, true);
            app.SamplesDropDown.Position = [393 571 279 22];
            app.SamplesDropDown.Value = '1+cos(t)';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [29 601 652 21];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'img', 'hline.png');

            % Create cKhaledMahmud2023Label
            app.cKhaledMahmud2023Label = uilabel(app.UIFigure);
            app.cKhaledMahmud2023Label.FontSize = 10;
            app.cKhaledMahmud2023Label.FontAngle = 'italic';
            app.cKhaledMahmud2023Label.Position = [10 2 176 24];
            app.cKhaledMahmud2023Label.Text = '(c) Khaled Mahmud, 2023';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PolarPlotsApp

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