unit uContentConfiguration;

interface

uses
  uInterfaces,
  System.IOUtils,
  System.StrUtils,
  System.SysUtils,
  System.Classes;

type
  TContentConfiguration = class(TInterfacedObject, IContentConfiguration)
  private
    FRawCfg: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetName(const AName: string);
    procedure SetPath(const APath: string);
    procedure SetShowCategoryDuplicated(AValue: Boolean);
    procedure SetShowTooFewSuggestions(AValue: Boolean);
    procedure SetGameType(AType: TGameType);

    function GetName: string;
    function GetPath: string;
    function GetShowCategoryDuplicated: Boolean;
    function GetShowTooFewSuggestions: Boolean;
    function GetGameType: TGameType;

    function Initialize(const APath: string): Boolean;
    procedure Save(const APath: string); overload;
    procedure Save; overload;
  end;

implementation

{ TContentConfiguration }

constructor TContentConfiguration.Create;
begin
  inherited;
  FRawCfg := TStringList.Create;
  FRawCfg.StrictDelimiter := True;
end;

destructor TContentConfiguration.Destroy;
begin
  FRawCfg.Free;
  inherited;
end;

function TContentConfiguration.GetGameType: TGameType;
begin
  var res := FRawCfg.Values['GameType'];
  if res.IsEmpty then
    Result := TGameType.FibbageXL
  else
    Result := TGameType(StrToInt(res));
end;

function TContentConfiguration.GetName: string;
begin
  Result := FRawCfg.Values['ProjectName'];
  if Result.IsEmpty then
    Result := GetPath;
end;

function TContentConfiguration.GetPath: string;
begin
  Result := FRawCfg.Values['ProjectPath'];
end;

function TContentConfiguration.GetShowCategoryDuplicated: Boolean;
begin
  Result := StrToBoolDef(FRawCfg.Values['ShowCategoryDuplicated'], True);
end;

function TContentConfiguration.GetShowTooFewSuggestions: Boolean;
begin
  Result := StrToBoolDef(FRawCfg.Values['ShowTooFewSuggestions'], True);
end;

function TContentConfiguration.Initialize(const APath: string): Boolean;
begin
  Result := False;
  if FileExists(TPath.Combine(APath, '.fcqeinfo')) then
  begin
    Result := True;
    FRawCfg.LoadFromFile(TPath.Combine(APath, '.fcqeinfo'));
  end;
  SetPath(APath);
end;

procedure TContentConfiguration.Save(const APath: string);
begin
  if GetPath <> APath then
    SetPath(APath);
  ForceDirectories(APath);
  FRawCfg.SaveToFile(TPath.Combine(APath, '.fcqeinfo'));
end;

procedure TContentConfiguration.Save;
begin
  Save(GetPath);
end;

procedure TContentConfiguration.SetGameType(AType: TGameType);
begin
  FRawCfg.Values['GameType'] := IntToStr(Ord(AType));
end;

procedure TContentConfiguration.SetName(const AName: string);
begin
  FRawCfg.Values['ProjectName'] := AName;
end;

procedure TContentConfiguration.SetPath(const APath: string);
begin
  FRawCfg.Values['ProjectPath'] := APath;
end;

procedure TContentConfiguration.SetShowCategoryDuplicated(AValue: Boolean);
begin
  FRawCfg.Values['ShowCategoryDuplicated'] := BoolToStr(AValue, True);
end;

procedure TContentConfiguration.SetShowTooFewSuggestions(AValue: Boolean);
begin
  FRawCfg.Values['ShowTooFewSuggestions'] := BoolToStr(AValue, True);
end;

end.
