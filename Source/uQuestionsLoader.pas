unit uQuestionsLoader;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
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
    ForcedFileName: string;
  end;

  TEditableBoolField = class(TEditableFieldBase)
    Name: string;
    Value: Boolean;
  end;

  TEditablePicField = class(TEditableFieldBase)
    Name: string;
    Value: string;
    BasePath: string;
  end;

  TEditableFields = TObjectList<TEditableFieldBase>;

  TTypePreview = record
    InternalName: string;
    DisplayName: string;
  end;

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
    function IsMissingSpecialEntry(out AError: string): Boolean; virtual; abstract;
  end;

  TFibbageAudioEntry = record
    BasePath: string;
    Name: string;
  end;

  PFibbageAudioEntry = ^TFibbageAudioEntry;

  TFibbagePicEntry = record
    BasePath: string;
    Name: string;
  end;

  PFibbagePicEntry = ^TFibbagePicEntry;

  TFibbageVideoEntry = record
    BasePath: string;
    Name: string;
  end;

  PFibbageVideoEntry = ^TFibbageVideoEntry;

  TFibbageSubtitlesEntry = record
    BasePath: string;
    Name: string;
  end;

  PFibbageSubtitlesEntry = ^TFibbageSubtitlesEntry;

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

    procedure ClearAudioEntryIfNotExistingFile(AEntry: PFibbageAudioEntry);
    procedure ClearPicEntryIfNotExistingFile(AEntry: PFibbagePicEntry);
    procedure ClearVideoEntryIfNotExistingFile(AEntry: PFibbageVideoEntry);
    procedure ClearVideoSubtitlesIfNotExistingFile(AEntry: PFibbageSubtitlesEntry);

    function CreateEmptyOGGFile(const AFilePath: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize(AReader: TFibbageFilesReader);
    procedure Save(const APath: string);
    function GetName: string; virtual; abstract;

    function CreateNewQuestion: T; virtual; abstract;
    procedure RemoveQuestion(AQuestion: T); virtual; abstract;

    function Count: Int32;

    function GetTypePreview: TTypePreview; virtual; abstract;

    function GetFirstQuestionWithDuplicatedCategory: T; virtual; abstract;
    function GetFirstQuestionWithTooFewSuggestions: T; virtual; abstract;
    function GetFirstQuestionWithMissingSpecialEntry: T; virtual; abstract;

    property Item[AIndex: Int32]: T read GetItem; default;
  end;

  TQuestionData = uFibbageFilesReader.TQuestionData;

implementation

{ TFibbageQuestions<T> }

procedure TFibbageQuestions<T>.ClearAudioEntryIfNotExistingFile(
  AEntry: PFibbageAudioEntry);
begin
  if AEntry.Name = '' then
    Exit;

  var wantedPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.ogg');
  if not FReader.FileExists(wantedPath) then
    AEntry.Name := '';
end;

procedure TFibbageQuestions<T>.ClearPicEntryIfNotExistingFile(
  AEntry: PFibbagePicEntry);
begin
  if AEntry.Name = '' then
    Exit;

  var wantedPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.png');
  if not FReader.FileExists(wantedPath) then
    AEntry.Name := '';
end;

procedure TFibbageQuestions<T>.ClearVideoEntryIfNotExistingFile(
  AEntry: PFibbageVideoEntry);
begin
  if AEntry.Name = '' then
    Exit;

  var wantedPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.srt');
  if not FReader.FileExists(wantedPath) then
    AEntry.Name := '';
end;

procedure TFibbageQuestions<T>.ClearVideoSubtitlesIfNotExistingFile(
  AEntry: PFibbageSubtitlesEntry);
begin
  if AEntry.Name = '' then
    Exit;

  var wantedPath := TPath.Combine(AEntry.BasePath, AEntry.Name + '.srt');
  if not FReader.FileExists(wantedPath) then
    AEntry.Name := '';
end;

function TFibbageQuestions<T>.Count: Int32;
begin
  Result := FList.Count;
end;

constructor TFibbageQuestions<T>.Create;
begin
  inherited Create;
  FList := TObjectList<T>.Create;
end;

function TFibbageQuestions<T>.CreateEmptyOGGFile(
  const AFilePath: string): Boolean;
begin
  Result := False;
  var oggHeader := TBytes.Create(
    $4F, $67, $67, $53,
    $00,
    $02,
    $00, $00, $00, $00, $00, $00, $00, $00,
    $01, $00, $00, $00,
    $00, $00, $00, $00,
    $00, $00, $00, $00,
    $01,
    $1E
  );

  var vorbisIdHeader := TBytes.Create(
    $01,
    $76, $6F, $72, $62, $69, $73,
    $00, $00, $00, $00,
    $02,
    $44, $AC, $00, $00,
    $00, $00, $00, $00,
    $00, $00, $00, $00,
    $00, $00, $00, $00,
    $00,
    $01
  );

  try
    var stream := TFileStream.Create(AFilePath, fmCreate);
    try
      Stream.WriteBuffer(oggHeader[0], Length(oggHeader));
      Stream.WriteBuffer(vorbisIdHeader[0], Length(vorbisIdHeader));
      Result := True;
    finally
      Stream.Free;
    end;
  except
    on E: Exception do
  end;
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
