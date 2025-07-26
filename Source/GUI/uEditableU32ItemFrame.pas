unit uEditableU32ItemFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.NumberBox, uQuestionsLoader;

type
  TFrmEditableU32Item = class(TFrame)
    Label1: TLabel;
    NumberBox1: TNumberBox;
    procedure NumberBox1Change(Sender: TObject);
  private
    FInitialized: Boolean;
    FField: TEditableU32Field;
  public
    constructor Create(AOwner: TComponent; AField: TEditableU32Field); reintroduce;
  end;

implementation

{$R *.fmx}

{ TFrmEditableU32Item }

constructor TFrmEditableU32Item.Create(AOwner: TComponent;
  AField: TEditableU32Field);
begin
  inherited Create(AOwner);
  FField := AField;

  Label1.Text := FField.Name;
  NumberBox1.Value := FField.Value;
  FInitialized := True;
end;

procedure TFrmEditableU32Item.NumberBox1Change(Sender: TObject);
begin
  if not FInitialized then
    Exit;
  FField.Value := Round(NumberBox1.Value);
end;

end.
