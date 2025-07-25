unit uCategoriesLoader;

interface

uses
  REST.JSON,
  REST.Json.Types,
  System.JSON,
  System.JSON.Builders,
  System.JSON.Writers,
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.Generics.Collections,
  uPathChecker,
  uInterfaces;

type
  TCategoryDataBase = class(TInterfacedObject, ICategory)
  public
    procedure CloneFrom(AObj: ICategory);

    function GetId: Integer; virtual;
    function GetCategory: string; virtual;
    function GetIsFamilyFriendly: Boolean; virtual;
    function GetIsPortrait: Boolean; virtual;
    function GetBumper: string; virtual;
    function GetQuestionText: string; virtual;

    function GetCorrectText: string; virtual;
    function GetSuggestions: string; virtual;
    function GetAlternateSpelling: string; virtual;

    function GetQuestionText1: string; virtual;
    function GetQuestionText2: string; virtual;
    function GetCorrectText1: string; virtual;
    function GetCorrectText2: string; virtual;
    function GetAlternateSpelling1: string; virtual;
    function GetAlternateSpelling2: string; virtual;

    procedure SetId(AId: Integer); virtual;
    procedure SetCategory(const ACategory: string); virtual;
    procedure SetIsFamilyFriendly(AValue: Boolean); virtual;
    procedure SetIsPortrait(AValue: Boolean); virtual;
    procedure SetBumper(const AValue: string); virtual;
    procedure SetQuestionText(const AValue: string); virtual;
    procedure SetFamilyFriendly(AValue: Boolean);  virtual;

    procedure SetQuestionText1(const AValue: string); virtual;
    procedure SetQuestionText2(const AValue: string); virtual;
    procedure SetCorrectText1(const AValue: string); virtual;
    procedure SetCorrectText2(const AValue: string); virtual;
    procedure SetAlternateSpelling1(const AValue: string); virtual;
    procedure SetAlternateSpelling2(const AValue: string); virtual;

    procedure SetCorrectText(const AValue: string); virtual;
    procedure SetSuggestions(const AValue: string); virtual;
    procedure SetAlternateSpelling(const AValue: string); virtual;
  end;

  TCategoryData = class(TCategoryDataBase)
  private
    FX: Boolean;
    FId: Integer;
    FCategory: string;
    FBumper: string;
  public
    function GetId: Integer; override;
    function GetCategory: string; override;
    function GetIsFamilyFriendly: Boolean; override;
    function GetBumper: string; override;

    procedure SetId(AId: Integer); override;
    procedure SetCategory(const ACategory: string); override;
    procedure SetIsFamilyFriendly(AValue: Boolean); override;
    procedure SetBumper(const AValue: string); override;
    procedure SetFamilyFriendly(AValue: Boolean); override;
  end;

  TCategoryData_FibbageXL = class(TCategoryData);

  TCategoryData_Fibbage3PartyPack4 = class(TCategoryData)
  private
    FPersonal: string;
    FPortrait: Boolean;
    FUs: Boolean;
  public
    procedure SetIsPortrait(AValue: Boolean); override;
    function GetIsPortrait: Boolean; override;
  end;

  TCategoryDataShortie_Fibbage4PartyPack9 = class(TCategoryDataBase)
  private
    FId: string;
    FBumper: string;
    FCategory: string;
    FX: Boolean;
    FUs: Boolean;
    FAlternateSpellings: TArray<string>;
    FCorrectText: string;
    FExtraCategories: TArray<string>;
    FIsValid: string;
    FPersonal: string;
    FQuestionText: string;
    FSuggestions: TArray<string>;
  public
    function GetId: Integer; override;
    function GetIsFamilyFriendly: Boolean; override;

    function GetCategory: string; override;
    procedure SetCategory(const ACategory: string); override;

    procedure SetId(AId: Integer); override;
    procedure SetIsFamilyFriendly(AValue: Boolean); override;

    function GetQuestionText: string; override;
    procedure SetQuestionText(const AValue: string); override;

    function GetCorrectText: string; override;
    procedure SetCorrectText(const AValue: string); override;

    function GetSuggestions: string; override;
    procedure SetSuggestions(const AValue: string); override;

    function GetAlternateSpelling: string; override;
    procedure SetAlternateSpelling(const AValue: string); override;
    procedure SetFamilyFriendly(AValue: Boolean); override;
  end;

  TCategoryDataFinal_Fibbage4PartyPack9 = class(TCategoryDataBase)
  private
    FUs: Boolean;
    FX: Boolean;
    FAlternateSpellings1: TArray<string>;
    FAlternateSpellings2: TArray<string>;
    FCorrectText1: string;
    FCorrectText2: string;
    FId: string;
    FExtraCategories: TArray<string>;
    FIsValid: string;
    FQuestionText1: string;
    FQuestionText2: string;
    FSuggestions: TArray<string>;
  public
    function GetId: Integer; override;
    function GetIsFamilyFriendly: Boolean; override;

    procedure SetId(AId: Integer); override;
    procedure SetIsFamilyFriendly(AValue: Boolean); override;

    function GetQuestionText1: string; override;
    procedure SetQuestionText1(const AValue: string); override;

    function GetQuestionText2: string; override;
    procedure SetQuestionText2(const AValue: string); override;

    function GetCorrectText1: string; override;
    procedure SetCorrectText1(const AValue: string); override;

    function GetCorrectText2: string; override;
    procedure SetCorrectText2(const AValue: string); override;

    function GetSuggestions: string; override;
    procedure SetSuggestions(const AValue: string); override;

    function GetAlternateSpelling1: string; override;
    procedure SetAlternateSpelling1(const AValue: string); override;

    function GetAlternateSpelling2: string; override;
    procedure SetAlternateSpelling2(const AValue: string); override;
  end;

  TBaseCategories = class(TInterfacedObject, ICategories)
  private
    FEpisodeId: Integer;

    [JSONMarshalledAttribute(False)]
    FContentList: TInterfaceList;
    [JSONMarshalledAttribute(False)]
    FContentListInitialized: Boolean;
  protected
    procedure InitializeContentList; virtual; abstract;
    procedure InitializeContentArray; virtual; abstract;
    function GetJsonToSave(ASaveOptions: TSaveOptions): string; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    function Count: Integer;
    function Category(AIdx: Integer): ICategory;
    function GetEpisodeId: Integer;

    procedure Add(ACategory: ICategory);
    procedure Delete(AId: Integer);

    procedure CopyDataFrom(ASource: ICategories); virtual; abstract;

    procedure Save(const APath, AName: string; ASaveOptions: TSaveOptions);
  end;

  TCategories_FibbageXL = class(TBaseCategories)
  private
    FContent: TArray<TCategoryData_FibbageXL>;
  protected
    procedure InitializeContentList; override;
    procedure InitializeContentArray; override;
    function GetJsonToSave(ASaveOptions: TSaveOptions): string; override;
  public
    procedure CopyDataFrom(ASource: ICategories); override;
  end;

  TCategories_FibbageXLPartyPack1 = class(TBaseCategories)
  private
    FQuestions: TArray<TCategoryData_FibbageXL>;
  protected
    procedure InitializeContentList; override;
    procedure InitializeContentArray; override;
    function GetJsonToSave(ASaveOptions: TSaveOptions): string; override;
  public
    procedure CopyDataFrom(ASource: ICategories); override;
  end;

  TCategories_Fibbage3PartyPack4 = class(TBaseCategories)
  private
    FContent: TArray<TCategoryData_Fibbage3PartyPack4>;
  protected
    procedure InitializeContentList; override;
    procedure InitializeContentArray; override;
    function GetJsonToSave(ASaveOptions: TSaveOptions): string; override;
  public
    procedure CopyDataFrom(ASource: ICategories); override;
  end;

  TCategories_Fibbage4PartyPack9<T: TCategoryDataBase, constructor> = class(TBaseCategories)
  private
    FContent: TArray<T>;
  protected
    procedure InitializeContentList; override;
    procedure InitializeContentArray; override;
    function GetJsonToSave(ASaveOptions: TSaveOptions): string; override;
  public
    procedure CopyDataFrom(ASource: ICategories); override;
  end;

  TCategoriesShortie_Fibbage4PartyPack9 = TCategories_Fibbage4PartyPack9<TCategoryDataShortie_Fibbage4PartyPack9>;
  TCategoriesFinal_Fibbage4PartyPack9 = TCategories_Fibbage4PartyPack9<TCategoryDataFinal_Fibbage4PartyPack9>;

  TFibbageCategoriesBase = class(TInterfacedObject, IFibbageCategories)
  private
    FContentDir: string;
    FShortieCategories: ICategories;
    FFinalCategories: ICategories;
    procedure LoadFinalCategories;
    procedure LoadShortieCategories;
    function GetAvailableId: Word;
  protected
    function GetShortiesJetPath: string; virtual;
    function GetFinalsJetPath: string; virtual;

    function GetShortieCategories(const APath: string): ICategories; virtual;
    function GetFinalCategories(const APath: string): ICategories; virtual;

    function CreateNewCategory(AType: TQuestionType): ICategory; virtual; abstract;
    procedure DoLoadCategories; virtual;
    function GetBackupPath(const APath: string): string;

    function DoGetBestCategoryForQuestion(ACategories: ICategories; AQuestion: IQuestion): ICategory;
  public
    procedure CopyDataFrom(ASource: IFibbageCategories);
    function ShortieCategories: ICategories;
    function FinalCategories: ICategories;

    function GetShortieCategory(AQuestion: IQuestion): ICategory;
    function GetFinalCategory(AQuestion: IQuestion): ICategory;

    procedure LoadCategories(const AContentDir: string);
    function CreateNewShortieCategory: ICategory;
    function CreateNewFinalCategory: ICategory;
    procedure RemoveShortieCategory(AQuestion: IQuestion);
    procedure RemoveFinalCategory(AQuestion: IQuestion);
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); virtual; abstract;
  end;

  TFibbageCategories_FibbageXL = class(TFibbageCategoriesBase)
  protected
    function CreateNewCategory(AType: TQuestionType): ICategory; override;
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

  TFibbageCategories_FibbageXLPP1 = class(TFibbageCategories_FibbageXL)
  private
    procedure SaveDemoShortieCategories(const APath: string);
    procedure SaveDemoFinalCategories(const APath: string);
  protected
    function GetShortiesJetPath: string; override;
    function GetShortieCategories(const APath: string): ICategories; override;
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

  TFibbageCategories_Fibbage3PP4 = class(TFibbageCategories_FibbageXL)
  private
    procedure SaveSpecialCategories(const APath: string; ASaveOptions: TSaveOptions);
    procedure SavePersonalShortieCategories(const APath: string; ASaveOptions: TSaveOptions);
  protected
    function GetShortieCategories(const APath: string): ICategories; override;
    function CreateNewCategory(AType: TQuestionType): ICategory; override;
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

  TFibbageCategories_Fibbage4PP9 = class(TFibbageCategoriesBase)
  private
    procedure CopyOtherCategories(const APath: string);
  protected
    function CreateNewCategory(AType: TQuestionType): ICategory; override;
    function GetShortiesJetPath: string; override;
    function GetFinalsJetPath: string; override;
    function GetShortieCategories(const APath: string): ICategories; override;
    function GetFinalCategories(const APath: string): ICategories; override;
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

