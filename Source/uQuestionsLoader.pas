unit uQuestionsLoader;

interface

uses
  uLog,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  REST.JSON,
  REST.Json.Types,
  DBXJSON,
  uPathChecker,
  System.IOUtils,
  uInterfaces;

type
  TQuestionField = class
  private
    FT: string;      
    FV: string;     
    FN: string;
  public
    property T: string read FT write FT;
    property V: string read FV write FV;
    property N: string read FN write FN;
  end;

  TQuestionItem = class(TInterfacedObject, IQuestion)
  strict private const
    EMPTY_STRING = '{EMPTY_STRING}';
  private
    FFields: TArray<TQuestionField>;

    [JSONMarshalledAttribute(False)]
    FId: Integer;
    [JSONMarshalledAttribute(False)]
    FQuestionType: TQuestionType;
    [JSONMarshalledAttribute(False)]
    FQuestionAudioBytes: TBytes;
    [JSONMarshalledAttribute(False)]
    FAnswerAudioBytes: TBytes;
    [JSONMarshalledAttribute(False)]
    FBumperAudioBytes: TBytes;
    [JSONMarshalledAttribute(False)]
    FPortraitBytes: TBytes;
    [JSONMarshalledAttribute(False)]
    FCategory: ICategory; {do not clone}

    procedure PrepareEmptyValues;
    procedure SetHaveQuestionAudio(AHave: Boolean);
    procedure SetHaveAnswerAudio(AHave: Boolean);
    procedure SetHaveBumperAudio(AHave: Boolean);
    
    function GetQuestionAudioName: string;
    function GetAnswerAudioName: string;
    function GetBumperAudioName: string;
    function GetPortraitName: string;

    procedure SetQuestionAudioName(const AName: string);
    procedure SetAnswerAudioName(const AName: string);
    procedure SetBumperAudioName(const AName: string);
    procedure CreateFile(const APath: string; const AData: TBytes);
    procedure SetId(AId: Integer);
    procedure SetCategory(const ACategory: string);
    procedure SetPortraitName(const AName: string);
  public
    destructor Destroy; override;

    procedure SetDefaults;
    procedure CloneFrom(AObj: IQuestion);

    function GetId: Integer;
    function GetQuestion: string;
    function GetSuggestions: string;
    function GetAnswer: string;
    function GetAlternateSpelling: string;
    function GetHaveQuestionAudio: Boolean;
    function GetHaveAnswerAudio: Boolean;
    function GetHaveBumperAudio: Boolean;
    function GetHavePortrait: Boolean;

    procedure SetQuestion(const AQuestion: string);
    procedure SetSuggestions(const ASuggestions: string);
    procedure SetAnswer(const AAnswer: string);
    procedure SetAlternateSpelling(const AAlternateSpelling: string);

    function GetQuestionAudioData: TBytes;
    function GetAnswerAudioData: TBytes;
    function GetBumperAudioData: TBytes;
    function GetPortraitData: TBytes;

    procedure SetQuestionAudioData(const AData: TBytes);
    procedure SetAnswerAudioData(const AData: TBytes);
    procedure SetBumperAudioData(const AData: TBytes);
    procedure SetPortraitData(const AData: TBytes);

    function GetCategoryObj: ICategory;
    procedure SetCategoryObj(ACategory: ICategory);

    function GetCategory: string;

    procedure Save(const APath: string);

    function GetQuestionType: TQuestionType;
    procedure SetQuestionType(AQuestionType: TQuestionType);

    property Fields: TArray<TQuestionField> read FFields write FFields;
  end;

  TQuestionListHelper = class helper for TQuestionList
  public
    procedure Save(const AProjectPath, AQuestionsDir: string);
  end;

  TQuestionsBase = class(TInterfacedObject, IFibbageQuestions)
   private
    FContentDir: string;
    FShortieQuestions: TQuestionList;
    FFinalQuestions: TQuestionList;
    function InnerCreateNewQuestion: IQuestion;
    procedure LoadFinals;
    procedure FillQuestions(const AMainDir: string; AQuestionsList: TList<IQuestion>);
    function ReadFileData(const APath: string): TBytes;
  protected
    procedure DoLoadQuestions; virtual;
    procedure LoadShorties; virtual;
    function GetBackupPath(const APath: string): string;
  public
    constructor Create;
    destructor Destroy; override;

    function ShortieQuestions: TQuestionList;
    function FinalQuestions: TQuestionList;
    procedure CopyDataFrom(ASource: IFibbageQuestions);

    procedure LoadQuestions(const AContentDir: string);

    procedure Save(const APath: string; ASaveOptions: TSaveOptions); virtual; abstract;
    procedure RemoveShortieQuestion(AQuestion: IQuestion);
    procedure RemoveFinalQuestion(AQuestion: IQuestion);

    function CreateNewShortieQuestion: IQuestion;
    function CreateNewFinalQuestion: IQuestion;
  end;

  TQuestionsFibbageXL = class(TQuestionsBase)
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

  TQuestionsFibbageXLPP1 = class(TQuestionsFibbageXL)
  protected
    procedure LoadShorties; override;
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

  TQuestionsFibbage3PP4 = class(TQuestionsFibbageXL)
  private
    procedure SaveSpecialQuestions(const APath: string; ASaveOptions: TSaveOptions);
    procedure SavePersonalShortieQuestions(const APath: string; ASaveOptions: TSaveOptions);
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

  EInternalFileNotFound = class(Exception);

