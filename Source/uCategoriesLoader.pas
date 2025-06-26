unit uCategoriesLoader;

interface

uses
  REST.JSON,
  REST.Json.Types,
  System.JSON,
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.Generics.Collections,
  uPathChecker,
  uInterfaces;

type
  TCategoryData = class(TInterfacedObject, ICategory)
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

    procedure SetId(AId: Integer);
    procedure SetCategory(const ACategory: string);
    procedure SetIsFamilyFriendly(AValue: Boolean);

    function Bumper: string;
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
    function EpisodeId: Integer;

    procedure Add(ACategory: ICategory);
    procedure Delete(AId: Integer);

    procedure Save(const APath, AName: string; ASaveOptions: TSaveOptions);
  end;

  TCategories_FibbageXL = class(TBaseCategories)
  private
    FContent: TArray<TCategoryData>;
  protected
    procedure InitializeContentList; override;
    procedure InitializeContentArray; override;
    function GetJsonToSave(ASaveOptions: TSaveOptions): string; override;
  end;

  TCategories_PartyPack1 = class(TBaseCategories)
  private
    FQuestions: TArray<TCategoryData>;
  protected
    procedure InitializeContentList; override;
    procedure InitializeContentArray; override;
    function GetJsonToSave(ASaveOptions: TSaveOptions): string; override;
  end;

  TFibbageCategoriesBase = class(TInterfacedObject, IFibbageCategories)
  private
    FContentDir: string;
    FShortieCategories: ICategories;
    FFinalCategories: ICategories;
    procedure LoadFinalCategories;
    procedure LoadShortieCategories;
    function CreateNewCategory: ICategory;
    function GetAvailableId: Word;
    function GetFinalsJetPath: string;
  protected
    function GetShortiesJetPath: string; virtual;
    function GetCategories(const APath: string): ICategories; virtual;
    procedure DoLoadCategories; virtual;
  public
    function ShortieCategories: ICategories;
    function FinalCategories: ICategories;

    function GetShortieCategory(AQuestion: IQuestion): ICategory;
    function GetFinalCategory(AQuestion: IQuestion): ICategory;

    procedure LoadCategories(const AContentDir: string);
    function CreateNewShortieCategory: ICategory;
    function CreateNewFinalCategory: ICategory;
    procedure RemoveShortieCategory(AQuestion: IQuestion);
    procedure RemoveFinalCategory(AQuestion: IQuestion);
    procedure Save(const APath: string; ASaveOptions: TSaveOptions);
  end;

  TFibbageCategories_FibbageXL = class(TFibbageCategoriesBase)

  end;

  TFibbageCategories_FibbageXLPP1 = class(TFibbageCategoriesBase)
  protected
    function GetShortiesJetPath: string; override;
    function GetCategories(const APath: string): ICategories; override;

  end;

  TFibbageCategories_Fibbage3PP4 = class(TFibbageCategoriesBase)

  end;


implementation

{ TFibbageCategoriesBase }

function TFibbageCategoriesBase.CreateNewCategory: ICategory;
begin
  Result := TCategoryData.Create;
  Result.SetId(GetAvailableId);
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

function TFibbageCategoriesBase.GetCategories(const APath: string): ICategories;
var
  res: TBaseCategories;
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
var
  bestCategory: ICategory;
begin
  Result := nil;
  for var idx := 0 to FFinalCategories.Count - 1 do
  begin
    var category := FFinalCategories.Category(idx);
    if (AQuestion.GetId = category.GetId) then
      if SameText(AQuestion.GetCategory, category.GetCategory) then
        Exit(category)
      else
        bestCategory := category;
  end;
  Result := bestCategory;
end;

function TFibbageCategoriesBase.GetFinalsJetPath: string;
begin
  Result := IncludeTrailingPathDelimiter(FContentDir) + 'finalfibbage.jet';
end;

function TFibbageCategoriesBase.GetShortieCategory(AQuestion: IQuestion): ICategory;
var
  bestCategory: ICategory;
begin
  bestCategory := nil;
  for var idx := 0 to FShortieCategories.Count - 1 do
  begin
    var category := FShortieCategories.Category(idx);
    if (AQuestion.GetId = category.GetId) then
      if SameText(AQuestion.GetCategory, category.GetCategory) then
        Exit(category)
      else
        bestCategory := category;
  end;
  Result := bestCategory;
end;

function TFibbageCategoriesBase.GetShortiesJetPath: string;
begin
  Result := IncludeTrailingPathDelimiter(FContentDir) + 'fibbageshortie.jet';
end;

