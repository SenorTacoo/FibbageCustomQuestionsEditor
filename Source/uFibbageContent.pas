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
  TPreviewTypes = class(TList<TTypePreview>)
  public
    function GetItemWithDisplayText(const ADisplayText: string): TTypePreview;
  end;

  TFibbageContent = class abstract
  private
    function GetEditableTypes: TPreviewTypes;
  protected
    FConfiguration: TContentConfiguration;
    FFilesReader: TFibbageFilesReader;
    FEditableTypes: TPreviewTypes;

    function DoInitialize: Boolean; virtual; abstract;

    function DoGetEditableTypes: TPreviewTypes; virtual; abstract;
  public
    constructor Create(ACfg: TContentConfiguration);
    destructor Destroy; override;

    function Initialize: Boolean;
    procedure Activate(const APath: string); virtual; abstract;
    procedure Save; virtual; abstract;

    function CreateNewQuestion(AType: TTypePreview): TFibbageQuestion; virtual; abstract;
    procedure RemoveQuestion(AType: TTypePreview; AQuestion: TFibbageQuestion); virtual; abstract;

    function CopyQuestion(AType: TTypePreview; AQuestion: TFibbageQuestion): Boolean; virtual; abstract;
    procedure MoveQuestion(ASrcType, ADstType: TTypePreview; AQuestion: TFibbageQuestion); virtual; abstract;

    procedure ForEachQuestion(AType: TTypePreview; AProc: TProc<TFibbageQuestion>); virtual; abstract;

    function HasDuplicatedCategory(AType: TTypePreview; AQuestion: TFibbageQuestion): Boolean; overload; virtual; abstract;
    function HasTooFewSuggestions(AType: TTypePreview; AQuestion: TFibbageQuestion): Boolean; virtual; abstract;
    function HasMissingSpecialEntries(AType: TTypePreview; AQuestion: TFibbageQuestion; out AError: string): Boolean; virtual; abstract;
    function HasTooFewQuestions(AType: TTypePreview): Boolean; virtual; abstract;

    function GetMoveCopyTypesFor(AType: TTypePreview): TArray<TTypePreview>; virtual; abstract;

    property EditableTypes: TPreviewTypes read GetEditableTypes;
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
  FEditableTypes.Free;
  FFilesReader.Free;
  inherited;
end;

function TFibbageContent.GetEditableTypes: TPreviewTypes;
begin
  if FEditableTypes = nil then
    FEditableTypes := DoGetEditableTypes;
  Result := FEditableTypes;
end;

function TFibbageContent.Initialize: Boolean;
begin
  Result := DoInitialize;
end;

{ TPreviewTypes }

function TPreviewTypes.GetItemWithDisplayText(
  const ADisplayText: string): TTypePreview;
begin
  Result := Default(TTypePreview);
  for var item in Self do
    if item.DisplayName = ADisplayText then
      Exit(item);
end;

end.
