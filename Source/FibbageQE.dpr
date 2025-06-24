program FibbageQE;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMainForm in 'uMainForm.pas' {FrmMain},
  uConfig in 'uConfig.pas',
  uInterfaces in 'uInterfaces.pas',
  uPathChecker in 'uPathChecker.pas',
  uQuestionsLoader in 'uQuestionsLoader.pas',
  uCategoriesLoader in 'uCategoriesLoader.pas',
  uFibbageContent in 'uFibbageContent.pas',
  uRecordForm in 'uRecordForm.pas' {RecordForm},
  uLastQuestionsLoader in 'uLastQuestionsLoader.pas',
  uLog in 'uLog.pas',
  uGetTextDlg in 'uGetTextDlg.pas' {GetTextDlg},
  uContentConfiguration in 'uContentConfiguration.pas',
  uAsyncAction in 'uAsyncAction.pas',
  uProjectActivator in 'uProjectActivator.pas',
  uUserDialog in 'uUserDialog.pas' {UserDialog};

{$R *.res}

begin
  {$ifdef debug}
  ReportMemoryLeaksOnShutdown := True;
  {$endif}
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
