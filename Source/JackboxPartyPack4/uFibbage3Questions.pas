unit uFibbage3Questions;

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
  TFibbage3Question = class(TFibbageQuestion)
  private
    FFamilyFriendly: Boolean;
    FPersonalQuestion: string;
    FId: UInt32;
    FPortrait: Boolean;
    FCategory: string;
    FBumperAudio: TFibbageAudioEntry;
    FUsCentric: Boolean;
    FKeywordAudio: TFibbageAudioEntry;
    FCorrectAudio: TFibbageAudioEntry;
    FQuestionAudio: TFibbageAudioEntry;
    FSuggestions: TArray<string>;
    FCorrectText: string;
    FBumperType: string;
    FQuestionText: string;
    FSocialMediaDate: string;
    FKeywordResponse: string;
    FSocialMediaName: string;
    FAlternateSpellings: TArray<string>;
    FPic: TFibbagePicEntry;
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
    function IsMissingBlank: Boolean; override;

    property Category: string read FCategory;
  end;

  TFibbage3Questions = class(TFibbageQuestions<TFibbage3Question>)
  strict private type
    TCategory = class
    private
      FX: Boolean;
      FPersonal: string;
      FId: UInt32;
      FPortrait: Boolean;
      FCategory: string;
      FBumper: string;
      FUs: Boolean;
    end;
    TCategories = class
    private
      FEpisodeId: UInt32;
      FContent: TArray<TCategory>;
    public
      destructor Destroy; override;
    end;
    TQuestion = class
      FT: string;
      FV: string;
      FN: string;
      FS: string;
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

    function GetNextRandomId: UInt32;

    procedure SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
    procedure ClearAudioEntryIfNotExistingFile(AEntry: TFibbageAudioEntry);
    procedure DoParseItem(AItem: TQuestionData);
  protected
    procedure DoInitialize; override;
    procedure DoSaveCategory; override;
    procedure DoSaveQuestions; override;
  public
    function GetCategoriesJSON: string;

    function CreateNewQuestion: TFibbage3Question; override;
    procedure RemoveQuestion(AQuestion: TFibbage3Question); override;

    function HasQuestionWithTheSameCategory(AQuestion: TFibbage3Question): Boolean;
    function GetFirstQuestionWithDuplicatedCategory: TFibbage3Question; override;
    function GetFirstQuestionWithTooFewSuggestions: TFibbage3Question; override;
    function GetFirstQuestionWithMissingBlank: TFibbage3Question; override;
  end;

  TFibbage3Questions_Shortie = class(TFibbage3Questions)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
  end;

  TFibbage3Questions_Final = class(TFibbage3Questions)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
  end;

  TFibbage3Questions_Special = class(TFibbage3Questions)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
  end;

  TFibbage3Questions_TmiShortie = class(TFibbage3Questions)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
  end;

implementation

{ TFibbage3Questions }

procedure TFibbage3Questions.ClearAudioEntryIfNotExistingFile(
  AEntry: TFibbageAudioEntry);
begin
  if AEntry.Name = '' then
    Exit;

  var wantedPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.ogg');
  if not FReader.FileExists(wantedPath) then
    AEntry.Name := '';
end;

function TFibbage3Questions.CreateNewQuestion: TFibbage3Question;
begin
  Result := TFibbage3Question.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

procedure TFibbage3Questions.DoInitialize;
begin
  var item := FReader.Read(GetName);
  try
    DoParseItem(item);
  finally
    item.Free;
  end;
end;

