unit uFibbageContent;

interface

uses
  uLog,
  System.IOUtils,
  System.SysUtils,
  System.Threading,
  System.Classes,
  System.JSON,
  System.JSON.Builders,
  System.JSON.Writers,
  uQuestionsLoader,
  uCategoriesLoader,
  uPathChecker,
  uInterfaces;

type
  TFibbageContent = class(TInterfacedObject, IFibbageContent)
  private
    FConfig: IContentConfiguration;
    FCategories: IFibbageCategories;
    FQuestions: IFibbageQuestions;

    procedure SaveManifest(const APath: string);
    procedure PrepareBackup(const APath: string);
    procedure RemoveBackup(const APath: string);
    procedure RestoreBackup(const APath: string);
    procedure PostSaveFailed(const APath: string);
    procedure PostSaveSuccessful(const APath: string);
    procedure PreSave(const APath: string);
    procedure InnerSave(const APath: string; ASaveOptions: TSaveOptions = []);
    procedure AssignCategoryToQuestion;
    procedure DoAssignCategoryToQuestion;
    procedure DoAssignQuestionToCategory;
    procedure CreateProperObjects;
  public
    function Questions: IFibbageQuestions;
    function Categories: IFibbageCategories;
    function GetPath: string;

    procedure Initialize(AConfiguration: IContentConfiguration);

    procedure Save; overload;
    procedure Save(const APath: string; ASaveOptions: TSaveOptions = []); overload;

    procedure CopyToFinalQuestions(const AQuestion: IQuestion; out ANewQuestion: IQuestion);
    procedure CopyToShortieQuestions(const AQuestion: IQuestion; out ANewQuestion: IQuestion);
    procedure MoveToFinalQuestions(const AQuestion: IQuestion);
    procedure MoveToShortieQuestions(const AQuestion: IQuestion);

    procedure AddShortieQuestion;
    procedure AddFinalQuestion;
    procedure AddSpecialQuestion;

    procedure RemoveShortieQuestion(AQuestion: IQuestion);
    procedure RemoveFinalQuestion(AQuestion: IQuestion);
    procedure RemoveSpecialQuestion(AQuestion: IQuestion);
  end;

implementation

{ TFibbageContent }

procedure TFibbageContent.AddFinalQuestion;
begin
  var category := FCategories.CreateNewFinalCategory;
  var question := FQuestions.CreateNewFinalQuestion;

  question.SetCategoryObj(category);
end;

procedure TFibbageContent.AddShortieQuestion;
begin
  var category := FCategories.CreateNewShortieCategory;
  var question := FQuestions.CreateNewShortieQuestion;

  question.SetCategoryObj(category);
end;

procedure TFibbageContent.AddSpecialQuestion;
begin
  var category := FCategories.CreateNewSpecialCategory;
  var question := FQuestions.CreateNewSpecialQuestion;

  question.SetCategoryObj(category);
end;

function TFibbageContent.Categories: IFibbageCategories;
begin
  Result := FCategories;
end;

procedure TFibbageContent.CopyToFinalQuestions(const AQuestion: IQuestion;
  out ANewQuestion: IQuestion);
begin
  var newQuestion := FQuestions.CreateNewFinalQuestion;
  newQuestion.CloneFrom(AQuestion);

  var newCategory := FCategories.CreateNewFinalCategory;
  newCategory.CloneFrom(AQuestion.GetCategoryObj);

  newCategory.SetId(FCategories.GetAvailableId);
  newQuestion.SetCategoryObj(newCategory);

  ANewQuestion := newQuestion;
end;

procedure TFibbageContent.CopyToShortieQuestions(const AQuestion: IQuestion;
  out ANewQuestion: IQuestion);
begin
  var newQuestion := FQuestions.CreateNewShortieQuestion;
  newQuestion.CloneFrom(AQuestion);

  var newCategory := FCategories.CreateNewShortieCategory;
  newCategory.CloneFrom(AQuestion.GetCategoryObj);

  newCategory.SetId(FCategories.GetAvailableId);
  newQuestion.SetCategoryObj(newCategory);

  ANewQuestion := newQuestion;
end;

