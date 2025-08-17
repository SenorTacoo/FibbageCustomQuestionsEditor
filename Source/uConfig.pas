unit uConfig;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IniFiles;

type
  TAppConfig = class
  strict private const
    APP_CONFIG_NAME = 'FibbageQE.ini';
    DEFAULT_LOGGING_BROKER = 'tcp:/' + '/localhost:7337';
    DEFAULT_LOGGING_SERVICE = 'Default';
  strict private class var
    FInstance: TAppConfig;
  public
    class function GetInstance: TAppConfig;
    class destructor Destroy;
  private
    FIniFile: TMemIniFile;
    function GetDarkModeEnabled: Boolean;
    procedure SetDarkModeEnabled(const Value: Boolean);
    function GetLastEditPath: string;
    procedure SetLastEditPath(const Value: string);
    function GetInputDeviceName: string;
    function GetOutputDeviceName: string;
    procedure SetInputDeviceName(const Value: string);
    procedure SetOutputDeviceName(const Value: string);
    function GetLogBroker: string;
    function GetLogService: string;
    procedure SetLogBroker(const Value: string);
    procedure SetLogService(const Value: string);
    function GetFibbagePath: string;
    procedure SetFibbagePath(const Value: string);
    function GetShowInfoAboutDuplicatedCategories: Boolean;
    procedure SetShowInfoAboutDuplicatedCategories(const Value: Boolean);
    function GetShowInfoAboutTooFewSuggestions: Boolean;
    procedure SetShowInfoAboutTooFewSuggestions(const Value: Boolean);
    function GetShowInfoAboutTooFewQuestions: Boolean;
    procedure SetShowInfoAboutTooFewQuestions(const Value: Boolean);
    function GetJackboxPartyPack4Path: string;
    function GetJackboxPartyPack1Path: string;
    procedure SetJackboxPartyPack4Path(const Value: string);
    procedure SetJackboxPartyPack1Path(const Value: string);
    function GetJackboxPartyPack9Path: string;
    procedure SetJackboxPartyPack9Path(const Value: string);
    function GetShowInfoAboutMissingSpecialEntries: Boolean;
    procedure SetShowInfoAboutMissingSpecialEntries(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    property DarkModeEnabled: Boolean read GetDarkModeEnabled write SetDarkModeEnabled;
    property LastEditPath: string read GetLastEditPath write SetLastEditPath;
    property OutputDeviceName: string read GetOutputDeviceName write SetOutputDeviceName;
    property InputDeviceName: string read GetInputDeviceName write SetInputDeviceName;
    property LogBroker: string read GetLogBroker write SetLogBroker;
    property LogService: string read GetLogService write SetLogService;

    property FibbageXLPath: string read GetFibbagePath write SetFibbagePath;
    property JackboxPartyPack1Path: string read GetJackboxPartyPack1Path write SetJackboxPartyPack1Path;
    property JackboxPartyPack4Path: string read GetJackboxPartyPack4Path write SetJackboxPartyPack4Path;
    property JackboxPartyPack9Path: string read GetJackboxPartyPack9Path write SetJackboxPartyPack9Path;

    property ShowInfoAboutDuplicatedCategories: Boolean read GetShowInfoAboutDuplicatedCategories write SetShowInfoAboutDuplicatedCategories;
    property ShowInfoAboutTooFewSuggestions: Boolean read GetShowInfoAboutTooFewSuggestions write SetShowInfoAboutTooFewSuggestions;
    property ShowInfoAboutTooFewQuestions: Boolean read GetShowInfoAboutTooFewQuestions write SetShowInfoAboutTooFewQuestions;
    property ShowInfoAboutMissingSpecialEntries: Boolean read GetShowInfoAboutMissingSpecialEntries write SetShowInfoAboutMissingSpecialEntries;
  end;

implementation

{ TAppConfig }

constructor TAppConfig.Create;
begin
  inherited;
  FIniFile := TMemIniFile.Create(APP_CONFIG_NAME, TEncoding.UTF8, False, False);
  FIniFile.AutoSave := True;
end;

destructor TAppConfig.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

class destructor TAppConfig.Destroy;
begin
  FreeAndNil(FInstance);
end;

function TAppConfig.GetDarkModeEnabled: Boolean;
begin
  Result := FIniFile.ReadBool('Style', 'DarkMode', False);
end;

function TAppConfig.GetJackboxPartyPack4Path: string;
begin
  Result := FIniFile.ReadString('General', 'JackboxPartyPack4Path', '');
end;

function TAppConfig.GetJackboxPartyPack9Path: string;
begin
  Result := FIniFile.ReadString('General', 'JackboxPartyPack9Path', '');
end;

function TAppConfig.GetFibbagePath: string;
begin
  Result := FIniFile.ReadString('General', 'FibbagePath', '');
end;

function TAppConfig.GetJackboxPartyPack1Path: string;
begin
  Result := FIniFile.ReadString('General', 'JackboxPartyPack1Path', '');
end;

function TAppConfig.GetInputDeviceName: string;
begin
  Result := FIniFile.ReadString('Audio', 'InputDeviceName', '');
end;

class function TAppConfig.GetInstance: TAppConfig;
begin
  if not Assigned(FInstance) then
    FInstance := TAppConfig.Create;
  Result := FInstance;
end;

function TAppConfig.GetLastEditPath: string;
begin
  Result := FIniFile.ReadString('Config', 'LastEditPath', '');
end;

function TAppConfig.GetLogBroker: string;
begin
  Result := FIniFile.ReadString('Logging', 'LogBroker', DEFAULT_LOGGING_BROKER);
end;

function TAppConfig.GetLogService: string;
begin
  Result := FIniFile.ReadString('Logging', 'LogService', DEFAULT_LOGGING_SERVICE);
end;

function TAppConfig.GetOutputDeviceName: string;
begin
  Result := FIniFile.ReadString('Audio', 'OutputDeviceName', '');
end;

function TAppConfig.GetShowInfoAboutDuplicatedCategories: Boolean;
begin
  Result := FIniFile.ReadBool('General', 'ShowInfoAboutDuplicatedCategories', True);
end;

function TAppConfig.GetShowInfoAboutMissingSpecialEntries: Boolean;
begin
  Result := FIniFile.ReadBool('General', 'ShowInfoAboutMissingSpecialEntries', True);
end;

function TAppConfig.GetShowInfoAboutTooFewQuestions: Boolean;
begin
  Result := FIniFile.ReadBool('General', 'ShowInfoAboutTooFewQuestions', True);
end;

function TAppConfig.GetShowInfoAboutTooFewSuggestions: Boolean;
begin
  Result := FIniFile.ReadBool('General', 'ShowInfoAboutTooFewSuggestions', True);
end;

procedure TAppConfig.SetDarkModeEnabled(const Value: Boolean);
begin
  FIniFile.WriteBool('Style', 'DarkMode', Value);
end;

procedure TAppConfig.SetJackboxPartyPack4Path(const Value: string);
begin
  FIniFile.WriteString('General', 'JackboxPartyPack4Path', Value);
end;

procedure TAppConfig.SetJackboxPartyPack9Path(const Value: string);
begin
  FIniFile.WriteString('General', 'JackboxPartyPack9Path', Value);
end;

procedure TAppConfig.SetFibbagePath(const Value: string);
begin
  FIniFile.WriteString('General', 'FibbagePath', Value);
end;

procedure TAppConfig.SetJackboxPartyPack1Path(const Value: string);
begin
  FIniFile.WriteString('General', 'JackboxPartyPack1Path', Value);
end;

procedure TAppConfig.SetInputDeviceName(const Value: string);
begin
  FIniFile.WriteString('Audio', 'InputDeviceName', Value);
end;

procedure TAppConfig.SetLastEditPath(const Value: string);
begin
  FIniFile.WriteString('Config', 'LastEditPath', Value);
end;

procedure TAppConfig.SetLogBroker(const Value: string);
begin
  FIniFile.WriteString('Logging', 'LogBroker', Value);
end;

procedure TAppConfig.SetLogService(const Value: string);
begin
  FIniFile.WriteString('Logging', 'LogService', Value);
end;

procedure TAppConfig.SetOutputDeviceName(const Value: string);
begin
  FIniFile.WriteString('Audio', 'OutputDeviceName', Value);
end;

procedure TAppConfig.SetShowInfoAboutDuplicatedCategories(const Value: Boolean);
begin
  FIniFile.WriteBool('General', 'ShowInfoAboutDuplicatedCategories', Value);
end;

procedure TAppConfig.SetShowInfoAboutMissingSpecialEntries(const Value: Boolean);
begin
  FIniFile.WriteBool('General', 'ShowInfoAboutMissingSpecialEntries', Value);
end;

procedure TAppConfig.SetShowInfoAboutTooFewQuestions(
  const Value: Boolean);
begin
  FIniFile.WriteBool('General', 'ShowInfoAboutTooFewQuestions', Value);
end;

procedure TAppConfig.SetShowInfoAboutTooFewSuggestions(const Value: Boolean);
begin
  FIniFile.WriteBool('General', 'ShowInfoAboutTooFewSuggestions', Value);
end;

end.