implementation

{ TQuestionItem }

destructor TQuestionItem.Destroy;
begin
  FCategory := nil;
  for var idx := Length(FFields) - 1 downto 0 do
    FreeAndNil(FFields[idx]);
  SetLength(FFields, 0);
  inherited;
end;

function TQuestionItem.GetAlternateSpelling: string;
begin
  for var field in FFields do
    if SameText('AlternateSpellings', field.N) then
      if SameText(EMPTY_STRING, field.V) then
        Exit('')
      else
        Exit(field.V);
end;

function TQuestionItem.GetAnswer: string;
begin
  for var field in FFields do
    if SameText('CorrectText', field.N) then
      Exit(field.V);
end;

function TQuestionItem.GetBumperAudioData: TBytes;
begin
  Result := FBumperAudioBytes;
end;

function TQuestionItem.GetBumperAudioName: string;
begin
  Result := '';
  for var field in FFields do
    if SameText('BumperAudio', field.N) then
    begin
      Result := field.V;
      Break;
    end;
end;

function TQuestionItem.GetCategory: string;
begin
  Result := '';
  for var field in FFields do
    if SameText('Category', field.N) then
    begin
      Result := field.V;
      Break;
    end;
end;

function TQuestionItem.GetCategoryObj: ICategory;
begin
  Result := FCategory;
end;

function TQuestionItem.GetHaveAnswerAudio: Boolean;
begin
  Result := False;
  for var field in FFields do
    if SameText('HasCorrectAudio', field.N) then
    begin
      Result := StrToBoolDef(field.V, False);
      Break;
    end;
end;

function TQuestionItem.GetHaveBumperAudio: Boolean;
begin
  Result := False;
  for var field in FFields do
    if SameText('HasBumperAudio', field.N) then
    begin
      Result := StrToBoolDef(field.V, False);
      Break;
    end;
end;

function TQuestionItem.GetHavePortrait: Boolean;
begin
  Result := False;
  for var field in FFields do
    if SameText('Pic', field.N) then
    begin
      Result := not field.v.IsEmpty;
      Break;
    end;
end;

function TQuestionItem.GetHaveQuestionAudio: Boolean;
begin
  Result := False;
  for var field in FFields do
    if SameText('HasQuestionAudio', field.N) then
    begin
      Result := StrToBoolDef(field.V, False);
      Break;
    end;
end;

function TQuestionItem.GetAnswerAudioData: TBytes;
begin
  Result := FAnswerAudioBytes;
end;

function TQuestionItem.GetAnswerAudioName: string;
begin
  Result := '';
  for var field in FFields do
    if SameText('CorrectAudio', field.N) then
    begin
      Result := field.V;
      Break;
    end;
