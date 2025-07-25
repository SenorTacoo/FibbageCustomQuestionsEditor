unit uFibbageFilesReader;

interface

uses
  System.Generics.Collections;

type
  TQuestionData = class
    CategoryData: string;
    QuestionData: TDictionary<string, string>;

    constructor Create;
    destructor Destroy; override;
  end;

  TFibbageFilesReader = class
  protected
    FQuestions: TObjectList<TQuestionData>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Read(const AType: string); virtual;
    function GetItem(AIndex: Int32): TQuestionData; virtual;
    function Count: Int32; virtual;
  end;

implementation

{ TQuestionData }

constructor TQuestionData.Create;
begin
  inherited Create;
  QuestionData := TDictionary<string, string>.Create;
end;

destructor TQuestionData.Destroy;
begin
  QuestionData.Free;
  inherited;
end;

{ TFibbageFilesReader }

function TFibbageFilesReader.Count: Int32;
begin
  Result := FQuestions.Count;
end;

constructor TFibbageFilesReader.Create;
begin
  inherited Create;
  FQuestions := TObjectList<TQuestionData>.Create;
end;

destructor TFibbageFilesReader.Destroy;
begin
  FQuestions.Free;
  inherited;
end;

function TFibbageFilesReader.GetItem(AIndex: Int32): TQuestionData;
begin
  Result := FQuestions[AIndex];
end;

procedure TFibbageFilesReader.Read(const AType: string);
begin
  FQuestions.Clear;

end;

end.
