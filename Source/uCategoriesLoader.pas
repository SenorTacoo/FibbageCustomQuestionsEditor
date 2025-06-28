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
  private
    FX: Boolean;
    FId: Integer;
    FCategory: string;
    FBumper: string;
  public
    procedure CloneFrom(AObj: ICategory);

    function GetId: Integer;
    function GetCategory: string;
    function GetIsFamilyFriendly: Boolean;
    function GetIsPortrait: Boolean; virtual;
    function GetBumper: string;

    procedure SetId(AId: Integer);
    procedure SetCategory(const ACategory: string);
    procedure SetIsFamilyFriendly(AValue: Boolean);
    procedure SetIsPortrait(AValue: Boolean); virtual;
    procedure SetBumper(const AValue: string);
  end;

  TCategoryData_FibbageXL = class(TCategoryDataBase);

  TCategoryData_Fibbage3PartyPack4 = class(TCategoryDataBase)
  private
    FPersonal: string;
    FPortrait: Boolean;
    FUs: Boolean;
  public
    procedure SetIsPortrait(AValue: Boolean); override;
    function GetIsPortrait: Boolean; override;
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

  TFibbageCategoriesBase = class(TInterfacedObject, IFibbageCategories)
  private
    FContentDir: string;
    FShortieCategories: ICategories;
    FFinalCategories: ICategories;
    procedure LoadFinalCategories;
    procedure LoadShortieCategories;
    function GetAvailableId: Word;
    function GetFinalsJetPath: string;
  protected
    function GetShortiesJetPath: string; virtual;
    function GetCategories(const APath: string): ICategories; virtual;
    function CreateNewCategory: ICategory; virtual; abstract;
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
    function CreateNewCategory: ICategory; override;
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

  TFibbageCategories_FibbageXLPP1 = class(TFibbageCategories_FibbageXL)
  private
    procedure SaveDemoShortieCategories(const APath: string);
    procedure SaveDemoFinalCategories(const APath: string);
  protected
    function GetShortiesJetPath: string; override;
    function GetCategories(const APath: string): ICategories; override;
  public
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); override;
  end;

  TFibbageCategories_Fibbage3PP4 = class(TFibbageCategories_FibbageXL)
  private
    procedure SaveSpecialCategories(const APath: string; ASaveOptions: TSaveOptions);
    procedure SavePersonalShortieCategories(const APath: string; ASaveOptions: TSaveOptions);
  protected
    function GetCategories(const APath: string): ICategories; override;
    function CreateNewCategory: ICategory; override;
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
  var newCategory := CreateNewCategory;
  FFinalCategories.Add(newCategory);
  Result := newCategory;
end;

function TFibbageCategoriesBase.CreateNewShortieCategory: ICategory;
begin
  var newCategory := CreateNewCategory;
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
  FShortieCategories := GetCategories(GetShortiesJetPath);
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
  FFinalCategories := GetCategories(GetFinalsJetPath);
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

function TFibbageCategoriesBase.GetCategories(const APath: string): ICategories;
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
end;

function TCategoryDataBase.GetBumper: string;
begin
  Result := FBumper;
end;

function TCategoryDataBase.GetCategory: string;
begin
  Result := FCategory;
end;

function TCategoryDataBase.GetId: Integer;
begin
  Result := FId;
end;

function TCategoryDataBase.GetIsFamilyFriendly: Boolean;
begin
  Result := not FX;
end;

function TCategoryDataBase.GetIsPortrait: Boolean;
begin
  Result := False;
end;

procedure TCategoryDataBase.SetBumper(const AValue: string);
begin
  FBumper := AValue;
end;

procedure TCategoryDataBase.SetCategory(const ACategory: string);
begin
  FCategory := ACategory;
end;

procedure TCategoryDataBase.SetId(AId: Integer);
begin
  FId := AId;
end;

procedure TCategoryDataBase.SetIsFamilyFriendly(AValue: Boolean);
begin
  FX := not AValue;
end;

procedure TCategoryDataBase.SetIsPortrait;
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

function TFibbageCategories_FibbageXLPP1.GetCategories(
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

function TFibbageCategories_Fibbage3PP4.CreateNewCategory: ICategory;
begin
  Result := TCategoryData_Fibbage3PartyPack4.Create;
  Result.SetId(GetAvailableId);
end;

function TFibbageCategories_Fibbage3PP4.GetCategories(
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

function TFibbageCategories_FibbageXL.CreateNewCategory: ICategory;
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

end.
