unit uFibbage4Content;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.JSON.Builders,
  uQuestionsLoader,
  uContentConfiguration,
  uFibbage4Questions,
  uFibbageJSONWriter,
  uFibbageContent;

type
  TFibbage4Content = class(TFibbageContent)
  private
    FShortieQuestions: TFibbage4Questions_Blankie;
    FFinalQuestions: TFibbage4Questions_Final;
    FPersonalQuestions: TFibbage4Questions_Personal;
    FCelebrityQuestions: TFibbage4Questions_Celebrity;
    FHeadlineQuestions: TFibbage4Questions_Headline;
    FHistoryQuestions: TFibbage4Questions_History;

    function GetManifestJSON: string;
    procedure SaveManifest(const APath: string);
    procedure SaveDummyFiles(const APath: string);
    procedure SaveIdBlankie(const APath: string);
    procedure SaveIdFinal(const APath: string);
    procedure SaveIdFan(const APath: string);
    procedure SaveIdHeadline(const APath: string);
    procedure SaveIdHistory(const APath: string);
    procedure SaveSkeleton(const APath: string);

    procedure DoSaveDummyContent(const APath, AFileName: string);
  protected
    function DoInitialize: Boolean; override;
    function DoGetEditableTypes: TPreviewTypes; override;
  public
    constructor Create(ACfg: TContentConfiguration);
    destructor Destroy; override;

    procedure ForEachQuestion(AType: TTypePreview; AProc: TProc<TFibbageQuestion>); override;
    function CreateNewQuestion(AType: TTypePreview): TFibbageQuestion; override;
    procedure RemoveQuestion(AType: TTypePreview; AQuestion: TFibbageQuestion); override;

    function CopyQuestion(AType: TTypePreview; AQuestion: TFibbageQuestion): Boolean; override;
    procedure MoveQuestion(ASrcType, ADstType: TTypePreview; AQuestion: TFibbageQuestion); override;

    procedure Activate(const APath: string); override;
    procedure Save; override;

    function HasDuplicatedCategory(AType: TTypePreview; AQuestion: TFibbageQuestion): Boolean; overload; override;
    function HasTooFewSuggestions(AType: TTypePreview; AQuestion: TFibbageQuestion): Boolean; override;
    function HasMissingSpecialEntries(AType: TTypePreview; AQuestion: TFibbageQuestion; out AError: string): Boolean; override;
    function HasTooFewQuestions(AType: TTypePreview): Boolean; override;

    function GetMoveCopyTypesFor(AType: TTypePreview): TArray<TTypePreview>; override;
  end;

implementation

{ TFibbage4Content }

function TFibbage4Content.CreateNewQuestion(AType: TTypePreview): TFibbageQuestion;
begin
  Result := nil;
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions, FPersonalQuestions, FCelebrityQuestions, FHeadlineQuestions, FHistoryQuestions] do
    if AType.InternalName = list.GetName then
      Exit(list.CreateNewQuestion);
  Assert(False);
end;

procedure TFibbage4Content.Activate(const APath: string);
begin
  var destPath := TPath.Combine(APath, 'content');
  var savePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  try
    try
      ForceDirectories(savePath);
      if SameText(FConfiguration.GetPath, destPath) then
        FConfiguration.Save(savePath);
      FShortieQuestions.Save(savePath);
      FFinalQuestions.Save(savePath);
      FPersonalQuestions.Save(savePath);
      FCelebrityQuestions.Save(savePath);
      FHeadlineQuestions.Save(savePath);
      FHistoryQuestions.Save(savePath);
      SaveManifest(savePath);
    except
      on E: Exception do
      begin
        TDirectory.Delete(savePath, True);
        raise;
      end;
    end;
  finally
    if TDirectory.Exists(savePath) then
    begin
      TDirectory.Delete(destPath, True);
      TDirectory.Copy(savePath, destPath); {CANNOT USE MOVE - NOT WORKING FOR MULTIPLE DRIVES}
      TDirectory.Delete(savePath, True);
    end;
  end;
end;

function TFibbage4Content.CopyQuestion;
begin
  Result := False;
end;

constructor TFibbage4Content.Create(ACfg: TContentConfiguration);
begin
  inherited Create(ACfg);
  FShortieQuestions := TFibbage4Questions_Blankie.Create;
  FFinalQuestions := TFibbage4Questions_Final.Create;
  FPersonalQuestions := TFibbage4Questions_Personal.Create;
  FCelebrityQuestions := TFibbage4Questions_Celebrity.Create;
  FHeadlineQuestions := TFibbage4Questions_Headline.Create;
  FHistoryQuestions := TFibbage4Questions_History.Create;
  FFilesReader.BasePath := TPath.Combine(FFilesReader.BasePath, 'en');
