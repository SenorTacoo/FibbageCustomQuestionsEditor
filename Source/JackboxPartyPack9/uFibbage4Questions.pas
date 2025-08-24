unit uFibbage4Questions;

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.IOUtils,
  System.Generics.Collections,
  System.Math,
  REST.Json,
  uInterfaces,
  System.JSON.Builders,
  uQuestionsLoader,
  uFibbageJSONWriter,
  uFibbageFilesReader;

type
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

  TFibbage4Question = class(TFibbageQuestion)
  private
    FId: UInt32;
    FIsValid: string;
    FUsCentric: Boolean;
    FFamilyFriendly: Boolean;
    FAlternateSpellings: TArray<string>;
    FBumperType: string;
    FCategory: string;
    FCorrectText: string;
    FExtraCategories: TArray<string>;
    FPersonal: string;
    FPortrait: Boolean;
    FQuestionText: string;
    FSuggestions: TArray<string>;
    FBumperAudio: TFibbageAudioEntry;
    FCorrectAudio: TFibbageAudioEntry;
    FQuestionAudio: TFibbageAudioEntry;
    FPic: TFibbagePicEntry;
    FSetupVideo: TFibbageVideoEntry;
    FFeaturedStill: TFibbagePicEntry;
    FTransitionStill: TFibbagePicEntry;
    FRevealVideo: TFibbageVideoEntry;
    FSetupSubtitles: TFibbageSubtitlesEntry;
    FRevealSubtitles: TFibbageSubtitlesEntry;
    FSetupAudio: TFibbageAudioEntry;
    FRevealAudio: TFibbageAudioEntry;
    FQuestionAudio2: TFibbageAudioEntry;
    FAlternateSpellings2: TArray<string>;
    FCorrectText2: string;
    FQuestionText2: string;
    function GetSuggestionsCount: Int32;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    function GetPreview: TQuestionPreview; override;

    property Category: string read FCategory;
    property SuggestionsCount: Int32 read GetSuggestionsCount;
  end;

  TFibbage4BaseQuestion = class(TFibbage4Question)
  public
    function GetJSON: string; override;
    function IsMissingSpecialEntry(out AError: string): Boolean; override;
  end;

  TFibbage4BlankieQuestion = class(TFibbage4BaseQuestion)
  public
    procedure SetEditableFields(AFields: TEditableFields); override;
    function GetEditableFields: TEditableFields; override;
  end;

  TFibbage4FinalQuestion = class(TFibbage4Question)
  public
    procedure SetEditableFields(AFields: TEditableFields); override;
    function GetEditableFields: TEditableFields; override;
    function GetJSON: string; override;
    function IsMissingSpecialEntry(out AError: string): Boolean; override;
    function GetPreview: TQuestionPreview; override;
  end;

  TFibbage4PersonalQuestion = class(TFibbage4BaseQuestion)
  public
    procedure SetEditableFields(AFields: TEditableFields); override;
    function GetEditableFields: TEditableFields; override;
    function GetPreview: TQuestionPreview; override;
  end;

  TFibbage4CelebrityQuestion = class(TFibbage4BlankieQuestion);

  TFibbage4HeadlineQuestion = class(TFibbage4BlankieQuestion);

  TFibbage4HistoryQuestion = class(TFibbage4BlankieQuestion);

  TFibbage4Questions = class(TFibbageQuestions<TFibbage4Question>)
  strict private const
    OPTIMAL_SUGGESTIONS_COUNT = 17;
  private
    procedure SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
    procedure SavePicFile(const ABasePath: string; AEntry: TFibbagePicEntry);
    procedure SaveVideoFile(const ABasePath: string; AEntry: TFibbageVideoEntry);
    procedure SaveVideoSubtitlesFile(const ABasePath: string; AEntry: TFibbageSubtitlesEntry);
  protected
    function GetNextRandomId: UInt32;
    procedure DoInitialize; override;
    procedure DoSaveCategory; override;
    procedure DoSaveQuestions; override;
    procedure DoParseItem(AItem: TQuestionData); virtual; abstract;
    function GetCategoriesJSON: string; virtual; abstract;
  public
    procedure RemoveQuestion(AQuestion: TFibbage4Question); override;

    function HasQuestionWithTheSameCategory(AQuestion: TFibbage4Question): Boolean;
    function GetFirstQuestionWithDuplicatedCategory: TFibbage4Question; override;
    function GetFirstQuestionWithTooFewSuggestions: TFibbage4Question; override;
    function GetFirstQuestionWithMissingSpecialEntry: TFibbage4Question; override;
  end;

  TFibbage4QuestionsBase = class(TFibbage4Questions)
  strict private type
    TCategory = class
    private
      FAlternateSpellings: TArray<string>;
      FBumper: string;
      FCategory: string;
      FCorrectText: string;
      FExtraCategories: TArray<string>;
      FId: UInt32;
      FIsValid: string;
      FPersonal: string;
      FPortrait: Boolean;
      FQuestionText: string;
      FSuggestions: TArray<string>;
      FUs: Boolean;
      FX: Boolean;
    end;
    TCategories = class
    private
      FContent: TArray<TCategory>;
    public
      destructor Destroy; override;
    end;
  protected
    procedure DoParseItem(AItem: TQuestionData); override;
  public
    function GetCategoriesJSON: string; override;
  end;

  TFibbage4Questions_Blankie = class(TFibbage4QuestionsBase)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
    function CreateNewQuestion: TFibbage4Question; override;
  end;

  TFibbage4Questions_Personal = class(TFibbage4QuestionsBase)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
    function CreateNewQuestion: TFibbage4Question; override;
  end;

  TFibbage4Questions_Celebrity = class(TFibbage4QuestionsBase)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
    function CreateNewQuestion: TFibbage4Question; override;
  end;

  TFibbage4Questions_Headline = class(TFibbage4QuestionsBase)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
    function CreateNewQuestion: TFibbage4Question; override;
  end;

  TFibbage4Questions_History = class(TFibbage4QuestionsBase)
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
    function CreateNewQuestion: TFibbage4Question; override;
  end;

  TFibbage4Questions_Final = class(TFibbage4Questions)
  strict private type
    TCategory = class
    private
      FAlternateSpellings1: TArray<string>;
      FAlternateSpellings2: TArray<string>;
      FCorrectText1: string;
      FCorrectText2: string;
      FId: UInt32;
      FIsValid: string;
      FQuestionText1: string;
      FQuestionText2: string;
      FSuggestions: TArray<string>;
      FUs: Boolean;
      FX: Boolean;
    end;
    TCategories = class
    private
      FContent: TArray<TCategory>;
    public
      destructor Destroy; override;
    end;
  protected
    procedure DoParseItem(AItem: TQuestionData); override;
  public
    function GetName: string; override;
    function GetTypePreview: TTypePreview; override;
    function CreateNewQuestion: TFibbage4Question; override;
    function GetCategoriesJSON: string; override;
  end;

  TFibbage4Questions_EAY = class(TFibbage4Question)

  end;

