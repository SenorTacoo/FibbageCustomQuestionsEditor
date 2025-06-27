unit uUserDialog;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation;

type
  TUserDialog = class(TForm)
    lUserDialogInfo: TLabel;
    gplButtons: TGridPanelLayout;
    bOk: TButton;
    bCancel: TButton;
    cbDontAskAgain: TCheckBox;
    procedure FormCreate(Sender: TObject);
  public
    function MakeInfo(const AInfo: string; out ADontAskAgain: Boolean): Boolean;
    procedure MakeSimpleInfo(const AInfo: string);
    function MakeSimpleInfoWithResult(const AInfo: string): Boolean;
  end;

implementation

uses
  uMainForm;

{$R *.fmx}

{ TUserDialog }

procedure TUserDialog.FormCreate(Sender: TObject);
begin
  StyleBook := Application.MainForm.StyleBook;
end;

function TUserDialog.MakeInfo(const AInfo: string; out ADontAskAgain: Boolean): Boolean;
begin
  Result := False;
  lUserDialogInfo.Text := AInfo;

  if ShowModal = mrOk then
  begin
    Result := True;
    ADontAskAgain := cbDontAskAgain.IsChecked;
  end;
end;

procedure TUserDialog.MakeSimpleInfo(const AInfo: string);
begin
  cbDontAskAgain.Visible := False;
  lUserDialogInfo.Text := AInfo;
  gplButtons.ColumnCollection[0].Value := 0;
  gplButtons.ColumnCollection[1].Value := 100;
  ShowModal;
end;

function TUserDialog.MakeSimpleInfoWithResult(const AInfo: string): Boolean;
begin
  cbDontAskAgain.Visible := False;
  lUserDialogInfo.Text := AInfo;

  Result := ShowModal = mrOk;
end;

end.
