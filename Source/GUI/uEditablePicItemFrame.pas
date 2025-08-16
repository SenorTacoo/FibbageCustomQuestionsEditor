unit uEditablePicItemFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.ExtCtrls, uQuestionsLoader,
  uUserDialog, System.IOUtils, FMX.Objects, System.Math;

type
  TfrmEditablePicItem = class(TFrame)
    Label1: TLabel;
    Image1: TImage;
    GridPanelLayout1: TGridPanelLayout;
    bRemove: TButton;
    bSelectFromFile: TButton;
    Layout1: TLayout;
    procedure Image1Click(Sender: TObject);
    procedure bAddImageClick(Sender: TObject);
    procedure bSelectFromFileClick(Sender: TObject);
    procedure bRemoveClick(Sender: TObject);
    procedure Layout1Resize(Sender: TObject);
  private
    FInitialized: Boolean;
    FField: TEditablePicField;

    procedure SelectImage;
    procedure RefreshImage;
    procedure GenerateImageBackground;
  public
    constructor Create(AOwner: TComponent; AField: TEditablePicField); reintroduce;
  end;


implementation

{$R *.fmx}

{ TfrmEditablePicItem }

procedure TfrmEditablePicItem.bAddImageClick(Sender: TObject);
begin
  SelectImage;
end;

procedure TfrmEditablePicItem.bRemoveClick(Sender: TObject);
begin
  FField.Value := '';
  FField.BasePath := '';
  RefreshImage;
end;

procedure TfrmEditablePicItem.bSelectFromFileClick(Sender: TObject);
begin
  SelectImage;
end;

constructor TfrmEditablePicItem.Create(AOwner: TComponent;
  AField: TEditablePicField);
begin
  inherited Create(AOwner);

  FField := AField;
  Label1.Text := AField.Name;

  RefreshImage;

  FInitialized := True;
end;

procedure TfrmEditablePicItem.GenerateImageBackground;
const
  SQUARE_SIZE = 20;
var
  squareLeft: Single;
  squareTop: Single;
  colorIdx: Int32;
begin
  var alternatingColors := [TAlphaColorRec.Lightgray, TAlphaColorRec.DkGray];

  Layout1.BeginUpdate;
  try
    for var idx := Layout1.ControlsCount - 1 downto 0 do
    begin
      if not (Layout1.Controls[idx] is TRectangle) then
        Continue;
      var item := Layout1.Controls.ExtractAt(idx);
      FreeAndNil(item);
    end;

    var rows := Ceil(Layout1.Height / SQUARE_SIZE);
    var columns := Ceil(Layout1.Width / SQUARE_SIZE);

    for var idx := 0 to rows - 1 do
    begin
      squareTop := SQUARE_SIZE * idx;
      colorIdx := idx mod Length(alternatingColors);
      for var jdx := 0 to columns - 1 do
      begin
        squareLeft := SQUARE_SIZE * jdx;

        var newItem := TRectangle.Create(Self);
        newItem.Width := SQUARE_SIZE;
        newItem.Height := SQUARE_SIZE;
        newItem.Position.X := squareLeft;
        newItem.Position.Y := squareTop;
        newItem.Fill.Color := alternatingColors[colorIdx];
        newItem.Stroke.Thickness := 0;
        newItem.Parent := Layout1;

        colorIdx := (colorIdx + 1) mod Length(alternatingColors);
      end;
    end;
    Image1.BringToFront;
  finally
    Layout1.EndUpdate;
  end;
end;

procedure TfrmEditablePicItem.Image1Click(Sender: TObject);
begin
  SelectImage;
end;

procedure TfrmEditablePicItem.Layout1Resize(Sender: TObject);
begin
  GenerateImageBackground;
end;

procedure TfrmEditablePicItem.RefreshImage;
begin
  bRemove.Enabled := not FField.Value.IsEmpty;

  if FField.Value.IsEmpty then
    Image1.MultiResBitmap.Clear//.Clear(TAlphaColorRec.White)  // TODO do ogarniecia obrazek
  else
  begin
    var filePath := System.IOUtils.TPath.Combine(FField.BasePath, FField.Value) + '.png';
    Image1.MultiResBitmap.Add.Bitmap.LoadFromFile(filePath);
  end;
end;

procedure TfrmEditablePicItem.SelectImage;
begin
  var dlg := TOpenDialog.Create(Self);
  try
    dlg.Filter := 'PNG file (*.png)|*.png';
    if not dlg.Execute then
      Exit;

    if not dlg.Files[0].EndsWith('.png') then
    begin
      var errdlg := TUserDialog.Create(Self);
      try
        errdlg.MakeSimpleInfo('Invalid file extension. Only .png is supported.');
      finally
        errDlg.Free;
      end;
      Exit;
    end;

    FField.Value := ChangeFileExt(System.IOUtils.TPath.GetFileName(dlg.Files[0]), '');
    FField.BasePath := System.IOUtils.TPath.GetDirectoryName(dlg.Files[0]);

    RefreshImage;
  finally
    dlg.Free;
  end;
end;

end.
