unit TestuFibbageXL;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Collections,
  uFibbageFilesReader,
  uFibbageXLQuestions;

type
  TTestXLReader = class(TFibbageFilesReader)
  protected
    procedure DoRead(const ACategoryFile, AQuestionsDirectory: string); override;
  public
    function FileExists(const AFile: string): Boolean; override;
  end;

  [TestFixture]
  TFibbageXLQuestionsLoader = class
  private
    FReader: TTestXLReader;

    function CategoryJSON_3: string;
    function QuestionJSON1: string;
    function QuestionJSON2: string;
    function QuestionJSON3: string;
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

{ TFibbageXLQuestionsLoader }

function TFibbageXLQuestionsLoader.CategoryJSON_3: string;
begin
  Result := '{' +
    '"content":[' +
        '{' +
            '"x":true,' +
            '"id":1234,' +
            '"category":"a",' +
            '"bumper":""' +
        '},' +
        '{' +
            '"x":false,' +
            '"id":2345,' +
            '"category":"b",' +
            '"bumper":""' +
        '},' +
        '{' +
            '"x":false,' +
            '"id":3456,' +
            '"category":"c",' +
            '"bumper":""' +
        '}' +
  ']}';
end;

function TFibbageXLQuestionsLoader.QuestionJSON1: string;
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

function TFibbageXLQuestionsLoader.QuestionJSON2: string;
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
            '"v":"b",' +
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

function TFibbageXLQuestionsLoader.QuestionJSON3: string;
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
            '"v":"s31,s32,s33",' +
            '"n":"Suggestions"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"c",' +
            '"n":"Category"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"text3",' +
            '"n":"CorrectText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"None",' +
            '"n":"BumperType"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"question3",' +
            '"n":"QuestionText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"as31, as32",' +
            '"n":"AlternateSpellings"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"n":"BumperAudio"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"v":"ca3",' +
            '"n":"CorrectAudio"' +
        '},' +
        '{' +
            '"t":"A",' +
            '"v":"qa3",' +
            '"n":"QuestionAudio"' +
        '}' +
    ']' +
  '}';
end;

procedure TFibbageXLQuestionsLoader.SetUp;
begin
  FReader := TTestXLReader.Create('');
end;

procedure TFibbageXLQuestionsLoader.should_load_final_questions;
begin
  FReader.FQuestionData.CategoryData := CategoryJSON_3;
  FReader.FQuestionData.QuestionData.Add('1234', QuestionJSON1);
  FReader.FQuestionData.QuestionData.Add('2345', QuestionJSON2);
  FReader.FQuestionData.QuestionData.Add('3456', QuestionJSON3);

  var loader := TFibbageXLQuestions_Final.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(3, loader.Count, '1');

  Assert.AreEqual(CategoryJSON_3, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON1, loader[0].GetJSON);
  Assert.AreEqual(QuestionJSON2, loader[1].GetJSON);
  Assert.AreEqual(QuestionJSON3, loader[2].GetJSON);

  loader.Free;
end;

procedure TFibbageXLQuestionsLoader.should_load_shortie_questions;
begin
  FReader.FQuestionData.CategoryData := CategoryJSON_3;
  FReader.FQuestionData.QuestionData.Add('1234', QuestionJSON1);
  FReader.FQuestionData.QuestionData.Add('2345', QuestionJSON2);
  FReader.FQuestionData.QuestionData.Add('3456', QuestionJSON3);

  var loader := TFibbageXLQuestions_Shortie.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(3, loader.Count, '1');

  Assert.AreEqual(CategoryJSON_3, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON1, loader[0].GetJSON);
  Assert.AreEqual(QuestionJSON2, loader[1].GetJSON);
  Assert.AreEqual(QuestionJSON3, loader[2].GetJSON);

  loader.Free;
end;

procedure TFibbageXLQuestionsLoader.TearDown;
begin
  FReader.Free;
end;

{ TTestXLReader }

procedure TTestXLReader.DoRead;
begin
  {}
end;

function TTestXLReader.FileExists;
begin
  Result := True;
end;

initialization

  TDUnitX.RegisterTestFixture(TFibbageXLQuestionsLoader);

end.
