unit uEditableLongStringItemFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, uQuestionsLoader;

type
  TFrmEditableLongStringItem = class(TFrame)
    Label1: TLabel;
    Memo1: TMemo;
    procedure Memo1Change(Sender: TObject);
  private
    FInitialized: Boolean;
    FField: TEditableLongStringField;
  public
    constructor Create(AOwner: TComponent; AField: TEditableLongStringField); reintroduce;
  end;

implementation

{$R *.fmx}

{ TFrmEditableLongStringItem }

constructor TFrmEditableLongStringItem.Create(AOwner: TComponent;
  AField: TEditableLongStringField);
begin
  inherited Create(AOwner);
  FField := AField;

  Label1.Text := FField.Name;
  Memo1.Text := FField.Value;

  FInitialized := True;
end;

procedure TFrmEditableLongStringItem.Memo1Change(Sender: TObject);
begin
  if not FInitialized then
    Exit;

  FField.Value := Memo1.Text;
end;

end.
