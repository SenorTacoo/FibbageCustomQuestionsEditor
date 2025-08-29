unit TestuFibbage4;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Collections,
  uFibbageFilesReader,
  uFibbage4Questions;

type
  TTestReader = class(TFibbageFilesReader)
  protected
    procedure DoRead(const ACategoryFile, AQuestionsDirectory: string); override;
  public
    function FileExists(const AFile: string): Boolean; override;
  end;

  [TestFixture]
  TFibbage4QuestionsLoader = class
  private
    FReader: TTestReader;

    function CategoriesJSON_Blankie: string;
    function CategoriesJSON_Final: string;

    function QuestionJSON_Blankie: string;
    function QuestionJSON_Final: string;
  public
    [SetUp]
    procedure SetUp;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure should_load_blankie_questions;
    [Test]
    procedure should_load_final_questions;
  end;

implementation

{ TFibbage4QuestionsLoader }

function TFibbage4QuestionsLoader.CategoriesJSON_Blankie: string;
begin
  Result := '{' +
    '"content":[' +
      '{' +
        '"alternateSpellings":[' +
            '"Hanes Underwear",' +
            '"Underware",' +
            '"Briefs",' +
            '"New Underwear",' +
            '"underwear",' +
            '"underpants"' +
          '],' +
          '"bumper":"None",' +
          '"category":"Vacation Blues",' +
          '"correctText":"Underwear",' +
          '"extraCategories":[],' +
          '"id":"86593",' +
          '"isValid":"",' +
          '"personal":"",' +
          '"portrait":false,' +
          '"questionText":"In 2009, a Florida man filed a lawsuit claiming his dream trip to Hawai''i was ruined by defective {{BLANK}}.",' +
          '"suggestions":[' +
            '"cell service",' +
            '"luaus",' +
            '"leis",' +
            '"pineapples",' +
            '"hula dancing",' +
            '"volcanic ash",' +
            '"a shard of obsidian",' +
            '"macadamia chocolates",' +
            '"airplane seat",' +
            '"Hamburgers",' +
            '"Orchids",' +
            '"Showers",' +
            '"Jacuzzis",' +
            '"Wave Pools",' +
            '"Surf Boards",' +
            '"Inner tubes",' +
            '"Beer",' +
            '"Waterslides"' +
            '],' +
          '"us":false,' +
          '"x":true' +
        '}]}';
end;

function TFibbage4QuestionsLoader.CategoriesJSON_Final: string;
begin
  Result := '{' +
  '"content":[' +
  '{' +
   '"alternateSpellings1":[' +
    '"the climate emergency",' +
    '"global warming"' +
   '],' +
   '"alternateSpellings2":[' +
    '"naked hiking"' +
   '],' +
   '"correctText1":"Climate Change",' +
   '"correctText2":"Hiking Naked",' +
   '"id":"89032",' +
   '"isValid":"",' +
   '"questionText1":"As a form of protest, New Belgium Brewing made a conceptual beer that was supposed to taste like {{BLANK}}.",' +
   '"questionText2":"Due to annoyance, the people of the Appenzell Alps got the highest court of Switzerland to ban {{BLANK}}.",' +
   '"suggestions":[' +
    '"sarcasm",' +
    '"goat turds",' +
    '"fruit bats",' +
    '"rubber tires",' +
    '"the yeti",' +
    '"lipstick",' +
    '"IKEA furniture",' +
    '"hairspray",' +
    '"cat hair",' +
    '"band aids",' +
    '"old currency",' +
    '"Sesame Street",' +
    '"toilet water",' +
    '"spray paint",' +
    '"mermaids",' +
    '"beef jerky",' +
    '"movie theaters",' +
    '"green M&M''s"' +
   '],' +
   '"us":false,' +
   '"x":true' +
    '}]}';
end;

