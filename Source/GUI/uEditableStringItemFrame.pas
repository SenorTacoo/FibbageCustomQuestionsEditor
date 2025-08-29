unit uEditableStringItemFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, uQuestionsLoader,
  FMX.Edit;

type
  TFrmEditableStringItem = class(TFrame)
    Label1: TLabel;
    Edit1: TEdit;
    procedure Edit1Change(Sender: TObject);
  private
    FInitialized: Boolean;
    FField: TEditableStringField;
  public
    constructor Create(AOwner: TComponent; AField: TEditableStringField); reintroduce;
  end;

implementation

{$R *.fmx}

{ TFrmEditableStringItem }

constructor TFrmEditableStringItem.Create(AOwner: TComponent;
  AField: TEditableStringField);
begin
  inherited Create(AOwner);
  FField := AField;

  Label1.Text := FField.Name;
  Edit1.Text := FField.Value;

  FInitialized := True;
end;

procedure TFrmEditableStringItem.Edit1Change(Sender: TObject);
begin
  if not FInitialized then
    Exit;
  FField.Value := Edit1.Text;
end;

end.
