unit mainfrm;

{$mode objfpc}

interface

uses
  classes, sysutils, forms, controls, graphics, dialogs, stdctrls, buttons,
  extctrls, comctrls, grids, menus, Spin, ColorBox, tagraph, taseries,
  kitesolver;

type
  { TMainForm }

  TMainForm = class(tform)
    Log: TMemo;
    previewbtn: TBitBtn;
    Bottombvl: TBevel;
    KLen: TFloatSpinEdit;
    SailsRo: TComboBox;
    RodsRo: TComboBox;
    Model: TComboBox;
    ImageList: TImageList;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    SolveBtn: tbitbtn;
    loadbtn: TBitBtn;
    savebtn: TBitBtn;
    dragseries: TLineSeries;
    liftseries: TLineSeries;
    lineseries: TLineSeries;
    KeyList: TStringGrid;
    TabSheet1: TTabSheet;
    torquechart: TChart;
    liftchart: TChart;
    linechart: TChart;
    Pages: TPageControl;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    torqseries: TLineSeries;
    procedure KLenChange(Sender: TObject);
    procedure previewbtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KeyListHeaderSizing(sender: TObject;
      const IsColumn: boolean; const aIndex, aSize: Integer);
    procedure KeyListResize(Sender: TObject);
    procedure KeyListSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
    procedure KiteModelChange(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure ModelEditingDone(Sender: TObject);
    procedure RodsRoEditingDone(Sender: TObject);
    procedure SailsRoEditingDone(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure SolveBtnClick(Sender: tobject);
  private
    function GetIndex(const aKey: string): Longint;
    function GetValue(const aKey: string): string;
    procedure PutValue(const aKey: string; const aUnit, aValue: string);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$r *.lfm}

uses
  ADim, Math, PreviewFrm;

const
  M   = '[00]    Kite model';    MUnit   = '';

  H1  = '[01]    Heigth 1';      H1Unit  = 'mm';
  H2  = '[02]    Heigth 2';      H2Unit  = 'mm';
  H3  = '[03]    Heigth 3';      H3Unit  = 'mm';

  W1  = '[04]    Width 1';       W1Unit  = 'mm';
  W2  = '[05]    Width 2';       W2Unit  = 'mm';
  W3  = '[06]    Width 3';       W3Unit  = 'mm';

  R1  = '[07]    Rod 1 length';  R1Unit  = 'mm';
  R2  = '[08]    Rod 2 length';  R2Unit  = 'mm';
  R3  = '[09]    Rod 3 length';  R3Unit  = 'mm';

  R1R = '[10]    Rod 1 ro';      R1RUnit = 'g/m';
  R2R = '[11]    Rod 2 ro';      R2RUnit = 'g/m';
  R3R = '[12]    Rod 3 ro';      R3RUnit = 'g/m';

  SR  = '[13]    Sail ro';       SRUnit  = 'g/m2';

  T   = '[14]    Tail length';   TUnit   = 'm';
  TR  = '[15]    Tail ro';       TRUnit  = 'g/m';

  B   = '[16]    B length';      BUnit   = 'mm';
  K   = '[17]    K length';      KUnit   = 'mm';

  L   = '[18]    Line length';   LUnit   = 'm';
  LR  = '[19]    Line ro';       LRUnit  = 'g/m';

  W   = '[20]    Air speed';     WUnit   = 'km/h';
  WR  = '[21]    Air ro';        WRUnit  = 'kg/m3';

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  PreviewForm := TPreviewForm.Create(Self);
  //
  KeyList.Columns[0].Width := 120;
  KeyList.Columns[1].Width := 80;
  if GetIndex(M) = -1 then
  begin
    PutValue(M, MUnit, 'DIAMOND');
  end;
  KiteModelChange(Sender);

  Model.Visible := False;
  RodsRo.Visible := False;
  SailsRo.Visible := False;
  KLen.Visible := False;

  RodsRo.Items.Clear;
  RodsRo.Items.LoadFromFile('rods.list');
  SailsRo.Items.Clear;
  SailsRo.Items.LoadFromFile('sails.list');

  Model.Anchors   := [];
  RodsRo.Anchors  := [];
  SailsRo.Anchors := [];
  KLen.Anchors    := [];

  Pages.ActivePageIndex := 0;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  PreviewForm.Destroy;
end;

procedure TMainForm.KeyListHeaderSizing(sender: TObject;
  const IsColumn: boolean; const aIndex, aSize: Integer);
begin
  KeyListResize(Sender);
end;

procedure TMainForm.KeyListResize(Sender: TObject);
begin
  KeyList.Columns[2].Width :=
    KeyList.ClientWidth      -
    KeyList.Columns[1].Width -
    KeyList.Columns[0].Width - 0;
end;

procedure TMainForm.SolveBtnClick(sender: tobject);
var
  Kite: TKite = nil;
begin
  DragSeries.Clear;
  LiftSeries.Clear;
  LineSeries.Clear;
  TorqSeries.Clear;

  if parse(GetValue(B)) > parse(GetValue(K)) then
  begin
    if UpperCase(GetValue(M)) = 'EDOLITO' then
    begin
      Kite := TKiteEdoLito.Create(Log.Lines);

      TKiteEdoLito(Kite).B        := parse(GetValue(B ))*mm - parse(GetValue(K))*mm;
      TKiteEdoLito(Kite).K        := parse(GetValue(K ))*mm;
      TKiteEdoLito(Kite).Heigth1  := parse(GetValue(H1))*mm;
      TKiteEdoLito(Kite).Width1   := parse(GetValue(W1))*mm;

      TKiteEdoLito(Kite).Bar1     := parse(GetValue(R1))*mm;
      TKiteEdoLito(Kite).Bar2     := parse(GetValue(R2))*mm;

      TKiteEdoLito(Kite).Bar1Ro   := parse(GetValue(R1R))*g/ADim.m;
      TKiteEdoLito(Kite).Bar2Ro   := parse(GetValue(R2R))*g/ADim.m;
      TKiteEdoLito(Kite).AreaRo   := parse(GetValue(SR ))*g/ADim.m2;
      TKiteEdoLito(Kite).Tail     := parse(GetValue(T  ))*  ADim.m;
      TKiteEdoLito(Kite).TailRo   := parse(GetValue(TR ))*g/ADim.m;

      TKiteEdoLito(Kite).Line     := parse(GetValue(L  ))*  ADim.m;
      TKiteEdoLito(Kite).LineRo   := parse(GetValue(LR ))*g/ADim.m;
      TKiteEdoLito(Kite).AirRo    := parse(GetValue(WR ))*kg/ADim.m3;
      TKiteEdoLito(Kite).AirSpeed := parse(GetValue(W  ))*km/hr;
    end else
    if UpperCase(GetValue(M)) = 'ROKKAKU' then
    begin
      Kite := TKiteRokkaku.Create(Log.Lines);

      TKiteRokkaku(Kite).B        := parse(GetValue(B  ))*mm - parse(GetValue(K))*mm;
      TKiteRokkaku(Kite).K        := parse(GetValue(K  ))*mm;
      TKiteRokkaku(Kite).Heigth1  := parse(GetValue(H1 ))*mm;
      TKiteRokkaku(Kite).Heigth2  := parse(GetValue(H2 ))*mm;
      TKiteRokkaku(Kite).Width1   := parse(GetValue(W1 ))*mm;

      TKiteRokkaku(Kite).Bar1     := parse(GetValue(R1 ))*mm;
      TKiteRokkaku(Kite).Bar2     := parse(GetValue(R2 ))*mm;
      TKiteRokkaku(Kite).Bar1Ro   := parse(GetValue(R1R))*g/ADim.m;
      TKiteRokkaku(Kite).Bar2Ro   := parse(GetValue(R2R))*g/ADim.m;
      TKiteRokkaku(Kite).AreaRo   := parse(GetValue(SR ))*g/ADim.m2;
      TKiteRokkaku(Kite).Tail     := parse(GetValue(T  ))*  ADim.m;
      TKiteRokkaku(Kite).TailRo   := parse(GetValue(TR ))*g/ADim.m;

      TKiteRokkaku(Kite).Line     := parse(GetValue(L  ))*  Adim.m;
      TKiteRokkaku(Kite).LineRo   := parse(GetValue(LR ))*g/ADim.m;
      TKiteRokkaku(Kite).AirRo    := parse(GetValue(WR ))*kg/ADim.m3;
      TKiteRokkaku(Kite).AirSpeed := parse(GetValue(W  ))*km/hr;
    end else
    if UpperCase(GetValue(M)) = 'DIAMOND' then
    begin
      Kite := TKiteDiamond.Create(Log.Lines);

      TKiteDiamond(Kite).B        := parse(GetValue(B  ))*mm - parse(GetValue(K))*mm;
      TKiteDiamond(Kite).K        := parse(GetValue(K  ))*mm;
      TKiteDiamond(Kite).Heigth1  := parse(GetValue(H1 ))*mm;
      TKiteDiamond(Kite).Heigth2  := parse(GetValue(H2 ))*mm;
      TKiteDiamond(Kite).Width1   := parse(GetValue(W1 ))*mm;

      TKiteDiamond(Kite).Bar1     := parse(GetValue(R1 ))*mm;
      TKiteDiamond(Kite).Bar2     := parse(GetValue(R2 ))*mm;
      TKiteDiamond(Kite).Bar1Ro   := parse(GetValue(R1R))*g/Adim.m;
      TKiteDiamond(Kite).Bar2Ro   := parse(GetValue(R2R))*g/Adim.m;
      TKiteDiamond(Kite).AreaRo   := parse(GetValue(SR ))*g/Adim.m2;
      TKiteDiamond(Kite).Tail     := parse(GetValue(T  ))*  Adim.m;
      TKiteDiamond(Kite).TailRo   := parse(GetValue(TR ))*g/Adim.m;

      TKiteDiamond(Kite).Line     := parse(GetValue(L  ))*  Adim.m;
      TKiteDiamond(Kite).LineRo   := parse(GetValue(LR ))*g/Adim.m;
      TKiteDiamond(Kite).AirRo    := parse(GetValue(WR ))*kg/Adim.m3;
      TKiteDiamond(Kite).AirSpeed := parse(GetValue(W  ))*km/hr;
    end;
  end;

  if Assigned(Kite) then
  begin
    Kite.Drags := DragSeries;
    Kite.Lifts := LiftSeries;
    Kite.Torqs := TorqSeries;
    Kite.Lines := LineSeries;

    Log.Clear;
    if Kite.Solve then
    begin

    end;
    Kite.Destroy;
  end;
end;

procedure TMainForm.LoadBtnClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    KeyList.LoadFromCSVFile(OpenDialog.FileName);
    KiteModelChange(Sender);
  end;
end;

procedure TMainForm.SaveBtnClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    KeyList.SaveToCSVFile(SaveDialog.FileName);
  end;
end;

procedure TMainForm.KiteModelChange(Sender: tobject);
begin
  PreviewForm.Image.Canvas.Clear;

  if UpperCase(GetValue(M)) = 'EDOLITO' then
  begin
    PreviewForm.ImageList.GetBitmap(0, PreviewForm.Image.Picture.Bitmap);

    if GetIndex(M)  = -1 then PutValue(M,  MUnit, 'EDOLITO');
    if GetIndex(H1) = -1 then PutValue(H1, H1Unit, '');
    if GetIndex(H2) > -1 then KeyList.DeleteRow(GetIndex(H2));
    if GetIndex(H3) > -1 then KeyList.DeleteRow(GetIndex(H3));
    if GetIndex(W1) = -1 then PutValue(W1, W1Unit, '');
    if GetIndex(W2) > -1 then KeyList.DeleteRow(GetIndex(W2));
    if GetIndex(W3) > -1 then KeyList.DeleteRow(GetIndex(W3));
    if GetIndex(SR) = -1 then PutValue(SR, SRUnit, '');

    if GetIndex(R1) = -1 then PutValue(R1,  R1Unit,  '');
    if GetIndex(R1R)= -1 then PutValue(R1R, R1RUnit, '');

    if GetIndex(R2) = -1 then PutValue(R2,  R2Unit,  '');
    if GetIndex(R2R)= -1 then PutValue(R2R, R2RUnit, '');

    if GetIndex(R3) > -1 then KeyList.DeleteRow(GetIndex(R3));
    if GetIndex(R3R)> -1 then KeyList.DeleteRow(GetIndex(R3R));

    if GetIndex(T)  = -1 then PutValue(T,  TUnit,  '');
    if GetIndex(TR) = -1 then PutValue(TR, TRUnit, '');

    if GetIndex(L)  = -1 then PutValue(L,  LUnit,  '');
    if GetIndex(LR) = -1 then PutValue(LR, LRUnit, '');

    if GetIndex(B)  = -1 then PutValue(B,  BUnit,  '');
    if GetIndex(K)  = -1 then PutValue(K,  KUnit,  '');

    if GetIndex(W)  = -1 then PutValue(W,  WUnit,  '');
    if GetIndex(WR) = -1 then PutValue(WR, WRUnit, '');
  end else
  if UpperCase(GetValue(M)) = 'ROKKAKU' then
  begin
    PreviewForm.ImageList.GetBitmap(1, PreviewForm.Image.Picture.Bitmap);

    if GetIndex(M)  = -1 then PutValue(M,  MUnit, 'ROKKAKU');
    if GetIndex(H1) = -1 then PutValue(H1, H1Unit, '');
    if GetIndex(H2) = -1 then PutValue(H2, H2Unit, '');
    if GetIndex(H3) > -1 then KeyList.DeleteRow(GetIndex(H3));
    if GetIndex(W1) = -1 then PutValue(W1, W1Unit, '');
    if GetIndex(W2) > -1 then KeyList.DeleteRow(GetIndex(W2));
    if GetIndex(W3) > -1 then KeyList.DeleteRow(GetIndex(W3));
    if GetIndex(SR) = -1 then PutValue(SR, SRUnit, '');

    if GetIndex(R1) = -1 then PutValue(R1,  R1Unit,  '');
    if GetIndex(R1R)= -1 then PutValue(R1R, R1RUnit, '');

    if GetIndex(R2) = -1 then PutValue(R2,  R2Unit,  '');
    if GetIndex(R2R)= -1 then PutValue(R2R, R2RUnit, '');

    if GetIndex(R3) > -1 then KeyList.DeleteRow(GetIndex(R3));
    if GetIndex(R3R)> -1 then KeyList.DeleteRow(GetIndex(R3R));

    if GetIndex(T)  = -1 then PutValue(T,  TUnit,  '');
    if GetIndex(TR) = -1 then PutValue(TR, TRUnit, '');

    if GetIndex(L)  = -1 then PutValue(L,  LUnit,  '');
    if GetIndex(LR) = -1 then PutValue(LR, LRUnit, '');

    if GetIndex(B)  = -1 then PutValue(B,  BUnit,  '');
    if GetIndex(K)  = -1 then PutValue(K,  KUnit,  '');

    if GetIndex(W)  = -1 then PutValue(W,  WUnit,  '');
    if GetIndex(WR) = -1 then PutValue(WR, WRUnit, '');
  end else
  if UpperCase(GetValue(M)) = 'DIAMOND' then
  begin
    if GetIndex(M)  = -1 then PutValue(M,  MUnit, 'DIAMOND');
    if GetIndex(H1) = -1 then PutValue(H1, H1Unit, '');
    if GetIndex(H2) = -1 then PutValue(H2, H2Unit, '');
    if GetIndex(H3) > -1 then KeyList.DeleteRow(GetIndex(H3));
    if GetIndex(W1) = -1 then PutValue(W1, W1Unit, '');
    if GetIndex(W2) > -1 then KeyList.DeleteRow(GetIndex(W2));
    if GetIndex(W3) > -1 then KeyList.DeleteRow(GetIndex(W3));
    if GetIndex(SR) = -1 then PutValue(SR, SRUnit, '');

    if GetIndex(R1) = -1 then PutValue(R1,  R1Unit,  '');
    if GetIndex(R1R)= -1 then PutValue(R1R, R1RUnit, '');

    if GetIndex(R2) = -1 then PutValue(R2,  R2Unit,  '');
    if GetIndex(R2R)= -1 then PutValue(R2R, R2RUnit, '');

    if GetIndex(R3) > -1 then KeyList.DeleteRow(GetIndex(R3));
    if GetIndex(R3R)> -1 then KeyList.DeleteRow(GetIndex(R3R));

    if GetIndex(T)  = -1 then PutValue(T,  TUnit,  '');
    if GetIndex(TR) = -1 then PutValue(TR, TRUnit, '');

    if GetIndex(L)  = -1 then PutValue(L,  LUnit,  '');
    if GetIndex(LR) = -1 then PutValue(LR, LRUnit, '');

    if GetIndex(B)  = -1 then PutValue(B,  BUnit,  '');
    if GetIndex(K)  = -1 then PutValue(K,  KUnit,  '');

    if GetIndex(W)  = -1 then PutValue(W,  WUnit,  '');
    if GetIndex(WR) = -1 then PutValue(WR, WRUnit, '');
  end;
  KeyList.SortColRow(True, 0);
end;

procedure TMainForm.ModelEditingDone(Sender: TObject);
begin
  KeyList.Cells[KeyList.Col, KeyList.Row] := Model.Text;
  KiteModelChange(Sender);
end;

procedure TMainForm.RodsRoEditingDone(Sender: TObject);
begin
  KeyList.Cells[2, KeyList.Row] := RodsRo.Text;
end;

procedure TMainForm.SailsRoEditingDone(Sender: TObject);
begin
  KeyList.Cells[2, KeyList.Row] := SailsRo.Text;
end;

procedure tmainform.PreviewBtnClick(sender: tobject);
begin
  PreviewForm.Show;
end;

procedure TMainForm.KLenChange(Sender: TObject);
begin
  KeyList.Cells[2, KeyList.Row] := KLen.Text;
  SolveBtnClick(Self);
end;

procedure TMainForm.KeyListSelectEditor(Sender: TObject;
  aCol, aRow: Integer; var Editor: TWinControl);
begin
  if (aCol = 2) and (aRow > 0) then
  begin
    if KeyList.Cells[0, aRow] = M then
    begin
      Model.BoundsRect := KeyList.CellRect(aCol, aRow);
      Model.Text := KeyList.Cells[aCol, aRow];
      Editor := Model;
    end else
    if ((KeyList.Cells[0, aRow] = R1R)  or
        (KeyList.Cells[0, aRow] = R2R)  or
        (KeyList.Cells[0, aRow] = R3R)) then
    begin
      RodsRo.BoundsRect := KeyList.CellRect(aCol, aRow);
      RodsRo.Text := KeyList.Cells[aCol, aRow];
      Editor := RodsRo;
    end else
    if KeyList.Cells[0, aRow] = SR then
    begin
      SailsRo.BoundsRect := KeyList.CellRect(aCol, aRow);
      SailsRo.Text := KeyList.Cells[aCol, aRow];
      Editor := SailsRo;
    end else
    if KeyList.Cells[0, aRow] = K then
    begin
      KLen.BoundsRect := KeyList.CellRect(aCol, aRow);
      KLen.Text := KeyList.Cells[aCol, aRow];
      Editor := KLen;
    end;
  //...
  end;
end;

function TMainForm.GetIndex(const aKey: String): Longint;
var
  I: longint;
begin
  Result := -1;
  for I := 1 to KeyList.RowCount -1 do
  begin
    if KeyList.Cells[0, I] = aKey then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TMainForm.GetValue(const aKey: String): string;
var
  I: longint;
begin
  Result := '';
  for I := 1 to KeyList.RowCount -1 do
  begin
    if KeyList.Cells[0, I] = aKey then
    begin
      Result := KeyList.Cells[2, I];
      Break;
    end;
  end;
end;

procedure TMainForm.PutValue(const aKey: string; const aUnit, aValue: string);
begin
  KeyList.InsertRowWithValues(KeyList.RowCount, [aKey, aUnit, aValue]);
end;

end.

