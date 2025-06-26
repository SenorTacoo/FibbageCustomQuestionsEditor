unit uGetGameTypeDlg;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uInterfaces,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, System.Rtti, System.Generics.Collections;

type
  TGetGameTypeDlg = class(TForm)
    gplButtons: TGridPanelLayout;
    bOk: TButton;
    bCancel: TButton;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FWasFirstShow: Boolean;
    FPossibleChoices: TList<TRadioButton>;

    procedure InitializeGameTypes;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetGameType(out AType: TGameType): Boolean;
  end;

implementation

uses
  uMainForm;

{$R *.fmx}

{ TGetGameTypeDlg }

constructor TGetGameTypeDlg.Create(AOwner: TComponent);
begin
  inherited;
  FPossibleChoices := TList<TRadioButton>.Create;
end;

destructor TGetGameTypeDlg.Destroy;
begin
  FPossibleChoices.Free;
  inherited;
end;

procedure TGetGameTypeDlg.FormCreate(Sender: TObject);
begin
  StyleBook := Application.MainForm.StyleBook;
end;

procedure TGetGameTypeDlg.FormShow(Sender: TObject);
begin
  if not FWasFirstShow then
  begin
    FWasFirstShow := True;
    InitializeGameTypes;
  end;
end;

function TGetGameTypeDlg.GetGameType(out AType: TGameType): Boolean;
begin
  Result := False;
  if ShowModal = mrOk then
  begin
    Result := True;
    for var idx := 0 to FPossibleChoices.Count - 1 do
      if FPossibleChoices[idx].IsChecked then
      begin
        AType := TGameType(FPossibleChoices[idx].Tag);
        Exit;
      end;
    Assert(False, 'should already have type set');
  end;
end;

procedure TGetGameTypeDlg.InitializeGameTypes;
begin
  BeginUpdate;
  try
    for var gameType := Low(TGameType) to High(TGameType) do
    begin
      var rb := TRadioButton.Create(Self);
      rb.Align := TAlignLayout.Top;
      rb.Text := TRttiEnumerationType.GetName(gameType);
      rb.TextAlign := TTextAlign.Center;
      rb.Tag := Ord(gameType);
      rb.Margins.Top := 3;
      rb.Margins.Bottom := 3;
      rb.Position.Y := MaxInt;
      rb.Parent := Self;

      rb.Height := 1.5 * rb.Canvas.TextHeight('Yy');
      FPossibleChoices.Add(rb);
    end;
  finally
    EndUpdate;
  end;

  FPossibleChoices.First.IsChecked := True;
end;

end.
