unit uFibbageXLQuestions;

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
  TFibbageXLQuestion = class(TFibbageQuestion)
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

    property Category: string read FCategory;
  end;

  TFibbageXLQuestions = class(TFibbageQuestions<TFibbageXLQuestion>)
  strict private type
    TXLCategory = class
    private
      FX: Boolean;
      FId: UInt32;
    end;
    TXLCategories = class
    private
      FContent: TArray<TXLCategory>;
    public
      destructor Destroy; override;
    end;
    TXLQuestion = class
      FT: string;
      FV: string;
      FN: string;
    end;
    TXLQuestions = class
      FFields: TArray<TXLQuestion>;
    public
      destructor Destroy; override;
      function GetValue(const AName: string): string;
    end;
  strict private const
    OPTIMAL_SUGGESTIONS_COUNT = 17;
  private
    function GetNextRandomId: UInt32;

    procedure SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
    procedure ClearAudioEntryIfNotExistingFile(AEntry: TFibbageAudioEntry);
  protected
    procedure DoParseItem(AItem: TQuestionData); override;
    procedure DoSaveCategory; override;
    procedure DoSaveQuestions; override;
  public
    function GetCategoriesJSON: string;

    function CreateNewQuestion: TFibbageXLQuestion; override;
    procedure RemoveQuestion(AQuestion: TFibbageXLQuestion); override;

    function HasQuestionWithTheSameCategory(AQuestion: TFibbageXLQuestion): Boolean;
    function GetFirstQuestionWithDuplicatedCategory: TFibbageXLQuestion; override;
    function GetFirstQuestionWithTooFewSuggestions: TFibbageXLQuestion; override;
    function GetFirstQuestionWithMissingBlank: TFibbageXLQuestion; override;
  end;

  TFibbageXLQuestions_Shortie = class(TFibbageXLQuestions)
  public
    function GetName: string; override;
  end;

  TFibbageXLQuestions_Final = class(TFibbageXLQuestions)
  public
    function GetName: string; override;
  end;

implementation

{ TFibbageXLQuestions }

procedure TFibbageXLQuestions.ClearAudioEntryIfNotExistingFile(
  AEntry: TFibbageAudioEntry);
begin
  if AEntry.Name = '' then
    Exit;

  var wantedPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.ogg');
  if not TFile.Exists(wantedPath) then
    AEntry.Name := '';
end;

function TFibbageXLQuestions.CreateNewQuestion: TFibbageXLQuestion;
begin
  Result := TFibbageXLQuestion.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

procedure TFibbageXLQuestions.DoParseItem(AItem: TQuestionData);
begin
  var rawCategory := TJson.JsonToObject<TXLCategories>(AItem.CategoryData);
  try
    for var idx := 0 to Length(rawCategory.FContent) - 1 do
    begin
      if not AItem.QuestionData.ContainsKey(rawCategory.FContent[idx].FId.ToString) then
        Continue;

      var newItem: TFibbageXLQuestion := nil;
      var rawQuestion := TJson.JsonToObject<TXLQuestions>(AItem.QuestionData[rawCategory.FContent[idx].FId.ToString]);
      try
        newItem := TFibbageXLQuestion.Create;
        newItem.FId := rawCategory.FContent[idx].FId;
        newItem.FCategory := rawQuestion.GetValue('Category');
        newItem.FFamilyFriendly := not rawCategory.FContent[idx].FX;

        newItem.FBumperAudio.Name := rawQuestion.GetValue('BumperAudio');
        newItem.FBumperAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FBumperAudio);

        newItem.FBumperType := rawQuestion.GetValue('BumperType');

        newItem.FCorrectAudio.Name := rawQuestion.GetValue('CorrectAudio');
        newItem.FCorrectAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FCorrectAudio);

        newItem.FQuestionAudio.Name := rawQuestion.GetValue('QuestionAudio');
        newItem.FQuestionAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FQuestionAudio);

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

procedure TFibbageXLQuestions.DoSaveCategory;
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

procedure TFibbageXLQuestions.DoSaveQuestions;
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

function TFibbageXLQuestions.GetCategoriesJSON: string;
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

