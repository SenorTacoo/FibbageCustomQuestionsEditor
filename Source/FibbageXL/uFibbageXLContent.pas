unit uFibbageXLContent;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.JSON.Builders,
  uQuestionsLoader,
  uContentConfiguration,
  uFibbageXLQuestions,
  uFibbageJSONWriter,
  uFibbageContent;

type
  TFibbageXLContent = class(TFibbageContent)
  private
    FShortieQuestions: TFibbageXLQuestions_Shortie;
    FFinalQuestions: TFibbageXLQuestions_Final;

    function GetManifestJSON: string;
    procedure SaveManifest(const APath: string);
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

{ TFibbageXLContent }

function TFibbageXLContent.CreateNewQuestion;
begin
  Result := nil;
  if AType.InternalName = FShortieQuestions.GetName then
    Result := FShortieQuestions.CreateNewQuestion
  else if AType.InternalName = FFinalQuestions.GetName then
    Result := FFinalQuestions.CreateNewQuestion
  else
    Assert(False);
end;

procedure TFibbageXLContent.Activate(const APath: string);
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

function TFibbageXLContent.CopyQuestion;
var
  question: TFibbageXLQuestion;
begin
  Result := True;
  if FShortieQuestions.GetName = AType.InternalName then
    question := FShortieQuestions.CreateNewQuestion
  else if FFinalQuestions.GetName = AType.InternalName then
    question := FFinalQuestions.CreateNewQuestion
  else
  begin
    Assert(False);
    Exit(False);
  end;
  question.Assign(AQuestion);
end;

constructor TFibbageXLContent.Create(ACfg: TContentConfiguration);
begin
  inherited Create(ACfg);
  FShortieQuestions := TFibbageXLQuestions_Shortie.Create;
  FFinalQuestions := TFibbageXLQuestions_Final.Create;
end;

destructor TFibbageXLContent.Destroy;
begin
  FShortieQuestions.Free;
  FFinalQuestions.Free;
  inherited;
end;

function TFibbageXLContent.DoInitialize: Boolean;
begin
  if not FConfiguration.NewContent then
  begin
    FShortieQuestions.Initialize(FFilesReader);
    FFinalQuestions.Initialize(FFilesReader);
  end;
  Result := True;
end;

procedure TFibbageXLContent.ForEachQuestion;
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

function TFibbageXLContent.DoGetEditableTypes: TPreviewTypes;
begin
  Result := TPreviewTypes.Create;
  Result.Add(FShortieQuestions.GetTypePreview);
  Result.Add(FFinalQuestions.GetTypePreview);
end;

function TFibbageXLContent.GetManifestJSON: string;
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

function TFibbageXLContent.GetMoveCopyTypesFor(
  AType: TTypePreview): TArray<TTypePreview>;
begin
  Result := [];
  for var item in FEditableTypes do
  begin
    if item.InternalName = AType.InternalName then
      Continue;
    Result := Result + [item];
  end;
end;

function TFibbageXLContent.HasDuplicatedCategory(AType: TTypePreview;
  AQuestion: TFibbageQuestion): Boolean;
begin
  Result := False;
  if AType.InternalName = FShortieQuestions.GetName then
    Result := FShortieQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbageXLQuestion)
  else if AType.InternalName = FFinalQuestions.GetName then
    Result := FFinalQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbageXLQuestion)
  else
    Assert(False);
end;

function TFibbageXLContent.HasMissingSpecialEntries(AType: TTypePreview; AQuestion: TFibbageQuestion; out AError: string): Boolean;
begin
  Result := (AQuestion as TFibbageXLQuestion).IsMissingSpecialEntry(AError);
end;

function TFibbageXLContent.HasTooFewQuestions(AType: TTypePreview): Boolean;
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

function TFibbageXLContent.HasTooFewSuggestions;
const
  OPTIMAL_SUGGESTIONS_NR = 17;
begin
  Result := (AQuestion as TFibbageXLQuestion).SuggestionsCount < OPTIMAL_SUGGESTIONS_NR;
end;

procedure TFibbageXLContent.MoveQuestion;
begin
  if CopyQuestion(ADstType, AQuestion) then
    RemoveQuestion(ASrcType, AQuestion);
end;

procedure TFibbageXLContent.RemoveQuestion;
begin
  if AType.InternalName = FShortieQuestions.GetName then
    FShortieQuestions.RemoveQuestion(AQuestion as TFibbageXLQuestion)
  else if AType.InternalName = FFinalQuestions.GetName then
    FFinalQuestions.RemoveQuestion(AQuestion as TFibbageXLQuestion)
  else
    Assert(False);
end;

procedure TFibbageXLContent.Save;
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

procedure TFibbageXLContent.SaveManifest(const APath: string);
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