end;

function TQuestionItem.GetId: Integer;
begin
  Result := FId;
end;

function TQuestionItem.GetPortraitData: TBytes;
begin
  Result := FPortraitBytes;
end;

function TQuestionItem.GetPortraitName: string;
begin
  Result := '';
  for var field in FFields do
    if SameText('Pic', field.N) then
    begin
      Result := field.V;
      Break;
    end;
end;

function TQuestionItem.GetQuestion: string;
begin
  for var field in FFields do
    if SameText('QuestionText', field.N) then
      Exit(field.V);
end;

function TQuestionItem.GetQuestionAudioData: TBytes;
begin
  Result := FQuestionAudioBytes;
end;

function TQuestionItem.GetQuestionAudioName: string;
begin
  Result := '';
  for var field in FFields do
    if SameText('QuestionAudio', field.N) then
    begin
      Result := field.V;
      Break;
    end;
end;

function TQuestionItem.GetQuestionType: TQuestionType;
begin
  Result := FQuestionType;
end;

procedure TQuestionItem.Save(const APath: string);
var
  fs: TFileStream;
  sw: TStreamWriter;
begin
  var data := TJson.ObjectToJsonString(Self, [joIgnoreEmptyStrings])
    .Replace(EMPTY_STRING, '');

  var dir := IncludeTrailingPathDelimiter(TPath.Combine(APath, IntToStr(FId)));
  ForceDirectories(dir);

  fs := TFileStream.Create(TPath.Combine(dir, 'data.jet'), fmCreate);
  sw := TStreamWriter.Create(fs);
  try
    sw.OwnStream;
    sw.Write(data);
  finally
    sw.Free;
  end;

  if GetHaveQuestionAudio then
    if Length(GetQuestionAudioData) > 0 then
      CreateFile(TPath.Combine(dir, GetQuestionAudioName + '.ogg'), GetQuestionAudioData)
    else
      LogE('Have question audio but audio file is empty');

  if GetHaveAnswerAudio then
    if Length(GetAnswerAudioData) > 0 then
      CreateFile(TPath.Combine(dir, GetAnswerAudioName + '.ogg'), GetAnswerAudioData)
    else
      LogE('Have answer audio but audio file is empty');

  if GetHaveBumperAudio then
    if Length(GetBumperAudioName) > 0 then
      CreateFile(TPath.Combine(dir, GetBumperAudioName + '.ogg'), GetBumperAudioData)
    else
      LogE('Have bumper audio but audio file is empty');

  if GetHavePortrait then
    if Length(GetPortraitData) > 0 then
      CreateFile(TPath.Combine(dir, GetPortraitName + '.png'), GetPortraitData)
    else
      LogE('Have picture but picture file is empty');
end;

procedure TQuestionItem.CloneFrom(AObj: IQuestion);
begin
  SetId(AObj.GetId);
  SetQuestion(AObj.GetQuestion);
  SetSuggestions(AObj.GetSuggestions);
  SetAnswer(AObj.GetAnswer);
  SetAlternateSpelling(AObj.GetAlternateSpelling);
  SetQuestionAudioData(AObj.GetQuestionAudioData);
  SetAnswerAudioData(AObj.GetAnswerAudioData);
  SetBumperAudioData(AObj.GetBumperAudioData);
  SetQuestionType(AObj.GetQuestionType);
  SetCategory(AObj.GetCategory);
  SetPortraitData(AObj.GetPortraitData);
end;

procedure TQuestionItem.CreateFile(const APath: string; const AData: TBytes);
begin
  var fs := TFileStream.Create(APath, fmCreate);
  try
    fs.Write(AData, Length(AData));
  finally
    fs.Free;
  end;
end;

procedure TQuestionItem.SetAlternateSpelling(const AAlternateSpelling: string);
begin
  for var field in FFields do
    if SameText('AlternateSpellings', field.N) then
    begin
      if AAlternateSpelling.IsEmpty then
        field.V := EMPTY_STRING
      else
        field.V := AAlternateSpelling;
      Break;
    end;
end;