implementation

{ TFibbageCategoriesBase }

procedure TFibbageCategoriesBase.CopyDataFrom(ASource: IFibbageCategories);
begin
  FShortieCategories.CopyDataFrom(ASource.ShortieCategories);
  FFinalCategories.CopyDataFrom(ASource.FinalCategories);
end;

function TFibbageCategoriesBase.CreateNewFinalCategory: ICategory;
begin
  var newCategory := CreateNewCategory(qtFinal);
  FFinalCategories.Add(newCategory);
  Result := newCategory;
end;

function TFibbageCategoriesBase.CreateNewShortieCategory: ICategory;
begin
  var newCategory := CreateNewCategory(qtShortie);
  FShortieCategories.Add(newCategory);
  Result := newCategory;
end;

function TFibbageCategoriesBase.DoGetBestCategoryForQuestion(ACategories: ICategories;
  AQuestion: IQuestion): ICategory;
var
  bestCategory: ICategory;
begin
  bestCategory := nil;
  for var idx := 0 to ACategories.Count - 1 do
  begin
    var category := ACategories.Category(idx);
    if (AQuestion.GetId = category.GetId) then
      if SameText(AQuestion.GetCategory, category.GetCategory) then
        Exit(category)
      else
        bestCategory := category;
  end;
  Result := bestCategory;
