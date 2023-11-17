unit kitesolver;

{$mode objfpc}{$h+}

interface

uses
  ADim, Classes, Dialogs, SysUtils, TASeries;

// length  [m    ]
// mass    [kg   ]
// force   [N    ]
// angle   [rad  ]
// density [kg/m2]
//         [kg/m3]

const
  Gravity : TMetersPerSecondSquared = (FValue: 9.807);

type
  TKite = class
  private
    fLog: TStrings;

    fAirRo: TKilogramsPerCubicMeter; // air density
    fAirSpeed: TMetersPerSecond; // air velocity
    fAspectRatio: double; // aspect ratio
    fAttackAngle: TRadians; // attack angle

    fCd: double; // drag coefficent
    fCg: TMeters; // kite center of gravity
    fCl: double; // lift coefficent
    fCp: TMeters; // kite center of pressure

    fDrag: TNewtons; // drag force
    fLift: TNewtons; // lift force
    fTorque: TNewtonMeters; // torque
    fWeight: TNewtons; // weigth force

    fLine: TMeters; // line length
    fLineRo: TKilogramsPerMeter; // line density
    fLineWeight: TKilograms; //line weigth

    fSail: TSquareMeters; // surface area
    fSailRo: TKilogramsPerSquareMeter; // sail density

    fTail: TMeters; // tail length
    fTailRo: TKilogramsPerMeter; // tail density
    fTailWeight: TKilograms; // tail weight

    fB: TMeters;
    fK: TMeters;
    fHeigth1: TMeters;
    fWidth1: TMeters;
    fKnotAngle: TRadians;

    fXb: TMeters;
    fYb: TMeters;
    fXKite: TMeters;
    fYKite: TMeters;

    fDragSeries: TLineSeries;
    fLiftSeries: TLineSeries;
    fLineSeries: TLineSeries;
    fTorqSeries: TLineSeries;
    fTension: TNewtons;
  public
    constructor Create(Log: TStrings);
    function Init: boolean; virtual; abstract;
    function Solve(const aAngle: TRadians): boolean;
    function Solve: boolean;
    function CalcKnotAngle(const aHeight: TMeters): boolean;
    function CalcTorque(const aAngle: TRadians): TNewtonMeters; // calculate torque
  public
    property AirRo: TKilogramsPerCubicMeter read fAirRo write fAirRo;
    property AirSpeed: TMetersPerSecond read fAirSpeed write fAirSpeed;

    property Area: TSquareMeters read fSail;
    property AreaRo: TKilogramsPErSquareMeter read fSailRo write fSailRo;

    property AspectRatio: double read fAspectRatio;
    property AttackAngle: TRadians read fAttackAngle;

    property Drag: TNewtons read fDrag;
    property Lift: TNewtons read fLift;
    property Torque: TNewtonMeters read fTorque;
    property Weight: TNewtons read fWeight;

    property Line: TMeters read fLine write fLine;
    property LineRo: TKilogramsPerMeter read fLineRo write fLineRo;
    property LineWeight: TKilograms read fLineWeight;

    property Tail: TMeters read fTail write fTail;
    property TailRo: TKilogramsPerMeter read fTailRo write fTailRo;
    property TailWeight: TKilograms read fTailWeight;

    property B: TMeters read fB write fB;
    property K: TMeters read fK write fK;

    property Xb: TMeters read fXb;
    property Yb: TMeters read fYb;

    property XKite: TMeters read fXKite;
    property YKite: TMeters read fYKite;

    property Heigth1: TMeters write fHeigth1;
    property Width1: TMeters write fWidth1;

    property Drags: TLineSeries write fDragSeries;
    property Lifts: TLineSeries write fLiftSeries;
    property Lines: TLineSeries write fLineSeries;
    property Torqs: TLineSeries write fTorqSeries;
    property Tension: TNewtons read fTension;
  end;

  TKiteDiamond = class(TKite)
  private
    fBar1: TMeters;
    fBar2: TMeters;
    fBar1Ro: TKilogramsPerMeter;
    fBar2Ro: TKilogramsPerMeter;
    fHeigth2: TMeters;
  public
    function Init: boolean; override;
  public
    property Bar1: TMeters write fBar1;
    property Bar2: TMeters write fBar2;
    property Bar1Ro: TKilogramsPerMeter write fBar1Ro;
    property Bar2Ro: TKilogramsPerMeter write fBar2Ro;
    property Heigth2: TMeters write fHeigth2;
  end;

  TKiteEdoLito = class(TKite)
  private
    fBar1: TMeters;
    fBar2: TMeters;
    fBar1Ro: TKilogramsPerMeter;
    fBar2Ro: TKilogramsPerMeter;
  public
    function Init: boolean; override;
  public
    property Bar1: TMeters write fBar1;
    property Bar2: TMeters write fBar2;
    property Bar1Ro: TKilogramsPerMeter write fBar1Ro;
    property Bar2Ro: TKilogramsPerMeter write fBar2Ro;
  end;

  TKiteRokkaku = class(TKite)
  private
    fBar1: TMeters;
    fBar2: TMeters;
    fBar1Ro: TKilogramsPerMeter;
    fBar2Ro: TKilogramsPerMeter;
    fHeigth2: TMeters;
  public
    function Init: boolean; override;
  public
    property Bar1: TMeters write fBar1;
    property Bar2: TMeters write fBar2;
    property Bar1Ro: TKilogramsPerMeter write fBar1Ro;
    property Bar2Ro: TKilogramsPerMeter write fBar2Ro;
    property Heigth2: TMeters write fHeigth2;
  end;

