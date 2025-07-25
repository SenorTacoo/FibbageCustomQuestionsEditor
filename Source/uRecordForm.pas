unit uRecordForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, NewAC_DSP,
  ACS_Classes, NewACIndicators, FMX.Controls.Presentation, FMX.StdCtrls,
  ACS_Vorbis, ACS_DXAudio, FMX.ListBox, uInterfaces, FMX.Layouts,
  ACS_Converters, NewACDSAudio, FMX.Media, uConfig, System.IOUtils, System.Math;

type
  TAudioType = (atQuestion, atAnswer, atBumper, atRecorded, atQuestion2);

  TRecordForm = class(TForm)
    DXAudioIn1: TDXAudioIn;
    voMic: TVorbisOut;
    bPlayOriginalAudio: TButton;
    bPlayRecordedAudio: TButton;
    bRecordAudio: TButton;
    bGoBack: TButton;
    bSaveRecordedAudio: TButton;
    Layout1: TLayout;
    lAudioInput: TLabel;
    cbAudioInput: TComboBox;
    Layout2: TLayout;
    lAudioOutput: TLabel;
    cbAudioOutput: TComboBox;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    GridPanelLayout1: TGridPanelLayout;
    DSAudioOut1: TDSAudioOut;
    VorbisIn1: TVorbisIn;
    StereoBalance1: TStereoBalance;
    bRemoveAllAudio: TButton;
    procedure bPlayOriginalAudioClick(Sender: TObject);
    procedure bPlayRecordedAudioClick(Sender: TObject);
    procedure bGoBackClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bRecordAudioClick(Sender: TObject);
    procedure bSaveRecordedAudioClick(Sender: TObject);
    procedure bRefreshDevicesClick(Sender: TObject);
    procedure cbAudioOutputChange(Sender: TObject);
    procedure cbAudioInputChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure voMicDone(Sender: TComponent);
    procedure DSAudioOut1Done(Sender: TComponent);
    procedure bRemoveAllAudioClick(Sender: TObject);
  private
    FAudioType: TAudioType;
    FQuestion: IQuestion;
    FFormCreated: Boolean;
    FCurrentlyPlayingMode: TAudioType;
    FRecordedData: TBytes;

    procedure FillDevices;
    procedure DisablePlay;
    procedure DisableRecord;
    procedure PlayAudio(AMode: TAudioType);
    procedure OnOutputAudioStart;
    procedure SaveAudio;
    procedure RemoveTmpFile;
    procedure RemoveTmpAudioFile;
    procedure OnInputAudioStart;
    procedure EnablePlayOriginalIfPossible;
    function CreateTempAudioFile(AMode: TAudioType): string;
    procedure SaveRecordedDataAndRemoveTmpFile;
  public
    function ShowModal: TModalResult; overload;

    procedure EditQuestionAudio(AQuestion: IQuestion);
    procedure EditQuestion2Audio(AQuestion: IQuestion);
    procedure EditAnswerAudio(AQuestion: IQuestion);
    procedure EditBumperAudio(AQuestion: IQuestion);
  end;

implementation

{$R *.fmx}

uses
  uMainForm;

procedure TRecordForm.bPlayOriginalAudioClick(Sender: TObject);
begin
  if DSAudioOut1.Input.IsBusy then
    DSAudioOut1.Stop
  else
    PlayAudio(FAudioType);
end;

procedure TRecordForm.bPlayRecordedAudioClick(Sender: TObject);
begin
  if DSAudioOut1.Input.IsBusy then
    DSAudioOut1.Stop
  else
    PlayAudio(atRecorded);
end;

procedure TRecordForm.bRecordAudioClick(Sender: TObject);
begin
  if voMic.Input.IsBusy then
    voMic.Stop
  else
  begin
    DXAudioIn1.DeviceNumber := cbAudioInput.ItemIndex;
    voMic.FileName := TPath.Combine(TPath.GetTempPath, ChangeFileExt(TPath.GetRandomFileName, '.ogg'));
    voMic.Run;
  end;
end;

procedure TRecordForm.bRefreshDevicesClick(Sender: TObject);
begin
  FillDevices;
end;

procedure TRecordForm.bRemoveAllAudioClick(Sender: TObject);
begin
  bPlayOriginalAudio.Enabled := False;
  bPlayRecordedAudio.Enabled := False;
  bRemoveAllAudio.Enabled := False;
  bRecordAudio.Enabled := False;
  bSaveRecordedAudio.Enabled := True;
  FRecordedData := nil;
end;

procedure TRecordForm.bSaveRecordedAudioClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TRecordForm.cbAudioInputChange(Sender: TObject);
begin
  if not FFormCreated then
    Exit;

  TAppConfig.GetInstance.InputDeviceName := cbAudioInput.Items[cbAudioInput.ItemIndex];
end;

procedure TRecordForm.cbAudioOutputChange(Sender: TObject);
begin
  if not FFormCreated then
    Exit;

  TAppConfig.GetInstance.OutputDeviceName := cbAudioOutput.Items[cbAudioOutput.ItemIndex];
end;