end;

procedure TFibbageCategoriesBase.DoLoadCategories;
begin
  LoadShortieCategories;
  LoadFinalCategories;
end;

function TFibbageCategoriesBase.FinalCategories: ICategories;
begin
  Result := FFinalCategories;
end;

procedure TFibbageCategoriesBase.LoadShortieCategories;
begin
  FShortieCategories := GetShortieCategories(GetShortiesJetPath);
end;

procedure TFibbageCategoriesBase.RemoveShortieCategory(AQuestion: IQuestion);
begin
  FShortieCategories.Delete(AQuestion.GetId);
end;

procedure TFibbageCategoriesBase.RemoveFinalCategory(AQuestion: IQuestion);
begin
  FFinalCategories.Delete(AQuestion.GetId);
end;

procedure TFibbageCategoriesBase.LoadFinalCategories;
begin
  FFinalCategories := GetFinalCategories(GetFinalsJetPath);
end;

function TFibbageCategoriesBase.GetAvailableId: Word;
var
  res: Boolean;
  idx: Integer;
begin
  while True do
  begin
    Result := Random(High(Word) - 1000) + 1000;

    res := True;
    idx := 0;
    while idx < FShortieCategories.Count - 1 do
    begin
      if FShortieCategories.Category(idx).GetId = Result then
      begin
        res := False;
        Break;
      end;
      Inc(idx);
    end;

    if res then
    begin
      res := True;
      idx := 0;
      while idx < FFinalCategories.Count - 1 do
      begin
        if FFinalCategories.Category(idx).GetId = Result then
        begin
          res := False;
          Break;
        end;
        Inc(idx);
      end;
      if res then
        Break;
    end;
  end;
end;

function TFibbageCategoriesBase.GetBackupPath(const APath: string): string;
begin
  Result := APath + '_backup';
end;

function TFibbageCategoriesBase.GetShortieCategories(const APath: string): ICategories;
begin
  Result := nil;
  if FileExists(APath) then
  begin
    var fs := TFileStream.Create(APath, fmOpenRead);
    var sr := TStreamReader.Create(fs);
    try
      Result := TJSON.JsonToObject<TCategories_FibbageXL>(sr.ReadToEnd);
    finally
      sr.Free;
      fs.Free;
    end;
  end
  else
    Result := TCategories_FibbageXL.Create;
end;

function TFibbageCategoriesBase.GetFinalCategories(
  const APath: string): ICategories;
begin
  GetShortieCategories(APath);
end;