// conversion routines

function Parse(S: string): double;

implementation

uses
  Math;

function Parse(S: String): double;
var
  I: Longint;
  T: String = '';
begin
  for I := 1 to Length(S) do
    if S[I] in ['.', ','] then
    begin
      S[I] := DefaultFormatSettings.DecimalSeparator;
    end;

  try
    Result := StrToFloat(S);
  except
    Result := 0;

    if Pos('(', S) > 0 then
    begin
      I := Pos('(', S) + 1;
      while I < Pos(')', S) do
      begin
        case S[I] of
          '0': T := T + S[I];
          '1': T := T + S[I];
          '2': T := T + S[I];
          '3': T := T + S[I];
          '4': T := T + S[I];
          '5': T := T + S[I];
          '6': T := T + S[I];
          '7': T := T + S[I];
          '8': T := T + S[I];
          '9': T := T + S[I];
          '.': T := T + S[I];
          ',': T := T + S[I];
        else Break;
        end;
        Inc(I);
      end;

      try
        Result := StrToFloat(T);
      except
        Result := 0;
      end;
    end;

  end;
end;

// tkite class

constructor TKite.Create(Log: TStrings);
begin
  inherited create;
  fLog := Log;

  fAspectRatio := 0;
  fAttackAngle := 0*deg;
  fCd          := 0;
  fCg          := 0*m;
  fCl          := 0;
  fCp          := 0*m;
  fDrag        := 0*N;
  fLift        := 0*N;
  fTorque      := 0*N*m;
  fWeight      := 0*N;
  fLineWeight  := 0*kg;
  fTailWeight  := 0*kg;
  fXb          := 0*m;
  fYb          := 0*m;
  fKnotAngle   := 0*deg;
  fXKite       := 0*m;
  fYKite       := 0*m;

  fAirRo       := 1.229*kg/m3;
  fAirSpeed    := 3*m/s;
  fLine        := 0*m;
  fLineRo      := 0*kg/m;
  fSail        := 0*m2;
  fSailRo      := 0*kg/m2;
  fTail        := 0*m;
  fTailRo      := 0*kg/m;

  fDragSeries  := nil;
  fLiftSeries  := nil;
  fTorqSeries  := nil;
  fLineSeries  := nil;
end;

function TKite.CalcKnotAngle(const aHeight: TMeters): boolean;
begin
  Result := True;
  try
    fKnotAngle := ADim.ArcCos((SquarePower(fK)+SquarePower(aHeight)-SquarePower(fB))/(2*fK*aHeight));
  except
    Result := False;
  end;
end;

function TKite.CalcTorque(const aAngle: TRadians): TNewtonMeters;
begin
  result := -fLift  *Cos(aAngle)*(fYb-fCp) -fLift  *Sin(aAngle)*fXb
            -fDrag  *Sin(aAngle)*(fYb-fCp) +fDrag  *Cos(aAngle)*fXb
            +fWeight*Cos(aAngle)*(fYb-fCg) +fWeight*Sin(aAngle)*fXb;
end;

function TKite.Solve(const aAngle: TRadians): boolean;
begin
  Result := True;
  try
    fCl     := (2*pi*aAngle.Value)/(1 + (2*aAngle.Value)/fAspectRatio);
    fCd     := 1.28*Sin(aAngle) + Sqr(fCl)/(0.7*Pi*fAspectRatio);
    fLift   := 0.5*fCl*fSail*(fAirRo*SquarePower(fAirSpeed));
    fDrag   := 0.5*fCd*fSail*(fAirRo*SquarePower(fAirSpeed));
    fTorque := CalcTorque(aAngle);
  except;
    Result := False;
  end;
