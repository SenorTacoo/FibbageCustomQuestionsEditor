unit uFibbage2Questions;

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
  TFibbage2Question = class(TFibbageQuestion)
  private
    FId: UInt32;
    FCategory: string;
    FFamilyFriendly: Boolean;
    FBumperAudio: TFibbageAudioEntry;
    FBumperType: string;
    FCorrectAudio: TFibbageAudioEntry;
    FQuestionAudio: TFibbageAudioEntry;
    FSuggestions: TArray<string>;
    FCorrectText: string;
    FQuestionText: string;
    FAlternateSpellings: TArray<string>;
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

  TFibbage2Questions = class(TFibbageQuestions<TFibbage2Question>)
  strict private type
    TCategory = class
    private
      FX: Boolean;
      FId: UInt32;
    end;
    TCategories = class
    private
      FContent: TArray<TCategory>;
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
    function GetNextRandomId: UInt32;

    procedure SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
    procedure DoParseItem(AItem: TQuestionData);
  protected
    procedure DoInitialize; override;
    procedure DoSaveCategory; override;
    procedure DoSaveQuestions; override;
  public
    function GetCategoriesJSON: string;

    function CreateNewQuestion: TFibbage2Question; override;
    procedure RemoveQuestion(AQuestion: TFibbage2Question); override;

    function HasQuestionWithTheSameCategory(AQuestion: TFibbage2Question): Boolean;
    function GetFirstQuestionWithDuplicatedCategory: TFibbage2Question; override;
    function GetFirstQuestionWithTooFewSuggestions: TFibbage2Question; override;
    function GetFirstQuestionWithMissingSpecialEntry: TFibbage2Question; override;
  end;

  TFibbage2Questions_Shortie = class(TFibbage2Questions)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
  end;

  TFibbage2Questions_Final = class(TFibbage2Questions)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
  end;

implementation

{ TFibbage2Questions }

function TFibbage2Questions.CreateNewQuestion: TFibbage2Question;
begin
  Result := TFibbage2Question.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

procedure TFibbage2Questions.DoInitialize;
begin
  var item := FReader.Read(GetName);
  try
    DoParseItem(item);
  finally
    item.Free;
  end;
end;

procedure TFibbage2Questions.DoParseItem(AItem: TQuestionData);
begin
  var rawCategory := TJson.JsonToObject<TCategories>(AItem.CategoryData);
  try
    for var idx := 0 to Length(rawCategory.FContent) - 1 do
    begin
      if not AItem.QuestionData.ContainsKey(rawCategory.FContent[idx].FId.ToString) then
        Continue;

      var newItem: TFibbage2Question := nil;
      var rawQuestion := TJson.JsonToObject<TQuestions>(AItem.QuestionData[rawCategory.FContent[idx].FId.ToString]);
      try
        newItem := TFibbage2Question.Create;
        newItem.FId := rawCategory.FContent[idx].FId;
        newItem.FCategory := rawQuestion.GetValue('Category');
        newItem.FFamilyFriendly := not rawCategory.FContent[idx].FX;

        newItem.FBumperAudio.Name := rawQuestion.GetValue('BumperAudio');
        newItem.FBumperAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(@newItem.FBumperAudio);

        newItem.FBumperType := rawQuestion.GetValue('BumperType');

        newItem.FCorrectAudio.Name := rawQuestion.GetValue('CorrectAudio');
        newItem.FCorrectAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(@newItem.FCorrectAudio);

        newItem.FQuestionAudio.Name := rawQuestion.GetValue('QuestionAudio');
        newItem.FQuestionAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(@newItem.FQuestionAudio);

        newItem.FSuggestions := rawQuestion.GetValue('Suggestions').Split([',']);
        newItem.FCorrectText := rawQuestion.GetValue('CorrectText');
        newItem.FQuestionText := rawQuestion.GetValue('QuestionText');
        newItem.FAlternateSpellings := rawQuestion.GetValue('AlternateSpellings').Split([',']);

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