function TFibbageCategoriesBase.GetFinalCategory(AQuestion: IQuestion): ICategory;
begin
  Result := DoGetBestCategoryForQuestion(FFinalCategories, AQuestion);
end;

function TFibbageCategoriesBase.GetFinalsJetPath: string;
begin
  Result := IncludeTrailingPathDelimiter(FContentDir) + 'finalfibbage.jet';
end;

function TFibbageCategoriesBase.GetShortieCategory(AQuestion: IQuestion): ICategory;
begin
  Result := DoGetBestCategoryForQuestion(FShortieCategories, AQuestion);
end;

function TFibbageCategoriesBase.GetShortiesJetPath: string;
begin
  Result := TPath.Combine(FContentDir, 'fibbageshortie.jet');
end;

procedure TFibbageCategoriesBase.LoadCategories(const AContentDir: string);
begin
  FContentDir := AContentDir;

  DoLoadCategories;
end;

function TFibbageCategoriesBase.ShortieCategories: ICategories;
begin
  Result := FShortieCategories;
end;

{ TBaseCategories }

procedure TBaseCategories.Add(ACategory: ICategory);
begin
  FContentList.Add(ACategory);
end;

function TBaseCategories.Category(AIdx: Integer): ICategory;
begin
  if not FContentListInitialized then
    InitializeContentList;
  Result := FContentList[AIdx] as ICategory;
end;

function TBaseCategories.Count: Integer;
begin
  if not FContentListInitialized then
    InitializeContentList;
  Result := FContentList.Count;
end;

constructor TBaseCategories.Create;
begin
  inherited;
  FContentList := TInterfaceList.Create;
end;

procedure TBaseCategories.Delete(AId: Integer);
begin
  for var idx := Count - 1 downto 0 do
    if Category(idx).GetId = AId then
    begin
      FContentList.Delete(idx);
      Break;
    end;
end;

destructor TBaseCategories.Destroy;
begin
  FContentList.Free;
  inherited;
end;

function TBaseCategories.GetEpisodeId: Integer;
begin
  Result := FEpisodeId;
end;

procedure TBaseCategories.Save(const APath, AName: string; ASaveOptions: TSaveOptions);
begin
  if FContentListInitialized then
    InitializeContentArray;

  InitializeContentList;

  var fs := TFileStream.Create(TPath.Combine(APath, AName + '.jet'), fmCreate);
  var sw := TStreamWriter.Create(fs);
  try
    sw.WriteLine(GetJsonToSave(ASaveOptions));
  finally
    sw.Free;
    fs.Free;
  end;
end;

{ TCategoryDataBase }

procedure TCategoryDataBase.CloneFrom(AObj: ICategory);
begin
  SetId(AObj.GetId);
  SetCategory(AObj.GetCategory);
  SetIsFamilyFriendly(AObj.GetIsFamilyFriendly);
  SetBumper(AObj.GetBumper);
  SetIsPortrait(AObj.GetIsPortrait);

  SetQuestionText(AObj.GetQuestionText);
  SetQuestionText1(AObj.GetQuestionText1);
  SetQuestionText2(AObj.GetQuestionText2);

  SetCorrectText(AObj.GetCorrectText);
  SetCorrectText1(AObj.GetCorrectText1);
  SetCorrectText2(AObj.GetCorrectText2);

  SetAlternateSpelling(AObj.GetAlternateSpelling);
  SetAlternateSpelling1(AObj.GetAlternateSpelling1);
  SetAlternateSpelling2(AObj.GetAlternateSpelling2);

  SetSuggestions(AObj.GetSuggestions);
end;

function TCategoryDataBase.GetAlternateSpelling: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetAlternateSpelling1: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetAlternateSpelling2: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetBumper: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetCategory: string;
begin
  Result := ''
end;

function TCategoryDataBase.GetCorrectText: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetCorrectText1: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetCorrectText2: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetId: Integer;
begin
  Result := -1;
end;

function TCategoryDataBase.GetIsFamilyFriendly: Boolean;
begin
  Result := False;
end;

function TCategoryDataBase.GetIsPortrait: Boolean;
begin
  Result := False;
end;

function TCategoryDataBase.GetQuestionText: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetQuestionText1: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetQuestionText2: string;
begin
  Result := '';
end;

function TCategoryDataBase.GetSuggestions: string;
begin
  Result := '';
end;

procedure TCategoryDataBase.SetAlternateSpelling;
begin
  {}
end;

procedure TCategoryDataBase.SetAlternateSpelling1;
begin
  {}
end;

procedure TCategoryDataBase.SetAlternateSpelling2;
begin
  {}
end;

procedure TCategoryDataBase.SetBumper;
begin
  {}
end;

procedure TCategoryDataBase.SetCategory;
begin
  {}
end;

procedure TCategoryDataBase.SetCorrectText;
begin
  {}
end;

procedure TCategoryDataBase.SetCorrectText1;
begin
  {}
end;

procedure TCategoryDataBase.SetCorrectText2;
begin
  {}
end;

procedure TCategoryDataBase.SetFamilyFriendly;
begin
  {}
end;

procedure TCategoryDataBase.SetId;
begin
  {}
end;

