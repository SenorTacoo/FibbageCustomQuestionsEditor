unit uEditableAudioItemFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, uQuestionsLoader, ACS_Classes,
  ACS_Vorbis, ACS_Converters, ACS_DXAudio, NewACDSAudio, uConfig, System.IOUtils,
  uUserDialog;

type
  TFrmEditableAudioItem = class(TFrame)
    Label1: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    bPlay: TButton;
    bRecordAudio: TButton;
    bRemoveAllAudio: TButton;
    DSAudioOut1: TDSAudioOut;
    DXAudioIn1: TDXAudioIn;
    StereoBalance1: TStereoBalance;
    voMic: TVorbisOut;
    VorbisIn1: TVorbisIn;
    bSelectAudioFromFile: TButton;
    procedure bPlayClick(Sender: TObject);
    procedure bRecordAudioClick(Sender: TObject);
    procedure bRemoveAllAudioClick(Sender: TObject);
    procedure bSelectAudioFromFileClick(Sender: TObject);
    procedure voMicDone(Sender: TComponent);
    procedure DSAudioOut1Done(Sender: TComponent);
  private
    FField: TEditableAudioField;

    procedure PlayAudio;
    procedure RecordAudio;

    procedure RefreshEnables;
    procedure OnOutputAudioStart;
    procedure OnInputAudioStart;
  public
    constructor Create(AOwner: TComponent; AField: TEditableAudioField); reintroduce;
  end;

implementation

{$R *.fmx}

{ TFrmEditableAudioItem }

procedure TFrmEditableAudioItem.bPlayClick(Sender: TObject);
begin
  if DSAudioOut1.Input.IsBusy then
    DSAudioOut1.Stop
  else
    PlayAudio;
end;

procedure TFrmEditableAudioItem.bRecordAudioClick(Sender: TObject);
begin
  if voMic.Status = TOutputStatus.tosPlaying then
    voMic.Stop
  else
    RecordAudio;
end;

procedure TFrmEditableAudioItem.bRemoveAllAudioClick(Sender: TObject);
begin
  FField.Value := '';
  RefreshEnables;
end;

procedure TFrmEditableAudioItem.bSelectAudioFromFileClick(Sender: TObject);
begin
  var dlg := TOpenDialog.Create(Self);
  try
    dlg.Filter := 'Audio file (*.ogg)|*.ogg';
    if not dlg.Execute then
      Exit;

    if not dlg.Files[0].EndsWith('.ogg') then
    begin
      var errdlg := TUserDialog.Create(Self);
      try
        errdlg.MakeSimpleInfo('Invalid file extension. Only .ogg is supported.');
      finally
        errDlg.Free;
      end;
      Exit;
    end;

    FField.Value := ChangeFileExt(TPath.GetFileName(dlg.Files[0]), '');
    FField.BasePath := TPath.GetDirectoryName(dlg.Files[0]);
    RefreshEnables;
  finally
    dlg.Free;
  end;
end;

constructor TFrmEditableAudioItem.Create(AOwner: TComponent;
  AField: TEditableAudioField);
begin
  inherited Create(AOwner);
  FField := AField;

  Label1.Text := FField.Name;

  DSAudioOut1.OnStart := OnOutputAudioStart;
  voMic.OnStart := OnInputAudioStart;
  RefreshEnables;
end;

procedure TFrmEditableAudioItem.OnOutputAudioStart;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      bPlay.StyleLookup := 'stoptoolbuttonmultiview';
      bPlay.Text := 'Stop';
      bRemoveAllAudio.Enabled := False;
      bRecordAudio.Enabled := False;
    end);
end;

procedure TFrmEditableAudioItem.OnInputAudioStart;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      bPlay.Enabled := False;
      bRemoveAllAudio.Enabled := False;
      bRecordAudio.StyleLookup := 'stoptoolbuttonmultiview';
      bRecordAudio.Text := 'Stop recording';
    end);
end;

procedure TFrmEditableAudioItem.DSAudioOut1Done(Sender: TComponent);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      bPlay.StyleLookup := 'playtoolbuttonmultiview';
      bPlay.Text := 'Play';

      RefreshEnables;
    end);
end;

procedure TFrmEditableAudioItem.PlayAudio;
begin
  for var idx := 0 to DSAudioOut1.DeviceCount - 1 do
    if DSAudioOut1.DeviceName[idx].Equals(TAppConfig.GetInstance.OutputDeviceName) then
    begin
      DSAudioOut1.DeviceNumber := idx;
      Break;
    end;

  DSAudioOut1.Stop(False);

  VorbisIn1.FileName := TPath.Combine(FField.BasePath, FField.Value + '.ogg');
  DSAudioOut1.Run;
end;

procedure TFrmEditableAudioItem.RecordAudio;
begin
  for var idx := 0 to DXAudioIn1.DeviceCount - 1 do
    if DXAudioIn1.DeviceName[idx].Equals(TAppConfig.GetInstance.InputDeviceName) then
    begin
      DXAudioIn1.DeviceNumber := idx;
      Break;
    end;

  FField.BasePath := TPath.GetTempPath;
  FField.Value := ChangeFileExt(TPath.GetRandomFileName, '');

  voMic.FileName := TPath.Combine(FField.BasePath, FField.Value + '.ogg');
  voMic.Run;
end;

procedure TFrmEditableAudioItem.RefreshEnables;
begin
  bPlay.Enabled := not FField.Value.IsEmpty;
  bRecordAudio.Enabled := True;
  bRemoveAllAudio.Enabled := bPlay.Enabled;
end;

procedure TFrmEditableAudioItem.voMicDone(Sender: TComponent);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      bRecordAudio.StyleLookup := 'mictoolbuttonmultiview';
      bRecordAudio.Text := 'Record audio';

      RefreshEnables;
    end);
end;

end.