function TFibbageXLQuestions.GetFirstQuestionWithDuplicatedCategory: TFibbageXLQuestion;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 2 do
    for var jdx := idx + 1 to FList.Count - 1 do
      if FList[idx].FCategory = FList[jdx].FCategory then
        Exit(FList[idx]);
end;

function TFibbageXLQuestions.GetFirstQuestionWithMissingBlank: TFibbageXLQuestion;
const
  BLANK = '<BLANK>';
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if not FList[idx].FQuestionText.Contains(BLANK) then
      Exit(FList[idx]);
end;

function TFibbageXLQuestions.GetFirstQuestionWithTooFewSuggestions: TFibbageXLQuestion;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if FList[idx].SuggestionsCount < OPTIMAL_SUGGESTIONS_COUNT then
      Exit(FList[idx]);
end;

function TFibbageXLQuestions.GetNextRandomId: UInt32;
begin
  var found := False;
  repeat
    Result := RandomRange(30000, 50000);
    for var item in FList do
      if item.FId = Result then
      begin
        found := True;
        Break;
      end;
  until not found;
end;

function TFibbageXLQuestions.HasQuestionWithTheSameCategory(
  AQuestion: TFibbageXLQuestion): Boolean;
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

procedure TFibbageXLQuestions.RemoveQuestion(AQuestion: TFibbageXLQuestion);
begin
  FList.Remove(AQuestion);
end;

procedure TFibbageXLQuestions.SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
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

{ TFibbageXLQuestions.TXLCategories }

destructor TFibbageXLQuestions.TXLCategories.Destroy;
begin
  for var idx := Length(FContent) - 1 downto 0 do
    FContent[idx].Free;
  SetLength(FContent, 0);
  inherited;
end;

{ TFibbageXLQuestions.TXLQuestions }

destructor TFibbageXLQuestions.TXLQuestions.Destroy;
begin
  for var idx := Length(FFields) - 1 downto 0 do
    FFields[idx].Free;
  SetLength(FFields, 0);
  inherited;
end;

function TFibbageXLQuestions.TXLQuestions.GetValue(const AName: string): string;
begin
  Result := '';
  for var idx := 0 to Length(FFields) - 1 do
    if FFields[idx].FN = AName then
      Exit(FFields[idx].FV);
end;

{ TFibbageXLQuestion }

procedure TFibbageXLQuestion.AssignTo(Dest: TPersistent);
begin
  if not (Dest is TFibbageXLQuestion) then
  begin
    Assert(False);
    Exit;
  end;

  var destQuestion := Dest as TFibbageXLQuestion;

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

constructor TFibbageXLQuestion.Create;
begin
  inherited Create;
  FCorrectAudio := TFibbageAudioEntry.Create;
  FQuestionAudio := TFibbageAudioEntry.Create;
  FBumperAudio := TFibbageAudioEntry.Create;
end;

destructor TFibbageXLQuestion.Destroy;
begin
  FCorrectAudio.Free;
  FQuestionAudio.Free;
  FBumperAudio.Free;
  inherited;
end;

function TFibbageXLQuestion.GetEditableFields: TEditableFields;
begin
  Result := TEditableFields.Create;

  var strItem := TEditableStringField.Create;
  strItem.Name := 'Category';
  strItem.Value := FCategory;
  Result.Add(strItem);

  var strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Question Text';
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

function TFibbageXLQuestion.GetJSON: string;
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

function TFibbageXLQuestion.GetPreview: TQuestionPreview;
begin
  Result := Default(TQuestionPreview);
  Result.Header := Format('Id: %d, Category: %s', [FId, FCategory]);
  Result.Question := FQuestionText;
end;

procedure TFibbageXLQuestion.SetEditableFields(AFields: TEditableFields);
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

function TFibbageXLQuestion.SuggestionsCount: Int32;
begin
  Result := Length(FSuggestions);
end;

{ TFibbageXLQuestions_Shortie }

function TFibbageXLQuestions_Shortie.GetName: string;
begin
  Result := 'fibbageshortie';
end;

{ TFibbageXLQuestions_Final }

function TFibbageXLQuestions_Final.GetName: string;
begin
  Result := 'finalfibbage';
end;

end.
