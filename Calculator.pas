unit Calculator;

interface

type
  TMathOperator = (opUnknown, opMultiply, opDivide, opAdd, opSubtract);

  TCalculator = class(TObject)
  strict private
    FFirstTerm: Double;
    FSecondTerm: Double;
    FMathOperator: TMathOperator;
    FHaveFirstTerm: Boolean;
    procedure SetFirstTerm(const Value: Double);
  public
    function Calc: Double;
    procedure Clear;
    function CanCalc: Boolean;

    property FirstTerm :Double write SetFirstTerm;
    property SecondTerm: Double write FSecondTerm;
    property HaveFirstTerm: Boolean read FHaveFirstTerm;
    property MathOperator: TMathOperator read FMathOperator write FMathOperator;
  end;

implementation

uses
  System.SysUtils;

{ TCalculator }

function TCalculator.CanCalc: Boolean;
begin
  //we will always have a first term of 0 unless it is replaced by the user
  //so in order to calculate we need an operator and the second term will be the display value
  Result := (MathOperator <> TMathOperator.opUnknown) and FHaveFirstTerm;
end;

function TCalculator.Calc: Double;
begin
  case FMathOperator of
    opMultiply: Result := FFirstTerm * FSecondTerm;
    opDivide: Result := FFirstTerm / FSecondTerm;
    opAdd: Result := FFirstTerm + FSecondTerm;
    opSubtract: Result := FFirstTerm - FSecondTerm;
    opUnknown: raise Exception.Create('Operator Unknown');
    else
      raise Exception.Create('Unknown Operator');
  end;

  //the result of a calculation becomes the first term for subsequent calcs
  FMathOperator := opUnknown;
  FSecondTerm := 0;
end;

procedure TCalculator.Clear;
begin
  FirstTerm := 0;
  SecondTerm := 0;

  FHaveFirstTerm := False;
  MathOperator := opUnknown;
end;

procedure TCalculator.SetFirstTerm(const Value: Double);
begin
  FFirstTerm := Value;
  FHaveFirstTerm := True;
end;


end.