procedure TCategoryDataBase.SetIsFamilyFriendly;
begin
  {}
end;

procedure TCategoryDataBase.SetIsPortrait;
begin
  {}
end;

procedure TCategoryDataBase.SetQuestionText;
begin
  {}
end;

procedure TCategoryDataBase.SetQuestionText1;
begin
  {}
end;

procedure TCategoryDataBase.SetQuestionText2;
begin
  {}
end;

procedure TCategoryDataBase.SetSuggestions;
begin
  {}
end;

{ TCategories_FibbageXL }

procedure TCategories_FibbageXL.CopyDataFrom(ASource: ICategories);
begin
  for var idx := Length(FContent) - 1 downto 0 do
    FContent[idx].Free;
  SetLength(FContent, ASource.Count);
  for var idx := 0 to ASource.Count - 1 do
  begin
    FContent[idx] := TCategoryData_FibbageXL.Create;
    FContent[idx].CloneFrom(ASource.Category(idx));
  end;
  InitializeContentList;
end;

function TCategories_FibbageXL.GetJsonToSave(
  ASaveOptions: TSaveOptions): string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

procedure TCategories_FibbageXL.InitializeContentArray;
begin
  SetLength(FContent, FContentList.Count);
  for var idx := 0 to FContentList.Count - 1 do
  begin
    var item := TCategoryData_FibbageXL.Create;
    item.CloneFrom((FContentList[idx] as ICategory));
    FContent[idx] := item;
  end;
end;

procedure TCategories_FibbageXL.InitializeContentList;
begin
  FContentList.Clear;
  for var item in FContent do
    FContentList.Add(item);
  FContentListInitialized := True;
end;

{ TCategories_FibbageXLPartyPack1 }

procedure TCategories_FibbageXLPartyPack1.CopyDataFrom(ASource: ICategories);
begin
  for var idx := Length(FQuestions) - 1 downto 0 do
    FQuestions[idx].Free;
  SetLength(FQuestions, ASource.Count);
  for var idx := 0 to ASource.Count - 1 do
  begin
    FQuestions[idx] := TCategoryData_FibbageXL.Create;
    FQuestions[idx].CloneFrom(ASource.Category(idx));
  end;
  InitializeContentList;
end;

function TCategories_FibbageXLPartyPack1.GetJsonToSave(
  ASaveOptions: TSaveOptions): string;
var
  questions: TJSONArray;
begin
  var jsonObj := TJson.ObjectToJsonObject(Self);
  try
    jsonObj.TryGetValue<TJSONArray>('questions', questions);
    for var idx := 0 to questions.Count - 1 do
    begin
      if not (questions[idx] is TJSONObject) then
        Continue;

      (questions[idx] as TJSONObject).RemovePair('x');
      (questions[idx] as TJSONObject).RemovePair('bumper');
    end;

    Exit(jsonObj.ToString);
  finally
    jsonObj.Free;
  end;
end;

procedure TCategories_FibbageXLPartyPack1.InitializeContentArray;
begin
  SetLength(FQuestions, FContentList.Count);
  for var idx := 0 to FContentList.Count - 1 do
  begin
    var item := TCategoryData_FibbageXL.Create;
    item.CloneFrom((FContentList[idx] as ICategory));
    FQuestions[idx] := item;
  end;
end;

procedure TCategories_FibbageXLPartyPack1.InitializeContentList;
begin
  FContentList.Clear;
  for var item in FQuestions do
    FContentList.Add(item);
  FContentListInitialized := True;
end;

{ TFibbageCategories_FibbageXLPP1 }

function TFibbageCategories_FibbageXLPP1.GetShortieCategories(
  const APath: string): ICategories;
begin
  Result := nil;
  if FileExists(APath) then
  begin
    var fs := TFileStream.Create(APath, fmOpenRead);
    var sr := TStreamReader.Create(fs);
    try
      Result := TJson.JsonToObject<TCategories_FibbageXLPartyPack1>(sr.ReadToEnd)
    finally
      sr.Free;
      fs.Free;
    end;
  end
  else
    Result := TCategories_FibbageXLPartyPack1.Create
end;

function TFibbageCategories_FibbageXLPP1.GetShortiesJetPath: string;
begin
  Result := IncludeTrailingPathDelimiter(FContentDir) + 'shortie.jet'
end;

procedure TFibbageCategories_FibbageXLPP1.Save(const APath: string;
  ASaveOptions: TSaveOptions);
begin
  ShortieCategories.Save(APath, 'shortie', ASaveOptions);
  FinalCategories.Save(APath, 'finalfibbage', ASaveOptions);
  SaveDemoShortieCategories(APath);
  SaveDemoFinalCategories(APath);
end;

procedure TFibbageCategories_FibbageXLPP1.SaveDemoFinalCategories(
  const APath: string);
begin
  var fs := TFileStream.Create(TPath.Combine(APath, 'demofinalfibbage.jet'), fmCreate);
  var jw := TJsonTextWriter.Create(fs);
  var job := TJSONObjectBuilder.Create(jw);
  try
    job.BeginObject
      .Add('episodeid', FShortieCategories.GetEpisodeId)
      .BeginArray('questions')
      .EndArray
    .EndObject;
  finally
    job.Free;
    jw.Free;
    fs.Free;
  end;
