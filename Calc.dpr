program Calc;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {CalculatorForm},
  Calculator in 'Calculator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TCalculatorForm, CalculatorForm);
  Application.Run;
end.
