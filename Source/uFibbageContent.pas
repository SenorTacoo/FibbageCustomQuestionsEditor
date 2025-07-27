unit uFibbageContent;

interface

uses
  System.Generics.Collections,
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.JSON.Builders,
  uContentConfiguration,
  uQuestionsLoader,
  uFibbageFilesReader,
  uFibbageJSONWriter,
  uInterfaces;

type
  TFibbageContent = class abstract
  protected
    FConfiguration: TContentConfiguration;
    FFilesReader: TFibbageFilesReader;

    function DoInitialize: Boolean; virtual; abstract;
  public
    constructor Create(ACfg: TContentConfiguration);
    destructor Destroy; override;

    function Initialize: Boolean;
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); overload;
    procedure Save; overload; virtual; abstract;

    function CreateNewQuestion(const AType: string): TFibbageQuestion; virtual; abstract;
    procedure RemoveQuestion(const AType: string; AQuestion: TFibbageQuestion); virtual; abstract;

    procedure CopyQuestion(const AType: string; AQuestion: TFibbageQuestion); virtual; abstract;
    procedure MoveQuestion(const ASrcType, ADstType: string; AQuestion: TFibbageQuestion); virtual; abstract;

    function GetEditableTypes: TStringList; virtual; abstract;
    procedure ForEachQuestion(const AType: string; AProc: TProc<TFibbageQuestion>); virtual; abstract;

    function GetQuestionWithTooFewSuggestions(out AType: string; out AQuestion: TFibbageQuestion): Boolean; virtual; abstract;
    function HasDuplicatedCategory(const AType: string; AQuestion: TFibbageQuestion): Boolean; overload; virtual; abstract;
    function HasDuplicatedCategory(out AType, ACategory: string; out AQuestion: TFibbageQuestion): Boolean; overload; virtual; abstract;
    function HasTooFewSuggestions(const AType: string; AQuestion: TFibbageQuestion): Boolean; virtual; abstract;
    function HasMissingBlanks(const AType: string; AQuestion: TFibbageQuestion; out AError: string): Boolean; virtual; abstract;
    function HasTooFewShortieQuestions(out AType: string; out AMinCount: UInt32): Boolean; virtual; abstract;
  end;

  TFibbageXLContent = class(TFibbageContent)
  private
    FShortieQuestions: TFibbageXLQuestions_Shortie;
    FFinalQuestions: TFibbageXLQuestions_Final;

    function GetManifestJSON: string;
    procedure SaveManifest(const APath: string);
  protected
    function DoInitialize: Boolean; override;
  public
    constructor Create(ACfg: TContentConfiguration);
    destructor Destroy; override;

    function GetEditableTypes: TStringList; override;
    procedure ForEachQuestion(const AType: string; AProc: TProc<TFibbageQuestion>); override;
    function CreateNewQuestion(const AType: string): TFibbageQuestion; override;
    procedure RemoveQuestion(const AType: string; AQuestion: TFibbageQuestion); override;

    procedure CopyQuestion(const AType: string; AQuestion: TFibbageQuestion); override;
    procedure MoveQuestion(const ASrcType, ADstType: string; AQuestion: TFibbageQuestion); override;

    procedure Save; override;

    function GetQuestionWithTooFewSuggestions(out AType: string; out AQuestion: TFibbageQuestion): Boolean; override;
    function HasDuplicatedCategory(const AType: string; AQuestion: TFibbageQuestion): Boolean; overload; override;
    function HasDuplicatedCategory(out AType, ACategory: string; out AQuestion: TFibbageQuestion): Boolean; overload; override;
    function HasTooFewSuggestions(const AType: string; AQuestion: TFibbageQuestion): Boolean; override;
    function HasMissingBlanks(const AType: string; AQuestion: TFibbageQuestion; out AError: string): Boolean; override;
    function HasTooFewShortieQuestions(out AType: string; out AMinCount: UInt32): Boolean; override;
  end;

implementation

{ TFibbageContent }

constructor TFibbageContent.Create(ACfg: TContentConfiguration);
begin
  inherited Create;
  FFilesReader := TFibbageFilesReader.Create(ACfg.GetPath);
  FConfiguration := ACfg;
end;

destructor TFibbageContent.Destroy;
begin
  FFilesReader.Free;
  inherited;
end;

function TFibbageContent.Initialize: Boolean;
begin
  Result := DoInitialize;
end;

procedure TFibbageContent.Save(const APath: string; ASaveOptions: TSaveOptions);
begin

end;

{ TFibbageXLContent }

function TFibbageXLContent.CreateNewQuestion(
  const AType: string): TFibbageQuestion;
begin
  Result := nil;
  if AType = FShortieQuestions.GetName then
    Result := FShortieQuestions.CreateNewQuestion
  else if AType = FFinalQuestions.GetName then
    Result := FFinalQuestions.CreateNewQuestion
  else
    Assert(False);
end;

procedure TFibbageXLContent.CopyQuestion(const AType: string;
  AQuestion: TFibbageQuestion);
var
  question: TFibbageXLQuestion;
begin
  if FShortieQuestions.GetName = AType then
    question := FShortieQuestions.CreateNewQuestion
  else if FFinalQuestions.GetName = AType then
    question := FFinalQuestions.CreateNewQuestion
  else
  begin
    Assert(False);
    Exit;
  end;
  question.Assign(AQuestion);
end;

constructor TFibbageXLContent.Create(ACfg: TContentConfiguration);
begin
  inherited Create(ACfg);
  FShortieQuestions := TFibbageXLQuestions_Shortie.Create;
  FFinalQuestions := TFibbageXLQuestions_Final.Create;
end;

destructor TFibbageXLContent.Destroy;
begin
  FShortieQuestions.Free;
  FFinalQuestions.Free;
  inherited;
