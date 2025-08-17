unit uLastQuestionsLoader;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.Generics.Collections,
  uContentConfiguration,
  uFibbageContent,
  uInterfaces;

type
  TLastQuestionsLoader = class
  strict private const
    FIBBAGE_DIRECTORY = 'FibbageCQE';
    LASTS_FILE_NAME = '.lasts';
  private
    FUpdateCount: Integer;
    FConfigurations: TContentConfigurations;
    function GetLastsFile: string;
    procedure SavePathsToFile;
    procedure LoadPathsFromFile;
    function GetConfiguration(const APath: string): TContentConfiguration;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize;

    procedure Add(AConfiguration: TContentConfiguration);
    procedure Remove(AConfiguration: TContentConfiguration);
    function Count: Integer;
    procedure BeginUpdate;
    procedure EndUpdate;

    property Configurations: TContentConfigurations read FConfigurations;
  end;

implementation

{ TLastQuestionsLoader }

procedure TLastQuestionsLoader.Add(AConfiguration: TContentConfiguration);
begin
  var cfg := GetConfiguration(AConfiguration.GetPath);

  if Assigned(cfg) then
    FConfigurations.Move(FConfigurations.IndexOf(cfg), 0)
  else
    FConfigurations.Insert(0, AConfiguration);
end;

procedure TLastQuestionsLoader.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

function TLastQuestionsLoader.Count: Integer;
begin
  Result := FConfigurations.Count;
end;

constructor TLastQuestionsLoader.Create;
begin
  inherited;
  FConfigurations := TContentConfigurations.Create;
end;

destructor TLastQuestionsLoader.Destroy;
begin
  FConfigurations.Free;
  inherited;
end;

procedure TLastQuestionsLoader.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    SavePathsToFile;
end;

function TLastQuestionsLoader.GetConfiguration(
  const APath: string): TContentConfiguration;
begin
  Result := nil;
  for var item in FConfigurations do
    if item.GetPath = APath then
      Exit(item);
end;

function TLastQuestionsLoader.GetLastsFile: string;
begin
  Result :=
    TPath.Combine(
      TPath.Combine(
        TPath.GetCachePath,
        FIBBAGE_DIRECTORY),
      LASTS_FILE_NAME);
end;

procedure TLastQuestionsLoader.Initialize;
begin
  ForceDirectories(TPath.Combine(TPath.GetCachePath, FIBBAGE_DIRECTORY));
  LoadPathsFromFile;
end;

procedure TLastQuestionsLoader.LoadPathsFromFile;
begin
  if not FileExists(GetLastsFile) then
    Exit;

  var lastFiles := TStringList.Create;
  try
    lastFiles.StrictDelimiter := True;
    lastFiles.LoadFromFile(GetLastsFile);

    for var path in lastFiles do
    begin
      if path.Trim.IsEmpty then
        Continue;

      var item := TContentConfiguration.Create;
      try
        if item.Initialize(path) then
        begin
          FConfigurations.Add(item);
          item := nil;
        end;
      finally
        item.Free;
      end;
    end;
  finally
    lastFiles.Free;
  end;
end;

procedure TLastQuestionsLoader.Remove(AConfiguration: TContentConfiguration);
begin
  var cfg := GetConfiguration(AConfiguration.GetPath);
  if Assigned(cfg) then
    FConfigurations.Remove(cfg);
end;

procedure TLastQuestionsLoader.SavePathsToFile;
begin
  var lastFiles := TStringList.Create;
  try
    lastFiles.StrictDelimiter := True;

    for var item in FConfigurations do
      lastFiles.Add(item.GetPath);

    lastFiles.SaveToFile(GetLastsFile);
  finally
    lastFiles.Free;
  end;
end;

end.