implementation

{ TFibbage4Questions }

procedure TFibbage4Questions.DoInitialize;
begin
  var item := FReader.Read(GetName);
  try
    DoParseItem(item);
  finally
    item.Free;
  end;
end;

procedure TFibbage4Questions.DoSaveCategory;
begin
  var filePath := TPath.Combine(FSavePath, 'en');
  ForceDirectories(filePath);
  filePath := TPath.Combine(filePath, Format('%s.jet', [GetName]));
  var fs := TFileStream.Create(filePath, fmCreate);
  var sw := TStreamWriter.Create(fs, TEncoding.UTF8);
  try
    sw.OwnStream;
    sw.Write(GetCategoriesJSON);
  finally
    sw.Free;
  end;
end;

procedure TFibbage4Questions.DoSaveQuestions;
begin
  for var item in FList do
  begin
    var basePath := TPath.Combine(FSavePath, 'en', GetName, UIntToStr(item.FId));
    ForceDirectories(basePath);
    var filePath := TPath.Combine(basePath, 'data.jet');
    var fs := TFileStream.Create(filePath, fmCreate);
    var sw := TStreamWriter.Create(fs, TEncoding.UTF8);
    try
      sw.OwnStream;
      var uniStr := UnicodeEscape(item.GetJSON);
      sw.Write(uniStr);
    finally
      sw.Free;
    end;

    if not item.FBumperAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FBumperAudio);

    if not item.FCorrectAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FCorrectAudio);

    if not item.FQuestionAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FQuestionAudio);

    if not item.FPic.Name.IsEmpty then
      SavePicFile(basePath, item.FPic);

    if not item.FSetupVideo.Name.IsEmpty then
      SaveVideoFile(basePath, item.FSetupVideo);

    if not item.FFeaturedStill.Name.IsEmpty then
      SavePicFile(basePath, item.FFeaturedStill);

    if not item.FTransitionStill.Name.IsEmpty then
      SavePicFile(basePath, item.FTransitionStill);

    if not item.FRevealVideo.Name.IsEmpty then
      SaveVideoFile(basePath, item.FRevealVideo);

    if not item.FSetupSubtitles.Name.IsEmpty then
      SaveVideoSubtitlesFile(basePath, item.FSetupSubtitles);

    if not item.FRevealSubtitles.Name.IsEmpty then
      SaveVideoSubtitlesFile(basePath, item.FRevealSubtitles);

    if not item.FSetupAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FSetupAudio);

    if not item.FRevealAudio.Name.IsEmpty then
      SaveAudioFile(basePath, item.FRevealAudio);

    if not item.FQuestionAudio2.Name.IsEmpty then
      SaveAudioFile(basePath, item.FQuestionAudio2);
  end;
end;