end;

procedure TFibbageCategories_FibbageXLPP1.SaveDemoShortieCategories(
  const APath: string);
begin
  var fs := TFileStream.Create(TPath.Combine(APath, 'demoshortie.jet'), fmCreate);
  var jw := TJsonTextWriter.Create(fs);
  var job := TJSONObjectBuilder.Create(jw);
  try
    job.BeginObject
      .Add('episodeid', FShortieCategories.GetEpisodeId)
      .BeginArray('questions')
      .EndArray
    .EndObject;
  finally
    job.Free;
    jw.Free;
    fs.Free;
  end;
end;

{ TFibbageCategories_Fibbage3PP4 }

function TFibbageCategories_Fibbage3PP4.CreateNewCategory;
begin
  Result := TCategoryData_Fibbage3PartyPack4.Create;
  Result.SetId(GetAvailableId);
end;

function TFibbageCategories_Fibbage3PP4.GetShortieCategories(
  const APath: string): ICategories;
begin
  Result := nil;
  if FileExists(APath) then
  begin
    var fs := TFileStream.Create(APath, fmOpenRead);
    var sr := TStreamReader.Create(fs);
    try
      Result := TJSON.JsonToObject<TCategories_Fibbage3PartyPack4>(sr.ReadToEnd);
    finally
      sr.Free;
      fs.Free;
    end;
  end
  else
    Result := TCategories_Fibbage3PartyPack4.Create;
end;

procedure TFibbageCategories_Fibbage3PP4.Save(const APath: string;
  ASaveOptions: TSaveOptions);
begin
  inherited;
  SaveSpecialCategories(APath, ASaveOptions);
  SavePersonalShortieCategories(APath, ASaveOptions);
end;

procedure TFibbageCategories_Fibbage3PP4.SavePersonalShortieCategories(const APath: string; ASaveOptions: TSaveOptions);
begin
  var dataPath := GetBackupPath(APath);
  var filePath := TPath.Combine(dataPath, 'tmishortie.jet');
  var wantedPath := TPath.Combine(APath, 'tmishortie.jet');

  if FileExists(filePath) then
    TFile.Copy(filePath, wantedPath, True)
  else if soActivatingProject in ASaveOptions then
    raise EActivateError.CreateFmt('Missing file %s, check for files integrity', [filePath]);
end;

procedure TFibbageCategories_Fibbage3PP4.SaveSpecialCategories(const APath: string; ASaveOptions: TSaveOptions);
begin
  var dataPath := GetBackupPath(APath);
  var filePath := TPath.Combine(dataPath, 'fibbagespecial.jet');
  var wantedPath := TPath.Combine(APath, 'fibbagespecial.jet');

  if FileExists(filePath) then
    TFile.Copy(filePath, wantedPath, True)
  else if soActivatingProject in ASaveOptions then
    raise EActivateError.CreateFmt('Missing file %s, check for files integrity', [filePath]);
end;

{ TFibbageCategories_FibbageXL }

function TFibbageCategories_FibbageXL.CreateNewCategory;
begin
  Result := TCategoryData_FibbageXL.Create;
  Result.SetId(GetAvailableId);
end;

procedure TFibbageCategories_FibbageXL.Save(const APath: string;
  ASaveOptions: TSaveOptions);
begin
  ShortieCategories.Save(APath, 'fibbageshortie', ASaveOptions);
  FinalCategories.Save(APath, 'finalfibbage', ASaveOptions);
end;

{ TCategories_Fibbage3PartyPack4 }

procedure TCategories_Fibbage3PartyPack4.CopyDataFrom(ASource: ICategories);
begin
  for var idx := Length(FContent) - 1 downto 0 do
    FContent[idx].Free;
  SetLength(FContent, ASource.Count);
  for var idx := 0 to ASource.Count - 1 do
  begin
    FContent[idx] := TCategoryData_Fibbage3PartyPack4.Create;
    FContent[idx].CloneFrom(ASource.Category(idx));
  end;
  InitializeContentList;
end;

function TCategories_Fibbage3PartyPack4.GetJsonToSave(
  ASaveOptions: TSaveOptions): string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

procedure TCategories_Fibbage3PartyPack4.InitializeContentArray;
begin
  SetLength(FContent, FContentList.Count);
  for var idx := 0 to FContentList.Count - 1 do
  begin
    var item := TCategoryData_Fibbage3PartyPack4.Create;
    item.CloneFrom((FContentList[idx] as ICategory));
    FContent[idx] := item;
  end;
end;

procedure TCategories_Fibbage3PartyPack4.InitializeContentList;
begin
  FContentList.Clear;
  for var item in FContent do
    FContentList.Add(item);
  FContentListInitialized := True;
end;

{ TCategoryData_Fibbage3PartyPack4 }

function TCategoryData_Fibbage3PartyPack4.GetIsPortrait: Boolean;
begin
  Result := FPortrait;
end;