procedure TFibbage3Questions.DoParseItem(AItem: TQuestionData);
begin
  var rawCategory := TJson.JsonToObject<TCategories>(AItem.CategoryData);
  try
    FEpisodeId := rawCategory.FEpisodeId;
    for var idx := 0 to Length(rawCategory.FContent) - 1 do
    begin
      if not AItem.QuestionData.ContainsKey(rawCategory.FContent[idx].FId.ToString) then
        Continue;

      var newItem: TFibbage3Question := nil;
      var rawQuestion := TJson.JsonToObject<TQuestions>(AItem.QuestionData[rawCategory.FContent[idx].FId.ToString]);
      try
        newItem := TFibbage3Question.Create;
        newItem.FId := rawCategory.FContent[idx].FId;
        newItem.FCategory := rawCategory.FContent[idx].FCategory;
        newItem.FFamilyFriendly := not rawCategory.FContent[idx].FX;
        newItem.FPersonalQuestion := rawCategory.FContent[idx].FPersonal;

        newItem.FPortrait := rawCategory.FContent[idx].FPortrait;
        newItem.FUsCentric := rawCategory.FContent[idx].FUs;

        newItem.FKeywordAudio.Name := rawQuestion.GetValue('KeywordResponseAudio');
        newItem.FKeywordAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FKeywordAudio);

        newItem.FBumperAudio.Name := rawQuestion.GetValue('BumperAudio');
        newItem.FBumperAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FBumperAudio);

        newItem.FCorrectAudio.Name := rawQuestion.GetValue('CorrectAudio');
        newItem.FCorrectAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FCorrectAudio);

        newItem.FQuestionAudio.Name := rawQuestion.GetValue('QuestionAudio');
        newItem.FQuestionAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
        ClearAudioEntryIfNotExistingFile(newItem.FQuestionAudio);

        newItem.FBumperType := rawQuestion.GetValue('BumperType');
        newItem.FSuggestions := rawQuestion.GetValue('Suggestions').Split([',']);
        newItem.FCorrectText := rawQuestion.GetValue('CorrectText');
        newItem.FQuestionText := rawQuestion.GetValue('QuestionText');
        newItem.FAlternateSpellings := rawQuestion.GetValue('AlternateSpellings').Split([',']);
        newItem.FSocialMediaDate := rawQuestion.GetValue('SocialMediaDate');
        //10:00 AM <br /> 3 Jul 2013 ALBO July 14, 2013
        newItem.FKeywordResponse := rawQuestion.GetValue('KeywordResponse');
        newItem.FSocialMediaName := rawQuestion.GetValue('SocialMediaName');
        //@50cent
        newItem.FPic.Name := rawQuestion.GetValue('Pic');
        newItem.FPic.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));

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

procedure TFibbage3Questions.DoSaveCategory;
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

procedure TFibbage3Questions.DoSaveQuestions;
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

    if not item.FKeywordAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FKeywordAudio);
  end;
end;

function TFibbage3Questions.GetCategoriesJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    var contentArr := builder.BeginObject
      .Add('episodeid', FEpisodeId)
      .BeginArray('content');

    for var question in FList do
    begin
      contentArr.BeginObject
        .Add('x', not question.FFamilyFriendly)
        .Add('personal', question.FPersonalQuestion)
        .Add('id', question.FId)
        .Add('portrait', question.FPortrait)
        .Add('category', question.FCategory)
        .Add('bumper', IfThen(question.FBumperType.IsEmpty or SameText(question.FBumperType, 'none'), '', question.FBumperType))
        .Add('us', question.FUsCentric)
      .EndObject;
    end;

    contentArr.EndArray.EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage3Questions.GetFirstQuestionWithDuplicatedCategory: TFibbage3Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 2 do
    for var jdx := idx + 1 to FList.Count - 1 do
      if FList[idx].FCategory = FList[jdx].FCategory then
        Exit(FList[idx]);
end;

function TFibbage3Questions.GetFirstQuestionWithMissingBlank: TFibbage3Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if FList[idx].IsMissingBlank then
      Exit(FList[idx]);
end;

function TFibbage3Questions.GetFirstQuestionWithTooFewSuggestions: TFibbage3Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if FList[idx].SuggestionsCount < OPTIMAL_SUGGESTIONS_COUNT then
      Exit(FList[idx]);
end;

function TFibbage3Questions.GetNextRandomId: UInt32;
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

function TFibbage3Questions.HasQuestionWithTheSameCategory(
  AQuestion: TFibbage3Question): Boolean;
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

procedure TFibbage3Questions.RemoveQuestion(AQuestion: TFibbage3Question);
begin
  FList.Remove(AQuestion);
end;

procedure TFibbage3Questions.SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
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

{ TFibbage3Questions.TCategories }

destructor TFibbage3Questions.TCategories.Destroy;
begin
  for var idx := Length(FContent) - 1 downto 0 do
    FContent[idx].Free;
  SetLength(FContent, 0);
  inherited;
end;

{ TFibbage3Questions.TQuestions }