procedure TFibbageCategoriesBase.LoadCategories(const AContentDir: string);
begin
  FContentDir := AContentDir;

  DoLoadCategories;
end;

procedure TFibbageCategoriesBase.Save(const APath: string; ASaveOptions: TSaveOptions);
begin
  if soPartyPack1 in ASaveOptions then
    ShortieCategories.Save(APath, 'shortie', ASaveOptions)
  else
    ShortieCategories.Save(APath, 'fibbageshortie', ASaveOptions);
  FinalCategories.Save(APath, 'finalfibbage', ASaveOptions);
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

function TBaseCategories.EpisodeId: Integer;
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

  if not (soPartyPack1 in ASaveOptions) then
    Exit;

  var demo := TCategories_PartyPack1.Create;
  try
    demo.FEpisodeId := FEpisodeId;
    fs := TFileStream.Create(TPath.Combine(APath, 'demo' + AName + '.jet'), fmCreate);
    sw := TStreamWriter.Create(fs);
    try
      sw.WriteLine(demo.GetJsonToSave(ASaveOptions));
    finally
      sw.Free;
      fs.Free;
    end;
  finally
    demo.Free;
  end;
end;

{ TCategoryData }

function TCategoryData.Bumper: string;
begin
  Result := FBumper;
end;

procedure TCategoryData.CloneFrom(AObj: ICategory);
begin
  SetId(AObj.GetId);
  SetCategory(AObj.GetCategory);
  SetIsFamilyFriendly(AObj.GetIsFamilyFriendly);
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

procedure TCategoryData.SetCategory(const ACategory: string);
begin
  FCategory := ACategory;
end;

procedure TCategoryData.SetId(AId: Integer);
begin
  FId := AId;
end;

procedure TCategoryData.SetIsFamilyFriendly(AValue: Boolean);
begin
  FX := not AValue;
end;

{ TCategories_FibbageXL }

function TCategories_FibbageXL.GetJsonToSave(
  ASaveOptions: TSaveOptions): string;
begin
  if not (soPartyPack1 in ASaveOptions) then
    Exit(TJson.ObjectToJsonString(Self));

  var pp1Categories := TCategories_PartyPack1.Create;
  try
    pp1Categories.FEpisodeId := FEpisodeId;
    pp1Categories.FQuestions := FContent;
    Result := pp1Categories.GetJsonToSave(ASaveOptions);
  finally
    pp1Categories.Free;
  end;
end;

procedure TCategories_FibbageXL.InitializeContentArray;
begin
  SetLength(FContent, FContentList.Count);
  for var idx := 0 to FContentList.Count - 1 do
  begin
    var item := TCategoryData.Create;
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

{ TCategories_PartyPack1 }

function TCategories_PartyPack1.GetJsonToSave(
  ASaveOptions: TSaveOptions): string;
var
  questions: TJSONArray;
begin
  if soPartyPack1 in ASaveOptions then
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

  var fxlCategories := TCategories_FibbageXL.Create;
  try
    fxlCategories.FEpisodeId := FEpisodeId;
    fxlCategories.FContent := FQuestions;
    Result := fxlCategories.GetJsonToSave(ASaveOptions);
  finally
    fxlCategories.Free;
  end;
end;

procedure TCategories_PartyPack1.InitializeContentArray;
begin
  SetLength(FQuestions, FContentList.Count);
  for var idx := 0 to FContentList.Count - 1 do
  begin
    var item := TCategoryData.Create;
    item.CloneFrom((FContentList[idx] as ICategory));
    FQuestions[idx] := item;
  end;
end;

procedure TCategories_PartyPack1.InitializeContentList;
begin
  FContentList.Clear;
  for var item in FQuestions do
    FContentList.Add(item);
  FContentListInitialized := True;
end;

{ TFibbageCategories_FibbageXLPP1 }

function TFibbageCategories_FibbageXLPP1.GetCategories(
  const APath: string): ICategories;
var
  res: TBaseCategories;
begin
  Result := nil;
  if FileExists(APath) then
  begin
    var fs := TFileStream.Create(APath, fmOpenRead);
    var sr := TStreamReader.Create(fs);
    try
      Result := TJson.JsonToObject<TCategories_PartyPack1>(sr.ReadToEnd)
    finally
      sr.Free;
      fs.Free;
    end;
  end
  else
    Result := TCategories_PartyPack1.Create
end;

function TFibbageCategories_FibbageXLPP1.GetShortiesJetPath: string;
begin
  Result := IncludeTrailingPathDelimiter(FContentDir) + 'shortie.jet'
end;

end.
