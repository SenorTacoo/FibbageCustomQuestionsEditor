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

    procedure DoRead(const ACategoryFile, AQuestionsDirectory: string); virtual;
  public
    constructor Create(const ABasePath: string);
    destructor Destroy; override;

    function Read(const AType: string): TQuestionData;
    function ReadWithCustomQuestionsDir(const AType, AQuestionsDir: string): TQuestionData;

    function FileExists(const AFile: string): Boolean; virtual;
    function DirectoryExists(const ADir: string): Boolean; virtual;

    property BasePath: string read FBasePath write FBasePath;
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

function TFibbageFilesReader.DirectoryExists(const ADir: string): Boolean;
begin
  Result := TDirectory.Exists(ADir);
end;

procedure TFibbageFilesReader.DoRead(const ACategoryFile, AQuestionsDirectory: string);
begin
  if FQuestionData = nil then
    FQuestionData := TQuestionData.Create;

  var jetFile := TDirectory.GetFiles(FBasePath, Format('%s.jet', [ACategoryFile]));
  if Length(jetFile) < 1 then
    raise EMissingFile.Create(TPath.Combine(FBasePath, ACategoryFile + '.jet'));

  var sr := TStreamReader.Create(jetFile[0], TEncoding.UTF8);
  try
    FQuestionData.CategoryData := sr.ReadToEnd;
  finally
    sr.Free;
  end;

  var questionDirs := TDirectory.GetDirectories(TPath.Combine(FBasePath, AQuestionsDirectory));

  for var dir in questionDirs do
  begin
    var questionId := TPath.GetFileNameWithoutExtension(dir);
    var dataFile := TDirectory.GetFiles(dir, 'data.jet');
    if Length(dataFile) < 1 then
      raise EMissingFile.Create(TPath.Combine(dir, 'data.jet'));

    sr := TStreamReader.Create(dataFile[0], TEncoding.UTF8);
    try
      FQuestionData.QuestionData.AddOrSetValue(questionId, sr.ReadToEnd);
    finally
      sr.Free;
    end;
  end;
end;

function TFibbageFilesReader.FileExists(const AFile: string): Boolean;
begin
  Result := TFile.Exists(AFile);
end;

function TFibbageFilesReader.Read(const AType: string): TQuestionData;
begin
  DoRead(AType, AType);
  Result := FQuestionData;
  FQuestionData := nil;
end;

function TFibbageFilesReader.ReadWithCustomQuestionsDir(const AType,
  AQuestionsDir: string): TQuestionData;
begin
  DoRead(AType, AQuestionsDir);
  Result := FQuestionData;
  FQuestionData := nil;
end;

end.