end;

function TKite.Solve: Boolean;
const
  Num = 250;
var
  A1: TMeters;
  A2: double;
  A3: double;
  C1: double;
  C2: TMeters;
  Lo: TRadians;
  Hi: TRadians;
  I:  longint;
  S:  TMeters;
  X,  Y:  TRadians;
  X0, Y0: TMeters;
  XK, YK: TMeters;
begin
  // Calc Lift, Drag and Torque graph
  Result := Init;
  if Result then
  begin

    for I := 0 to Num do
    begin
      X := (Pi/2*rad)*(I/Num);

      Result := Solve(X);
      if Result = False then Exit;

      if Assigned(fLiftSeries) then fLiftSeries.AddXY(X.ToDegree.Value, fLift.Value  );
      if Assigned(fDragSeries) then fDragSeries.AddXY(X.ToDegree.Value, fDrag.Value  );
      if Assigned(fTorqSeries) then fTorqSeries.AddXY(X.ToDegree.Value, fTorque.Value);
    end;
    // Find attack angle
    Lo := 0*deg;
    Hi := 90*deg;
    repeat
      fAttackAngle := (Lo+Hi)/2;
      if fAttackAngle = Lo then Break;
      if fAttackAngle = Hi then Break;

      Result := Solve(fAttackAngle);
      if Result = False then Exit;

      if fTorque > (0*N*m) then
        Lo := fAttackAngle
      else
      if fTorque < (0*N*m) then
        Hi := fAttackAngle;

    until fTorque.Abs < (1E-20*N*m);

    // Calc Line
    if (fLift < fWeight) then Exit;

    S  := ((fLift-fWeight)/gravity)/fLineRo;
    A1 := (fDrag/gravity)/fLineRo;
    A2 := (fLift-fWeight)/fDrag;
    A3 := (fLift-(S*fLineRo*gravity)-fWeight)/fDrag;
    C1 := ArcSinH(A3);
    C2 := -A1*CosH(C1);

    if fLine < S then
    begin
      XK := A1*(ArcSinH(A2)-C1);
      YK := C2 + A1*CosH(XK/A1 + C1);
    end else
    begin
      XK := 0*m;
      YK := C2 + A1*CosH(XK/A1 + C1);
    end;
    // Calc Line graph
    if Assigned(fLineSeries) then
      for I := Num downto 1 do
      begin
        fLineSeries.AddXY(XK.Value/I, YK.Value/I);
      end;
    fXKite := XK;
    fYKite := YK;
    //Calc Line Tension
    fTension := SquareRoot(SquarePower(fLift-fWeight)+SquarePower(fDrag));

    if Assigned(fLog) then
    begin
      fLog.Add(Format('Attack Angle = %s', [fAttackAngle.ToDegree.toString(3, 5, [])]));
      fLog.Add(Format('Torque       = %s', [fTorque.ToNewtonMeter.ToString(3, 5, [])]));
      fLog.Add(Format('Lift         = %s', [fLift  .ToString(3, 5, [])]));
      fLog.Add(Format('Drag         = %s', [fDrag  .ToString(3, 5, [])]));
      fLog.Add(Format('Weight       = %s', [fWeight.ToString(3, 5, [])]));
      fLog.Add('');
      fLog.Add(Format('Heigth-1     = %s', [fHeigth1.ToString(5, 1, [pMilli])]));
      fLog.Add(Format('Width -1     = %s', [fWidth1 .ToString(5, 1, [pMilli])]));
      fLog.Add(Format('Area         = %s', [fSail   .ToString(5, 1, [pCenti])]));
      fLog.Add(Format('Aspect Ratio = %f', [fAspectRatio]));
      fLog.Add(Format('Weight       = %s', [fWeight.ToString(3, 5, [])]));
      fLog.Add(Format('Line Weigth  = %s', [fLineWeight.ToString(3, 5, [pNone])]));
      fLog.Add(Format('Cg           = %s', [fCg.ToString(2, 2, [pMilli])]));
      fLog.Add(Format('Cp           = %s', [fCp.ToString(2, 2, [pMilli])]));
      fLog.Add(Format('AirSpeed     = %s', [fAirSpeed.ToMeterPerHour.ToString(2, 2, [pKilo])]));
      fLog.Add(Format('AttackAngle  = %s', [fAttackAngle.ToDegree.ToString]));
      fLog.Add(Format('Cl           = %f', [fCl]));
      fLog.Add(Format('Cd           = %f', [fCd]));
      fLog.Add(Format('Xb           = %s', [fXb.ToString(2, 2, [pMilli])]));
      fLog.Add(Format('Yb           = %s', [fYb.ToString(2, 2, [pMilli])]));
      fLog.Add(Format('Knot Angle   = %s', [fKnotAngle.ToDegree.ToString]));
      fLog.Add(Format('X Kite       = %s', [fXKite.ToString(2, 2, [pMilli])]));
      fLog.Add(Format('Y Kite       = %s', [fYKite.ToString(2, 2, [pMilli])]));
      fLog.Add(Format('Tension      = %s', [fTension.ToString]));
    end;
  end;