procedure TQuestionItem.SetAnswer(const AAnswer: string);
begin
  for var field in FFields do
    if SameText('CorrectText', field.N) then
    begin
      field.V := AAnswer;
      Break;
    end;
end;

procedure TQuestionItem.SetAnswerAudioData(const AData: TBytes);
begin
  SetLength(FAnswerAudioBytes, Length(AData));
  Move(AData[0], FAnswerAudioBytes[0], Length(AData));

  if AData = nil then
    SetAnswerAudioName('')
  else
    SetAnswerAudioName(ChangeFileExt(TPath.GetRandomFileName, ''));
end;

procedure TQuestionItem.SetAnswerAudioName(const AName: string);
begin
  for var field in FFields do
    if SameText('CorrectAudio', field.N) then
    begin
      field.V := AName;
      SetHaveAnswerAudio(not AName.IsEmpty);
      Break;
    end;
end;

procedure TQuestionItem.SetBumperAudioData(const AData: TBytes);
begin
  SetLength(FBumperAudioBytes, Length(AData));
  Move(AData[0], FBumperAudioBytes[0], Length(AData));

  if AData = nil then
    SetBumperAudioName('')
  else
    SetBumperAudioName(ChangeFileExt(TPath.GetRandomFileName, ''));
end;

procedure TQuestionItem.SetBumperAudioName(const AName: string);
begin
  for var field in FFields do
    if SameText('BumperAudio', field.N) then
    begin
      field.V := AName;
      SetHaveBumperAudio(not AName.IsEmpty);
      Break;
    end;
end;

procedure TQuestionItem.SetCategory(const ACategory: string);
begin
  for var field in FFields do
    if SameText('Category', field.N) then
    begin
      field.V := ACategory;
      Break;
    end;
end;

procedure TQuestionItem.SetCategoryObj(ACategory: ICategory);
begin
  FCategory := ACategory;
  SetId(FCategory.GetId);
  SetCategory(FCategory.GetCategory);
end;

procedure TQuestionItem.SetDefaults;
begin
  SetLength(FFields, 13);

  FFields[0] := TQuestionField.Create;
  FFields[0].N := 'HasBumperAudio';
  FFields[0].V := 'false';
  FFields[0].T := 'B';

  FFields[1] := TQuestionField.Create;
  FFields[1].N := 'HasBumperType';
  FFields[1].V := 'false';
  FFields[1].T := 'B';

  FFields[2] := TQuestionField.Create;
  FFields[2].N := 'HasCorrectAudio';
  FFields[2].V := 'false';
  FFields[2].T := 'B';

  FFields[3] := TQuestionField.Create;
  FFields[3].N := 'HasQuestionAudio';
  FFields[3].V := 'false';
  FFields[3].T := 'B';

  FFields[4] := TQuestionField.Create;
  FFields[4].N := 'Suggestions';
  FFields[4].V := '';
  FFields[4].T := 'S';

  FFields[5] := TQuestionField.Create;
  FFields[5].N := 'Category';
  FFields[5].V := '';
  FFields[5].T := 'S';

  FFields[6] := TQuestionField.Create;
  FFields[6].N := 'CorrectText';
  FFields[6].V := '';
  FFields[6].T := 'S';

  FFields[7] := TQuestionField.Create;
  FFields[7].N := 'BumperType';
  FFields[7].V := 'None';
  FFields[7].T := 'S';

  FFields[8] := TQuestionField.Create;
  FFields[8].N := 'QuestionText';
  FFields[8].V := '';
  FFields[8].T := 'S';

  FFields[9] := TQuestionField.Create;
  FFields[9].N := 'AlternateSpellings';
  FFields[9].V := '';
  FFields[9].T := 'S';

  FFields[10] := TQuestionField.Create;
  FFields[10].N := 'BumperAudio';
  FFields[10].V := '';
  FFields[10].T := 'A';

  FFields[11] := TQuestionField.Create;
  FFields[11].N := 'CorrectAudio';
  FFields[11].V := '';
  FFields[11].T := 'A';

  FFields[12] := TQuestionField.Create;
  FFields[12].N := 'QuestionAudio';
  FFields[12].V := '';
  FFields[12].T := 'A';
