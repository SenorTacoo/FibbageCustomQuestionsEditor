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
  uFibbage4Skeleton,
  uFibbageJSONWriter,
  uFibbageContent;

type
  TFibbage4Content = class(TFibbageContent)
  private
    FShortieQuestions: TFibbage4Questions_Blankie;
    FFinalQuestions: TFibbage4Questions_Final;
    FPersonalQuestions: TFibbage4Questions_Personal;
    FSkeleton: TFibbage4Skeleton;
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
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions, FPersonalQuestions] do
    if AType.InternalName = list.GetName then
      Exit(list.CreateNewQuestion);
  Assert(False);
end;

procedure TFibbage4Content.Activate(const APath: string);
begin
  var destPath := TPath.Combine(APath, 'content', 'en');
  var savePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  try
    try
      ForceDirectories(savePath);
      if SameText(FConfiguration.GetPath, destPath) then
        FConfiguration.Save(savePath);
      FShortieQuestions.Save(savePath);
      FFinalQuestions.Save(savePath);
      FPersonalQuestions.Save(savePath);
      FSkeleton.Save(savePath);
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
  if FFilesReader.DirectoryExists(TPath.Combine(FFilesReader.BasePath, 'en')) then
    FFilesReader.BasePath := TPath.Combine(FFilesReader.BasePath, 'en');
  FSkeleton := TFibbage4Skeleton.Create;
end;

destructor TFibbage4Content.Destroy;
begin
  FShortieQuestions.Free;
  FFinalQuestions.Free;
  FPersonalQuestions.Free;
  FSkeleton.Free;
  inherited;
end;

function TFibbage4Content.DoInitialize: Boolean;
begin
  if not FConfiguration.NewContent then
  begin
    FShortieQuestions.Initialize(FFilesReader);
    FFinalQuestions.Initialize(FFilesReader);
    FPersonalQuestions.Initialize(FFilesReader);
  end;
  Result := True;
end;

procedure TFibbage4Content.ForEachQuestion;
begin
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions, FPersonalQuestions] do
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
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions, FPersonalQuestions] do
    Result.Add(list.GetTypePreview);
end;

function TFibbage4Content.GetMoveCopyTypesFor;
begin
  Result := [];
end;

function TFibbage4Content.HasDuplicatedCategory(AType: TTypePreview;
  AQuestion: TFibbageQuestion): Boolean;
begin
  Result := False;
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions, FPersonalQuestions] do
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
begin
  Result := False;
  if AType.InternalName = FShortieQuestions.GetName then
    Result := FShortieQuestions.Count < MIN_SHORTIE_QUESTIONS_COUNT
  else if AType.InternalName = FFinalQuestions.GetName then
    Result := FFinalQuestions.Count < MIN_FINAL_QUESTIONS_COUNT
  else if AType.InternalName = FPersonalQuestions.GetName then
    Result := FPersonalQuestions.Count < MIN_PERSONAL_QUESTIONS_COUNT
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
  for var list: TFibbage4Questions in [FShortieQuestions, FFinalQuestions, FPersonalQuestions] do
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
      FSkeleton.Save(savePath);
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

end.

