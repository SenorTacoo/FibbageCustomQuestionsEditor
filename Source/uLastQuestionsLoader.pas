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
    FPaths: TStringList;
    FUpdateCount: Integer;
    FConfigurations: TContentConfigurations;
    function GetLastsFile: string;
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
  var index := FPaths.IndexOf(AConfiguration.GetPath);
  case index of
    -1: ;
    0: Exit;
    else
      FPaths.Delete(index);
  end;

  FPaths.Insert(0, AConfiguration.GetPath);
end;

procedure TLastQuestionsLoader.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

function TLastQuestionsLoader.Count: Integer;
begin
  Result := FPaths.Count;
end;

constructor TLastQuestionsLoader.Create;
begin
  inherited;
  FPaths := TStringList.Create;
  FPaths.StrictDelimiter := True;
  FConfigurations := TContentConfigurations.Create;
end;

destructor TLastQuestionsLoader.Destroy;
begin
  FPaths.Free;
  FConfigurations.Free;
  inherited;
end;

procedure TLastQuestionsLoader.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    FPaths.SaveToFile(GetLastsFile);
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
  if FileExists(GetLastsFile) then
    FPaths.LoadFromFile(GetLastsFile);

  for var path in FPaths do
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

end;

procedure TLastQuestionsLoader.Remove(AConfiguration: TContentConfiguration);
begin
  var index := FPaths.IndexOf(AConfiguration.GetPath);
  if index = -1 then
    Exit;

  FPaths.Delete(index);
end;

end.
