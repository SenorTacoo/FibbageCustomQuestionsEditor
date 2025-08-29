unit uFibbageXLQuestions;

interface

uses
  System.Classes,
  System.SysUtils,
  uQuestionsLoader;

type
  TFibbageXLQuestion = class(TFibbageQuestion)
  private
    FId: UInt32;
    FCategory: string;
    FFamilyFriendly: Boolean;
    FBumperAudio: TFibbageAudioEntry;
    FBumperType: string;
    FCorrectAudio: TFibbageAudioEntry;
    FQuestionAudio: TFibbageAudioEntry;
    FSuggestions: TArray<string>;
    FCorrectText: string;
    FQuestionText: string;
    FAlternateSpellings: TArray<string>;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetEditableFields(AFields: TEditableFields); override;
    function GetEditableFields: TEditableFields; override;
    function GetPreview: TQuestionPreview; override;
    function GetJSON: string; override;
    function SuggestionsCount: Int32;

    property Category: string read FCategory;
  end;

  TFibbageXLQuestions_Shortie = class(TFibbageXLQuestions)
  public
    function GetName: string; override;
  end;

  TFibbageXLQuestions_Final = class(TFibbageXLQuestions)
  public
    function GetName: string; override;
  end;

implementation

end.
