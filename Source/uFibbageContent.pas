unit uFibbageContent;

interface

uses
  uLog,
  System.IOUtils,
  System.SysUtils,
  System.Threading,
  System.Classes,
  uQuestionsLoader,
  uCategoriesLoader,
  uPathChecker,
  uInterfaces;

type
  TFibbageContent = class(TInterfacedObject, IFibbageContent)
  private
    FConfig: IContentConfiguration;
    FCategories: IFibbageCategories;
    FQuestionsLoader: IQuestionsLoader;
    procedure SaveManifest(const APath: string; ASaveOptions: TSaveOptions);
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
  public
    constructor Create(ACategories: IFibbageCategories; AQuestionsLoader: IQuestionsLoader);

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

    procedure RemoveShortieQuestion(AQuestion: IQuestion);
    procedure RemoveFinalQuestion(AQuestion: IQuestion);
  end;

implementation

{ TFibbageContent }

procedure TFibbageContent.AddFinalQuestion;
begin
  var category := FCategories.CreateNewFinalCategory;
  var question := FQuestionsLoader.Questions.CreateNewFinalQuestion;

  question.SetCategoryObj(category);
end;

procedure TFibbageContent.AddShortieQuestion;
begin
  var category := FCategories.CreateNewShortieCategory;
  var question := FQuestionsLoader.Questions.CreateNewShortieQuestion;

  question.SetCategoryObj(category);
end;

function TFibbageContent.Categories: IFibbageCategories;
begin
  Result := FCategories;
end;

procedure TFibbageContent.CopyToFinalQuestions(const AQuestion: IQuestion;
  out ANewQuestion: IQuestion);
begin
  var newQuestion := FQuestionsLoader.Questions.CreateNewFinalQuestion;
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
  var newQuestion := FQuestionsLoader.Questions.CreateNewShortieQuestion;
  newQuestion.CloneFrom(AQuestion);

  var newCategory := FCategories.CreateNewShortieCategory;
  newCategory.CloneFrom(AQuestion.GetCategoryObj);

  newCategory.SetId(FCategories.GetAvailableId);
  newQuestion.SetCategoryObj(newCategory);

  ANewQuestion := newQuestion;
end;

constructor TFibbageContent.Create(ACategories: IFibbageCategories;
  AQuestionsLoader: IQuestionsLoader);
begin
  inherited Create;
  FCategories := ACategories;
  FQuestionsLoader := AQuestionsLoader;
end;

procedure TFibbageContent.DoAssignCategoryToQuestion;
begin
  for var idx := FQuestionsLoader.Questions.ShortieQuestions.Count - 1 downto 0 do
  begin
    var item := FQuestionsLoader.Questions.ShortieQuestions[idx];
    var category := FCategories.GetShortieCategory(item);
    if Assigned(category) then
      item.SetCategoryObj(category)
    else
    begin
      LogE('AssignCategoryToQuestion, have shortie question (%d) without category', [item.GetId]);
      FQuestionsLoader.Questions.ShortieQuestions.Delete(idx);
    end;
  end;

  for var idx := FQuestionsLoader.Questions.FinalQuestions.Count - 1 downto 0 do
  begin
    var item := FQuestionsLoader.Questions.FinalQuestions[idx];
    var category := FCategories.GetFinalCategory(item);
    if Assigned(category) then
      item.SetCategoryObj(category)
    else
    begin
      LogE('AssignCategoryToQuestion, have final question (%d) without category', [item.GetId]);
      FQuestionsLoader.Questions.FinalQuestions.Delete(idx);
    end;
  end;
end;

procedure TFibbageContent.DoAssignQuestionToCategory;
begin
  for var idx := FQuestionsLoader.Questions.ShortieQuestions.Count - 1 downto 0 do
  begin
    var question := FQuestionsLoader.Questions.ShortieQuestions[idx];
    var category := FCategories.GetShortieCategory(question);
    if Assigned(category) then
    begin
      question.SetCategoryObj(category);
      Continue;
    end;

    FQuestionsLoader.Questions.ShortieQuestions.Extract(question);
    FQuestionsLoader.Questions.FinalQuestions.Add(question);
    question.SetQuestionType(qtFinal);

    category := FCategories.GetFinalCategory(question);
    if Assigned(category) then
    begin
      question.SetCategoryObj(category);
      Continue;
    end;

    LogE('AssignQuestionToCategory, have question (%d) without category', [question.GetId]);
    FQuestionsLoader.Questions.FinalQuestions.Extract(question);
  end;
end;

function TFibbageContent.GetPath: string;
begin
  Result := FConfig.GetPath;
end;

procedure TFibbageContent.Initialize(AConfiguration: IContentConfiguration);
begin
  FConfig := AConfiguration;

  FCategories.LoadCategories(GetPath);
  FQuestionsLoader.LoadQuestions(GetPath);
  AssignCategoryToQuestion;
end;

procedure TFibbageContent.AssignCategoryToQuestion;
begin
  if TContentPathChecker.IsPartyPack1(GetPath) then
    DoAssignQuestionToCategory
  else
    DoAssignCategoryToQuestion
end;

function TFibbageContent.Questions: IFibbageQuestions;
begin
  Result := FQuestionsLoader.Questions;
end;

procedure TFibbageContent.RemoveFinalQuestion(AQuestion: IQuestion);
begin
  FCategories.RemoveFinalCategory(AQuestion);
  FQuestionsLoader.Questions.RemoveFinalQuestion(AQuestion);
end;

procedure TFibbageContent.RemoveShortieQuestion(AQuestion: IQuestion);
begin
  FCategories.RemoveShortieCategory(AQuestion);
  FQuestionsLoader.Questions.RemoveShortieQuestion(AQuestion);
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
  if TContentPathChecker.IsPartyPack1(APath) then
    ASaveOptions := ASaveOptions + [soPartyPack1];
  PreSave(APath);
  try
    if not (soDoNotSaveConfig in ASaveOptions) then
      FConfig.Save(APath);
    
    FQuestionsLoader.Questions.Save(APath, ASaveOptions);
    FCategories.Save(APath, ASaveOptions);
    SaveManifest(APath, ASaveOptions);

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
  FQuestionsLoader.Questions.FinalQuestions.Add(AQuestion);
  FQuestionsLoader.Questions.ShortieQuestions.Remove(AQuestion);
end;

procedure TFibbageContent.MoveToShortieQuestions(const AQuestion: IQuestion);
begin
  FCategories.RemoveFinalCategory(AQuestion);
  var category := FCategories.CreateNewShortieCategory;
  category.CloneFrom(AQuestion.GetCategoryObj);

  AQuestion.SetQuestionType(qtShortie);
  FQuestionsLoader.Questions.ShortieQuestions.Add(AQuestion);
  FQuestionsLoader.Questions.FinalQuestions.Remove(AQuestion);
end;

procedure TFibbageContent.Save;
begin
  InnerSave(FConfig.GetPath);
end;

procedure TFibbageContent.SaveManifest(const APath: string; ASaveOptions: TSaveOptions);
begin
  if soPartyPack1 in ASaveOptions then
    Exit;
  var fs := TFileStream.Create(TPath.Combine(APath, 'manifest.jet'), fmCreate);
  var sw := TStreamWriter.Create(fs);
  try
    sw.WriteLine('{ "id":"Main", "name":"Main Content Pack", "types":["fibbageshortie","finalfibbage"] }');
  finally
    sw.Free;
    fs.Free;
  end;
end;

procedure TFibbageContent.Save(const APath: string; ASaveOptions: TSaveOptions = []);
begin
  InnerSave(APath, ASaveOptions);
end;

end.