procedure TRecordForm.DisablePlay;
begin
  bPlayOriginalAudio.Enabled := False;
  bPlayRecordedAudio.Enabled := False;
  bRemoveAllAudio.Enabled := False;
end;

procedure TRecordForm.EnablePlayOriginalIfPossible;
begin
  var res := True;
  case FAudioType of
    atQuestion:
      res := FQuestion.GetHaveQuestionAudio and (Length(FQuestion.GetQuestionAudioData) > 0);
    atAnswer:
      res := FQuestion.GetHaveAnswerAudio and (Length(FQuestion.GetAnswerAudioData) > 0);
    atBumper:
      res := FQuestion.GetHaveBumperAudio and (Length(FQuestion.GetBumperAudioData) > 0);
    atQuestion2:
      res := FQuestion.GetHaveQuestionAudio2 and (Length(FQuestion.GetQuestionAudioData2) > 0);
  end;
  bPlayOriginalAudio.Enabled := res;
  bRemoveAllAudio.Enabled := bPlayOriginalAudio.Enabled;
end;

procedure TRecordForm.DisableRecord;
begin
  bRecordAudio.Enabled := False;
end;

procedure TRecordForm.DSAudioOut1Done(Sender: TComponent);
begin
  TThread.Synchronize(nil,
  procedure
  begin
    RemoveTmpAudioFile;
    case FCurrentlyPlayingMode of
      atRecorded:
      begin
        bPlayRecordedAudio.StyleLookup := 'playtoolbuttonmultiview';
        bPlayRecordedAudio.Text := 'Play recorded audio';
      end
      else
      begin
        bPlayOriginalAudio.StyleLookup := 'playtoolbuttonmultiview';
        bPlayOriginalAudio.Text := 'Play original audio';
      end;
    end;

    EnablePlayOriginalIfPossible;
    bRecordAudio.Enabled := True;
    bPlayRecordedAudio.Enabled := Length(FRecordedData) > 0;
    bSaveRecordedAudio.Enabled := bPlayRecordedAudio.Enabled;
  end);
end;

procedure TRecordForm.EditAnswerAudio(AQuestion: IQuestion);
begin
  FAudioType := atAnswer;
  FQuestion := AQuestion;
  if ShowModal = mrOk then
    SaveAudio
end;

procedure TRecordForm.EditBumperAudio(AQuestion: IQuestion);
begin
  FAudioType := atBumper;
  FQuestion := AQuestion;
  if ShowModal = mrOk then
    SaveAudio
end;

procedure TRecordForm.EditQuestion2Audio(AQuestion: IQuestion);
begin
  FAudioType := atQuestion2;
  FQuestion := AQuestion;
  if ShowModal = mrOk then
    SaveAudio
end;

procedure TRecordForm.EditQuestionAudio(AQuestion: IQuestion);
begin
  FAudioType := atQuestion;
  FQuestion := AQuestion;
  if ShowModal = mrOk then
    SaveAudio
end;

procedure TRecordForm.bGoBackClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TRecordForm.FillDevices;
var
  idx: Integer;
  itemWidth: Single;
  itemIndex: Integer;
begin
  itemWidth := 0.0;
  itemIndex := 0;
  cbAudioOutput.Items.BeginUpdate;
  try
    cbAudioOutput.Items.Clear;
    for idx := 0 to DSAudioOut1.DeviceCount - 1 do
    begin
      cbAudioOutput.Items.Add(DSAudioOut1.DeviceName[idx]);
      if DSAudioOut1.DeviceName[idx].Equals(TAppConfig.GetInstance.OutputDeviceName) then
        itemIndex := idx;
      if itemWidth < cbAudioOutput.Canvas.TextWidth(DSAudioOut1.DeviceName[idx]) then
        itemWidth := cbAudioOutput.Canvas.TextWidth(DSAudioOut1.DeviceName[idx]);
    end;
    if cbAudioOutput.Items.Count = 0 then
      DisablePlay
    else
      cbAudioOutput.ItemIndex := itemIndex;
    cbAudioOutput.ItemWidth := Max(itemWidth, cbAudioOutput.Width);
    cbAudioOutput.ItemHeight := cbAudioOutput.Canvas.TextHeight('Yy');
  finally
    cbAudioOutput.Items.EndUpdate;
  end;

  itemWidth := 0;
  itemIndex := 0;
  cbAudioInput.Items.BeginUpdate;
  try
    cbAudioInput.Items.Clear;
    for idx := 0 to DXAudioIn1.DeviceCount - 1 do
    begin
      cbAudioInput.Items.Add(DXAudioIn1.DeviceName[idx]);
      if DXAudioIn1.DeviceName[idx].Equals(TAppConfig.GetInstance.InputDeviceName) then
        itemIndex := idx;
      if itemWidth < cbAudioInput.Canvas.TextWidth(DXAudioIn1.DeviceName[idx]) then
        itemWidth := cbAudioInput.Canvas.TextWidth(DXAudioIn1.DeviceName[idx]);
    end;
    if cbAudioInput.Items.Count = 0 then
      DisableRecord
    else
      cbAudioInput.ItemIndex := itemIndex;
    cbAudioInput.ItemWidth := Max(itemWidth, cbAudioInput.Width);
    cbAudioInput.ItemHeight := cbAudioInput.Canvas.TextHeight('Yy');
  finally
    cbAudioInput.Items.EndUpdate;
  end;