end;

destructor TFibbage4Content.Destroy;
begin
  FShortieQuestions.Free;
  FFinalQuestions.Free;
  FPersonalQuestions.Free;
  FCelebrityQuestions.Free;
  FHeadlineQuestions.Free;
  FHistoryQuestions.Free;
  inherited;
end;

function TFibbage4Content.DoInitialize: Boolean;
begin
  if not FConfiguration.NewContent then
  begin
    FShortieQuestions.Initialize(FFilesReader);
    FFinalQuestions.Initialize(FFilesReader);
    FPersonalQuestions.Initialize(FFilesReader);
    FCelebrityQuestions.Initialize(FFilesReader);
    FHeadlineQuestions.Initialize(FFilesReader);
    FHistoryQuestions.Initialize(FFilesReader);
  end;
  Result := True;
end;

procedure TFibbage4Content.DoSaveDummyContent(const APath, AFileName: string);
begin
  var fileName := TPath.Combine(APath, 'en', AFileName);
  var fs := TFileStream.Create(fileName, fmCreate);
  var sw := TStreamWriter.Create(fs);
  var builder := TFibbageJSONBuilder.Create;
  try
    builder
      .BeginObject
        .BeginArray('content')
        .EndArray
      .EndObject;

    sw.OwnStream;
    sw.Write(builder.Build);
  finally
    builder.Free;
    sw.Free;
  end;
end;

procedure TFibbage4Content.ForEachQuestion;
begin
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions,
    FPersonalQuestions, FCelebrityQuestions, FHeadlineQuestions, FHistoryQuestions] do
    if AType.InternalName = list.GetName then
    begin
      for var idx := 0 to list.Count - 1 do
        AProc(list[idx]);
      Exit;
    end;

  Assert(False);
end;

function TFibbage4Content.DoGetEditableTypes: TPreviewTypes;
begin
  Result := TPreviewTypes.Create;
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions,
    FPersonalQuestions, FCelebrityQuestions, FHeadlineQuestions, FHistoryQuestions] do
    Result.Add(list.GetTypePreview);
end;

function TFibbage4Content.GetManifestJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    builder.BeginObject
      .Add('id', 'Main')
      .Add('name', 'Fibbage4')
      .BeginArray('types')
        .Add(FShortieQuestions.GetName)
        .Add(FFinalQuestions.GetName)
        .Add('skeleton')
        .Add(FPersonalQuestions.GetName)
        .Add(FCelebrityQuestions.GetName)
        .Add(FHeadlineQuestions.GetName)
        .Add(FHistoryQuestions.GetName)
        .Add('fanblankie')
        .Add('movieblankie')
        .Add('idblankie')
        .Add('idheadline')
        .Add('idhistory')
        .Add('idfan')
        .Add('idfinal')
      .EndArray
    .EndObject;
    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage4Content.GetMoveCopyTypesFor(
  AType: TTypePreview): TArray<TTypePreview>;
begin
  Result := [];
    // TODO REST
  for var item in FEditableTypes do
  begin
    if item.InternalName = AType.InternalName then
      Continue;
    // TODO REST
    Result := Result + [item];
  end;
end;

function TFibbage4Content.HasDuplicatedCategory(AType: TTypePreview;
  AQuestion: TFibbageQuestion): Boolean;
begin
  Result := False;
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions, FPersonalQuestions, FCelebrityQuestions, FHeadlineQuestions, FHistoryQuestions] do
    if AType.InternalName = list.GetName then
      Exit(list.HasQuestionWithTheSameCategory(AQuestion as TFibbage4Question));
  Assert(False);
end;

function TFibbage4Content.HasMissingSpecialEntries(AType: TTypePreview; AQuestion: TFibbageQuestion; out AError: string): Boolean;
begin
  Result := (AQuestion as TFibbage4Question).IsMissingSpecialEntry(AError);
end;

function TFibbage4Content.HasTooFewQuestions(AType: TTypePreview): Boolean;
const
  MIN_SHORTIE_QUESTIONS_COUNT = 5;
  MIN_FINAL_QUESTIONS_COUNT = 1;
  MIN_PERSONAL_QUESTIONS_COUNT = 6;
  MIN_CELEBRITY_QUESTIONS_COUNT = 2;
  MIN_HEADLINE_QUESTIONS_COUNT = 2;
  MIN_HISTORY_QUESTIONS_COUNT = 2;
