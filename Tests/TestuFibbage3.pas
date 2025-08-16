unit TestuFibbage3;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Collections,
  uFibbageFilesReader,
  uFibbage3Questions;

type
  TTestReader = class(TFibbageFilesReader)
  protected
    procedure DoRead(const ACategoryFile, AQuestionsDirectory: string); override;
  public
    function FileExists(const AFile: string): Boolean; override;
  end;

  [TestFixture]
  TFibbage3QuestionsLoader = class
  private
    FReader: TTestReader;

    function CategoriesJSON_TMI: string;
    function CategoriesJSON: string;
    function CategoriesJSON_Special: string;

    function QuestionJSON: string;
    function QuestionJSON_Special: string;
    function QuestionJSON_TMI: string;
  public
    [SetUp]
    procedure SetUp;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure should_load_shortie_questions;
    [Test]
    procedure should_load_final_questions;
    [Test]
    procedure should_load_special_questions;
    [Test]
    procedure should_load_tmishortie_questions;
  end;

implementation

{ TFibbage3QuestionsLoader }

function TFibbage3QuestionsLoader.CategoriesJSON: string;
begin
  Result := '{'+
    '"episodeid":1307,'+
    '"content":['+
    '{'+
    '"x":false,'+
    '"personal":"",'+
    '"id":43520,'+
    '"portrait":false,'+
    '"category":"Presidential Gambling",'+
    '"bumper":"",'+
    '"us":false'+
    '}]}';
end;

function TFibbage3QuestionsLoader.CategoriesJSON_Special: string;
begin
  Result := '{'+
    '"episodeid":1317,'+
    '"content":['+
    '{'+
    '"x":true,'+
    '"personal":"",'+
    '"id":43504,'+
    '"portrait":false,'+
    '"category":"Wot’s Weeth The Sheep?",'+
    '"bumper":"Russian",'+
    '"us":false'+
    '}]}';
end;

function TFibbage3QuestionsLoader.CategoriesJSON_TMI: string;
begin
  Result := '{' +
    '"episodeid":1309,' +
    '"content":[' +
      '{' +
        '"x":false,' +
        '"personal":"What celebrity do you think you should be best friends with?",' +
        '"id":48783,' +
        '"portrait":false,' +
        '"category":"",' +
        '"bumper":"",' +
        '"us":false' +
      '}]}';
end;

function TFibbage3QuestionsLoader.QuestionJSON: string;
begin
  Result:= '{'+
    '"fields":['+
      '{'+
        '"t":"B",'+
        '"v":"false",'+
        '"n":"HasBumperAudio"'+
      '},'+
      '{'+
        '"t":"B",'+
        '"v":"false",'+
        '"n":"HasKeywordAudio"'+
      '},'+
      '{'+
        '"t":"B",'+
        '"v":"false",'+
        '"n":"HasBumperType"'+
      '},'+
      '{'+
        '"t":"B",'+
        '"v":"false",'+
        '"n":"HasCorrectAudio"'+
      '},'+
      '{'+
        '"t":"B",'+
        '"v":"true",'+
        '"n":"HasQuestionAudio"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"stationary,furniture,rugs,portraits,keys,drapes,statues,lamps,Lincoln bedroom linens,chandeliers,rose garden,map collection,pastry chef,guard dog,bathtub,welcome mats,library,decorative napkins",' +
        '"n":"Suggestions"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"",'+
        '"n":"PersonalQuestionText"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"Presidential Gambling",' +
        '"n":"Category"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"china",'+
        '"n":"CorrectText"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"None",'+
        '"n":"BumperType"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"President Warren G. Harding was a fan of poker. In one game he ended up gambling away the White House <BLANK>.",' +
        '"n":"QuestionText"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"",'+
        '"n":"SocialMediaDate"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"",'+
        '"n":"KeywordResponse"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"",'+
        '"n":"SocialMediaName"'+
      '},'+
      '{'+
        '"t":"S",'+
        '"v":"dishes,fine china,plates,silverware",' +
        '"n":"AlternateSpellings"'+
      '},'+
      '{'+
        '"s":"[category=host]",'+
        '"t":"A",'+
        '"n":"KeywordResponseAudio"'+
      '},'+
      '{'+
        '"s":"[category=host]",'+
        '"t":"A",'+
        '"n":"BumperAudio"'+
      '},'+
      '{'+
        '"t":"G",'+
        '"n":"Pic"'+
      '},'+
      '{'+
        '"s":"[category=host]",'+
        '"t":"A",'+
        '"n":"CorrectAudio"'+
      '},'+
      '{'+
        '"s":"[category=host]",'+
        '"t":"A",'+
        '"v":"317630_0",'+
        '"n":"QuestionAudio"'+
      '}]}';
end;