end;

// TKiteDiamond

function TKiteDiamond.Init: boolean;
var
  Weight0: TNewtons;
  Weight1: TNewtons;
  Weight2: TNewtons;
  Weight3: TNewtons;
begin
  // calc knotangle
  Result := CalcKnotAngle(fHeigth1);
  if Result then
  begin
    // bridle point
    fYb := fK*Cos(fKnotAngle);
    fXb := fK*Sin(fKnotAngle);
    // area, aspect ratio & center of pressure
    fSail := fHeigth1*fWidth1*0.5;
    fAspectRatio := SquarePower(fWidth1)/fSail;
    fCp := (fHeigth1*0.5)+(fHeigth2/3);
    // Weight & center of gravity
    Weight0 := fSail*fSailRo*Gravity;
    Weight1 := fBar1*fBar1Ro*Gravity;
    Weight2 := fBar2*fBar2Ro*Gravity;
    Weight3 := fTail*fTailRo*Gravity;
    fWeight := (Weight0+Weight1+Weight2+Weight3);
    fLineWeight := (fLine*fLineRo);
    fCg := (Weight0*((fHeigth1+fHeigth2)/3) +
            Weight1*(fHeigth1*0.5) +
            Weight2*(fHeigth2) +
            Weight3*(-fTail*0.5))/fWeight;
  end;
end;

// TKite Rokkaku

function TKiteRokkaku.Init: boolean;
var
  Weight0: TNewtons;
  Weight1: TNewtons;
  Weight2: TNewtons;
  Weight3: TNewtons;
begin
  // calc knotangle
  Result := CalcKnotAngle(fHeigth1);
  if Result then
  begin
    // bridle point
    fYb := fK*Cos(fKnotAngle);
    fXb := fK*Sin(fKnotAngle);
    // area, aspect ratio & center of pressure
    fSail := (fHeigth2+(fHeigth1-fHeigth2)*0.5)*fWidth1;
    fAspectRatio := SquarePower(fWidth1)/fSail;
    fCp := fHeigth1*0.75;
    // Weight & center of gravity
    Weight0 := fSail*fSailRo*Gravity;
    Weight1 := fBar1*fBar1Ro*Gravity;
    Weight2 := fBar2*fBar2Ro*2*Gravity;
    Weight3 := fTail*fTailRo*Gravity;
    fWeight := (Weight0+Weight1+Weight2+Weight3);
    fLineWeight := (fLine*fLineRo);
    fCg := fHeigth1*0.5;
  end;
end;

// TKite EdoLito

function TKiteEdoLito.Init: boolean;
var
  Weight0: TNewtons;
  Weight1: TNewtons;
  Weight2: TNewtons;
  Weight3: TNewtons;
begin
  // calc knotangle
  Result := CalcKnotAngle(fHeigth1*0.75);
  if Result then
  begin
    // bridle point
    fYb := fK*Cos(fKnotAngle)+fHeigth1*0.25;
    fXb := fK*Sin(fKnotAngle);
    // area, aspect ratio & center of pressure
    fSail := fHeigth1*fWidth1;
    fAspectRatio := SquarePower(fWidth1)/fSail;
    fCp := fHeigth1*0.75;
    // Weight & center of gravity
    Weight0 := fSail*fSailRo*Gravity;
    Weight1 := fBar1*fBar1Ro*Gravity;
    Weight2 := fBar2*fBar2Ro*5*Gravity;
    Weight3 := fTail*fTailRo*Gravity;
    fWeight := (Weight0+Weight1+Weight2+Weight3);
    fLineWeight := (fLine*fLineRo);
    fCg := (Weight0*( 0.5*fHeigth1)+
            Weight1*( 0.5*fHeigth1)+
            Weight2*( 0.5*fHeigth1)+
            Weight3*(-0.5*ftail-0.5*(fBar1-fHeigth1)))/fWeight;
  end;
end;

end.
