unit uFibbageXLPartyPack1Content;

interface

uses
  System.Math,
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.JSON.Builders,
  uQuestionsLoader,
  uContentConfiguration,
  uFibbageXLPartyPack1Questions,
  uFibbageJSONWriter,
  uFibbageContent;

type
  TFibbageXLPartyPack1Content = class(TFibbageContent)
  private
    FShortieQuestions: TFibbageXLPartyPack1Questions_Shortie;
    FFinalQuestions: TFibbageXLPartyPack1Questions_Final;

    function GetManifestJSON: string;
    procedure SaveManifest(const APath: string);
    function GetNextQuestionId: UInt32;
  protected
    function DoInitialize: Boolean; override;
    function DoGetEditableTypes: TPreviewTypes; override;
  public
    constructor Create(ACfg: TContentConfiguration);
    destructor Destroy; override;

    procedure ForEachQuestion(AType: TTypePreview; AProc: TProc<TFibbageQuestion>); override;
    function CreateNewQuestion(AType: TTypePreview): TFibbageQuestion; override;
    procedure RemoveQuestion(AType: TTypePreview; AQuestion: TFibbageQuestion); override;

    procedure CopyQuestion(AType: TTypePreview; AQuestion: TFibbageQuestion); override;
    procedure MoveQuestion(ASrcType, ADstType: TTypePreview; AQuestion: TFibbageQuestion); override;

    procedure Activate(const APath: string); override;
    procedure Save; override;

    function HasDuplicatedCategory(AType: TTypePreview; AQuestion: TFibbageQuestion): Boolean; overload; override;
    function HasTooFewSuggestions(AType: TTypePreview; AQuestion: TFibbageQuestion): Boolean; override;
    function HasMissingBlank(AType: TTypePreview; AQuestion: TFibbageQuestion; out AError: string): Boolean; override;
    function HasTooFewQuestions(AType: TTypePreview): Boolean; override;
  end;

implementation

{ TFibbageXLPartyPack1Content }

function TFibbageXLPartyPack1Content.CreateNewQuestion(AType: TTypePreview): TFibbageQuestion;
begin
  Result := nil;
  if AType.InternalName = FShortieQuestions.GetName then
    Result := FShortieQuestions.CreateNewQuestion
  else if AType.InternalName = FFinalQuestions.GetName then
    Result := FFinalQuestions.CreateNewQuestion
  else
    Assert(False);
end;

procedure TFibbageXLPartyPack1Content.Activate(const APath: string);
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

procedure TFibbageXLPartyPack1Content.CopyQuestion(AType: TTypePreview;
  AQuestion: TFibbageQuestion);
var
  question: TFibbageXLPartyPack1Question;
begin
  if FShortieQuestions.GetName = AType.InternalName then
    question := FShortieQuestions.CreateNewQuestion
  else if FFinalQuestions.GetName = AType.InternalName then
    question := FFinalQuestions.CreateNewQuestion
  else
  begin
    Assert(False);
    Exit;
  end;
  question.Assign(AQuestion);
end;

constructor TFibbageXLPartyPack1Content.Create(ACfg: TContentConfiguration);
begin
  inherited Create(ACfg);
  FShortieQuestions := TFibbageXLPartyPack1Questions_Shortie.Create;
  FFinalQuestions := TFibbageXLPartyPack1Questions_Final.Create;

  FShortieQuestions.OnGetNextQuestionId := GetNextQuestionId;
  FFinalQuestions.OnGetNextQuestionId := GetNextQuestionId;
end;

destructor TFibbageXLPartyPack1Content.Destroy;
begin
  FShortieQuestions.Free;
  FFinalQuestions.Free;
  inherited;
end;

function TFibbageXLPartyPack1Content.DoInitialize: Boolean;
begin
  if not FConfiguration.NewContent then
  begin
    FShortieQuestions.Initialize(FFilesReader);
    FFinalQuestions.Initialize(FFilesReader);
  end;
  Result := True;
end;

