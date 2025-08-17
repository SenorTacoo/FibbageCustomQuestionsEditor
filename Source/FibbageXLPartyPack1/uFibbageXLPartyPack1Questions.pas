unit uFibbageXLPartyPack1Questions;

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.IOUtils,
  System.Generics.Collections,
  System.Math,
  REST.Json,
  System.JSON.Builders,
  uQuestionsLoader,
  uFibbageJSONWriter,
  uFibbageFilesReader;

type
  TFibbageXLPartyPack1Question = class(TFibbageQuestion)
  private
    FId: UInt32;
    FCategory: string;
    FQuestionAudio: TFibbageAudioEntry;
    FCorrectAudio: TFibbageAudioEntry;
    FSuggestions: TArray<string>;
    FCorrectText: string;
    FStamp: string;
    FAlternateSpellings: TArray<string>;
    FQuestionText: string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetEditableFields(AFields: TEditableFields); override;
    function GetEditableFields: TEditableFields; override;
    function GetPreview: TQuestionPreview; override;
    function GetJSON: string; override;
    function SuggestionsCount: Int32;
    function IsMissingSpecialEntry(out AError: string): Boolean; override;

    property Category: string read FCategory;
  end;

  TOnGetNextQuestionId = function: UInt32 of object;

  TFibbageXLPartyPack1Questions = class(TFibbageQuestions<TFibbageXLPartyPack1Question>)
  strict private type
    TCategory = class
    private
      FId: UInt32;
    end;
    TCategories = class
    private
      FQuestions: TArray<TCategory>;
      FEpisodeId: UInt32;
    public
      destructor Destroy; override;
    end;
    TQuestion = class
      FT: string;
      FV: string;
      FN: string;
    end;
    TQuestions = class
      FFields: TArray<TQuestion>;
    public
      destructor Destroy; override;
      function GetValue(const AName: string): string;
    end;
  strict private const
    OPTIMAL_SUGGESTIONS_COUNT = 17;
  private
    FEpisodeId: UInt32;
    FOnGetNextQuestionId: TOnGetNextQuestionId;

    function GetNextRandomId: UInt32;

    procedure SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
    procedure ClearAudioEntryIfNotExistingFile(AEntry: TFibbageAudioEntry);
    procedure DoParseItem(AItem: TQuestionData);
  protected
    procedure DoSaveCategory; override;
    procedure DoSaveQuestions; override;
    procedure DoInitialize; override;
  public
    function GetCategoriesJSON: string;

    function CreateNewQuestion: TFibbageXLPartyPack1Question; override;
    procedure RemoveQuestion(AQuestion: TFibbageXLPartyPack1Question); override;

    function HasQuestionWithTheSameCategory(AQuestion: TFibbageXLPartyPack1Question): Boolean;
    function GetFirstQuestionWithDuplicatedCategory: TFibbageXLPartyPack1Question; override;
    function GetFirstQuestionWithTooFewSuggestions: TFibbageXLPartyPack1Question; override;
    function GetFirstQuestionWithMissingSpecialEntry: TFibbageXLPartyPack1Question; override;

    function GetFirstQuestionWithId(AId: UInt32): TFibbageXLPartyPack1Question;

    property OnGetNextQuestionId: TOnGetNextQuestionId read FOnGetNextQuestionId write FOnGetNextQuestionId;
  end;

  TFibbageXLPartyPack1Questions_Shortie = class(TFibbageXLPartyPack1Questions)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
  end;

  TFibbageXLPartyPack1Questions_Final = class(TFibbageXLPartyPack1Questions)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
  end;

implementation

{ TFibbageXLPartyPack1Questions }

procedure TFibbageXLPartyPack1Questions.ClearAudioEntryIfNotExistingFile(
  AEntry: TFibbageAudioEntry);
begin
  if AEntry.Name = '' then
    Exit;

  var wantedPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.ogg');
  if not TFile.Exists(wantedPath) then
    AEntry.Name := '';
end;

function TFibbageXLPartyPack1Questions.CreateNewQuestion: TFibbageXLPartyPack1Question;
begin
  Result := TFibbageXLPartyPack1Question.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

procedure TFibbageXLPartyPack1Questions.DoInitialize;
begin
  var item := FReader.ReadWithCustomQuestionsDir(GetName, 'questions');
  try
    DoParseItem(item);
  finally
    item.Free;
  end;