function TFibbage4Questions.GetFirstQuestionWithDuplicatedCategory: TFibbage4Question;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 2 do
    for var jdx := idx + 1 to FList.Count - 1 do
      if FList[idx].FCategory = FList[jdx].FCategory then
        Exit(FList[idx]);
end;

function TFibbage4Questions.GetFirstQuestionWithMissingSpecialEntry: TFibbage4Question;
var
  dummy: string;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if FList[idx].IsMissingSpecialEntry(dummy) then
      Exit(FList[idx]);
end;

function TFibbage4Questions.GetFirstQuestionWithTooFewSuggestions: TFibbage4Question;
const
  OPTIMAL_SUGGESTIONS_COUNT = 17;
begin
  Result := nil;
  for var idx := 0 to FList.Count - 1 do
    if Length(FList[idx].FSuggestions) < OPTIMAL_SUGGESTIONS_COUNT then
      Exit(FList[idx]);
end;

function TFibbage4Questions.GetNextRandomId: UInt32;
var
  found: Boolean;
begin
  repeat
    found := false;
    Result := RandomRange(30000, 90000);
    for var item in FList do
      if item.FId = Result then
      begin
        found := True;
        Break;
      end;
  until not found;
end;

function TFibbage4Questions.HasQuestionWithTheSameCategory(
  AQuestion: TFibbage4Question): Boolean;
begin
  Result := False;
  for var item in FList do
  begin
    if AQuestion = item then
      Continue;
    if item.Category.IsEmpty then
      Continue;
    if AQuestion.FCategory = item.FCategory then
      Exit(True);
  end;
end;

procedure TFibbage4Questions.RemoveQuestion(AQuestion: TFibbage4Question);
begin
  FList.Remove(AQuestion);
end;

procedure TFibbage4Questions.SaveAudioFile(const ABasePath: string; AEntry: TFibbageAudioEntry);
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

procedure TFibbage4Questions.SavePicFile(const ABasePath: string;
  AEntry: TFibbagePicEntry);
begin
  var srcPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.png');
  var dstPath := TPath.Combine(ABasePath, AEntry.Name + '.png');

  if srcPath = dstPath then
    Exit;

  if srcPath.StartsWith(TPath.GetTempPath) then
    TFile.Move(srcPath, dstPath)
  else
    TFile.Copy(srcPath, dstPath);
end;

procedure TFibbage4Questions.SaveVideoFile(const ABasePath: string;
  AEntry: TFibbageVideoEntry);
begin
//
end;

procedure TFibbage4Questions.SaveVideoSubtitlesFile(const ABasePath: string;
  AEntry: TFibbageSubtitlesEntry);
begin
//
end;

{ TFibbage4QuestionsBase }