function TFibbage3QuestionsLoader.QuestionJSON_Special: string;
begin
  Result := '{' +
    '"fields":[' +
      '{' +
        '"t":"B",' +
        '"v":"true",' +
        '"n":"HasBumperAudio"' +
      '},' +
      '{' +
        '"t":"B",' +
        '"v":"false",' +
        '"n":"HasKeywordAudio"' +
      '},' +
      '{' +
        '"t":"B",' +
        '"v":"true",' +
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
        '"v":"ugly,skinny,dead,bald,drunk,sexy,limping,wolf-like,dumb,talking,hairless,smart,black,waxy,tall,eaten,burping,decomposing",' +
        '"n":"Suggestions"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"",' +
        '"n":"PersonalQuestionText"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"Wot’s Weeth The Sheep?",' +
        '"n":"Category"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"scabby",' +
        '"n":"CorrectText"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"Russian",' +
        '"n":"BumperType"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"A Russian phrase similar to “One bad apple spoils the whole bunch” translates to “The <BLANK> sheep spoils the whole flock.”",' +
        '"n":"QuestionText"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"",' +
        '"n":"SocialMediaDate"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"",' +
        '"n":"KeywordResponse"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"",' +
        '"n":"SocialMediaName"' +
      '},' +
      '{' +
        '"t":"S",' +
        '"v":"scabbed",' +
        '"n":"AlternateSpellings"' +
      '},' +
      '{' +
        '"s":"[category=host]",' +
        '"t":"A",' +
        '"n":"KeywordResponseAudio"' +
      '},' +
      '{' +
        '"s":"[category=host]",' +
        '"t":"A",' +
        '"v":"563937_0",' +
        '"n":"BumperAudio"' +
      '},' +
      '{' +
        '"t":"G",' +
        '"n":"Pic"' +
      '},' +
      '{' +
        '"s":"[category=host]",' +
        '"t":"A",' +
        '"v":"563935_0",' +
        '"n":"CorrectAudio"' +
      '},' +
      '{' +
        '"s":"[category=host]",' +
        '"t":"A",' +
        '"v":"563932_1",' +
        '"n":"QuestionAudio"' +
      '}]}';
end;

function TFibbage3QuestionsLoader.QuestionJSON_TMI: string;
begin
  Result:= '{' +
    '"fields":[' +
        '{' +
            '"t":"B",' +
            '"v":"false",' +
            '"n":"HasBumperAudio"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"false",' +
            '"n":"HasKeywordAudio"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"false",' +
            '"n":"HasBumperType"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"false",' +
            '"n":"HasCorrectAudio"' +
        '},' +
        '{' +
            '"t":"B",' +
            '"v":"true",' +
            '"n":"HasQuestionAudio"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"Channing Tatum,John Cena,Beyonce,Taylor Swift,Kevin Hart,Jennifer Lawrence,Ellen DeGeneres",' +
            '"n":"Suggestions"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"What celebrity do you think you should be best friends with?",' +
            '"n":"PersonalQuestionText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"",' +
            '"n":"Category"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"",' +
            '"n":"CorrectText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"None",' +
            '"n":"BumperType"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"The celebrity that <PLAYER> thinks they should be best friends with is <BLANK>.",' +
            '"n":"QuestionText"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"",' +
            '"n":"SocialMediaDate"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"",' +
            '"n":"KeywordResponse"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"",' +
            '"n":"SocialMediaName"' +
        '},' +
        '{' +
            '"t":"S",' +
            '"v":"",' +
            '"n":"AlternateSpellings"' +
        '},' +
        '{' +
            '"s":"[category=host]",' +
            '"t":"A",' +
            '"n":"KeywordResponseAudio"' +
        '},' +
        '{' +
            '"s":"[category=host]",' +
            '"t":"A",' +
            '"n":"BumperAudio"' +
        '},' +
        '{' +
            '"t":"G",' +
            '"n":"Pic"' +
        '},' +
        '{' +
            '"s":"[category=host]",' +
            '"t":"A",' +
            '"n":"CorrectAudio"' +
        '},' +
        '{' +
            '"s":"[category=host]",' +
            '"t":"A",' +
            '"v":"697324_0",' +
            '"n":"QuestionAudio"' +
        '}]}';
end;

procedure TFibbage3QuestionsLoader.SetUp;
begin
  FReader := TTestReader.Create('');
end;

procedure TFibbage3QuestionsLoader.should_load_final_questions;
begin
  FReader.FQuestionData.CategoryData := CategoriesJSON;
  FReader.FQuestionData.QuestionData.Add('43520', QuestionJSON);

  var loader := TFibbage3Questions_Final.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(1, loader.Count, '1');

  Assert.AreEqual(CategoriesJSON, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON, loader[0].GetJSON);
  
  loader.Free;
end;

procedure TFibbage3QuestionsLoader.should_load_shortie_questions;
begin
  FReader.FQuestionData.CategoryData := CategoriesJSON;
  FReader.FQuestionData.QuestionData.Add('43520', QuestionJSON);

  var loader := TFibbage3Questions_Shortie.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(1, loader.Count, '1');

  Assert.AreEqual(CategoriesJSON, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON, loader[0].GetJSON);

  loader.Free;
end;

procedure TFibbage3QuestionsLoader.should_load_special_questions;
begin
  FReader.FQuestionData.CategoryData := CategoriesJSON_Special;
  FReader.FQuestionData.QuestionData.Add('43504', QuestionJSON_Special);

  var loader := TFibbage3Questions_Special.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(1, loader.Count, '1');

  Assert.AreEqual(CategoriesJSON_Special, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON_Special, loader[0].GetJSON);

  loader.Free;
end;

procedure TFibbage3QuestionsLoader.should_load_tmishortie_questions;
begin
  FReader.FQuestionData.CategoryData := CategoriesJSON_TMI;
  FReader.FQuestionData.QuestionData.Add('48783', QuestionJSON_TMI);

  var loader := TFibbage3Questions_TmiShortie.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(1, loader.Count, '1');

  Assert.AreEqual(CategoriesJSON_TMI, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON_TMI, loader[0].GetJSON);

  loader.Free;
end;

procedure TFibbage3QuestionsLoader.TearDown;
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

  TDUnitX.RegisterTestFixture(TFibbage3QuestionsLoader);

end.