end;

procedure TFibbageXLPartyPack1Questions.DoParseItem(AItem: TQuestionData);
begin
  var rawCategory := TJson.JsonToObject<TCategories>(AItem.CategoryData);
  try
    FEpisodeId := rawCategory.FEpisodeId;
    for var idx := 0 to Length(rawCategory.FQuestions) - 1 do
    begin
      if not AItem.QuestionData.ContainsKey(rawCategory.FQuestions[idx].FId.ToString) then
        Continue;

      var newItem: TFibbageXLPartyPack1Question := nil;
      var rawQuestion := TJson.JsonToObject<TQuestions>(AItem.QuestionData[rawCategory.FQuestions[idx].FId.ToString]);
      try
        newItem := TFibbageXLPartyPack1Question.Create;
        newItem.FId := rawCategory.FQuestions[idx].FId;
        newItem.FCategory := rawQuestion.GetValue('Category');

        newItem.FCorrectAudio.Name := rawQuestion.GetValue('CorrectAudio');
        newItem.FCorrectAudio.BasePath := TPath.Combine(FReader.BasePath, 'questions', UIntToStr(rawCategory.FQuestions[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FCorrectAudio);

        newItem.FQuestionAudio.Name := rawQuestion.GetValue('QuestionAudio');
        newItem.FQuestionAudio.BasePath := TPath.Combine(FReader.BasePath, 'questions', UIntToStr(rawCategory.FQuestions[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FQuestionAudio);

        newItem.FSuggestions := rawQuestion.GetValue('Suggestions').Split([',']);
        newItem.FCorrectText := rawQuestion.GetValue('CorrectText');
        newItem.FQuestionText := rawQuestion.GetValue('QuestionText');
        newItem.FAlternateSpellings := rawQuestion.GetValue('AlternateSpellings').Split([',']);
        newItem.FStamp := rawQuestion.GetValue('Stamp');

        FList.Add(newItem);
        newItem := nil;
      finally
        rawQuestion.Free;
        newItem.Free;
      end;
    end;
  finally
    rawCategory.Free;
  end;
end;

procedure TFibbageXLPartyPack1Questions.DoSaveCategory;
begin
  var filePath := TPath.Combine(FSavePath, Format('%s.jet', [GetName]));
  var fs := TFileStream.Create(filePath, fmCreate);
  var sw := TStreamWriter.Create(fs);
  try
    sw.OwnStream;
    sw.Write(GetCategoriesJSON);
  finally
    sw.Free;
  end;

  filePath := TPath.Combine(FSavePath, Format('demo%s.jet', [GetName]));
  fs := TFileStream.Create(filePath, fmCreate);
  sw := TStreamWriter.Create(fs);
  try
    sw.OwnStream;
    sw.Write(GetCategoriesJSON);
  finally
    sw.Free;
  end;
end;

procedure TFibbageXLPartyPack1Questions.DoSaveQuestions;
begin
  for var item in FList do
  begin
    var basePath := TPath.Combine(FSavePath, 'questions', UIntToStr(item.FId));
    ForceDirectories(basePath);
    var filePath := TPath.Combine(basePath, 'data.jet');
    var fs := TFileStream.Create(filePath, fmCreate);
    var sw := TStreamWriter.Create(fs);
    try
      sw.OwnStream;
      sw.Write(item.GetJSON);
    finally
      sw.Free;
    end;

    if not item.FCorrectAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FCorrectAudio);

    if not item.FQuestionAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FQuestionAudio);
  end;
end;

function TFibbageXLPartyPack1Questions.GetCategoriesJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    var contentArr :=
      builder
        .BeginObject
          .Add('episodeid', IfThen(FEpisodeId = 0, 1210, FEpisodeId))
          .BeginArray('questions');

    for var question in FList do
    begin
      contentArr.BeginObject
        .Add('id', question.FId)
        .Add('category', question.FCategory)
      .EndObject;
    end;

    contentArr.EndArray.EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbageXLPartyPack1Questions.GetFirstQuestionWithDuplicatedCategory: TFibbageXLPartyPack1Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 2 do
    for var jdx := idx + 1 to FList.Count - 1 do
      if FList[idx].FCategory = FList[jdx].FCategory then
        Exit(FList[idx]);
end;

function TFibbageXLPartyPack1Questions.GetFirstQuestionWithId(
  AId: UInt32): TFibbageXLPartyPack1Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if not FList[idx].FId = AId then
      Exit(FList[idx]);
end;

function TFibbageXLPartyPack1Questions.GetFirstQuestionWithMissingSpecialEntry: TFibbageXLPartyPack1Question;
var
  dummy: string;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if FList[idx].IsMissingSpecialEntry(dummy) then
      Exit(FList[idx]);
end;

function TFibbageXLPartyPack1Questions.GetFirstQuestionWithTooFewSuggestions: TFibbageXLPartyPack1Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if FList[idx].SuggestionsCount < OPTIMAL_SUGGESTIONS_COUNT then
      Exit(FList[idx]);
end;

function TFibbageXLPartyPack1Questions.GetNextRandomId: UInt32;
begin
  Result := FOnGetNextQuestionId;
end;

function TFibbageXLPartyPack1Questions.HasQuestionWithTheSameCategory(
  AQuestion: TFibbageXLPartyPack1Question): Boolean;
begin
  Result := False;
  for var item in FList do
  begin
    if AQuestion = item then
      Continue;
    if AQuestion.FCategory = item.FCategory then
      Exit(True);
  end;
end;

procedure TFibbageXLPartyPack1Questions.RemoveQuestion(AQuestion: TFibbageXLPartyPack1Question);
begin
  FList.Remove(AQuestion);
end;

procedure TFibbageXLPartyPack1Questions.SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
begin
  var srcPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.ogg');
  var dstPath := TPath.Combine(ABasePath, AEntry.Name + '.ogg');

  if srcPath = dstPath then
    Exit;

  if srcPath.StartsWith(TPath.GetTempPath) then
    TFile.Move(srcPath, dstPath)
  else
    TFile.Copy(srcPath, dstPath);
end;

{ TFibbageXLPartyPack1Questions.TCategories }

destructor TFibbageXLPartyPack1Questions.TCategories.Destroy;
begin
  for var idx := Length(FQuestions) - 1 downto 0 do
    FQuestions[idx].Free;
  SetLength(FQuestions, 0);
  inherited;
end;

{ TFibbageXLPartyPack1Questions.TQuestions }

destructor TFibbageXLPartyPack1Questions.TQuestions.Destroy;
begin
  for var idx := Length(FFields) - 1 downto 0 do
    FFields[idx].Free;
  SetLength(FFields, 0);
  inherited;
end;

function TFibbageXLPartyPack1Questions.TQuestions.GetValue(const AName: string): string;
begin
  Result := '';
  for var idx := 0 to Length(FFields) - 1 do
    if FFields[idx].FN = AName then
      Exit(FFields[idx].FV);
end;

{ TFibbageXLPartyPack1Question }

procedure TFibbageXLPartyPack1Question.AssignTo(Dest: TPersistent);
begin
  if not (Dest is TFibbageXLPartyPack1Question) then
  begin
    Assert(False);
    Exit;
  end;

  var destQuestion := Dest as TFibbageXLPartyPack1Question;

  {destQuestion.FId := FId;}
  destQuestion.FCategory := FCategory;
  destQuestion.FCorrectAudio.BasePath := FCorrectAudio.BasePath;
  destQuestion.FCorrectAudio.Name := FCorrectAudio.Name;
  destQuestion.FQuestionAudio.BasePath := FQuestionAudio.BasePath;
  destQuestion.FQuestionAudio.Name := FQuestionAudio.Name;
  destQuestion.FSuggestions := FSuggestions;
  destQuestion.FCorrectText := FCorrectText;
  destQuestion.FQuestionText := FQuestionText;
  destQuestion.FAlternateSpellings := FAlternateSpellings;
  destQuestion.FStamp := FStamp;
end;

constructor TFibbageXLPartyPack1Question.Create;
begin
  inherited Create;
end;

destructor TFibbageXLPartyPack1Question.Destroy;
begin
  inherited;
end;

function TFibbageXLPartyPack1Question.GetEditableFields: TEditableFields;
begin
  Result := TEditableFields.Create;

  var strItem := TEditableStringField.Create;
  strItem.Name := 'Category';
  strItem.Value := FCategory;
  Result.Add(strItem);

  var strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Question Text (with <BLANK>)';
  strLongItem.Value := FQuestionText;
  Result.Add(strLongItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Correct Text';
  strItem.Value := FCorrectText;
  Result.Add(strItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Alternate Spellings';
  strLongItem.Value := string.Join(', ', FAlternateSpellings);
  Result.Add(strLongItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Suggestions';
  strLongItem.Value := string.Join(', ', FSuggestions);
  Result.Add(strLongItem);

  var audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Question Audio';
  audioItem.Value := FQuestionAudio.Name;
  audioItem.BasePath := FQuestionAudio.BasePath;
  Result.Add(audioItem);

  audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Correct Audio';
  audioItem.Value := FCorrectAudio.Name;
  audioItem.BasePath := FCorrectAudio.BasePath;
  Result.Add(audioItem);
end;

function TFibbageXLPartyPack1Question.GetJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    var fields := builder.BeginObject.BeginArray('fields');

    fields
      .BeginObject
        .Add('v', BoolToStr(not FQuestionAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('t', 'B')
        .Add('n', 'HasQuestionAudio')
      .EndObject
      .BeginObject
        .Add('v', BoolToStr(not FCorrectAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('t', 'B')
        .Add('n', 'HasCorrectAudio')
      .EndObject
      .BeginObject
        .Add('v', string.Join(',', FSuggestions))
        .Add('t', 'S')
        .Add('n', 'Suggestions')
      .EndObject
      .BeginObject
        .Add('v', FCategory)
        .Add('t', 'S')
        .Add('n', 'Category')
      .EndObject
      .BeginObject
        .Add('v', FCorrectText)
        .Add('t', 'S')
        .Add('n', 'CorrectText')
      .EndObject
      .BeginObject
        .Add('v', FStamp)
        .Add('t', 'S')
        .Add('n', 'Stamp')
      .EndObject
      .BeginObject
        .Add('v', string.Join(',', FAlternateSpellings))
        .Add('t', 'S')
        .Add('n', 'AlternateSpellings')
      .EndObject
      .BeginObject
        .Add('v', FQuestionText)
        .Add('t', 'S')
        .Add('n', 'QuestionText')
      .EndObject
      .BeginObject
        .Add('v', FQuestionAudio.Name)
        .Add('t', 'A')
        .Add('n', 'QuestionAudio')
      .EndObject
      .BeginObject
        .Add('v', FCorrectAudio.Name)
        .Add('t', 'A')
        .Add('n', 'CorrectAudio')
      .EndObject
      .EndArray
    .EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbageXLPartyPack1Question.GetPreview: TQuestionPreview;
begin
  Result := Default(TQuestionPreview);
  Result.Header := Format('Id: %d, Category: %s', [FId, FCategory]);
  Result.Question := FQuestionText;
end;

function TFibbageXLPartyPack1Question.IsMissingSpecialEntry(out AError: string): Boolean;
const
  BLANK = '<BLANK>';
begin
  Result := False;
  if not FQuestionText.Contains(BLANK) then
  begin
    Result := False;
    AError := 'Question is missing <BLANK>';
  end;
end;

procedure TFibbageXLPartyPack1Question.SetEditableFields(AFields: TEditableFields);
begin
  FCategory := (AFields[0] as TEditableStringField).Value;
  FQuestionText := (AFields[1] as TEditableLongStringField).Value;
  FCorrectText := (AFields[2] as TEditableStringField).Value;
  FAlternateSpellings := (AFields[3] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FSuggestions := (AFields[4] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FQuestionAudio.Name := (AFields[5] as TEditableAudioField).Value;
  FQuestionAudio.BasePath := (AFields[5] as TEditableAudioField).BasePath;
  FCorrectAudio.Name := (AFields[6] as TEditableAudioField).Value;
  FCorrectAudio.BasePath := (AFields[6] as TEditableAudioField).BasePath;
end;

function TFibbageXLPartyPack1Question.SuggestionsCount: Int32;
begin
  Result := Length(FSuggestions);
end;

{ TFibbageXLPartyPack1Questions_Shortie }

function TFibbageXLPartyPack1Questions_Shortie.GetName: string;
begin
  Result := 'shortie';
end;

function TFibbageXLPartyPack1Questions_Shortie.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Round 1 + Round 2';
end;

{ TFibbageXLPartyPack1Questions_Final }

function TFibbageXLPartyPack1Questions_Final.GetName: string;
begin
  Result := 'finalfibbage';
end;

function TFibbageXLPartyPack1Questions_Final.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Round 3';
end;

end.