procedure TFibbage4QuestionsBase.DoParseItem(AItem: TQuestionData);
begin
  var rawCategory := TJson.JsonToObject<TCategories>(AItem.CategoryData);
  try
    for var idx := 0 to Length(rawCategory.FContent) - 1 do
    begin
      if not AItem.QuestionData.ContainsKey(rawCategory.FContent[idx].FId.ToString) then
        Continue;

      var newItem: TFibbage4Question := nil;
      var rawQuestion := TJson.JsonToObject<TQuestions>(AItem.QuestionData[rawCategory.FContent[idx].FId.ToString]);
      try
        newItem := CreateNewQuestion;

        newItem.FId := rawCategory.FContent[idx].FId;
        newItem.FIsValid := rawCategory.FContent[idx].FIsValid;
        newItem.FUsCentric := rawCategory.FContent[idx].FUs;
        newItem.FFamilyFriendly := not rawCategory.FContent[idx].FX;

        newItem.FAlternateSpellings := rawCategory.FContent[idx].FAlternateSpellings;
        newItem.FBumperType := rawCategory.FContent[idx].FBumper;
        newItem.FCategory := rawCategory.FContent[idx].FCategory;
        newItem.FCorrectText := rawCategory.FContent[idx].FCorrectText;
        newItem.FExtraCategories := rawCategory.FContent[idx].FExtraCategories;
        newItem.FPersonal := rawCategory.FContent[idx].FPersonal;
        newItem.FPortrait := rawCategory.FContent[idx].FPortrait;
        newItem.FQuestionText := rawCategory.FContent[idx].FQuestionText;
        newItem.FSuggestions := rawCategory.FContent[idx].FSuggestions;

        if StrToBoolDef(rawQuestion.GetValue('HasBumperAudio'), False) then
        begin
          newItem.FBumperAudio.Name := rawQuestion.GetValue('BumperAudio');
          newItem.FBumperAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearAudioEntryIfNotExistingFile(@newItem.FBumperAudio);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasCorrectAudio'), False) then
        begin
          newItem.FCorrectAudio.Name := rawQuestion.GetValue('CorrectAudio');
          newItem.FCorrectAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearAudioEntryIfNotExistingFile(@newItem.FCorrectAudio);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasQuestionAudio'), False) then
        begin
          newItem.FQuestionAudio.Name := rawQuestion.GetValue('QuestionAudio');
          newItem.FQuestionAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearAudioEntryIfNotExistingFile(@newItem.FQuestionAudio);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasPic'), False) then
        begin
          newItem.FPic.Name := rawQuestion.GetValue('Pic');
          newItem.FPic.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearPicEntryIfNotExistingFile(@newItem.FPic);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasSetupVideo'), False) then
        begin
          newItem.FSetupVideo.Name := rawQuestion.GetValue('SetupVideo');
          newItem.FSetupVideo.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearVideoEntryIfNotExistingFile(@newItem.FSetupVideo);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasFeaturedStill'), False) then
        begin
          newItem.FFeaturedStill.Name := rawQuestion.GetValue('FeaturedStill');
          newItem.FFeaturedStill.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearPicEntryIfNotExistingFile(@newItem.FFeaturedStill);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasTransitionStill'), False) then
        begin
          newItem.FTransitionStill.Name := rawQuestion.GetValue('TransitionStill');
          newItem.FTransitionStill.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearPicEntryIfNotExistingFile(@newItem.FTransitionStill);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasRevealVideo'), False) then
        begin
          newItem.FRevealVideo.Name := rawQuestion.GetValue('RevealVideo');
          newItem.FRevealVideo.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearVideoEntryIfNotExistingFile(@newItem.FRevealVideo);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasSetupSubtitles'), False) then
        begin
          newItem.FSetupSubtitles.Name := rawQuestion.GetValue('SetupSubtitles');
          newItem.FSetupSubtitles.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearVideoSubtitlesIfNotExistingFile(@newItem.FSetupSubtitles);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasRevealSubtitles'), False) then
        begin
          newItem.FRevealSubtitles.Name := rawQuestion.GetValue('RevealSubtitles');
          newItem.FRevealSubtitles.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearVideoSubtitlesIfNotExistingFile(@newItem.FRevealSubtitles);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasSetupAudio'), False) then
        begin
          newItem.FSetupAudio.Name := rawQuestion.GetValue('SetupAudio');
          newItem.FSetupAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearAudioEntryIfNotExistingFile(@newItem.FSetupAudio);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasRevealAudio'), False) then
        begin
          newItem.FRevealAudio.Name := rawQuestion.GetValue('RevealAudio');
          newItem.FRevealAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearAudioEntryIfNotExistingFile(@newItem.FRevealAudio);
        end;

        newItem := nil;
      finally
        rawQuestion.Free;
        if Assigned(newItem) then
          FList.Remove(newItem);
        newItem.Free;
      end;
    end;
  finally
    rawCategory.Free;
  end;
end;

function TFibbage4QuestionsBase.GetCategoriesJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    var contentArr := builder.BeginObject
      .BeginArray('content');

    for var question in FList do
    begin
      var altSpellings := contentArr.BeginObject
        .BeginArray('alternateSpellings');
          for var idx := 0 to Length(question.FAlternateSpellings) - 1 do
            altSpellings.Add(question.FAlternateSpellings[idx]);
      var extraCategories := altSpellings
        .EndArray
        .Add('bumper', IfThen(question.FBumperType.IsEmpty or SameText(question.FBumperType, 'none'), 'None', question.FBumperType))
        .Add('category', question.FCategory)
        .Add('correctText', question.FCorrectText)
        .BeginArray('extraCategories');
          for var idx := 0 to Length(question.FExtraCategories) - 1 do
            extraCategories.Add(question.FExtraCategories[idx]);
      var suggestions := extraCategories
        .EndArray
        .Add('id', UIntToStr(question.FId))
        .Add('isValid', question.FIsValid)
        .Add('personal', question.FPersonal)
        .Add('portrait', question.FPortrait)
        .Add('questionText', question.FQuestionText)
        .BeginArray('suggestions');
          for var idx := 0 to Length(question.FSuggestions) - 1 do
            suggestions.Add(question.FSuggestions[idx]);
          suggestions
        .EndArray
        .Add('us', question.FUsCentric)
        .Add('x', not question.FFamilyFriendly)
      .EndObject;
    end;

    contentArr.EndArray.EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

{ TFibbage4Questions_Final }

function TFibbage4Questions_Final.CreateNewQuestion: TFibbage4Question;
begin
  Result := TFibbage4FinalQuestion.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