procedure TFibbage2Questions.DoSaveCategory;
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
end;

procedure TFibbage2Questions.DoSaveQuestions;
begin
  for var item in FList do
  begin
    var basePath := TPath.Combine(FSavePath, GetName, UIntToStr(item.FId));
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

    if not item.FBumperAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FBumperAudio);

    if not item.FCorrectAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FCorrectAudio);

    if not item.FQuestionAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FQuestionAudio);
  end;
end;

function TFibbage2Questions.GetCategoriesJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    var contentArr := builder.BeginObject
      .BeginArray('content');

    for var question in FList do
    begin
      contentArr.BeginObject
        .Add('x', not question.FFamilyFriendly)
        .Add('id', question.FId)
        .Add('category', question.FCategory)
        .Add('bumper', question.FBumperAudio.Name)
      .EndObject;
    end;

    contentArr.EndArray.EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage2Questions.GetFirstQuestionWithDuplicatedCategory: TFibbage2Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 2 do
    for var jdx := idx + 1 to FList.Count - 1 do
      if FList[idx].FCategory = FList[jdx].FCategory then
        Exit(FList[idx]);
end;

function TFibbage2Questions.GetFirstQuestionWithMissingSpecialEntry: TFibbage2Question;
var
  dummy: string;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if FList[idx].IsMissingSpecialEntry(dummy) then
      Exit(FList[idx]);
end;

function TFibbage2Questions.GetFirstQuestionWithTooFewSuggestions: TFibbage2Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if FList[idx].SuggestionsCount < OPTIMAL_SUGGESTIONS_COUNT then
      Exit(FList[idx]);
end;

function TFibbage2Questions.GetNextRandomId: UInt32;
var
  found: Boolean;
begin
  repeat
    found := False;
    Result := RandomRange(30000, 50000);
    for var item in FList do
      if item.FId = Result then
      begin
        found := True;
        Break;
      end;
  until not found;
end;

function TFibbage2Questions.HasQuestionWithTheSameCategory(
  AQuestion: TFibbage2Question): Boolean;
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

procedure TFibbage2Questions.RemoveQuestion(AQuestion: TFibbage2Question);
begin
  FList.Remove(AQuestion);
end;

procedure TFibbage2Questions.SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
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

{ TFibbage2Questions.TCategories }

destructor TFibbage2Questions.TCategories.Destroy;
begin
  for var idx := Length(FContent) - 1 downto 0 do
    FContent[idx].Free;
  SetLength(FContent, 0);
  inherited;
end;

{ TFibbage2Questions.TQuestions }

destructor TFibbage2Questions.TQuestions.Destroy;
begin
  for var idx := Length(FFields) - 1 downto 0 do
    FFields[idx].Free;
  SetLength(FFields, 0);
  inherited;
end;

function TFibbage2Questions.TQuestions.GetValue(const AName: string): string;
begin
  Result := '';
  for var idx := 0 to Length(FFields) - 1 do
    if FFields[idx].FN = AName then
      Exit(FFields[idx].FV);
end;

{ TFibbage2Question }

procedure TFibbage2Question.AssignTo(Dest: TPersistent);
begin
  if not (Dest is TFibbage2Question) then
  begin
    Assert(False);
    Exit;
  end;

  var destQuestion := Dest as TFibbage2Question;

  {destQuestion.FId := FId;}
  destQuestion.FCategory := FCategory;
  destQuestion.FFamilyFriendly := FFamilyFriendly;
  destQuestion.FBumperAudio := FBumperAudio;
  destQuestion.FBumperType := FBumperType;
  destQuestion.FCorrectAudio.BasePath := FCorrectAudio.BasePath;
  destQuestion.FCorrectAudio.Name := FCorrectAudio.Name;
  destQuestion.FQuestionAudio.BasePath := FQuestionAudio.BasePath;
  destQuestion.FQuestionAudio.Name := FQuestionAudio.Name;
  destQuestion.FSuggestions := FSuggestions;
  destQuestion.FCorrectText := FCorrectText;
  destQuestion.FQuestionText := FQuestionText;
  destQuestion.FAlternateSpellings := FAlternateSpellings;