destructor TFibbage3Questions.TQuestions.Destroy;
begin
  for var idx := Length(FFields) - 1 downto 0 do
    FFields[idx].Free;
  SetLength(FFields, 0);
  inherited;
end;

function TFibbage3Questions.TQuestions.GetValue(const AName: string): string;
begin
  Result := '';
  for var idx := 0 to Length(FFields) - 1 do
    if FFields[idx].FN = AName then
      Exit(FFields[idx].FV);
end;

{ TFibbage3Question }

procedure TFibbage3Question.AssignTo(Dest: TPersistent);
begin
  if not (Dest is TFibbage3Question) then
  begin
    Assert(False);
    Exit;
  end;

  var destQuestion := Dest as TFibbage3Question;

  {destQuestion.FId := FId;}

  destQuestion.FFamilyFriendly := FFamilyFriendly;
  destQuestion.FPersonalQuestion := FPersonalQuestion;
  destQuestion.FPortrait := FPortrait;
  destQuestion.FCategory := FCategory;
  destQuestion.FBumperAudio := FBumperAudio;
  destQuestion.FUsCentric := FUsCentric;
  destQuestion.FKeywordAudio := FKeywordAudio;
  destQuestion.FCorrectAudio := FCorrectAudio;
  destQuestion.FQuestionAudio := FQuestionAudio;
  destQuestion.FSuggestions := FSuggestions;
  destQuestion.FCorrectText := FCorrectText;
  destQuestion.FBumperType := FBumperType;
  destQuestion.FQuestionText := FQuestionText;
  destQuestion.FSocialMediaDate := FSocialMediaDate;
  destQuestion.FKeywordResponse := FKeywordResponse;
  destQuestion.FSocialMediaName := FSocialMediaName;
  destQuestion.FAlternateSpellings := FAlternateSpellings;
  destQuestion.FPic := FPic;
end;

constructor TFibbage3Question.Create;
begin
  inherited Create;
end;

destructor TFibbage3Question.Destroy;
begin
  inherited;
end;