end;

procedure TQuestionItem.SetHaveAnswerAudio(AHave: Boolean);
begin
  for var field in FFields do
    if SameText('HasCorrectAudio', field.N) then
    begin
      field.V := BoolToStr(AHave, True).ToLowerInvariant;
      Break;
    end;
end;

procedure TQuestionItem.SetHaveBumperAudio(AHave: Boolean);
begin
  for var field in FFields do
    if SameText('HasBumperAudio', field.N) then
    begin
      field.V := BoolToStr(AHave, True).ToLowerInvariant;
      Break;
    end;
end;

procedure TQuestionItem.SetHaveQuestionAudio(AHave: Boolean);
begin
  for var field in FFields do
    if SameText('HasQuestionAudio', field.N) then
    begin
      field.V := BoolToStr(AHave, True).ToLowerInvariant;
      Break;
    end;
end;

procedure TQuestionItem.SetId(AId: Integer);
begin
  FId := AId;
end;

procedure TQuestionItem.SetPortraitData(const AData: TBytes);
begin
  FPortraitBytes := Copy(AData, 0, Length(AData));

  if AData = nil then
    SetPortraitName('')
  else
    SetPortraitName(ChangeFileExt(TPath.GetRandomFileName, ''));
end;

procedure TQuestionItem.SetPortraitName(const AName: string);
begin
  for var field in FFields do
    if SameText('Pic', field.N) then
    begin
      field.V := AName;
      Break;
    end;
end;

procedure TQuestionItem.SetQuestion(const AQuestion: string);
begin
  for var field in FFields do
    if SameText('QuestionText', field.N) then
    begin
      field.V := AQuestion;
      Break;
    end;
end;

procedure TQuestionItem.SetQuestionAudioData(const AData: TBytes);
begin
  SetLength(FQuestionAudioBytes, Length(AData));
  Move(AData[0], FQuestionAudioBytes[0], Length(AData));

  if AData = nil then
    SetQuestionAudioName('')
  else
    SetQuestionAudioName(ChangeFileExt(TPath.GetRandomFileName, ''));
end;

procedure TQuestionItem.SetQuestionAudioName(const AName: string);
begin
  for var field in FFields do
    if SameText('QuestionAudio', field.N) then
    begin
      field.V := AName;
      SetHaveQuestionAudio(not AName.IsEmpty);
      Break;
    end;
end;

procedure TQuestionItem.SetQuestionType(AQuestionType: TQuestionType);
begin
  FQuestionType := AQuestionType;
end;

procedure TQuestionItem.SetSuggestions(const ASuggestions: string);
begin
  for var field in FFields do
    if SameText('Suggestions', field.N) then
    begin
      field.V := ASuggestions;
      Break;
    end;
end;

function TQuestionItem.GetSuggestions: string;
begin
  for var field in FFields do
    if SameText('Suggestions', field.N) then
      Exit(field.V);
end;

procedure TQuestionItem.PrepareEmptyValues;
begin
  for var field in Fields do
    if SameText('AlternateSpellings', field.N) then
      if field.V.IsEmpty then
        field.V := EMPTY_STRING;
end;

{ TQuestionsBase }

procedure TQuestionsBase.CopyDataFrom(ASource: IFibbageQuestions);
begin
  FShortieQuestions.Clear;
  FFinalQuestions.Clear;
  for var idx := 0 to ASource.ShortieQuestions.Count - 1 do
  begin
    var item := TQuestionItem.Create;
    item.SetDefaults;
    item.CloneFrom(ASource.ShortieQuestions[idx]);
    FShortieQuestions.Add(item);
  end;
  for var idx := 0 to ASource.FinalQuestions.Count - 1 do
  begin
    var item := TQuestionItem.Create;
    item.SetDefaults;
    item.CloneFrom(ASource.FinalQuestions[idx]);
    FFinalQuestions.Add(item);
  end;
end;

constructor TQuestionsBase.Create;
begin
  inherited;
  FShortieQuestions := TList<IQuestion>.Create;
  FFinalQuestions := TList<IQuestion>.Create;