end;

function TFibbageXLContent.DoInitialize: Boolean;
begin
  if not FConfiguration.NewContent then
  begin
    FShortieQuestions.Initialize(FFilesReader);
    FFinalQuestions.Initialize(FFilesReader);
  end;
  Result := True;
end;

procedure TFibbageXLContent.ForEachQuestion(const AType: string;
  AProc: TProc<TFibbageQuestion>);
begin
  if AType = FShortieQuestions.GetName then
  begin
    for var idx := 0 to FShortieQuestions.Count - 1 do
      AProc(FShortieQuestions[idx]);
  end
  else if AType = FFinalQuestions.GetName then
  begin
    for var idx := 0 to FFinalQuestions.Count - 1 do
      AProc(FFinalQuestions[idx]);
  end
  else
    Assert(False);
end;

function TFibbageXLContent.GetEditableTypes: TStringList;
begin
  Result := TStringList.Create;
  Result.Add(FShortieQuestions.GetName);
  Result.Add(FFinalQuestions.GetName);
end;

function TFibbageXLContent.GetManifestJSON: string;
begin
  var builder := TFibbageJSONBuilder.Create;
  try
    builder.BeginObject
      .Add('id', 'Main')
      .Add('name', 'Main Content Pack')
      .BeginArray('types')
        .Add(FShortieQuestions.GetName)
        .Add(FFinalQuestions.GetName)
      .EndArray
    .EndObject;
    Result := builder.Build;
  finally
    builder.Free;
  end;
end;

function TFibbageXLContent.GetQuestionWithTooFewSuggestions(out AType: string;
  out AQuestion: TFibbageQuestion): Boolean;
var
  questionList: TFibbageXLQuestions;
begin
  Result := False;
  for questionList in [FShortieQuestions, FFinalQuestions] do
  begin
    var question := questionList.GetFirstQuestionWithTooFewSuggestions;
    if Assigned(question) then
    begin
      AType := questionList.GetName;
      AQuestion := question;
      Exit(True);
    end;
  end;
end;

function TFibbageXLContent.HasDuplicatedCategory(const AType: string;
  AQuestion: TFibbageQuestion): Boolean;
begin
  Result := False;
  if AType = FShortieQuestions.GetName then
    Result := FShortieQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbageXLQuestion)
  else if AType = FFinalQuestions.GetName then
    Result := FFinalQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbageXLQuestion)
  else
    Assert(False);
end;

function TFibbageXLContent.HasDuplicatedCategory(out AType, ACategory: string;
  out AQuestion: TFibbageQuestion): Boolean;
var
  questionList: TFibbageXLQuestions;
begin
  Result := False;
  for questionList in [FShortieQuestions, FFinalQuestions] do
  begin
    var question := questionList.GetFirstQuestionWithDuplicatedCategory;
    if Assigned(question) then
    begin
      AType := questionList.GetName;
      ACategory := question.Category;
      AQuestion := question;
      Exit(True);
    end;
  end;
end;

function TFibbageXLContent.HasMissingBlanks;
begin
  // DO SPRAWDZENIA
  Result := False;
end;

function TFibbageXLContent.HasTooFewShortieQuestions(out AType: string;
  out AMinCount: UInt32): Boolean;
const
  MIN_NR_OF_SHORTIE_QUESTIONS = 6;
begin
  if FShortieQuestions.Count >= MIN_NR_OF_SHORTIE_QUESTIONS then
    Exit(False);

  AType := FShortieQuestions.GetName;
  AMinCount := MIN_NR_OF_SHORTIE_QUESTIONS;
  Result := True;
end;

function TFibbageXLContent.HasTooFewSuggestions(const AType: string;
  AQuestion: TFibbageQuestion): Boolean;
const
  OPTIMAL_SUGGESTIONS_NR = 17;
begin
  Result := (AQuestion as TFibbageXLQuestion).SuggestionsCount < OPTIMAL_SUGGESTIONS_NR;
end;

procedure TFibbageXLContent.MoveQuestion(const ASrcType, ADstType: string;
  AQuestion: TFibbageQuestion);
begin
  CopyQuestion(ADstType, AQuestion);
  RemoveQuestion(ASrcType, AQuestion);
end;

procedure TFibbageXLContent.RemoveQuestion(const AType: string;
  AQuestion: TFibbageQuestion);
begin
  if AType = FShortieQuestions.GetName then
    FShortieQuestions.RemoveQuestion(AQuestion as TFibbageXLQuestion)
  else if AType = FFinalQuestions.GetName then
    FFinalQuestions.RemoveQuestion(AQuestion as TFibbageXLQuestion)
  else
    Assert(False);
end;

procedure TFibbageXLContent.Save;
begin
  var savePath := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName);
  try
    try
      FConfiguration.Save(savePath);
      FShortieQuestions.Save(savePath);
      FFinalQuestions.Save(savePath);
      SaveManifest(savePath);
    except
      on E: Exception do
      begin
        TDirectory.Delete(savePath, True);
        raise;
      end;
    end;
  finally
    if TDirectory.Exists(savePath) then
    begin
      TDirectory.Delete(FConfiguration.GetPath, True);
      TDirectory.Copy(savePath, FConfiguration.GetPath); {CANNOT USE MOVE - NOT WORKING FOR MULTIPLE DRIVES}
      TDirectory.Delete(savePath, True);
    end;
  end;
end;

procedure TFibbageXLContent.SaveManifest(const APath: string);
begin
  var fileName := TPath.Combine(APath, 'manifest.jet');
  var fs := TFileStream.Create(fileName, fmCreate);
  var sw := TStreamWriter.Create(fs);
  try
    sw.OwnStream;
    sw.Write(GetManifestJSON);
  finally
    sw.Free;
  end;
end;

end.
