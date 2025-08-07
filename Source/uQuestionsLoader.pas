unit uQuestionsLoader;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  uFibbageFilesReader;

type
  TEditableFieldBase = class(TObject);

  TEditableStringField = class(TEditableFieldBase)
    Name: string;
    Value: string;
  end;

  TEditableLongStringField = class(TEditableFieldBase)
    Name: string;
    Value: string;
  end;

  TEditableU32Field = class(TEditableFieldBase)
    Name: string;
    Value: UInt32;
  end;

  TEditableAudioField = class(TEditableFieldBase)
    Name: string;
    Value: string;
    BasePath: string;
  end;

  TEditableBoolField = class(TEditableFieldBase)
    Name: string;
    Value: Boolean;
  end;

  TEditableFields = TObjectList<TEditableFieldBase>;

  TQuestionPreview = record
    Header: string;
    Question: string;
  end;

  TFibbageQuestion = class(TPersistent)
  public
    procedure SetEditableFields(AFields: TEditableFields); virtual; abstract;
    function GetEditableFields: TEditableFields; virtual; abstract;
    function GetPreview: TQuestionPreview; virtual; abstract;
    function GetJSON: string; virtual; abstract;
    function IsMissingBlank: Boolean; virtual; abstract;
  end;

  TFibbageAudioEntry = class
    BasePath: string;
    Name: string;
  end;

  TFibbageQuestions<T: class> = class abstract
  private
    function GetItem(AIndex: Int32): T;
  protected
    FList: TObjectList<T>;
    FReader: TFibbageFilesReader;
    FSavePath: string;

    procedure DoInitialize; virtual; abstract;
    procedure DoSaveCategory; virtual; abstract;
    procedure DoSaveQuestions; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize(AReader: TFibbageFilesReader);
    procedure Save(const APath: string);
    function GetName: string; virtual; abstract;

    function CreateNewQuestion: T; virtual; abstract;
    procedure RemoveQuestion(AQuestion: T); virtual; abstract;

    function Count: Int32;

    function GetFirstQuestionWithDuplicatedCategory: T; virtual; abstract;
    function GetFirstQuestionWithTooFewSuggestions: T; virtual; abstract;
    function GetFirstQuestionWithMissingBlank: T; virtual; abstract;

    property Item[AIndex: Int32]: T read GetItem; default;
  end;

  TQuestionData = uFibbageFilesReader.TQuestionData;

implementation

{ TFibbageQuestions<T> }

function TFibbageQuestions<T>.Count: Int32;
begin
  Result := FList.Count;
end;

constructor TFibbageQuestions<T>.Create;
begin
  inherited Create;
  FList := TObjectList<T>.Create;
end;

destructor TFibbageQuestions<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

function TFibbageQuestions<T>.GetItem(AIndex: Int32): T;
begin
  Result := FList[AIndex];
end;

procedure TFibbageQuestions<T>.Initialize(AReader: TFibbageFilesReader);
begin
  FList.Clear;
  FReader := AReader;
  DoInitialize;
end;

procedure TFibbageQuestions<T>.Save(const APath: string);
begin
  FSavePath := APath;
  DoSaveCategory;
  DoSaveQuestions;
end;

end.
