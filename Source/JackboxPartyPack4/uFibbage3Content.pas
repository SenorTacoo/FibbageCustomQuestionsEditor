unit uFibbage3Content;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.JSON.Builders,
  uQuestionsLoader,
  uContentConfiguration,
  uFibbage3Questions,
  uFibbageJSONWriter,
  uFibbageContent;

type
  TFibbage3Content = class(TFibbageContent)
  private
    FShortieQuestions: TFibbage3Questions_Shortie;
    FFinalQuestions: TFibbage3Questions_Final;
    FSpecialQuestions: TFibbage3Questions_Special;
    FTMIQuestions: TFibbage3Questions_TmiShortie;

    function GetManifestJSON: string;
    procedure SaveManifest(const APath: string);
  protected
    function DoInitialize: Boolean; override;
  public
    constructor Create(ACfg: TContentConfiguration);
    destructor Destroy; override;

    function GetEditableTypes: TPreviewTypes; override;
    procedure ForEachQuestion(const AType: string; AProc: TProc<TFibbageQuestion>); override;
    function CreateNewQuestion(const AType: string): TFibbageQuestion; override;
    procedure RemoveQuestion(const AType: string; AQuestion: TFibbageQuestion); override;

    procedure CopyQuestion(const AType: string; AQuestion: TFibbageQuestion); override;
    procedure MoveQuestion(const ASrcType, ADstType: string; AQuestion: TFibbageQuestion); override;

    procedure Activate(const APath: string); override;
    procedure Save; override;

    function HasDuplicatedCategory(const AType: string; AQuestion: TFibbageQuestion): Boolean; overload; override;
    function HasTooFewSuggestions(const AType: string; AQuestion: TFibbageQuestion): Boolean; override;
    function HasMissingBlank(const AType: string; AQuestion: TFibbageQuestion; out AError: string): Boolean; override;
    function HasTooFewQuestions(const AType: string): Boolean; override;
  end;

implementation

{ TFibbage3Content }

function TFibbage3Content.CreateNewQuestion(
  const AType: string): TFibbageQuestion;
begin
  Result := nil;
  if AType = FShortieQuestions.GetName then
    Result := FShortieQuestions.CreateNewQuestion
  else if AType = FFinalQuestions.GetName then
    Result := FFinalQuestions.CreateNewQuestion
  else if AType = FSpecialQuestions.GetName then
    Result := FSpecialQuestions.CreateNewQuestion
  else if AType = FTMIQuestions.GetName then
    Result := FTMIQuestions.CreateNewQuestion
  else
    Assert(False);
end;

procedure TFibbage3Content.Activate(const APath: string);
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
      FSpecialQuestions.Save(savePath);
      FTMIQuestions.Save(savePath);
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

procedure TFibbage3Content.CopyQuestion(const AType: string;
  AQuestion: TFibbageQuestion);
var
  question: TFibbageQuestion;
begin
  if FShortieQuestions.GetName = AType then
    question := FShortieQuestions.CreateNewQuestion
  else if FFinalQuestions.GetName = AType then
    question := FFinalQuestions.CreateNewQuestion
  else if FSpecialQuestions.GetName = AType then
    question := FSpecialQuestions.CreateNewQuestion
  else if FFinalQuestions.GetName = AType then
    question := FFinalQuestions.CreateNewQuestion
  else
  begin
    Assert(False);
    Exit;
  end;
  question.Assign(AQuestion);
end;

constructor TFibbage3Content.Create(ACfg: TContentConfiguration);
begin
  inherited Create(ACfg);
  FShortieQuestions := TFibbage3Questions_Shortie.Create;
  FFinalQuestions := TFibbage3Questions_Final.Create;
  FSpecialQuestions := TFibbage3Questions_Special.Create;
  FTMIQuestions := TFibbage3Questions_TmiShortie.Create;
end;

destructor TFibbage3Content.Destroy;
begin
  FShortieQuestions.Free;
  FFinalQuestions.Free;
  FSpecialQuestions.Free;
  FTMIQuestions.Free;
  inherited;
end;

function TFibbage3Content.DoInitialize: Boolean;
begin
  if not FConfiguration.NewContent then
  begin
    FShortieQuestions.Initialize(FFilesReader);
    FFinalQuestions.Initialize(FFilesReader);
    FSpecialQuestions.Initialize(FFilesReader);
    FTMIQuestions.Initialize(FFilesReader);
  end;
  Result := True;
end;

procedure TFibbage3Content.ForEachQuestion(const AType: string;
  AProc: TProc<TFibbageQuestion>);