end;

function TQuestionsBase.InnerCreateNewQuestion: IQuestion;
begin
  var res := TQuestionItem.Create;
  res.SetDefaults;

  Result := res;
end;

procedure TQuestionsBase.LoadFinals;
begin
  var finalDirs := TDirectory.GetDirectories(FContentDir, '*finalfibbage*');
  if Length(finalDirs) = 0 then
    Exit;

  FillQuestions(finalDirs[0], FFinalQuestions);

  for var item in FFinalQuestions do
    item.SetQuestionType(qtFinal);
end;

procedure TQuestionsBase.LoadQuestions(const AContentDir: string);
begin
  FContentDir := AContentDir;

  DoLoadQuestions;
end;

procedure TQuestionsBase.LoadShorties;
begin
  var shortieDir := TDirectory.GetDirectories(FContentDir, '*fibbageshortie*');

  if Length(shortieDir) = 0 then
    Exit;

  FillQuestions(shortieDir[0], FShortieQuestions);

  for var item in FShortieQuestions do
    item.SetQuestionType(qtShortie);
end;

function TQuestionsBase.CreateNewFinalQuestion: IQuestion;
begin
  Result := InnerCreateNewQuestion;
  Result.SetQuestionType(qtFinal);

  FFinalQuestions.Add(Result);
end;

function TQuestionsBase.CreateNewShortieQuestion: IQuestion;
begin
  Result := InnerCreateNewQuestion;
  Result.SetQuestionType(qtShortie);

  FShortieQuestions.Add(Result);
end;

destructor TQuestionsBase.Destroy;
begin
  FShortieQuestions.Free;
  FFinalQuestions.Free;
  inherited;
end;

procedure TQuestionsBase.DoLoadQuestions;
begin
  LoadShorties;
  LoadFinals;
end;

procedure TQuestionsBase.FillQuestions(const AMainDir: string;
  AQuestionsList: TList<IQuestion>);
var
  singleQuestion: TQuestionItem;
  fs: TFileStream;
  sr: TStreamReader;
begin
  if not Assigned(AQuestionsList) then
    Assert(False, 'AQuestionsList not assigned');

  var shortieDirs := TDirectory.GetDirectories(AMainDir);
  for var dir in shortieDirs do
  begin
    var dataFile := TDirectory.GetFiles(dir, '*.jet');

    singleQuestion := nil;
    fs := TFileStream.Create(dataFile[0], fmOpenRead);
    sr := TStreamReader.Create(fs);
    try
      try
        sr.OwnStream;
        singleQuestion := TJSON.JsonToObject<TQuestionItem>(sr.ReadToEnd);
        singleQuestion.FId := StrToIntDef(ExtractFileName(dir), 0);

        if singleQuestion.GetHaveQuestionAudio then
          singleQuestion.FQuestionAudioBytes := ReadFileData(TPath.Combine(dir, singleQuestion.GetQuestionAudioName + '.ogg'));

        if singleQuestion.GetHaveAnswerAudio then
          singleQuestion.FAnswerAudioBytes := ReadFileData(TPath.Combine(dir, singleQuestion.GetAnswerAudioName + '.ogg'));

        if singleQuestion.GetHaveBumperAudio then
          singleQuestion.FBumperAudioBytes := ReadFileData(TPath.Combine(dir, singleQuestion.GetBumperAudioName + '.ogg'));

        if singleQuestion.GetHavePortrait then
          singleQuestion.FPortraitBytes := ReadFileData(TPath.Combine(dir, singleQuestion.GetPortraitName + '.png'));

        singleQuestion.PrepareEmptyValues;
        AQuestionsList.Add(singleQuestion);
        singleQuestion := nil;
      except
        on E: EInternalFileNotFound do ;
      end;
    finally
      sr.Free;
      singleQuestion.Free;
    end;
  end;
end;

function TQuestionsBase.FinalQuestions: TQuestionList;
begin
  Result := FFinalQuestions;
end;

function TQuestionsBase.GetBackupPath(const APath: string): string;
begin
  Result := APath + '_backup';