end;

constructor TFibbage2Question.Create;
begin
  inherited Create;
end;

destructor TFibbage2Question.Destroy;
begin
  inherited;
end;

function TFibbage2Question.GetEditableFields: TEditableFields;
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

  var boolItem := TEditableBoolField.Create;
  boolItem.Name := 'Family Friendly';
  boolItem.Value := FFamilyFriendly;
  Result.Add(boolItem);

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

function TFibbage2Question.GetJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    var fields := builder.BeginObject.BeginArray('fields');

    fields
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FBumperAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasBumperAudio')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr((not FBumperType.IsEmpty) and (FBumperType <> 'None'), True).ToLowerInvariant)
        .Add('n', 'HasBumperType')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FCorrectAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasCorrectAudio')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FQuestionAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasQuestionAudio')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', string.Join(',', FSuggestions))
        .Add('n', 'Suggestions')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', FCategory)
        .Add('n', 'Category')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', FCorrectText)
        .Add('n', 'CorrectText')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', IfThen(FBumperType.IsEmpty, 'None', FBumperType))
        .Add('n', 'BumperType')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', FQuestionText)
        .Add('n', 'QuestionText')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', string.Join(',', FAlternateSpellings))
        .Add('n', 'AlternateSpellings')
      .EndObject;

      var bumperAudio := fields.BeginObject;
        bumperAudio.Add('t', 'A');
        if not FBumperAudio.Name.IsEmpty then
          bumperAudio.Add('v', FBumperAudio.Name);
        bumperAudio.Add('n', 'BumperAudio')

      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', FCorrectAudio.Name)
        .Add('n', 'CorrectAudio')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', FQuestionAudio.Name)
        .Add('n', 'QuestionAudio')
      .EndObject
    .EndArray
    .EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage2Question.GetPreview: TQuestionPreview;
begin
  Result := Default(TQuestionPreview);
  Result.Header := Format('Id: %d, Category: %s', [FId, FCategory]);
  Result.Question := FQuestionText;
end;

function TFibbage2Question.IsMissingSpecialEntry(out AError: string): Boolean;
const
  BLANK = '<BLANK>';
begin
  Result := False;
  if not FQuestionText.Contains(BLANK) then
  begin
    Result := True;
    AError := 'Question is missing <BLANK>';
  end;
end;

procedure TFibbage2Question.SetEditableFields(AFields: TEditableFields);
begin
  FCategory := (AFields[0] as TEditableStringField).Value;
  FQuestionText := (AFields[1] as TEditableLongStringField).Value;
  FCorrectText := (AFields[2] as TEditableStringField).Value;
  FAlternateSpellings := (AFields[3] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FSuggestions := (AFields[4] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FFamilyFriendly := (AFields[5] as TEditableBoolField).Value;
  FQuestionAudio.Name := (AFields[6] as TEditableAudioField).Value;
  FQuestionAudio.BasePath := (AFields[6] as TEditableAudioField).BasePath;
  FCorrectAudio.Name := (AFields[7] as TEditableAudioField).Value;
  FCorrectAudio.BasePath := (AFields[7] as TEditableAudioField).BasePath;
end;

function TFibbage2Question.SuggestionsCount: Int32;
begin
  Result := Length(FSuggestions);
end;

{ TFibbage2Questions_Shortie }

function TFibbage2Questions_Shortie.GetName: string;
begin
  Result := 'fibbageshortie';
end;

function TFibbage2Questions_Shortie.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Round 1 + Round 2';
end;

{ TFibbage2Questions_Final }

function TFibbage2Questions_Final.GetName: string;
begin
  Result := 'finalfibbage';
end;

function TFibbage2Questions_Final.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Round 3';
end;

end.
