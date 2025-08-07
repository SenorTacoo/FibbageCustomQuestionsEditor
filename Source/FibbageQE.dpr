program FibbageQE;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMainForm in 'uMainForm.pas' {FrmMain},
  uConfig in 'uConfig.pas',
  uInterfaces in 'uInterfaces.pas',
  uPathChecker in 'uPathChecker.pas',
  uLastQuestionsLoader in 'uLastQuestionsLoader.pas',
  uLog in 'uLog.pas',
  uGetTextDlg in 'uGetTextDlg.pas' {GetTextDlg},
  uContentConfiguration in 'uContentConfiguration.pas',
  uAsyncAction in 'uAsyncAction.pas',
  uProjectActivator in 'uProjectActivator.pas',
  uUserDialog in 'uUserDialog.pas' {UserDialog},
  uGetGameTypeDlg in 'uGetGameTypeDlg.pas' {GetGameTypeDlg},
  uFibbageContent in 'uFibbageContent.pas',
  uFibbageFilesReader in 'uFibbageFilesReader.pas',
  uFibbageJSONWriter in 'uFibbageJSONWriter.pas',
  uQuestionsLoader in 'uQuestionsLoader.pas',
  uEditQuestionFrame in 'GUI\uEditQuestionFrame.pas' {FrmEditQuestion: TFrame},
  uEditableStringItemFrame in 'GUI\uEditableStringItemFrame.pas' {FrmEditableStringItem: TFrame},
  uEditableU32ItemFrame in 'GUI\uEditableU32ItemFrame.pas' {FrmEditableU32Item: TFrame},
  uEditableBoolItemFrame in 'GUI\uEditableBoolItemFrame.pas' {FrmEditableBoolItem: TFrame},
  uEditableLongStringItemFrame in 'GUI\uEditableLongStringItemFrame.pas' {FrmEditableLongStringItem: TFrame},
  uEditableAudioItemFrame in 'GUI\uEditableAudioItemFrame.pas' {FrmEditableAudioItem: TFrame},
  uFibbageContentFactory in 'uFibbageContentFactory.pas',
  uFibbageXLContent in 'FibbageXL\uFibbageXLContent.pas',
  uFibbageXLQuestions in 'FibbageXL\uFibbageXLQuestions.pas';

{$R *.res}

begin
  {$ifdef debug}
  ReportMemoryLeaksOnShutdown := True;
  {$endif}
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