procedure TCategoryData_Fibbage3PartyPack4.SetIsPortrait(AValue: Boolean);
begin
  FPortrait := AValue;
end;

{ TFibbageCategories_Fibbage4PP9 }

procedure TFibbageCategories_Fibbage4PP9.CopyOtherCategories(const APath: string);
begin
  var dataPath := GetBackupPath(APath);
  var jetFiles := TDirectory.GetFiles(dataPath, '*.jet');

  for var idx := 0 to Length(jetFiles) - 1 do
  begin
    var fileName := ExtractFileName(jetFiles[idx]);

    if fileName = 'fibbageblankie.jet' then
      Continue;

    if fileName = 'fibbagefinalround.jet' then
      Continue;

    var filePath := jetFiles[idx];
    var wantedPath := TPath.Combine(APath, fileName);

    if FileExists(filePath) then
      TFile.Copy(filePath, wantedPath, True)
  end;
end;

function TFibbageCategories_Fibbage4PP9.CreateNewCategory(AType: TQuestionType): ICategory;
begin
  if AType = qtShortie then
    Result := TCategoryDataShortie_Fibbage4PartyPack9.Create
  else
    Result := TCategoryDataFinal_Fibbage4PartyPack9.Create;
  Result.SetId(GetAvailableId);
end;

function TFibbageCategories_Fibbage4PP9.GetShortieCategories(
  const APath: string): ICategories;
begin
  Result := nil;
  if FileExists(APath) then
  begin
    var fs := TFileStream.Create(APath, fmOpenRead);
    var sr := TStreamReader.Create(fs);
    try
      var res := TJson.JsonToObject<TCategoriesShortie_Fibbage4PartyPack9>(sr.ReadToEnd);
      Result := res;
    finally
      sr.Free;
      fs.Free;
    end;
  end
  else
    Result := TCategoriesShortie_Fibbage4PartyPack9.Create;
end;

function TFibbageCategories_Fibbage4PP9.GetFinalCategories(
  const APath: string): ICategories;
begin
  Result := nil;
  if FileExists(APath) then
  begin
    var fs := TFileStream.Create(APath, fmOpenRead);
    var sr := TStreamReader.Create(fs);
    try
      var obj := TJson.JsonToObject<TCategoriesFinal_Fibbage4PartyPack9>(sr.ReadToEnd);
      Result := obj;
    finally
      sr.Free;
      fs.Free;
    end;
  end
  else
    Result := TCategoriesFinal_Fibbage4PartyPack9.Create;
end;

function TFibbageCategories_Fibbage4PP9.GetFinalsJetPath: string;
begin
  Result := TPath.Combine(FContentDir, 'fibbagefinalround.jet');
end;

function TFibbageCategories_Fibbage4PP9.GetShortiesJetPath: string;
begin
  Result := TPath.Combine(FContentDir, 'fibbageblankie.jet');
end;

procedure TFibbageCategories_Fibbage4PP9.Save(const APath: string;
  ASaveOptions: TSaveOptions);
begin
  ShortieCategories.Save(APath, 'fibbageblankie', ASaveOptions);
  FinalCategories.Save(APath, 'fibbagefinalround', ASaveOptions);
  if soActivatingProject in ASaveOptions then
    CopyOtherCategories(APath);
end;

{ TCategories_Fibbage4PartyPack9 }

procedure TCategories_Fibbage4PartyPack9<T>.CopyDataFrom(ASource: ICategories);
begin
  for var idx := Length(FContent) - 1 downto 0 do
    FContent[idx].Free;
  SetLength(FContent, ASource.Count);
  for var idx := 0 to ASource.Count - 1 do
  begin
    FContent[idx] := T.Create;
    FContent[idx].CloneFrom(ASource.Category(idx));
  end;
  InitializeContentList;
end;

function TCategories_Fibbage4PartyPack9<T>.GetJsonToSave(
  ASaveOptions: TSaveOptions): string;
begin
  Result := TJson.ObjectToJsonString(Self);
end;

procedure TCategories_Fibbage4PartyPack9<T>.InitializeContentArray;
begin
  SetLength(FContent, FContentList.Count);
  for var idx := 0 to FContentList.Count - 1 do
  begin
    var item := T.Create;
    item.CloneFrom((FContentList[idx] as ICategory));
    FContent[idx] := item;
  end;
end;

procedure TCategories_Fibbage4PartyPack9<T>.InitializeContentList;
begin
  FContentList.Clear;
  for var item in FContent do
    FContentList.Add(item);
  FContentListInitialized := True;
end;

{ TCategoryDataShortie_Fibbage4PartyPack9 }

function TCategoryDataShortie_Fibbage4PartyPack9.GetAlternateSpelling: string;
begin
  Result := string.Join(',', FAlternateSpellings);
end;

function TCategoryDataShortie_Fibbage4PartyPack9.GetCategory: string;
begin
  Result := FCategory;
end;

function TCategoryDataShortie_Fibbage4PartyPack9.GetCorrectText: string;
begin
  Result := FCorrectText;
end;

function TCategoryDataShortie_Fibbage4PartyPack9.GetId: Integer;
begin
  Result := StrToIntDef(FId, 0);