end;

procedure TRecordForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  voMic.Stop(False);
  DSAudioOut1.Stop(False);
end;

procedure TRecordForm.FormCreate(Sender: TObject);
begin
  StyleBook := Application.MainForm.StyleBook;

  var font := TFont.Create;
  try
    font.Family := 'Segoe UI';
    font.Size := 18;
    font.Style := [];

    cbAudioOutput.Canvas.Font.Assign(font);
    cbAudioInput.Canvas.Font.Assign(font);
  finally
    font.Free;
  end;

  DSAudioOut1.OnStart := OnOutputAudioStart;
  voMic.OnStart := OnInputAudioStart;
  FillDevices;
  FFormCreated := True;
end;

procedure TRecordForm.OnInputAudioStart;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      bPlayOriginalAudio.Enabled := False;
      bRemoveAllAudio.Enabled := False;
      bRecordAudio.StyleLookup := 'stoptoolbuttonmultiview';
      bRecordAudio.Text := 'Stop recording';
      bPlayRecordedAudio.Enabled := False;
      bSaveRecordedAudio.Enabled := False;
    end);
end;

procedure TRecordForm.OnOutputAudioStart;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      case FCurrentlyPlayingMode of
        atRecorded:
        begin
          bPlayRecordedAudio.StyleLookup := 'stoptoolbuttonmultiview';
          bPlayRecordedAudio.Text := 'Stop';
          bPlayOriginalAudio.Enabled := False;
        end
        else
        begin
          bPlayOriginalAudio.StyleLookup := 'stoptoolbuttonmultiview';
          bPlayOriginalAudio.Text := 'Stop';
          bPlayRecordedAudio.Enabled := False;
        end;
      end;
      bRemoveAllAudio.Enabled := False;
      bRecordAudio.Enabled := False;
      bSaveRecordedAudio.Enabled := False;
    end);
end;

procedure TRecordForm.PlayAudio(AMode: TAudioType);
begin
  DSAudioOut1.DeviceNumber := cbAudioOutput.ItemIndex;
  DSAudioOut1.Stop(False);

  FCurrentlyPlayingMode := AMode;
  VorbisIn1.FileName := CreateTempAudioFile(AMode);
  DSAudioOut1.Run;
end;

function TRecordForm.CreateTempAudioFile(AMode: TAudioType): string;
var
  buffer: TBytes;
begin
  case AMode of
    atQuestion: buffer := FQuestion.GetQuestionAudioData;
    atAnswer: buffer := FQuestion.GetAnswerAudioData;
    atBumper: buffer := FQuestion.GetBumperAudioData;
    atRecorded: buffer := FRecordedData;
    atQuestion2: buffer := FQuestion.GetQuestionAudioData2;
  end;

  Result := TPath.Combine(TPath.GetTempPath, TPath.GetTempFileName);
  var fs := TFileStream.Create(Result, fmCreate);
  try
    fs.Write(buffer, Length(buffer));
  finally
    fs.Free;
  end;
end;

procedure TRecordForm.RemoveTmpAudioFile;
begin
  if (VorbisIn1.FileName <> '') and FileExists(VorbisIn1.FileName) then
    DeleteFile(VorbisIn1.FileName);
end;

procedure TRecordForm.RemoveTmpFile;
begin
  if (voMic.FileName <> '') and FileExists(voMic.FileName) then
    DeleteFile(voMic.FileName);
end;

procedure TRecordForm.SaveAudio;
begin
  case FAudioType of
    atQuestion:
      FQuestion.SetQuestionAudioData(FRecordedData);
    atAnswer:
      FQuestion.SetAnswerAudioData(FRecordedData);
    atBumper:
      FQuestion.SetBumperAudioData(FRecordedData);
    atQuestion2:
      FQuestion.SetQuestionAudioData2(FRecordedData);
  end;
end;

function TRecordForm.ShowModal: TModalResult;
begin
  EnablePlayOriginalIfPossible;
  Result := inherited;
end;

procedure TRecordForm.SaveRecordedDataAndRemoveTmpFile;
begin
  if not FileExists(voMic.FileName) then
    Exit;
  var fs := TFileStream.Create(voMic.FileName, fmOpenRead);
  try
    SetLength(FRecordedData, fs.Size);
    fs.Read(FRecordedData, Length(FRecordedData));
  finally
    fs.Free;
  end;

  RemoveTmpFile;
end;

procedure TRecordForm.voMicDone(Sender: TComponent);
begin
  TThread.Synchronize(nil,
  procedure
  begin
    SaveRecordedDataAndRemoveTmpFile;

    EnablePlayOriginalIfPossible;
    bRecordAudio.StyleLookup := 'mictoolbuttonmultiview';
    bRecordAudio.Text := 'Record audio';
    bPlayRecordedAudio.Enabled := Length(FRecordedData) > 0;
    bSaveRecordedAudio.Enabled := bPlayRecordedAudio.Enabled;
  end);
end;

end.
