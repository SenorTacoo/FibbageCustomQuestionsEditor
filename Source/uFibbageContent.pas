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
    constructor Create(ACfg: TContentConfiguration);
    destructor Destroy; override;

    function Initialize: Boolean;
    procedure Activate(const APath: string); virtual; abstract;
    procedure Save; virtual; abstract;

    function CreateNewQuestion(const AType: string): TFibbageQuestion; virtual; abstract;
    procedure RemoveQuestion(const AType: string; AQuestion: TFibbageQuestion); virtual; abstract;

    procedure CopyQuestion(const AType: string; AQuestion: TFibbageQuestion); virtual; abstract;
    procedure MoveQuestion(const ASrcType, ADstType: string; AQuestion: TFibbageQuestion); virtual; abstract;

    function GetEditableTypes: TStringList; virtual; abstract;
    procedure ForEachQuestion(const AType: string; AProc: TProc<TFibbageQuestion>); virtual; abstract;

    function HasDuplicatedCategory(const AType: string; AQuestion: TFibbageQuestion): Boolean; overload; virtual; abstract;
    function HasTooFewSuggestions(const AType: string; AQuestion: TFibbageQuestion): Boolean; virtual; abstract;
    function HasMissingBlank(const AType: string; AQuestion: TFibbageQuestion; out AError: string): Boolean; overload; virtual; abstract;
    function HasTooFewQuestions(const AType: string): Boolean; virtual; abstract;
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
  if Assigned(FConfiguration) and FConfiguration.ImportedContent then
    FConfiguration.Free;
  FFilesReader.Free;
  inherited;
end;

function TFibbageContent.Initialize: Boolean;
begin
  Result := DoInitialize;
end;

end.
