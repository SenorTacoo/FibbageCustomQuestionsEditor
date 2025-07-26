unit uEditableBoolItemFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, uQuestionsLoader;

type
  TFrmEditableBoolItem = class(TFrame)
    Label1: TLabel;
    Switch1: TSwitch;
    procedure Switch1Switch(Sender: TObject);
  private
    FInitialized: Boolean;
    FField: TEditableBoolField;
  public
    constructor Create(AOwner: TComponent; AField: TEditableBoolField); reintroduce;
  end;

implementation

{$R *.fmx}

{ TFrmEditableBoolItem }

constructor TFrmEditableBoolItem.Create(AOwner: TComponent;
  AField: TEditableBoolField);
begin
  inherited Create(AOwner);
  FField := AField;

  Label1.Text := FField.Name;
  Switch1.IsChecked := FField.Value;

  FInitialized := True;
end;

procedure TFrmEditableBoolItem.Switch1Switch(Sender: TObject);
begin
  if not FInitialized then
    Exit;

  FField.Value := Switch1.IsChecked;
end;

end.