procedure TFibbageContent.CreateProperObjects;
begin
  case FConfig.GetGameType of
    TGameType.FibbageXL:
      begin
        FCategories := TFibbageCategories_FibbageXL.Create;
        FQuestions := TQuestionsFibbageXL.Create;
      end;
    TGameType.FibbageXLPartyPack1:
      begin
        FCategories := TFibbageCategories_FibbageXLPP1.Create;
        FQuestions:= TQuestionsFibbageXLPP1.Create;
      end;
    TGameType.Fibbage3PartyPack4:
      begin
        FCategories := TFibbageCategories_Fibbage3PP4.Create;
        FQuestions := TQuestionsFibbage3PP4.Create;
      end;
    else
      raise Exception.Create('Unknown game type');
  end;
end;

procedure TFibbageContent.DoAssignCategoryToQuestion;
begin
  for var idx := FQuestions.ShortieQuestions.Count - 1 downto 0 do
  begin
    var item := FQuestions.ShortieQuestions[idx];
    var category := FCategories.GetShortieCategory(item);
    if Assigned(category) then
      item.SetCategoryObj(category)
    else
    begin
      LogE('AssignCategoryToQuestion, have shortie question (%d) without category', [item.GetId]);
      FQuestions.ShortieQuestions.Delete(idx);
    end;
  end;

  for var idx := FQuestions.FinalQuestions.Count - 1 downto 0 do
  begin
    var item := FQuestions.FinalQuestions[idx];
    var category := FCategories.GetFinalCategory(item);
    if Assigned(category) then
      item.SetCategoryObj(category)
    else
    begin
      LogE('AssignCategoryToQuestion, have final question (%d) without category', [item.GetId]);
      FQuestions.FinalQuestions.Delete(idx);
    end;
  end;

  if FConfig.GetGameType <> TGameType.Fibbage3PartyPack4 then
    Exit;

  for var idx := FQuestions.SpecialQuestions.Count - 1 downto 0 do
  begin
    var item := FQuestions.SpecialQuestions[idx];
    var category := FCategories.GetSpecialCategory(item);
    if Assigned(category) then
      item.SetCategoryObj(category)
    else
    begin
      LogE('AssignCategoryToQuestion, have special question (%d) without category', [item.GetId]);
      FQuestions.SpecialQuestions.Delete(idx);
    end;
  end;
end;

procedure TFibbageContent.DoAssignQuestionToCategory;
begin
  for var idx := FQuestions.ShortieQuestions.Count - 1 downto 0 do
  begin
    var question := FQuestions.ShortieQuestions[idx];
    var category := FCategories.GetShortieCategory(question);
    if Assigned(category) then
    begin
      question.SetCategoryObj(category);
      Continue;
    end;

    FQuestions.ShortieQuestions.Extract(question);
    FQuestions.FinalQuestions.Add(question);
    question.SetQuestionType(qtFinal);

    category := FCategories.GetFinalCategory(question);
    if Assigned(category) then
    begin
      question.SetCategoryObj(category);
      Continue;
    end;

    LogE('AssignQuestionToCategory, have question (%d) without category', [question.GetId]);
    FQuestions.FinalQuestions.Extract(question);
  end;
end;

function TFibbageContent.GetPath: string;
begin
  Result := FConfig.GetPath;
end;

procedure TFibbageContent.Initialize(AConfiguration: IContentConfiguration);
begin
  FConfig := AConfiguration;

  CreateProperObjects;

  FCategories.LoadCategories(GetPath);
  FQuestions.LoadQuestions(GetPath);
  AssignCategoryToQuestion;
end;

procedure TFibbageContent.AssignCategoryToQuestion;
begin
  if FConfig.GetGameType = TGameType.FibbageXLPartyPack1 then
    DoAssignQuestionToCategory
  else
    DoAssignCategoryToQuestion
end;

function TFibbageContent.Questions: IFibbageQuestions;
begin
  Result := FQuestions;
end;

procedure TFibbageContent.RemoveFinalQuestion(AQuestion: IQuestion);
begin
  FCategories.RemoveFinalCategory(AQuestion);
  FQuestions.RemoveFinalQuestion(AQuestion);
end;

procedure TFibbageContent.RemoveShortieQuestion(AQuestion: IQuestion);
begin
  FCategories.RemoveShortieCategory(AQuestion);
  FQuestions.RemoveShortieQuestion(AQuestion);
end;