function TFibbage4QuestionsLoader.QuestionJSON_Blankie: string;
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
   '"n":"HasKeywordAudio"' +
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
   '"t":"A",' +
   '"v":"bumperAudio",' +
   '"n":"BumperAudio"' +
  '},' +
  '{' +
   '"t":"A",' +
   '"v":"correctAnswer",' +
   '"n":"CorrectAudio"' +
  '},' +
  '{' +
   '"t":"A",' +
   '"v":"questionAudio",' +
   '"n":"QuestionAudio"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasPic"' +
  '},' +
  '{' +
   '"t":"G",' +
   '"v":"picture",' +
   '"n":"Pic"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasSetupVideo"' +
  '},' +
  '{' +
   '"t":"",' +
   '"v":"setupVideo",' +
   '"n":"SetupVideo"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasSetupAudio"' +
  '},' +
  '{' +
   '"t":"A",' +
   '"v":"setupAudio",' +
   '"n":"SetupAudio"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasFeaturedStill"' +
  '},' +
  '{' +
   '"t":"G",' +
   '"v":"featuredStill",' +
   '"n":"FeaturedStill"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasTransitionStill"' +
  '},' +
  '{' +
   '"t":"G",' +
   '"v":"transitionStill",' +
   '"n":"TransitionStill"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasSetupSubtitles"' +
  '},' +
  '{' +
   '"t":"",' +
   '"v":"setupSubtitles",' +
   '"n":"SetupSubtitles"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasRevealVideo"' +
  '},' +
  '{' +
   '"t":"",' +
   '"v":"revealVideo",' +
   '"n":"RevealVideo"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasRevealAudio"' +
  '},' +
  '{' +
   '"t":"A",' +
   '"v":"revealAudio",' +
   '"n":"RevealAudio"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"false",' +
   '"n":"HasRevealSubtitles"' +
  '},' +
  '{' +
   '"t":"",' +
   '"v":"revealSubtitles",' +
   '"n":"RevealSubtitles"' +
  '}]}';
end;

function TFibbage4QuestionsLoader.QuestionJSON_Final: string;
begin
  Result := '{' +
 '"fields":[' +
  '{' +
   '"t":"B",' +
   '"v":"true",' +
   '"n":"HasQuestionAudio1"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"true",' +
   '"n":"HasQuestionAudio2"' +
  '},' +
  '{' +
   '"t":"B",' +
   '"v":"true",' +
   '"n":"HasCorrectAudio"' +
  '},' +
  '{' +
   '"t":"A",' +
   '"v":"questionAudio1",' +
   '"n":"QuestionAudio1"' +
  '},' +
  '{' +
   '"t":"A",' +
   '"v":"questionAudio2",' +
   '"n":"QuestionAudio2"' +
  '},' +
  '{' +
   '"t":"A",' +
   '"v":"correctAnswer1",' +
   '"n":"CorrectAudio"' +
  '}]}';
end;

procedure TFibbage4QuestionsLoader.SetUp;
begin
  FReader := TTestReader.Create('');
end;

procedure TFibbage4QuestionsLoader.should_load_final_questions;
begin
  FReader.FQuestionData.CategoryData := CategoriesJSON_Final;
  FReader.FQuestionData.QuestionData.Add('89032', QuestionJSON_Final);

  var loader := TFibbage4Questions_Final.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(1, loader.Count, '1');

  Assert.AreEqual(CategoriesJSON_Final, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON_Final, loader[0].GetJSON);

  loader.Free;
end;

procedure TFibbage4QuestionsLoader.should_load_blankie_questions;
begin
  FReader.FQuestionData.CategoryData := CategoriesJSON_Blankie;
  FReader.FQuestionData.QuestionData.Add('86593', QuestionJSON_Blankie);

  var loader := TFibbage4Questions_Blankie.Create;

  loader.Initialize(FReader);

  Assert.AreEqual(1, loader.Count, '1');

  Assert.AreEqual(CategoriesJSON_Blankie, loader.GetCategoriesJSON);
  Assert.AreEqual(QuestionJSON_Blankie, loader[0].GetJSON);

  loader.Free;
end;

procedure TFibbage4QuestionsLoader.TearDown;
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

  TDUnitX.RegisterTestFixture(TFibbage4QuestionsLoader);

end.
