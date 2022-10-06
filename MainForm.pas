unit MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, Calculator,
  System.ImageList, FMX.ImgList, FMX.Objects;

const
  ZeroValue = '0';
  LeadingZeroDecimal ='0.';

type
  TTermState = (Appending, New);
  ///
  ///  Summary
  ///  The calculator form displays the current term and gathers input for the
  ///  Calculator object ensuring it can be converted to a double value and is
  ///  provided to the Calculator at the proper time (manages input state).
  ///
  TCalculatorForm = class(TForm)
    btnCE: TButton;
    btnC: TButton;
    btnBackSpace: TButton;
    btnDivide: TButton;
    btn7: TButton;
    btn8: TButton;
    btn9: TButton;
    btnMultiply: TButton;
    btn4: TButton;
    btn5: TButton;
    btn6: TButton;
    btnSubtract: TButton;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btnAdd: TButton;
    btnInvertSign: TButton;
    btn0: TButton;
    btnDecimal: TButton;
    btnEqual: TButton;
    edDisplay: TEdit;
    Image1: TImage;
    procedure btnNumericClick(Sender: TObject);
    procedure btnDecimalClick(Sender: TObject);
    procedure btnCEClick(Sender: TObject);
    procedure btnBackSpaceClick(Sender: TObject);
    procedure btnOperatorClick(Sender: TObject);
    procedure btnEqualClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnInvertSignClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  strict private
    FCalculator: TCalculator;
    FTermState: TTermState;
    procedure DisplayZero;
    procedure ApplyOperator(MathOperator: TMathOperator);
    procedure ApplyNumericInput(const InputText: string);
    procedure Calculate;
    procedure ApplyDecimal;
    procedure ApplyBackspace;
    procedure ClearAll;
  public
  end;

var
  CalculatorForm: TCalculatorForm;

implementation

{$R *.fmx}

procedure TCalculatorForm.ApplyBackspace;
begin
  if (edDisplay.Text.Length = 1) then
    DisplayZero
  else
    edDisplay.Text := edDisplay.Text.Substring(0, edDisplay.Text.Length - 1);
end;

procedure TCalculatorForm.btnBackSpaceClick(Sender: TObject);
begin
  ApplyBackspace;
end;

procedure TCalculatorForm.ClearAll;
begin
  FCalculator.Clear;
  DisplayZero;
end;

procedure TCalculatorForm.btnCClick(Sender: TObject);
begin
  ClearAll;
end;

procedure TCalculatorForm.btnCEClick(Sender: TObject);
begin
  //clears the entry which is effectively the displayed value
  DisplayZero;
end;

procedure TCalculatorForm.ApplyDecimal;
begin
  if (FTermState = New) then
  begin
    edDisplay.Text := LeadingZeroDecimal;
    FTermState := Appending;
  end
  else
  if not edDisplay.Text.Contains('.') then //can only contain 1 decimal
    edDisplay.Text := edDisplay.Text + '.';
end;

procedure TCalculatorForm.btnDecimalClick(Sender: TObject);
begin
  ApplyDecimal;
end;

procedure TCalculatorForm.ApplyNumericInput(const InputText: string);
begin
  if (FTermState = New) then
  begin
    edDisplay.Text := InputText;
    FTermState := Appending;
  end
  else
    edDisplay.Text := edDisplay.Text + InputText;
end;

procedure TCalculatorForm.btnNumericClick(Sender: TObject);
begin
  ApplyNumericInput((Sender as TButton).Text);
end;

procedure TCalculatorForm.Calculate;
begin
  //ensure we can calculate assuming the displayvalue is the second term
  if FCalculator.CanCalc then
  try
    FCalculator.SecondTerm := StrToFloat(edDisplay.Text);
    edDisplay.Text := FloatToStr(FCalculator.Calc);
  except
    ;
  end;
end;

procedure TCalculatorForm.btnEqualClick(Sender: TObject);
begin
  Calculate;
end;

procedure TCalculatorForm.btnInvertSignClick(Sender: TObject);
begin
  //toggle sign of current display value
  if (Pos('-', edDisplay.Text, 1) = 1) then
    edDisplay.Text := copy(edDisplay.Text, 2)
  else //explicitly positive
  if (Pos('+', edDisplay.Text, 1) = 1) then
    edDisplay.Text := '-'+ edDisplay.Text
  else //implicitly positive
    edDisplay.Text := '-'+ edDisplay.Text;
end;

procedure TCalculatorForm.ApplyOperator(MathOperator :TMathOperator);
begin
  //if we have both terms
  Calculate;

  //Sets calculator operand and first term
  try
    FCalculator.FirstTerm := StrToFloat(edDisplay.Text);
    FCalculator.MathOperator := MathOperator;
    FTermState := New;
  except
    ;
  end;
end;

procedure TCalculatorForm.btnOperatorClick(Sender: TObject);
begin
  ApplyOperator(TMathOperator((Sender as TButton).Tag));
end;

procedure TCalculatorForm.DisplayZero;
begin
  edDisplay.Text := ZeroValue;
  FTermState := New;
end;

procedure TCalculatorForm.FormCreate(Sender: TObject);
begin
  FCalculator := TCalculator.Create;

  //setup operator Tag values so we know what operator to use when the button is clicked
  btnMultiply.Tag := Ord(TMathOperator.opMultiply);
  btnDivide.Tag := Ord(TMathOperator.opDivide);
  btnSubtract.Tag := Ord(TMathOperator.opSubtract);
  btnAdd.Tag := Ord(TMathOperator.opAdd);

  //change mainform window appearance based on target OS
  {$ifdef LINUX}
    BorderIcons := [];
  {$endif}
  {$ifdef WINDOWS}
    BorderIcons := [biSystemMenu];  //shows close button
  {$endif}
end;

procedure TCalculatorForm.FormDestroy(Sender: TObject);
begin
  FCalculator.Free;
end;

procedure TCalculatorForm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkEscape) then
    ClearAll
  else
  if (Key = vkBack) then
    ApplyBackspace
  else
  if CharInSet(KeyChar, ['0'..'9']) then
    ApplyNumericInput(KeyChar)
  else
  if KeyChar = '*' then
    ApplyOperator(TMathOperator.opMultiply)
  else
  if KeyChar = '+' then
    ApplyOperator(TMathOperator.opAdd)
  else
  if KeyChar = '/' then
    ApplyOperator(TMathOperator.opDivide)
  else
  if KeyChar = '-' then
    ApplyOperator(TMathOperator.opSubtract)
  else
  if KeyChar = '.' then
    ApplyDecimal
  else
  if (Key = vkReturn) or (KeyChar = '=') then
    Calculate;
end;

procedure TCalculatorForm.FormShow(Sender: TObject);
begin
  DisplayZero;
end;

end.