end;

function TCategoryDataShortie_Fibbage4PartyPack9.GetIsFamilyFriendly: Boolean;
begin
  Result := not FX;
end;

function TCategoryDataShortie_Fibbage4PartyPack9.GetQuestionText: string;
begin
  Result := FQuestionText;
end;

function TCategoryDataShortie_Fibbage4PartyPack9.GetSuggestions: string;
begin
  Result := string.Join(',', FSuggestions);
end;

procedure TCategoryDataShortie_Fibbage4PartyPack9.SetAlternateSpelling(
  const AValue: string);
begin
  FAlternateSpellings := AValue.Split([',']);
end;

procedure TCategoryDataShortie_Fibbage4PartyPack9.SetCategory(
  const ACategory: string);
begin
  FCategory := ACategory;
end;

procedure TCategoryDataShortie_Fibbage4PartyPack9.SetCorrectText(
  const AValue: string);
begin
  FCorrectText := AValue;
end;

procedure TCategoryDataShortie_Fibbage4PartyPack9.SetFamilyFriendly(
  AValue: Boolean);
begin
  FX := not AValue;
end;

procedure TCategoryDataShortie_Fibbage4PartyPack9.SetId(AId: Integer);
begin
  FId := IntToStr(AId);
end;

procedure TCategoryDataShortie_Fibbage4PartyPack9.SetIsFamilyFriendly(
  AValue: Boolean);
begin
  FX := not AValue;
end;

procedure TCategoryDataShortie_Fibbage4PartyPack9.SetQuestionText(
  const AValue: string);
begin
  FQuestionText := AValue;
end;

procedure TCategoryDataShortie_Fibbage4PartyPack9.SetSuggestions(
  const AValue: string);
begin
  FSuggestions := AValue.Split([',']);
end;

{ TCategoryDataFinal_Fibbage4PartyPack9 }

function TCategoryDataFinal_Fibbage4PartyPack9.GetAlternateSpelling1: string;
begin
  Result := string.Join(',', FAlternateSpellings1);
end;

function TCategoryDataFinal_Fibbage4PartyPack9.GetAlternateSpelling2: string;
begin
  Result := string.Join(',', FAlternateSpellings2);
end;

function TCategoryDataFinal_Fibbage4PartyPack9.GetCorrectText1: string;
begin
  Result := FCorrectText1;
end;

function TCategoryDataFinal_Fibbage4PartyPack9.GetCorrectText2: string;
begin
  Result := FCorrectText2;
end;

function TCategoryDataFinal_Fibbage4PartyPack9.GetId: Integer;
begin
  Result := StrToIntDef(FId, 0);
end;

function TCategoryDataFinal_Fibbage4PartyPack9.GetIsFamilyFriendly: Boolean;
begin
  Result := not FX;
end;

function TCategoryDataFinal_Fibbage4PartyPack9.GetQuestionText1: string;
begin
  Result := FQuestionText1;
end;

function TCategoryDataFinal_Fibbage4PartyPack9.GetQuestionText2: string;
begin
  Result := FQuestionText2;
end;

function TCategoryDataFinal_Fibbage4PartyPack9.GetSuggestions: string;
begin
  Result := string.Join(',', FSuggestions);
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetAlternateSpelling1(
  const AValue: string);
begin
  FAlternateSpellings1 := AValue.Split([',']);
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetAlternateSpelling2(
  const AValue: string);
begin
  FAlternateSpellings2 := AValue.Split([',']);
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetCorrectText1(
  const AValue: string);
begin
  FCorrectText1 := AValue;
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetCorrectText2(
  const AValue: string);
begin
  FCorrectText2 := AValue;
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetId(AId: Integer);
begin
  FId := IntToStr(AId);
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetIsFamilyFriendly(
  AValue: Boolean);
begin
  FX := not AValue;
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetQuestionText1(
  const AValue: string);
begin
  FQuestionText1 := AValue;
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetQuestionText2(
  const AValue: string);
begin
  FQuestionText2 := AValue;
end;

procedure TCategoryDataFinal_Fibbage4PartyPack9.SetSuggestions(
  const AValue: string);
begin
  FSuggestions := AValue.Split([',']);
end;

{ TCategoryData }

function TCategoryData.GetBumper: string;
begin
  Result := FBumper;
end;

function TCategoryData.GetCategory: string;
begin
  Result := FCategory;
end;

function TCategoryData.GetId: Integer;
begin
  Result := FId;
end;

function TCategoryData.GetIsFamilyFriendly: Boolean;
begin
  Result := not FX;
end;

procedure TCategoryData.SetBumper(const AValue: string);
begin
  FBumper := AValue;
end;

procedure TCategoryData.SetCategory(const ACategory: string);
begin
  FCategory := ACategory;
end;

procedure TCategoryData.SetFamilyFriendly(AValue: Boolean);
begin
  Fx := not AValue;
end;

procedure TCategoryData.SetId(AId: Integer);
begin
  FId := AId;
end;

procedure TCategoryData.SetIsFamilyFriendly(AValue: Boolean);
begin
  FX := AValue;
end;

end.