function TFibbage3Question.GetEditableFields: TEditableFields;
begin
  Result := TEditableFields.Create;

  var strItem := TEditableStringField.Create;
  strItem.Name := 'Category';
  strItem.Value := FCategory;
  Result.Add(strItem);

  var strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Question';
  strLongItem.Value := FQuestionText;
  Result.Add(strLongItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Answer';
  strItem.Value := FCorrectText;
  Result.Add(strItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Personal question';
  strItem.Value := FCorrectText;
  Result.Add(strItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Keyword response';
  strItem.Value := FKeywordResponse;
  Result.Add(strItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Alternate Spellings';
  strLongItem.Value := string.Join(', ', FAlternateSpellings);
  Result.Add(strLongItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Suggestions';
  strLongItem.Value := string.Join(', ', FSuggestions);
  Result.Add(strLongItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Social media date';
  strLongItem.Value := FSocialMediaDate;
  Result.Add(strLongItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Social media name';
  strLongItem.Value := FSocialMediaName;
  Result.Add(strLongItem);

  var boolItem := TEditableBoolField.Create;
  boolItem.Name := 'Family Friendly';
  boolItem.Value := FFamilyFriendly;
  Result.Add(boolItem);

  boolItem := TEditableBoolField.Create;
  boolItem.Name := 'Portrait';
  boolItem.Value := FPortrait;
  Result.Add(boolItem);

  boolItem := TEditableBoolField.Create;
  boolItem.Name := 'US Centric';
  boolItem.Value := FUsCentric;
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

  audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Bumper Audio';
  audioItem.Value := FBumperAudio.Name;
  audioItem.BasePath := FBumperAudio.BasePath;
  Result.Add(audioItem);

  audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Keyword Audio';
  audioItem.Value := FKeywordAudio.Name;
  audioItem.BasePath := FKeywordAudio.BasePath;
  Result.Add(audioItem);

  var pic := TEditablePicField.Create; //512x512px
  pic.Name := 'Picture';
  pic.Value := FPic.Name;
  pic.BasePath := FPic.BasePath;
  Result.Add(pic);
end;

function TFibbage3Question.GetJSON: string;
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
        .Add('v', BoolToStr(not FKeywordAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasKeywordAudio')
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
        .Add('v', FPersonalQuestion)
        .Add('n', 'PersonalQuestionText')
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
        .Add('v', FSocialMediaDate)
        .Add('n', 'SocialMediaDate')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', FKeywordResponse)
        .Add('n', 'KeywordResponse')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', FSocialMediaName)
        .Add('n', 'SocialMediaName')
      .EndObject
      .BeginObject
        .Add('t', 'S')
        .Add('v', string.Join(',', FAlternateSpellings))
        .Add('n', 'AlternateSpellings')
      .EndObject;

      var keywordAudio := fields.BeginObject;
        keywordAudio
          .Add('s', '[category=host]')
          .Add('t', 'A');
        if not FKeywordAudio.Name.IsEmpty then
          keywordAudio.Add('v', FKeywordAudio.Name);
        keywordAudio.Add('n', 'KeywordResponseAudio')
      .EndObject;

      var bumperAudio := fields.BeginObject;
        bumperAudio
          .Add('s', '[category=host]')
          .Add('t', 'A');
        if not FBumperAudio.Name.IsEmpty then
          bumperAudio.Add('v', FBumperAudio.Name);
        bumperAudio.Add('n', 'BumperAudio')
      .EndObject;

      var pic := fields.BeginObject;
        pic.Add('t', 'G');
        if not FPic.Name.IsEmpty then
          pic.Add('v', FCorrectAudio.Name);
        pic.Add('n', 'Pic')
      .EndObject;

      var correctAudio := fields.BeginObject;
        correctAudio
          .Add('s', '[category=host]')
          .Add('t', 'A');
        if not FCorrectAudio.Name.IsEmpty then
          correctAudio.Add('v', FCorrectAudio.Name);
        correctAudio.Add('n', 'CorrectAudio')
      .EndObject;

      var questionAudio := fields.BeginObject;
        questionAudio
          .Add('s', '[category=host]')
          .Add('t', 'A');
        if not FQuestionAudio.Name.IsEmpty then
          questionAudio.Add('v', FQuestionAudio.Name);
        questionAudio.Add('n', 'QuestionAudio')
      .EndObject
    .EndArray
    .EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage3Question.GetPreview: TQuestionPreview;
begin
  Result := Default(TQuestionPreview);
  Result.Header := Format('Id: %d, Category: %s', [FId, FCategory]);
  Result.Question := FQuestionText;
end;

function TFibbage3Question.IsMissingBlank: Boolean;
const
  BLANK = '<BLANK>';
begin
  Result := not FQuestionText.Contains(BLANK);
end;

procedure TFibbage3Question.SetEditableFields(AFields: TEditableFields);
begin
//  FCategory := (AFields[0] as TEditableStringField).Value;
//  FQuestionText := (AFields[1] as TEditableLongStringField).Value;
//  FCorrectText := (AFields[2] as TEditableStringField).Value;
//  FAlternateSpellings := (AFields[3] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
//  FSuggestions := (AFields[4] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
//  FFamilyFriendly := (AFields[5] as TEditableBoolField).Value;
//  FQuestionAudio.Name := (AFields[6] as TEditableAudioField).Value;
//  FQuestionAudio.BasePath := (AFields[6] as TEditableAudioField).BasePath;
//  FCorrectAudio.Name := (AFields[7] as TEditableAudioField).Value;
//  FCorrectAudio.BasePath := (AFields[7] as TEditableAudioField).BasePath;
end;

function TFibbage3Question.SuggestionsCount: Int32;
begin
  Result := Length(FSuggestions);
end;

{ TFibbage3Questions_Shortie }

function TFibbage3Questions_Shortie.GetName: string;
begin
  Result := 'fibbageshortie';
end;

function TFibbage3Questions_Shortie.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Round 1 + Round 2';
end;

{ TFibbage3Questions_Final }

function TFibbage3Questions_Final.GetName: string;
begin
  Result := 'finalfibbage';
end;

function TFibbage3Questions_Final.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Round 3';
end;

{ TFibbage3Questions_Special }

function TFibbage3Questions_Special.GetName: string;
begin
  Result := 'fibbagespecial';
end;

function TFibbage3Questions_Special.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Special (random during R1/R2)';
end;

{ TFibbage3Questions_TmiShortie }

function TFibbage3Questions_TmiShortie.GetName: string;
begin
  Result := 'tmishortie';
end;

function TFibbage3Questions_TmiShortie.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Personal';
end;

end.