procedure TFibbageXLPartyPack1Content.ForEachQuestion(AType: TTypePreview;
  AProc: TProc<TFibbageQuestion>);
begin
  if AType.InternalName = FShortieQuestions.GetName then
  begin
    for var idx := 0 to FShortieQuestions.Count - 1 do
      AProc(FShortieQuestions[idx]);
  end
  else if AType.InternalName = FFinalQuestions.GetName then
  begin
    for var idx := 0 to FFinalQuestions.Count - 1 do
      AProc(FFinalQuestions[idx]);
  end
  else
    Assert(False);
end;

function TFibbageXLPartyPack1Content.DoGetEditableTypes: TPreviewTypes;
begin
  Result := TPreviewTypes.Create;
  Result.Add(FShortieQuestions.GetTypePreview);
  Result.Add(FFinalQuestions.GetTypePreview);
end;

function TFibbageXLPartyPack1Content.GetManifestJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    builder.BeginObject
      .Add('id', 'Main')
      .Add('name', 'Main Content Pack')
      .BeginArray('types')
        .Add(FShortieQuestions.GetName)
        .Add(FFinalQuestions.GetName)
      .EndArray
    .EndObject;
    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbageXLPartyPack1Content.GetNextQuestionId: UInt32;
var
  found: Boolean;
begin
  repeat
    Result := RandomRange(16000, 50000);
    found := Assigned(FShortieQuestions.GetFirstQuestionWithId(Result)) or
      Assigned(FFinalQuestions.GetFirstQuestionWithId(Result));
  until not found;
end;

function TFibbageXLPartyPack1Content.HasDuplicatedCategory(AType: TTypePreview;
  AQuestion: TFibbageQuestion): Boolean;
begin
  Result := False;
  if AType.InternalName = FShortieQuestions.GetName then
    Result := FShortieQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbageXLPartyPack1Question)
  else if AType.InternalName = FFinalQuestions.GetName then
    Result := FFinalQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbageXLPartyPack1Question)
  else
    Assert(False);
end;

function TFibbageXLPartyPack1Content.HasMissingBlank(AType: TTypePreview;
  AQuestion: TFibbageQuestion; out AError: string): Boolean;
begin
  Result := False;
end;

function TFibbageXLPartyPack1Content.HasTooFewQuestions;
const
  MIN_SHORTIE_QUESTIONS_COUNT = 5;
  MIN_FINAL_QUESTIONS_COUNT = 1;
begin
  Result := False;
  if AType.InternalName = FShortieQuestions.GetName then
    Result := FShortieQuestions.Count < MIN_SHORTIE_QUESTIONS_COUNT
  else if AType.InternalName = FFinalQuestions.GetName then
    Result := FFinalQuestions.Count < MIN_FINAL_QUESTIONS_COUNT
  else
    Assert(False);
end;

function TFibbageXLPartyPack1Content.HasTooFewSuggestions;
const
  OPTIMAL_SUGGESTIONS_NR = 17;
begin
  Result := (AQuestion as TFibbageXLPartyPack1Question).SuggestionsCount < OPTIMAL_SUGGESTIONS_NR;
end;

procedure TFibbageXLPartyPack1Content.MoveQuestion;
begin
  CopyQuestion(ADstType, AQuestion);
  RemoveQuestion(ASrcType, AQuestion);
end;

procedure TFibbageXLPartyPack1Content.RemoveQuestion;
begin
  if AType.InternalName = FShortieQuestions.GetName then
    FShortieQuestions.RemoveQuestion(AQuestion as TFibbageXLPartyPack1Question)
  else if AType.InternalName = FFinalQuestions.GetName then
    FFinalQuestions.RemoveQuestion(AQuestion as TFibbageXLPartyPack1Question)
  else
    Assert(False);
end;

procedure TFibbageXLPartyPack1Content.Save;
begin
  var savePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  try
    try
      FConfiguration.Save(savePath);
      FShortieQuestions.Save(savePath);
      FFinalQuestions.Save(savePath);
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

procedure TFibbageXLPartyPack1Content.SaveManifest(const APath: string);
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
