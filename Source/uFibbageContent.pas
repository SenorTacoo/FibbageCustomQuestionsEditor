unit uFibbageContent;

interface

uses
  System.Generics.Collections,
  System.Classes,
  System.SysUtils,
  uContentConfiguration,
  uQuestionsLoader,
  uFibbageFilesReader,
  uInterfaces;

type
  TFibbageContent = class abstract
  protected
    FConfiguration: TContentConfiguration;
    FFilesReader: TFibbageFilesReader;

    function DoInitialize: Boolean; virtual; abstract;
  public
    constructor Create(const ABasePath: string);
    destructor Destroy; override;

    function Initialize(ACfg: TContentConfiguration): Boolean;
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); overload;
    procedure Save; overload;

    function CreateNewQuestion(const AType: string): TFibbageQuestion; virtual; abstract;
    procedure RemoveQuestion(const AType: string; AQuestion: TFibbageQuestion); virtual; abstract;

    function GetEditableTypes: TStringList; virtual; abstract;
    procedure ForEachQuestion(const AType: string; AProc: TProc<TFibbageQuestion>); virtual; abstract;

    function HasDuplicatedCategory(const AType: string; AQuestion: TFibbageQuestion): Boolean; virtual; abstract;
    function HasTooFewSuggestions(const AType: string; AQuestion: TFibbageQuestion): Boolean; virtual; abstract;
    function HasMissingBlanks(const AType: string; AQuestion: TFibbageQuestion; out AError: string): Boolean; virtual; abstract;
  end;

  TFibbageXLContent = class(TFibbageContent)
  private
    FShortieQuestions: TFibbageXLQuestions_Shortie;
    FFinalQuestions: TFibbageXLQuestions_Final;
  protected
    function DoInitialize: Boolean; override;
  public
    constructor Create(const ABasePath: string);
    destructor Destroy; override;

    function GetEditableTypes: TStringList; override;
    procedure ForEachQuestion(const AType: string; AProc: TProc<TFibbageQuestion>); override;
    function CreateNewQuestion(const AType: string): TFibbageQuestion; override;
    procedure RemoveQuestion(const AType: string; AQuestion: TFibbageQuestion); override;

    function HasDuplicatedCategory(const AType: string; AQuestion: TFibbageQuestion): Boolean; override;
    function HasTooFewSuggestions(const AType: string; AQuestion: TFibbageQuestion): Boolean; override;
    function HasMissingBlanks(const AType: string; AQuestion: TFibbageQuestion; out AError: string): Boolean; override;
  end;

implementation

{ TFibbageContent }

constructor TFibbageContent.Create(const ABasePath: string);
begin
  inherited Create;
  FFilesReader := TFibbageFilesReader.Create(ABasePath);
end;

destructor TFibbageContent.Destroy;
begin
  FFilesReader.Free;
  inherited;
end;

function TFibbageContent.Initialize(ACfg: TContentConfiguration): Boolean;
begin
  FConfiguration := ACfg;
  Result := DoInitialize;
end;

procedure TFibbageContent.Save(const APath: string; ASaveOptions: TSaveOptions);
begin

end;

procedure TFibbageContent.Save;
begin
//
end;

{ TFibbageXLContent }

function TFibbageXLContent.CreateNewQuestion(
  const AType: string): TFibbageQuestion;
begin
  if AType = FShortieQuestions.GetName then
    Result := FShortieQuestions.CreateNewQuestion
  else if AType = FFinalQuestions.GetName then
    Result := FFinalQuestions.CreateNewQuestion
  else
    Assert(False);
end;

constructor TFibbageXLContent.Create(const ABasePath: string);
begin
  inherited Create(ABasePath);
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
  FShortieQuestions.Initialize(FFilesReader);
  FFinalQuestions.Initialize(FFilesReader);
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

function TFibbageXLContent.HasDuplicatedCategory(const AType: string;
  AQuestion: TFibbageQuestion): Boolean;
begin
  if AType = FShortieQuestions.GetName then
    Result := FShortieQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbageXLQuestion)
  else if AType = FFinalQuestions.GetName then
    Result := FFinalQuestions.HasQuestionWithTheSameCategory(AQuestion as TFibbageXLQuestion)
  else
    Assert(False);
end;

function TFibbageXLContent.HasMissingBlanks;
begin
  Result := False;
end;

function TFibbageXLContent.HasTooFewSuggestions(const AType: string;
  AQuestion: TFibbageQuestion): Boolean;
const
  OPTIMAL_SUGGESTIONS_NR = 17;
begin
  Result := (AQuestion as TFibbageXLQuestion).SuggestionsCount < OPTIMAL_SUGGESTIONS_NR;
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

end.