begin
  if AType = FShortieQuestions.GetName then
  begin
    for var idx := 0 to FShortieQuestions.Count - 1 do
      AProc(FShortieQuestions[idx]);
  end
  else if AType = FFinalQuestions.GetName then
  begin
    for var idx := 0 to FFinalQuestions.Count - 1 do
      AProc(FFinalQuestions[idx]);
  end
  else if AType = FSpecialQuestions.GetName then
  begin
    for var idx := 0 to FSpecialQuestions.Count - 1 do
      AProc(FSpecialQuestions[idx]);
  end
  else if AType = FTMIQuestions.GetName then
  begin
    for var idx := 0 to FTMIQuestions.Count - 1 do
      AProc(FTMIQuestions[idx]);
  end
  else
    Assert(False);
end;

function TFibbage3Content.GetEditableTypes: TPreviewTypes;
begin
  Result := TPreviewTypes.Create;
  Result.Add(FShortieQuestions.GetTypePreview);
  Result.Add(FFinalQuestions.GetTypePreview);
  Result.Add(FSpecialQuestions.GetTypePreview);
  Result.Add(FTMIQuestions.GetTypePreview);
end;

function TFibbage3Content.GetManifestJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    builder.BeginObject
      .Add('id', 'Main')
      .Add('name', 'Main Content Pack')
      .BeginArray('types')
        .Add(FShortieQuestions.GetName)
        .Add(FFinalQuestions.GetName)
        .Add(FTMIQuestions.GetName)
        .Add(FSpecialQuestions.GetName)
      .EndArray
    .EndObject;
    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage3Content.HasDuplicatedCategory(const AType: string;
  AQuestion: TFibbageQuestion): Boolean;
begin
  Result := False;
  if AType = FShortieQuestions.GetName then
    Result := FShortieQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbage3Question)
  else if AType = FFinalQuestions.GetName then
    Result := FFinalQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbage3Question)
  else if AType = FSpecialQuestions.GetName then
    Result := FSpecialQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbage3Question)
  else if AType = FTMIQuestions.GetName then
    Result := FTMIQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbage3Question)
  else
    Assert(False);
end;

function TFibbage3Content.HasMissingBlank(const AType: string; AQuestion: TFibbageQuestion; out AError: string): Boolean;
begin
  Result := (AQuestion as TFibbage3Question).IsMissingBlank;
end;

function TFibbage3Content.HasTooFewQuestions(const AType: string): Boolean;
const
  MIN_SHORTIE_QUESTIONS_COUNT = 5;
  MIN_FINAL_QUESTIONS_COUNT = 1;
  MIN_SPECIAL_QUESTIONS_COUNT = 1;
  MIN_TMI_SHORTIE_QUESTIONS_COUNT = 5;
begin
  Result := False;
  if AType = FShortieQuestions.GetName then
    Result := FShortieQuestions.Count < MIN_SHORTIE_QUESTIONS_COUNT
  else if AType = FFinalQuestions.GetName then
    Result := FFinalQuestions.Count < MIN_FINAL_QUESTIONS_COUNT
  else if AType = FSpecialQuestions.GetName then
    Result := FSpecialQuestions.Count < MIN_SPECIAL_QUESTIONS_COUNT
  else if AType = FTMIQuestions.GetName then
    Result := FTMIQuestions.Count < MIN_TMI_SHORTIE_QUESTIONS_COUNT
  else
    Assert(False);
end;

function TFibbage3Content.HasTooFewSuggestions(const AType: string;
  AQuestion: TFibbageQuestion): Boolean;
const
  OPTIMAL_SUGGESTIONS_NR = 17;
begin
  Result := (AQuestion as TFibbage3Question).SuggestionsCount < OPTIMAL_SUGGESTIONS_NR;
end;

procedure TFibbage3Content.MoveQuestion(const ASrcType, ADstType: string;
  AQuestion: TFibbageQuestion);
begin
  CopyQuestion(ADstType, AQuestion);
  RemoveQuestion(ASrcType, AQuestion);
end;

procedure TFibbage3Content.RemoveQuestion(const AType: string;
  AQuestion: TFibbageQuestion);
begin
  if AType = FShortieQuestions.GetName then
    FShortieQuestions.RemoveQuestion(AQuestion as TFibbage3Question)
  else if AType = FFinalQuestions.GetName then
    FFinalQuestions.RemoveQuestion(AQuestion as TFibbage3Question)
  else if AType = FSpecialQuestions.GetName then
    FSpecialQuestions.RemoveQuestion(AQuestion as TFibbage3Question)
  else if AType = FFinalQuestions.GetName then
    FTMIQuestions.RemoveQuestion(AQuestion as TFibbage3Question)
  else
    Assert(False);
end;

procedure TFibbage3Content.Save;
begin
  var savePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  try
    try
      FConfiguration.Save(savePath);
      FShortieQuestions.Save(savePath);
      FFinalQuestions.Save(savePath);
      FSpecialQuestions.Save(savePath);
      FTMIQuestions.Save(savePath);
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

procedure TFibbage3Content.SaveManifest(const APath: string);
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

end.