procedure TFibbage4Questions_Final.DoParseItem(AItem: TQuestionData);
begin
  var rawCategory := TJson.JsonToObject<TCategories>(AItem.CategoryData);
  try
    for var idx := 0 to Length(rawCategory.FContent) - 1 do
    begin
      if not AItem.QuestionData.ContainsKey(rawCategory.FContent[idx].FId.ToString) then
        Continue;

      var newItem: TFibbage4Question := nil;
      var rawQuestion := TJson.JsonToObject<TQuestions>(AItem.QuestionData[rawCategory.FContent[idx].FId.ToString]);
      try
        newItem := CreateNewQuestion;

        newItem.FAlternateSpellings := rawCategory.FContent[idx].FAlternateSpellings1;
        newItem.FAlternateSpellings2 := rawCategory.FContent[idx].FAlternateSpellings2;
        newItem.FCorrectText := rawCategory.FContent[idx].FCorrectText1;
        newItem.FCorrectText2 := rawCategory.FContent[idx].FCorrectText2;
        newItem.FId := rawCategory.FContent[idx].FId;
        newItem.FIsValid := rawCategory.FContent[idx].FIsValid;
        newItem.FQuestionText := rawCategory.FContent[idx].FQuestionText1;
        newItem.FQuestionText2 := rawCategory.FContent[idx].FQuestionText2;
        newItem.FSuggestions := rawCategory.FContent[idx].FSuggestions;
        newItem.FUsCentric := rawCategory.FContent[idx].FUs;
        newItem.FFamilyFriendly := not rawCategory.FContent[idx].FX;

        if StrToBoolDef(rawQuestion.GetValue('HasQuestionAudio1'), False) then
        begin
          newItem.FQuestionAudio.Name := rawQuestion.GetValue('QuestionAudio1');
          newItem.FQuestionAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearAudioEntryIfNotExistingFile(@newItem.FQuestionAudio);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasQuestionAudio2'), False) then
        begin
          newItem.FQuestionAudio2.Name := rawQuestion.GetValue('QuestionAudio2');
          newItem.FQuestionAudio2.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearAudioEntryIfNotExistingFile(@newItem.FQuestionAudio2);
        end;

        if StrToBoolDef(rawQuestion.GetValue('HasCorrectAudio'), False) then
        begin
          newItem.FCorrectAudio.Name := rawQuestion.GetValue('CorrectAudio');
          newItem.FCorrectAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));
          ClearAudioEntryIfNotExistingFile(@newItem.FCorrectAudio);
        end;

        newItem := nil;
      finally
        rawQuestion.Free;
        if Assigned(newItem) then
          FList.Remove(newItem);
        newItem.Free;
      end;
    end;
  finally
    rawCategory.Free;
  end;
end;

function TFibbage4Questions_Final.GetCategoriesJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    var contentArr := builder.BeginObject
      .BeginArray('content');

    for var question in FList do
    begin
      var altSpellings := contentArr.BeginObject
        .BeginArray('alternateSpellings1');
          for var idx := 0 to Length(question.FAlternateSpellings) - 1 do
            altSpellings.Add(question.FAlternateSpellings[idx]);
      var altSpellings2 := altSpellings.EndArray
        .BeginArray('alternateSpellings2');
          for var idx := 0 to Length(question.FAlternateSpellings2) - 1 do
            altSpellings2.Add(question.FAlternateSpellings2[idx]);
      var suggestions := altSpellings2.EndArray
        .Add('correctText1', question.FCorrectText)
        .Add('correctText2', question.FCorrectText2)
        .Add('id', UIntToStr(question.FId))
        .Add('isValid', question.FIsValid)
        .Add('questionText1', question.FQuestionText)
        .Add('questionText2', question.FQuestionText2)
        .BeginArray('suggestions');
          for var idx := 0 to Length(question.FSuggestions) - 1 do
            suggestions.Add(question.FSuggestions[idx]);
          suggestions
        .EndArray
        .Add('us', question.FUsCentric)
        .Add('x', not question.FFamilyFriendly)
      .EndObject;
    end;

    contentArr.EndArray.EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage4Questions_Final.GetName: string;
begin
  Result := 'fibbagefinalround';
end;

function TFibbage4Questions_Final.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Round 3';
end;

{ TFibbage4BlankieQuestion }

