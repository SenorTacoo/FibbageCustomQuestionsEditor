unit TestuFibbage2;
interface

uses
  DUnitX.TestFramework,
  System.Generics.Collections,
  uFibbageFilesReader,
  uFibbage2Questions;

type
  TTestReader = class(TFibbageFilesReader)
  protected
    procedure DoRead(const ACategoryFile, AQuestionsDirectory: string); override;
  public
    function FileExists(const AFile: string): Boolean; override;
  end;

  [TestFixture]
  TFibbage2QuestionsLoader = class
  private
    FReader: TTestReader;

    function CategoryJSON: string;
    function QuestionJSON_Shortie: string;
    function QuestionJSON_Final: string;
  public
    [SetUp]
    procedure SetUp;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure should_load_shortie_questions;
    [Test]
    procedure should_load_final_questions;
  end;

implementation

{ TFibbage2QuestionsLoader }

function TFibbage2QuestionsLoader.CategoryJSON: string;
begin
  Result := '{' +
    '"content":[' +
        '{' +
            '"x":true,' +
            '"id":1234,' +
            '"category":"a",' +
            '"bumper":""' +
        '}]}';
end;

function TFibbage2QuestionsLoader.QuestionJSON_Shortie: string;
begin
   Result := '{' +
    '"fields":[' +
        '{' +
            '"t":"B",' +
            '"v":"false",' +
            '"n":"HasBumperAudio"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"false",' +
            '"n":"HasBumperType"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"true",' +
            '"n":"HasCorrectAudio"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"true",' +
            '"n":"HasQuestionAudio"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"s1,s2,s3",' +
            '"n":"Suggestions"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"a",' +
            '"n":"Category"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"text1",' +
            '"n":"CorrectText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"None",' +
            '"n":"BumperType"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"question1",' +
            '"n":"QuestionText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"as1, as2",' +
            '"n":"AlternateSpellings"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"n":"BumperAudio"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"v":"ca1",' +
            '"n":"CorrectAudio"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"v":"qa1",' +
            '"n":"QuestionAudio"' +
        '}' +
    ']' +
  '}';
end;

function TFibbage2QuestionsLoader.QuestionJSON_Final: string;
begin
   Result := '{' +
    '"fields":[' +
        '{' +
            '"t":"B",' +
            '"v":"false",' +
            '"n":"HasBumperAudio"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"false",' +
            '"n":"HasBumperType"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"true",' +
            '"n":"HasCorrectAudio"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"true",' +
            '"n":"HasQuestionAudio"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"s20,s21,s22",' +
            '"n":"Suggestions"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"a",' +
            '"n":"Category"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"text2",' +
            '"n":"CorrectText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"None",' +
            '"n":"BumperType"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"question2",' +
            '"n":"QuestionText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"as20, as21",' +
            '"n":"AlternateSpellings"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"n":"BumperAudio"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"v":"ca2",' +
            '"n":"CorrectAudio"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"v":"qa2",' +
            '"n":"QuestionAudio"' +
        '}' +
    ']' +
  '}';
end;

procedure TFibbage2QuestionsLoader.SetUp;
begin
  FReader := TTestReader.Create('');
end;

procedure TFibbage2QuestionsLoader.should_load_final_questions;
begin
  FReader.FQuestionData.CategoryData := CategoryJSON;
  FReader.FQuestionData.QuestionData.Add('1234', QuestionJSON_Final);

  var loader := TFibbage2Questions_Final.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(1, loader.Count, '1');

  Assert.AreEqual(CategoryJSON, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON_Final, loader[0].GetJSON);

  loader.Free;
end;

procedure TFibbage2QuestionsLoader.should_load_shortie_questions;
begin
  FReader.FQuestionData.CategoryData := CategoryJSON;
  FReader.FQuestionData.QuestionData.Add('1234', QuestionJSON_Shortie);

  var loader := TFibbage2Questions_Shortie.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(1, loader.Count, '1');

  Assert.AreEqual(CategoryJSON, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON_Shortie, loader[0].GetJSON);

  loader.Free;
end;

procedure TFibbage2QuestionsLoader.TearDown;
begin
  FReader.Free;
end;

{ TTestReader }

procedure TTestReader.DoRead;
begin
  {}
end;

function TTestReader.FileExists;
begin
  Result := True;
end;

initialization

  TDUnitX.RegisterTestFixture(TFibbage2QuestionsLoader);

end.