end;

function TQuestionsBase.ReadFileData(const APath: string): TBytes;
begin
  Result := nil;
  try
    if not TFile.Exists(APath) then
      raise EInternalFileNotFound.Create(APath);

    var fs := TFileStream.Create(APath, fmOpenRead);
    try
      SetLength(Result, fs.Size);
      fs.Read(Result, fs.Size);
    finally
      fs.Free;
    end;
  except
    on E: Exception do
      LogE('ReadFileData exception, %s/%s', [E.Message, E.ClassName]);
  end;
end;

procedure TQuestionsBase.RemoveFinalQuestion(AQuestion: IQuestion);
begin
  FFinalQuestions.Remove(AQuestion);
end;

procedure TQuestionsBase.RemoveShortieQuestion(AQuestion: IQuestion);
begin
  FShortieQuestions.Remove(AQuestion);
end;

function TQuestionsBase.ShortieQuestions: TQuestionList;
begin
  Result := FShortieQuestions;
end;

{ TQuestionListHelper }

procedure TQuestionListHelper.Save(const AProjectPath, AQuestionsDir: string);
begin
  var targetDir := TPath.Combine(AProjectPath, AQuestionsDir);
  ForceDirectories(targetDir);
  for var question in Self do
    question.Save(targetDir);
end;

{ TQuestionsFibbageXLPP1 }

procedure TQuestionsFibbageXLPP1.LoadShorties;
begin
  var shortieDir := TDirectory.GetDirectories(FContentDir, '*questions*');

  if Length(shortieDir) = 0 then
    Exit;

  FillQuestions(shortieDir[0], FShortieQuestions);

  for var item in FShortieQuestions do
    item.SetQuestionType(qtShortie);
end;

procedure TQuestionsFibbageXLPP1.Save(const APath: string;
  ASaveOptions: TSaveOptions);
begin
  FShortieQuestions.Save(APath, 'questions');
  FFinalQuestions.Save(APath, 'questions');
end;

{ TQuestionsFibbage3PP4 }

procedure TQuestionsFibbage3PP4.Save(const APath: string;
  ASaveOptions: TSaveOptions);
begin
  inherited;
  SaveSpecialQuestions(APath, ASaveOptions);
  SavePersonalShortieQuestions(APath, ASaveOptions);
end;

procedure TQuestionsFibbage3PP4.SavePersonalShortieQuestions(const APath: string; ASaveOptions: TSaveOptions);
begin
  var dataPath := GetBackupPath(APath);
  var dirPath := TPath.Combine(dataPath, 'tmishortie');
  var wantedPath := TPath.Combine(APath, 'tmishortie');

  if not DirectoryExists(dirPath) then
  begin
    if soActivatingProject in ASaveOptions then
      raise EActivateError.CreateFmt('Missing directory %s, check for files integrity', [dirPath]);
    Exit;
  end;

  if DirectoryExists(wantedPath) then
    TDirectory.Delete(wantedPath, True);

  TDirectory.Copy(dirPath, wantedPath);
end;

procedure TQuestionsFibbage3PP4.SaveSpecialQuestions(const APath: string; ASaveOptions: TSaveOptions);
begin
  var dataPath := GetBackupPath(APath);
  var dirPath := TPath.Combine(dataPath, 'fibbagespecial');
  var wantedPath := TPath.Combine(APath, 'fibbagespecial');

  if not DirectoryExists(dirPath) then
  begin
    if soActivatingProject in ASaveOptions then
      raise EActivateError.CreateFmt('Missing directory %s, check for files integrity', [dirPath]);
    Exit;
  end;

  if DirectoryExists(wantedPath) then
    TDirectory.Delete(wantedPath, True);

  TDirectory.Copy(dirPath, wantedPath);
end;

{ TQuestionsFibbageXL }

procedure TQuestionsFibbageXL.Save(const APath: string;
  ASaveOptions: TSaveOptions);
begin
  FShortieQuestions.Save(APath, 'fibbageshortie');
  FFinalQuestions.Save(APath, 'finalfibbage');
end;

end.