function TFibbage4BlankieQuestion.GetEditableFields: TEditableFields;
begin
  Result := TEditableFields.Create;

  var strItem := TEditableStringField.Create;
  strItem.Name := 'Category';
  strItem.Value := FCategory;
  Result.Add(strItem);

  var strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Question (with {{BLANK}})';
  strLongItem.Value := FQuestionText;
  Result.Add(strLongItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Answer';
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

  boolItem := TEditableBoolField.Create;
  boolItem.Name := 'US Centric';
  boolItem.Value := FUsCentric;
  Result.Add(boolItem);

  var audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Question Audio';
  audioItem.Value := FQuestionAudio.Name;
  audioItem.BasePath := FQuestionAudio.BasePath;
  audioItem.ForcedFileName := 'questionAudio';
  Result.Add(audioItem);

  audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Correct Audio';
  audioItem.Value := FCorrectAudio.Name;
  audioItem.BasePath := FCorrectAudio.BasePath;
  audioItem.ForcedFileName := 'correctAnswer';
  Result.Add(audioItem);
end;

function TFibbage4BaseQuestion.GetJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    builder.BeginObject.BeginArray('fields')
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FBumperAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasBumperAudio')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', 'false')
        .Add('n', 'HasKeywordAudio')
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
        .Add('t', 'A')
        .Add('v', 'bumperAudio')
        .Add('n', 'BumperAudio')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', 'correctAnswer')
        .Add('n', 'CorrectAudio')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', 'questionAudio')
        .Add('n', 'QuestionAudio')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FPic.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasPic')
      .EndObject
      .BeginObject
        .Add('t', 'G')
        .Add('v', 'picture')
        .Add('n', 'Pic')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FSetupVideo.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasSetupVideo')
      .EndObject
      .BeginObject
        .Add('t', '')
        .Add('v', 'setupVideo')
        .Add('n', 'SetupVideo')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FSetupAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasSetupAudio')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', 'setupAudio')
        .Add('n', 'SetupAudio')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FFeaturedStill.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasFeaturedStill')
      .EndObject
      .BeginObject
        .Add('t', 'G')
        .Add('v', 'featuredStill')
        .Add('n', 'FeaturedStill')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FTransitionStill.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasTransitionStill')
      .EndObject
      .BeginObject
        .Add('t', 'G')
        .Add('v', 'transitionStill')
        .Add('n', 'TransitionStill')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FSetupSubtitles.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasSetupSubtitles')
      .EndObject
      .BeginObject
        .Add('t', '')
        .Add('v', 'setupSubtitles')
        .Add('n', 'SetupSubtitles')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FRevealVideo.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasRevealVideo')
      .EndObject
      .BeginObject
        .Add('t', '')
        .Add('v', 'revealVideo')
        .Add('n', 'RevealVideo')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FRevealAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasRevealAudio')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', 'revealAudio')
        .Add('n', 'RevealAudio')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FRevealSubtitles.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasRevealSubtitles')
      .EndObject
      .BeginObject
        .Add('t', '')
        .Add('v', 'revealSubtitles')
        .Add('n', 'RevealSubtitles')
      .EndObject
    .EndArray
    .EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage4BaseQuestion.IsMissingSpecialEntry(
  out AError: string): Boolean;
const
  BLANK = '{{BLANK}}';
begin
  Result := False;
  if not FQuestionText.Contains(BLANK) then
  begin
    Result := True;
    AError := 'Question is missing {{BLANK}}';
  end;
end;