begin
  Result := False;
  if AType.InternalName = FShortieQuestions.GetName then
    Result := FShortieQuestions.Count < MIN_SHORTIE_QUESTIONS_COUNT
  else if AType.InternalName = FFinalQuestions.GetName then
    Result := FFinalQuestions.Count < MIN_FINAL_QUESTIONS_COUNT
  else if AType.InternalName = FPersonalQuestions.GetName then
    Result := FPersonalQuestions.Count < MIN_PERSONAL_QUESTIONS_COUNT
  else if AType.InternalName = FCelebrityQuestions.GetName then
    Result := FCelebrityQuestions.Count < MIN_CELEBRITY_QUESTIONS_COUNT
  else if AType.InternalName = FHeadlineQuestions.GetName then
    Result := FCelebrityQuestions.Count < MIN_HEADLINE_QUESTIONS_COUNT
  else if AType.InternalName = FHistoryQuestions.GetName then
    Result := FCelebrityQuestions.Count < MIN_HISTORY_QUESTIONS_COUNT
  else
    Assert(False);
end;

function TFibbage4Content.HasTooFewSuggestions(AType: TTypePreview;
  AQuestion: TFibbageQuestion): Boolean;
const
  OPTIMAL_SUGGESTIONS_NR = 17;
begin
  Result := (AQuestion as TFibbage4Question).SuggestionsCount < OPTIMAL_SUGGESTIONS_NR;
end;

procedure TFibbage4Content.MoveQuestion(ASrcType, ADstType: TTypePreview;
  AQuestion: TFibbageQuestion);
begin
  if CopyQuestion(ADstType, AQuestion) then
    RemoveQuestion(ASrcType, AQuestion);
end;

procedure TFibbage4Content.RemoveQuestion(AType: TTypePreview;
  AQuestion: TFibbageQuestion);
begin
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions,
    FPersonalQuestions, FCelebrityQuestions, FHeadlineQuestions, FHistoryQuestions] do
    if AType.InternalName = list.GetName then
    begin
      list.RemoveQuestion(AQuestion as TFibbage4Question);
      Exit;
    end;

  Assert(False);
end;

procedure TFibbage4Content.Save;
begin
  var savePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  try
    try
      FConfiguration.Save(savePath);
      FShortieQuestions.Save(savePath);
      FFinalQuestions.Save(savePath);
      FPersonalQuestions.Save(savePath);
      FCelebrityQuestions.Save(savePath);
      FHeadlineQuestions.Save(savePath);
      FHistoryQuestions.Save(savePath);
      SaveDummyFiles(savePath);
      SaveManifest(savePath);
    except
      on E: Exception do
      begin
        TDirectory.Delete(savePath, True);
        raise;
      end;
    end;
  finally
    if TDirectory.Exists(savePath) then
    begin
      TDirectory.Delete(FConfiguration.GetPath, True);
      TDirectory.Copy(savePath, FConfiguration.GetPath); {CANNOT USE MOVE - NOT WORKING FOR MULTIPLE DRIVES}
      TDirectory.Delete(savePath, True);
    end;
  end;
end;

procedure TFibbage4Content.SaveDummyFiles(const APath: string);
begin
  SaveIdBlankie(APath);
  SaveIdFinal(APath);
  SaveIdFan(APath);
  SaveIdHeadline(APath);
  SaveIdHistory(APath);
  SaveSkeleton(APath);
end;

procedure TFibbage4Content.SaveIdBlankie(const APath: string);
begin
  DoSaveDummyContent(APath, 'idblankie.jet');
end;

procedure TFibbage4Content.SaveIdFan(const APath: string);
begin
  DoSaveDummyContent(APath, 'idfan.jet');
end;

procedure TFibbage4Content.SaveIdFinal(const APath: string);
begin
  DoSaveDummyContent(APath, 'idfinal.jet');
end;

procedure TFibbage4Content.SaveIdHeadline(const APath: string);
begin
  DoSaveDummyContent(APath, 'idheadline.jet');
end;

procedure TFibbage4Content.SaveIdHistory(const APath: string);
begin
  DoSaveDummyContent(APath, 'idhistory.jet');
end;

procedure TFibbage4Content.SaveManifest(const APath: string);
begin
  var fileName := TPath.Combine(APath, 'manifest.jet');
  var fs := TFileStream.Create(fileName, fmCreate);
  var sw := TStreamWriter.Create(fs);
  try
    sw.OwnStream;
    sw.Write(GetManifestJSON);
  finally
    sw.Free;
  end;
end;

procedure TFibbage4Content.SaveSkeleton(const APath: string);
begin
  DoSaveDummyContent(APath, 'skeleton.jet');
end;

end.