procedure TFibbageContent.RemoveSpecialQuestion(AQuestion: IQuestion);
begin
  FCategories.RemoveSpecialCategory(AQuestion);
  FQuestions.RemoveSpecialQuestion(AQuestion);
end;

procedure TFibbageContent.PrepareBackup(const APath: string);
begin
  if DirectoryExists(APath) then
  begin
    if DirectoryExists(APath + '_backup') then
      TDirectory.Delete(APath + '_backup', True);
    TDirectory.Move(APath, APath + '_backup');
  end;
end;

procedure TFibbageContent.RemoveBackup(const APath: string);
begin
  if DirectoryExists(APath + '_backup') then
    TDirectory.Delete(APath + '_backup', True);
end;

procedure TFibbageContent.RestoreBackup(const APath: string);
begin
  if DirectoryExists(APath + '_backup') then
  begin
    if TDirectory.Exists(APath) then
      TDirectory.Delete(APath);
    TDirectory.Move(APath + '_backup', APath);
  end;
end;

procedure TFibbageContent.PreSave(const APath: string);
begin
  PrepareBackup(APath);
end;

procedure TFibbageContent.PostSaveSuccessful(const APath: string);
begin
  RemoveBackup(APath);
end;

procedure TFibbageContent.PostSaveFailed(const APath: string);
begin
  RestoreBackup(APath);
end;

procedure TFibbageContent.InnerSave(const APath: string; ASaveOptions: TSaveOptions = []);
begin
//  if TContentPathChecker.IsPartyPack1(APath) then
//    ASaveOptions := ASaveOptions + [soPartyPack1]; //???
  PreSave(APath);
  try
    if not (soDoNotSaveConfig in ASaveOptions) then
      FConfig.Save(APath);
    
    FQuestions.Save(APath, ASaveOptions);
    FCategories.Save(APath, ASaveOptions);
    SaveManifest(APath);

    PostSaveSuccessful(APath);
  except
    on E: Exception do
    begin
      LogE('save exception %s/%s', [E.Message, E.ClassName]);
      PostSaveFailed(APath);
    end;
  end;
end;

procedure TFibbageContent.MoveToFinalQuestions(const AQuestion: IQuestion);
begin
  FCategories.RemoveShortieCategory(AQuestion);
  var category := FCategories.CreateNewFinalCategory;
  category.CloneFrom(AQuestion.GetCategoryObj);

  AQuestion.SetQuestionType(qtFinal);
  FQuestions.FinalQuestions.Add(AQuestion);
  FQuestions.ShortieQuestions.Remove(AQuestion);
end;

procedure TFibbageContent.MoveToShortieQuestions(const AQuestion: IQuestion);
begin
  FCategories.RemoveFinalCategory(AQuestion);
  var category := FCategories.CreateNewShortieCategory;
  category.CloneFrom(AQuestion.GetCategoryObj);

  AQuestion.SetQuestionType(qtShortie);
  FQuestions.ShortieQuestions.Add(AQuestion);
  FQuestions.FinalQuestions.Remove(AQuestion);
end;

procedure TFibbageContent.Save;
begin
  InnerSave(FConfig.GetPath);
end;

procedure TFibbageContent.SaveManifest(const APath: string);
begin
  if FConfig.GetGameType = TGameType.FibbageXLPartyPack1 then
    Exit;

  var fs := TFileStream.Create(TPath.Combine(APath, 'manifest.jet'), fmCreate);
  var jw := TJsonTextWriter.Create(fs);
  var job := TJSONObjectBuilder.Create(jw);
  try
    var jsonObj := job.BeginObject;

    var typesArray := jsonObj
      .Add('id', 'Main')
      .Add('name', 'Main Content Pack')
      .BeginArray('types');

    typesArray
        .Add('fibbageshortie')
        .Add('finalfibbage');

    if FConfig.GetGameType = TGameType.Fibbage3PartyPack4 then
      typesArray.Add('fibbagespecial');

    typesArray.EndArray;

    jsonObj.EndObject;
  finally
    job.Free;
    jw.Free;
    fs.Free;
  end;
end;

procedure TFibbageContent.Save(const APath: string; ASaveOptions: TSaveOptions = []);
begin
  InnerSave(APath, ASaveOptions);
end;

end.
