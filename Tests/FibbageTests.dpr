program FibbageTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  TestuFibbageXL in 'TestuFibbageXL.pas',
  uInterfaces in '..\Source\uInterfaces.pas',
  uLog in '..\Source\uLog.pas',
  uFibbageContent in '..\Source\uFibbageContent.pas',
  uQuestionsLoader in '..\Source\uQuestionsLoader.pas',
  uFibbageFilesReader in '..\Source\uFibbageFilesReader.pas',
  uContentConfiguration in '..\Source\uContentConfiguration.pas',
  uFibbageJSONWriter in '..\Source\uFibbageJSONWriter.pas',
  uFibbageXLQuestions in '..\Source\FibbageXL\uFibbageXLQuestions.pas',
  TestuFibbage3 in 'TestuFibbage3.pas',
  uFibbage3Questions in '..\Source\JackboxPartyPack4\uFibbage3Questions.pas',
  TestuFibbage2 in 'TestuFibbage2.pas',
  uFibbage2Questions in '..\Source\JackboxPartyPack2\uFibbage2Questions.pas',
  TestuFibbage4 in 'TestuFibbage4.pas',
  uFibbage4Questions in '..\Source\JackboxPartyPack9\uFibbage4Questions.pas';

begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    var runner: ITestRunner;
    var results: IRunResults;
    var logger: ITestLogger;
    var nunitLogger : ITestLogger;

    TDUnitX.CheckCommandLine;
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := True;
    runner.FailsOnNoAsserts := False;
    TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;

    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
