unit uQuestionsLoaderTests;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Collections,
  uFibbageFilesReader,
  uQuestionsLoader;

type
  TTestXLReader = class(TFibbageFilesReader)
  public
    procedure Read(const AType: string); override;
  end;

  [TestFixture]
  TFibbageXLQuestionsLoader = class
  private
    FReader: TTestXLReader;
    procedure AddQuestionData;
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

procedure TFibbageXLQuestionsLoader.AddQuestionData;
begin
var data := TQuestionData.Create;
  data.CategoryData :=
  '''
  {
    "content": [
        {
            "x": true,
            "id": 1234,
            "category": "a",
            "bumper": ""
        },
        {
            "x": false,
            "id": 2345,
            "category": "b",
            "bumper": ""
        },
        {
            "x": false,
            "id": 3456,
            "category": "c",
            "bumper": ""
        }
  ]}
  ''';
  data.QuestionData.Add('1234',
  '''
   {
    "fields": [
        {
            "t": "B",
            "v": "false",
            "n": "HasBumperAudio"
        },
        {
            "t": "B",
            "v": "false",
            "n": "HasBumperType"
        },
        {
            "t": "B",
            "v": "true",
            "n": "HasCorrectAudio"
        },
        {
            "t": "B",
            "v": "true",
            "n": "HasQuestionAudio"
        },
        {
            "t": "S",
            "v": "s1,s2,s3",
            "n": "Suggestions"
        },
        {
            "t": "S",
            "v": "a",
            "n": "Category"
        },
        {
            "t": "S",
            "v": "text1",
            "n": "CorrectText"
        },
        {
            "t": "S",
            "v": "None",
            "n": "BumperType"
        },
        {
            "t": "S",
            "v": "question1",
            "n": "QuestionText"
        },
        {
            "t": "S",
            "v": "as1, as2",
            "n": "AlternateSpellings"
        },
        {
            "t": "A",
            "n": "BumperAudio"
        },
        {
            "t": "A",
            "v": "ca1",
            "n": "CorrectAudio"
        },
        {
            "t": "A",
            "v": "qa1",
            "n": "QuestionAudio"
        }
    ]
  }
  '''
  );

  data.QuestionData.Add('2345',
  '''
   {
    "fields": [
        {
            "t": "B",
            "v": "false",
            "n": "HasBumperAudio"
        },
        {
            "t": "B",
            "v": "false",
            "n": "HasBumperType"
        },
        {
            "t": "B",
            "v": "true",
            "n": "HasCorrectAudio"
        },
        {
            "t": "B",
            "v": "true",
            "n": "HasQuestionAudio"
        },
        {
            "t": "S",
            "v": "s20,s21,s22",
            "n": "Suggestions"
        },
        {
            "t": "S",
            "v": "b",
            "n": "Category"
        },
        {
            "t": "S",
            "v": "text2",
            "n": "CorrectText"
        },
        {
            "t": "S",
            "v": "None",
            "n": "BumperType"
        },
        {
            "t": "S",
            "v": "question2",
            "n": "QuestionText"
        },
        {
            "t": "S",
            "v": "as20, as21",
            "n": "AlternateSpellings"
        },
        {
            "t": "A",
            "n": "BumperAudio"
        },
        {
            "t": "A",
            "v": "ca2",
            "n": "CorrectAudio"
        },
        {
            "t": "A",
            "v": "qa2",
            "n": "QuestionAudio"
        }
    ]
  }
  '''
  );

  data.QuestionData.Add('3456',
  '''
   {
    "fields": [
        {
            "t": "B",
            "v": "false",
            "n": "HasBumperAudio"
        },
        {
            "t": "B",
            "v": "false",
            "n": "HasBumperType"
        },
        {
            "t": "B",
            "v": "true",
            "n": "HasCorrectAudio"
        },
        {
            "t": "B",
            "v": "true",
            "n": "HasQuestionAudio"
        },
        {
            "t": "S",
            "v": "s31,s32,s33",
            "n": "Suggestions"
        },
        {
            "t": "S",
            "v": "c",
            "n": "Category"
        },
        {
            "t": "S",
            "v": "text3",
            "n": "CorrectText"
        },
        {
            "t": "S",
            "v": "None",
            "n": "BumperType"
        },
        {
            "t": "S",
            "v": "question3",
            "n": "QuestionText"
        },
        {
            "t": "S",
            "v": "as31, as32",
            "n": "AlternateSpellings"
        },
        {
            "t": "A",
            "n": "BumperAudio"
        },
        {
            "t": "A",
            "v": "ca3",
            "n": "CorrectAudio"
        },
        {
            "t": "A",
            "v": "qa3",
            "n": "QuestionAudio"
        }
    ]
  }
  '''
  );
  FReader.FQuestions.Add(data);
end;

procedure TFibbageXLQuestionsLoader.SetUp;
begin
  FReader := TTestXLReader.Create;
end;

procedure TFibbageXLQuestionsLoader.should_load_final_questions;
begin
end;

procedure TFibbageXLQuestionsLoader.should_load_shortie_questions;
const
  EXPECTED_JSON_1 =
  '{' +
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
        '}]' +
  '}';
begin
  AddQuestionData;
  var loader := TFibbageXLQuestions.Create;

  loader.Initialize(FReader, '');

  Assert.AreEqual(3, loader.Count, '1');
//  Assert.AreEqual(3, loader[0].GetCategoryJSON, '2');

  Assert.AreEqual(EXPECTED_JSON_1, loader.GetCategoriesJSON);

  loader.Free;
end;

procedure TFibbageXLQuestionsLoader.TearDown;
begin
  FReader.Free;
end;

{ TTestXLReader }

procedure TTestXLReader.Read;
begin
  {}
end;

initialization

  TDUnitX.RegisterTestFixture(TFibbageXLQuestionsLoader);

end.
