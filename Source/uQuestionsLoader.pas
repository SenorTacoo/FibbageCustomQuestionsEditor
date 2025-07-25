unit uQuestionsLoader;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  REST.Json,
  System.JSON.Writers,
  System.JSON.Builders,
  uFibbageFilesReader;

type
  TEditableFieldBase = class(TObject);

  TEditableStringField = class(TEditableFieldBase)
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
  end;

  TEditableBoolField = class(TEditableFieldBase)
    Name: string;
    Value: Boolean;
  end;

  TEditableFields = TObjectList<TEditableFieldBase>;

  TFibbageQuestion = class
  public
    function GetEditableFields: TEditableFields; virtual; abstract;
  end;

  TFibbageXLQuestion = class(TFibbageQuestion)
  private
    FId: UInt32;
    FCategory: string;
    FFamilyFriendly: Boolean;
    FBumperAudio: string;
    FBumperType: string;
    FCorrectAudio: string;
    FQuestionAudio: string;
    FSuggestions: TArray<string>;
    FCorrectText: string;
    FQuestionText: string;
    FAlternateSpellings: TArray<string>;
  public
    function GetEditableFields: TEditableFields; override;
  end;

  TFibbageQuestions<T: class> = class
  private
    function GetItem(AIndex: Int32): T;
  protected
    FQuestionsType: string;
    FList: TObjectList<T>;
    FReader: TFibbageFilesReader;

    procedure DoInitialize; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize(AReader: TFibbageFilesReader; const AType: string);

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
  private
    procedure DoParseItem(AItem: TQuestionData);
  protected
    procedure DoInitialize; override;
  public
    function GetCategoriesJSON: string;
  end;

implementation

{ TFibbageXLQuestions }

procedure TFibbageXLQuestions.DoInitialize;
begin
  FReader.Read(FQuestionsType);
  for var idx := 0 to FReader.Count - 1 do
    DoParseItem(FReader.GetItem(idx));
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
        newItem.FCorrectAudio := rawQuestion.GetValue('CorrectAudio');
        newItem.FQuestionAudio := rawQuestion.GetValue('QuestionAudio');
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
  var strStream := TStringWriter.Create;
  var jw := TJsonTextWriter.Create(strStream);
  var job := TJSONObjectBuilder.Create(jw);
  try
    var contentArr := job.BeginObject
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
    Result := strStream.ToString;
  finally
    job.Free;
    jw.Free;
    strStream.Free;
  end;
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

function TFibbageQuestions<T>.GetItem(AIndex: Int32): T;
begin
  Result := FList[AIndex];
end;

procedure TFibbageQuestions<T>.Initialize(AReader: TFibbageFilesReader; const AType: string);
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

function TFibbageXLQuestion.GetEditableFields: TEditableFields;
begin
  Result := TEditableFields.Create;

  var u32Item := TEditableU32Field.Create;
  u32Item.Name := 'Id';
  u32Item.Value := FId;
  Result.Add(u32Item);

  var strItem := TEditableStringField.Create;
  strItem.Name := 'Category';
  strItem.Value := FCategory;
  Result.Add(strItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Question Text';
  strItem.Value := FQuestionText;
  Result.Add(strItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Correct Text';
  strItem.Value := FCorrectText;
  Result.Add(strItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Alternate Spellings';
  strItem.Value := string.Join(',', FAlternateSpellings);
  Result.Add(strItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Suggestions';
  strItem.Value := string.Join(',', FSuggestions);
  Result.Add(strItem);

  var boolItem := TEditableBoolField.Create;
  boolItem.Name := 'Family Friendly';
  boolItem.Value := FFamilyFriendly;
  Result.Add(boolItem);

  var audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Bumper Audio';
  audioItem.Value := FBumperAudio;
  Result.Add(audioItem);

  strItem := TEditableStringField.Create;
  strItem.Name := 'Bumper Type';
  strItem.Value := FBumperType;
  Result.Add(strItem);

  audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Question Audio';
  audioItem.Value := FQuestionAudio;
  Result.Add(audioItem);

  audioItem := TEditableAudioField.Create;
  audioItem.Name := 'Correct Audio';
  audioItem.Value := FCorrectAudio;
  Result.Add(audioItem);
end;

end.
