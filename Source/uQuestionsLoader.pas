unit uQuestionsLoader;

interface

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.IOUtils,
  System.Generics.Collections,
  REST.Json,
  System.JSON.Builders,
  uFibbageJSONWriter,
  uFibbageFilesReader;

type
  TEditableFieldBase = class(TObject);

  TEditableStringField = class(TEditableFieldBase)
    Name: string;
    Value: string;
  end;

  TEditableLongStringField = class(TEditableFieldBase)
    Name: string;
    Value: string;
  end;

  TEditableU32Field = class(TEditableFieldBase)
    Name: string;
    Value: UInt32;
  end;

  TEditableAudioField = class(TEditableFieldBase)
    Name: string;
    Value: string;
    BasePath: string;
  end;

  TEditableBoolField = class(TEditableFieldBase)
    Name: string;
    Value: Boolean;
  end;

  TEditableFields = TObjectList<TEditableFieldBase>;

  TQuestionPreview = record
    Header: string;
    Question: string;
  end;

//  TQuestionsPreview = TObjectList<TQuestionPreview>;

  TFibbageQuestion = class
  public
    procedure SetEditableFields(AFields: TEditableFields); virtual; abstract;
    function GetEditableFields: TEditableFields; virtual; abstract;
    function GetPreview: TQuestionPreview; virtual; abstract;
    function GetJSON: string; virtual; abstract;
  end;

  TFibbageAudioEntry = class
    BasePath: string;
    Name: string;
  end;

  TFibbageXLQuestion = class(TFibbageQuestion)
  private
    FId: UInt32;
    FCategory: string;
    FFamilyFriendly: Boolean;
    FBumperAudio: string;
    FBumperType: string;
    FCorrectAudio: TFibbageAudioEntry;
    FQuestionAudio: TFibbageAudioEntry;
    FSuggestions: TArray<string>;
    FCorrectText: string;
    FQuestionText: string;
    FAlternateSpellings: TArray<string>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetEditableFields(AFields: TEditableFields); override;
    function GetEditableFields: TEditableFields; override;
    function GetPreview: TQuestionPreview; override;
    function GetJSON: string; override;
    function SuggestionsCount: Int32;
  end;

  TFibbageQuestions<T: class> = class abstract
  private
    function GetItem(AIndex: Int32): T;
  protected
    FList: TObjectList<T>;
    FReader: TFibbageFilesReader;

    procedure DoInitialize;
    procedure DoParseItem(AItem: TQuestionData); virtual; abstract;
    function GetName: string; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize(AReader: TFibbageFilesReader);

    function CreateNewQuestion: T; virtual; abstract;
    procedure RemoveQuestion(AQuestion: T); virtual; abstract;

    function Count: Int32;

    property Item[AIndex: Int32]: T read GetItem; default;
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
  protected
    procedure DoParseItem(AItem: TQuestionData); override;
  public
    function GetCategoriesJSON: string;

    function CreateNewQuestion: TFibbageXLQuestion; override;
    procedure RemoveQuestion(AQuestion: TFibbageXLQuestion); override;

    function HasQuestionWithTheSameCategory(AQuestion: TFibbageXLQuestion): Boolean;
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

function TFibbageXLQuestions.CreateNewQuestion: TFibbageXLQuestion;
begin
  Result := TFibbageXLQuestion.Create;
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
        newItem.FBumperAudio := rawQuestion.GetValue('BumperAudio');
        newItem.FBumperType := rawQuestion.GetValue('BumperType');

        newItem.FCorrectAudio.Name := rawQuestion.GetValue('CorrectAudio');
        newItem.FCorrectAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));

        newItem.FQuestionAudio.Name := rawQuestion.GetValue('QuestionAudio');
        newItem.FQuestionAudio.BasePath := TPath.Combine(FReader.BasePath, GetName, UIntToStr(rawCategory.FContent[idx].FId));

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
        .Add('bumper', question.FBumperAudio)
      .EndObject;
    end;

    contentArr.EndArray.EndObject;

    Result := builder.Build;
  finally
    builder.Free;
  end;
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

{ TFibbageQuestions<T> }

function TFibbageQuestions<T>.Count: Int32;
begin
  Result := FList.Count;
end;

constructor TFibbageQuestions<T>.Create;
begin
  inherited Create;
  FList := TObjectList<T>.Create;
end;

destructor TFibbageQuestions<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TFibbageQuestions<T>.DoInitialize;
begin
  DoParseItem(FReader.Read(GetName));
end;

function TFibbageQuestions<T>.GetItem(AIndex: Int32): T;
begin
  Result := FList[AIndex];
end;

procedure TFibbageQuestions<T>.Initialize(AReader: TFibbageFilesReader);
begin
  FList.Clear;
  FReader := AReader;
  DoInitialize;
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

constructor TFibbageXLQuestion.Create;
begin
  inherited Create;
  FCorrectAudio := TFibbageAudioEntry.Create;
  FQuestionAudio := TFibbageAudioEntry.Create;
end;

destructor TFibbageXLQuestion.Destroy;
begin
  FCorrectAudio.Free;
  FQuestionAudio.Free;
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
        .Add('v', BoolToStr(not FBumperAudio.IsEmpty, True).ToLowerInvariant)
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
        if not FBumperAudio.IsEmpty then
          bumperAudio.Add('v', FBumperAudio);
        bumperAudio.Add('n', 'BumperAudio')

      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', FCorrectAudio)
        .Add('n', 'CorrectAudio')
      .EndObject
      .BeginObject
        .Add('t', 'A')
        .Add('v', FQuestionAudio)
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