procedure TFibbage4BlankieQuestion.SetEditableFields(AFields: TEditableFields);
begin
  FCategory := (AFields[0] as TEditableStringField).Value;
  FQuestionText := (AFields[1] as TEditableLongStringField).Value;
  FCorrectText := (AFields[2] as TEditableStringField).Value;
  FAlternateSpellings := (AFields[3] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FSuggestions := (AFields[4] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FFamilyFriendly := (AFields[5] as TEditableBoolField).Value;
  FUsCentric := (AFields[6] as TEditableBoolField).Value;
  FQuestionAudio.Name := (AFields[7] as TEditableAudioField).Value;
  FQuestionAudio.BasePath := (AFields[7] as TEditableAudioField).BasePath;
  FCorrectAudio.Name := (AFields[8] as TEditableAudioField).Value;
  FCorrectAudio.BasePath := (AFields[8] as TEditableAudioField).BasePath;
end;

{ TFibbage4FinalQuestion }

function TFibbage4FinalQuestion.GetEditableFields: TEditableFields;
begin
  Result := TEditableFields.Create;

  var strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Left question (with {{BLANK}})';
  strLongItem.Value := FQuestionText;
  Result.Add(strLongItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Right question (with {{BLANK}})';
  strLongItem.Value := FQuestionText2;
  Result.Add(strLongItem);

  var strItem := TEditableStringField.Create;
  strItem.Name := 'Answer (for left question)';
  strItem.Value := FCorrectText;
  Result.Add(strItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Answer (for right question)';
  strItem.Value := FCorrectText2;
  Result.Add(strItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Alternate Spellings (for left question)';
  strLongItem.Value := string.Join(', ', FAlternateSpellings);
  Result.Add(strLongItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Alternate Spellings (for right question)';
  strLongItem.Value := string.Join(', ', FAlternateSpellings2);
  Result.Add(strLongItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Suggestions (for both questions)';
  strLongItem.Value := string.Join(', ', FSuggestions);
  Result.Add(strLongItem);

  var boolItem := TEditableBoolField.Create;
  boolItem.Name := 'Family Friendly';
  boolItem.Value := FFamilyFriendly;
  Result.Add(boolItem);

  boolItem := TEditableBoolField.Create;
  boolItem.Name := 'US Centric';
  boolItem.Value := FUsCentric;
  Result.Add(boolItem);

  var audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Question Audio (for left question)';
  audioItem.Value := FQuestionAudio.Name;
  audioItem.BasePath := FQuestionAudio.BasePath;
  audioItem.ForcedFileName := 'questionAudio1';
  Result.Add(audioItem);

  audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Question Audio (for right question)';
  audioItem.Value := FQuestionAudio2.Name;
  audioItem.BasePath := FQuestionAudio2.BasePath;
  audioItem.ForcedFileName := 'questionAudio2';
  Result.Add(audioItem);

  audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Correct Audio';
  audioItem.Value := FCorrectAudio.Name;
  audioItem.BasePath := FCorrectAudio.BasePath;
  audioItem.ForcedFileName := 'correctAnswer1';
  Result.Add(audioItem);
end;

function TFibbage4FinalQuestion.GetJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    builder.BeginObject.BeginArray('fields')
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FQuestionAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasQuestionAudio1')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FQuestionAudio2.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasQuestionAudio2')
      .EndObject
      .BeginObject
        .Add('t', 'B')
        .Add('v', BoolToStr(not FCorrectAudio.Name.IsEmpty, True).ToLowerInvariant)
        .Add('n', 'HasCorrectAudio')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', 'questionAudio1')
        .Add('n', 'QuestionAudio1')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', 'questionAudio2')
        .Add('n', 'QuestionAudio2')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', 'correctAnswer1')
        .Add('n', 'CorrectAudio')
      .EndObject
    .EndArray
    .EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbage4FinalQuestion.GetPreview: TQuestionPreview;
begin
  Result := Default(TQuestionPreview);
  Result.Header := Format('Id: %d', [FId]);
  Result.Question := Trim(FQuestionText + sLineBreak + sLineBreak + FQuestionText2);
end;

function TFibbage4FinalQuestion.IsMissingSpecialEntry(
  out AError: string): Boolean;
const
  BLANK = '{{BLANK}}';
begin
  Result := True;

  var fIdx := FQuestionText.IndexOf(BLANK);
  var sIdx := FQuestionText2.IndexOf(BLANK);

  if fIdx = -1 then
    AError := 'Left question is missing ' + BLANK
  else if sIdx = -1 then
    AError := 'Right question is missing ' + BLANK
  else
    Result := False;
end;

procedure TFibbage4FinalQuestion.SetEditableFields(AFields: TEditableFields);
begin
  FQuestionText := (AFields[0] as TEditableLongStringField).Value;
  FQuestionText2 := (AFields[1] as TEditableLongStringField).Value;
  FCorrectText := (AFields[2] as TEditableStringField).Value;
  FCorrectText2 := (AFields[3] as TEditableStringField).Value;
  FAlternateSpellings := (AFields[4] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FAlternateSpellings2 := (AFields[5] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FSuggestions := (AFields[6] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FFamilyFriendly := (AFields[7] as TEditableBoolField).Value;
  FUsCentric := (AFields[8] as TEditableBoolField).Value;
  FQuestionAudio.BasePath := (AFields[9] as TEditableAudioField).BasePath;
  FQuestionAudio.Name := (AFields[9] as TEditableAudioField).Value;
  FQuestionAudio2.BasePath := (AFields[10] as TEditableAudioField).BasePath;
  FQuestionAudio2.Name := (AFields[10] as TEditableAudioField).Value;
  FCorrectAudio.BasePath := (AFields[11] as TEditableAudioField).BasePath;
  FCorrectAudio.Name := (AFields[11] as TEditableAudioField).Value;
end;

{ TQuestions }

destructor TQuestions.Destroy;
begin
  for var idx := Length(FFields) - 1 downto 0 do
    FFields[idx].Free;
  SetLength(FFields, 0);
  inherited;
end;

function TQuestions.GetValue(const AName: string): string;
begin
  Result := '';
  for var idx := 0 to Length(FFields) - 1 do
    if FFields[idx].FN = AName then
      Exit(FFields[idx].FV);
end;

{ TFibbage4Question }

procedure TFibbage4Question.AssignTo(Dest: TPersistent);
begin
  if not (Dest is TFibbage4Question) then
  begin
    Assert(False);
    Exit;
  end;

  var destQuestion := Dest as TFibbage4Question;

  {destQuestion.FId := FId;}
  destQuestion.FIsValid := FIsValid;
  destQuestion.FUsCentric := FUsCentric;
  destQuestion.FFamilyFriendly := FFamilyFriendly;
  destQuestion.FAlternateSpellings := FAlternateSpellings;
  destQuestion.FBumperType := FBumperType;
  destQuestion.FCategory := FCategory;
  destQuestion.FCorrectText := FCorrectText;
  destQuestion.FExtraCategories := FExtraCategories;
  destQuestion.FPersonal := FPersonal;
  destQuestion.FPortrait := FPortrait;
  destQuestion.FQuestionText := FQuestionText;
  destQuestion.FSuggestions := FSuggestions;
  destQuestion.FBumperAudio := FBumperAudio;
  destQuestion.FCorrectAudio := FCorrectAudio;
  destQuestion.FQuestionAudio := FQuestionAudio;
  destQuestion.FPic := FPic;
  destQuestion.FSetupVideo := FSetupVideo;
  destQuestion.FFeaturedStill := FFeaturedStill;
  destQuestion.FTransitionStill := FTransitionStill;
  destQuestion.FRevealVideo := FRevealVideo;
  destQuestion.FSetupSubtitles := FSetupSubtitles;
  destQuestion.FRevealSubtitles := FRevealSubtitles;
  destQuestion.FSetupAudio := FSetupAudio;
  destQuestion.FRevealAudio := FRevealAudio;
  destQuestion.FAlternateSpellings2 := FAlternateSpellings2;
  destQuestion.FCorrectText2 := FCorrectText2;
  destQuestion.FQuestionText2 := FQuestionText2;
  destQuestion.FQuestionAudio2 := FQuestionAudio2;
end;

function TFibbage4Question.GetPreview: TQuestionPreview;
begin
  Result := Default(TQuestionPreview);
  Result.Header := Format('Id: %d, Category: %s', [FId, FCategory]);
  Result.Question := FQuestionText;
end;

function TFibbage4Question.GetSuggestionsCount: Int32;
begin
  Result := Length(FSuggestions);
end;

{ TFibbage4Questions_Final.TCategories }

destructor TFibbage4Questions_Final.TCategories.Destroy;
begin
  for var idx := Length(FContent) - 1 downto 0 do
    FContent[idx].Free;
  SetLength(FContent, 0);
  inherited;
end;

{ TFibbage4QuestionsBase.TCategories }

destructor TFibbage4QuestionsBase.TCategories.Destroy;
begin
  for var idx := Length(FContent) - 1 downto 0 do
    FContent[idx].Free;
  SetLength(FContent, 0);
  inherited;
end;

{ TFibbage4Questions_Blankie }

function TFibbage4Questions_Blankie.CreateNewQuestion: TFibbage4Question;
begin
  Result := TFibbage4BlankieQuestion.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

function TFibbage4Questions_Blankie.GetName: string;
begin
  Result := 'fibbageblankie';
end;

function TFibbage4Questions_Blankie.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Round 1 + Round 2';
end;

{ TFibbage4Questions_Personal }

function TFibbage4Questions_Personal.CreateNewQuestion: TFibbage4Question;
begin
  Result := TFibbage4PersonalQuestion.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

function TFibbage4Questions_Personal.GetName: string;
begin
  Result := 'eayblankie';
end;

function TFibbage4Questions_Personal.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Personal';
end;

{ TFibbage4PersonalQuestion }

function TFibbage4PersonalQuestion.GetEditableFields: TEditableFields;
begin
  Result := TEditableFields.Create;

  var strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Question (when asked for truth,' + sLineBreak + 'without any special elements)';
  strLongItem.Value := FPersonal;
  Result.Add(strLongItem);

  strLongItem := TEditableLongStringField.Create;
  strLongItem.Name := 'Question (when picking truth,' + sLineBreak + 'with {{PLAYER}})';
  strLongItem.Value := FQuestionText;
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
  audioItem.ForcedFileName := 'questionAudio';
  Result.Add(audioItem);
end;

function TFibbage4PersonalQuestion.GetPreview: TQuestionPreview;
begin
  Result := Default(TQuestionPreview);
  Result.Header := Format('Id: %d', [FId]);
  Result.Question := FQuestionText;
end;

procedure TFibbage4PersonalQuestion.SetEditableFields(AFields: TEditableFields);
begin
  FPersonal := (AFields[0] as TEditableLongStringField).Value;
  FQuestionText := (AFields[1] as TEditableLongStringField).Value;
  FSuggestions := (AFields[2] as TEditableLongStringField).Value.Replace(', ', ',').Split([',']);
  FFamilyFriendly := (AFields[3] as TEditableBoolField).Value;

  FQuestionAudio.Name := (AFields[4] as TEditableAudioField).Value;
  FQuestionAudio.BasePath := (AFields[4] as TEditableAudioField).BasePath;
end;

{ TFibbage4Questions_Celebrity }

function TFibbage4Questions_Celebrity.CreateNewQuestion: TFibbage4Question;
begin
  Result := TFibbage4CelebrityQuestion.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

function TFibbage4Questions_Celebrity.GetName: string;
begin
  Result := 'celebrityblankie';
end;

function TFibbage4Questions_Celebrity.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Celebrity';
end;

{ TFibbage4Questions_Headline }

function TFibbage4Questions_Headline.CreateNewQuestion: TFibbage4Question;
begin
  Result := TFibbage4HeadlineQuestion.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

function TFibbage4Questions_Headline.GetName: string;
begin
  Result := 'headlineblankie';
end;

function TFibbage4Questions_Headline.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'Headline';
end;

{ TFibbage4Questions_History }

function TFibbage4Questions_History.CreateNewQuestion: TFibbage4Question;
begin
  Result := TFibbage4HistoryQuestion.Create;
  Result.FId := GetNextRandomId;
  FList.Add(Result);
end;

function TFibbage4Questions_History.GetName: string;
begin
  Result := 'historyblankie';
end;

function TFibbage4Questions_History.GetTypePreview: TTypePreview;
begin
  Result.InternalName := GetName;
  Result.DisplayName := 'History';
end;

end.
