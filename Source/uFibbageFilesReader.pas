unit uFibbageFilesReader;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.Generics.Collections;

type
  TQuestionData = class
    CategoryData: string;
    QuestionData: TDictionary<string, string>;

    constructor Create;
    destructor Destroy; override;
    procedure Clear;
  end;

  TFibbageFilesReader = class
  protected
    FQuestionData: TQuestionData;
    FBasePath: string;
  public
    constructor Create(const ABasePath: string);
    destructor Destroy; override;

    function Read(AType: string): TQuestionData;

    property BasePath: string read FBasePath;
  end;

  EMissingFile = class(Exception);

implementation

{ TQuestionData }

procedure TQuestionData.Clear;
begin
  CategoryData := '';
  QuestionData.Clear;
end;

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

constructor TFibbageFilesReader.Create(const ABasePath: string);
begin
  inherited Create;
  FQuestionData := TQuestionData.Create;
  FBasePath := ABasePath;
end;

destructor TFibbageFilesReader.Destroy;
begin
  FQuestionData.Free;
  inherited;
end;

function TFibbageFilesReader.Read(AType: string): TQuestionData;
begin
  if FQuestionData = nil then
    FQuestionData := TQuestionData.Create;

  var jetFile := TDirectory.GetFiles(FBasePath, Format('%s.jet', [AType]));
  if Length(jetFile) < 1 then
    raise EMissingFile.Create(TPath.Combine(FBasePath, AType + '.jet'));

  var sr := TStreamReader.Create(jetFile[0]);
  try
    FQuestionData.CategoryData := sr.ReadToEnd;
  finally
    sr.Free;
  end;

  var questionDirs := TDirectory.GetDirectories(TPath.Combine(FBasePath, AType));

  for var dir in questionDirs do
  begin
    var questionId := TPath.GetFileNameWithoutExtension(dir);
    var dataFile := TDirectory.GetFiles(dir, 'data.jet');
    if Length(dataFile) < 1 then
      raise EMissingFile.Create(TPath.Combine(dir, 'data.jet'));

    sr := TStreamReader.Create(dataFile[0]);
    try
      FQuestionData.QuestionData.AddOrSetValue(questionId, sr.ReadToEnd);
    finally
      sr.Free;
    end;
  end;

  Result := FQuestionData;
  FQuestionData := nil;
end;

end.
