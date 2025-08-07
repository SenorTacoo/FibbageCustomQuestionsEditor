unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.MultiView, FMX.TabControl,
  System.Actions, FMX.ActnList, FMX.StdActns, FMX.Layouts, uConfig,
  uInterfaces, uPathChecker, System.IOUtils,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, Data.Bind.GenData, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.ObjectScope, FMX.Platform, System.Math,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Media,
  ACS_Classes, ACS_DXAudio, ACS_Vorbis, ACS_Converters, ACS_Wave,
  NewACDSAudio, System.Generics.Collections, uRecordForm, FMX.ListBox, 
  System.Messaging, System.DateUtils, uLog,
  FMX.Menus, System.StrUtils, uGetTextDlg, FMX.Objects, FMX.DialogService, uAsyncAction,
  uContentConfiguration, uProjectActivator, uLastQuestionsLoader,
  FMX.Effects, Winapi.Windows, Winapi.ShellAPI, FMX.Platform.Win, Grijjy.CloudLogging,
  uUserDialog, uGetGameTypeDlg, uQuestionsLoader, uFibbageContent,
  uEditQuestionFrame;

type
  TQuestionScrollItem = class(TPanel)
  private
    FDetails: TLabel;
    FQuestion: TLabel;
    FOrgQuestion: TFibbageQuestion;
    FSelected: Boolean;
    procedure SetSelected(const Value: Boolean);
  protected
    procedure Resize; override;
  public
    constructor CreateItem(AOwner: TComponent; AQuestion: TFibbageQuestion);
    procedure RefreshData;

    property Selected: Boolean read FSelected write SetSelected;
    property OrgQuestion: TFibbageQuestion read FOrgQuestion write FOrgQuestion;
  end;

  TQuestionScrollItems = class(TList<TQuestionScrollItem>)
  public
    procedure ClearSelection;
    procedure SelectAll;
    function SelectedCount: Integer;
    procedure SelectNext;
    procedure SelectPrev;
    function Selected: TQuestionScrollItem;
    procedure Select(AQuestion: TFibbageQuestion);
  end;

  TProjectScrollItem = class(TPanel)
  private
    FName: TLabel;
    FPath: TLabel;
    FOrgConfiguration: TContentConfiguration;
    FSelected: Boolean;
    procedure SetSelected(const Value: Boolean);
  protected
    procedure Resize; override;
  public
    constructor CreateItem(AOwner: TComponent; AConfiguration: TContentConfiguration);

    procedure RefreshData;

    property Selected: Boolean read FSelected write SetSelected;
    property OrgConfiguration: TContentConfiguration read FOrgConfiguration;
  end;

  TProjectScrollItems = class(TList<TProjectScrollItem>)
  private
    FOwnerScroll: TCustomScrollBox;
  public
    constructor Create(AOwner: TCustomScrollBox);

    procedure ClearSelection;
    procedure SelectAll;
    function SelectedCount: Integer;
    function Selected: TProjectScrollItem;
    procedure SelectNext;
    procedure SelectPrev;
  end;

  TAppTab = (atHomeBeforeImport, atHome, atQuestions, atSingleQuestion);

  TFrmMain = class(TForm)
    mvHomeOptions: TMultiView;
    bMenu: TButton;
    bImportQuestions: TButton;
    alMain: TActionList;
    tcEditTabs: TTabControl;
    tiEditSingleItem: TTabItem;
    aiContentLoading: TAniIndicator;
    lyDarkMode: TLayout;
    sDarkMode: TSwitch;
    lDarkMode: TLabel;
    aGoToQuestionDetails: TChangeTabAction;
    aGoToFinalQuestions: TChangeTabAction;
    aGoToShortieQuestions: TChangeTabAction;
    tiQuestions: TTabItem;
    aGoToAllQuestions: TChangeTabAction;
    sbLightStyle: TStyleBook;
    sbDarkStyle: TStyleBook;
    tiQuestionProjects: TTabItem;
    aGoToHome: TChangeTabAction;
    bQuestions: TButton;
    tbQuestionProjects: TToolBar;
    lProjects: TLabel;
    ToolBar2: TToolBar;
    lProjectQuestions: TLabel;
    gplQuestions: TGridPanelLayout;
    bNewProject: TButton;
    lineTabs: TLine;
    miAddQuestion: TMenuItem;
    miEditQuestion: TMenuItem;
    miRemoveQuestions: TMenuItem;
    aRemoveQuestions: TAction;
    aAddQuestion: TAction;
    pmQuestions: TPopupMenu;
    aEditQuestion: TAction;
    lyProjectsContent: TLayout;
    lyQuestionsContent: TLayout;
    mvQuestionsOptions: TMultiView;
    bQuestionsMenu: TButton;
    bSaveQuestions: TButton;
    Layout1: TLayout;
    sDarkModeOptions: TSwitch;
    lDarkModeOptions: TLabel;
    bGoToHome: TButton;
    bAddQuestion: TButton;
    bRemoveQuestions: TButton;
    Line1: TLine;
    Line2: TLine;
    aNewProject: TAction;
    aSaveProject: TAction;
    aImportProject: TAction;
    bRemoveProjects: TButton;
    aRemoveProjects: TAction;
    Line3: TLine;
    sbxProjects: TVertScrollBox;
    aInitializeProject: TAction;
    pmProjects: TPopupMenu;
    miAddProject: TMenuItem;
    miEditProjectDetails: TMenuItem;
    miRemoveProject: TMenuItem;
    miImportProject: TMenuItem;
    aEditProjectName: TAction;
    miAddSeparator: TMenuItem;
    miEditSeparator: TMenuItem;
    aRemoveProjectsAllData: TAction;
    aRemoveProjectsJustLastInfo: TAction;
    miEditProjectQuestions: TMenuItem;
    bSaveQuestionsAs: TButton;
    aSaveProjectAs: TAction;
    pLoading: TPanel;
    pContent: TPanel;
    pQuestionsToolbar: TPanel;
    pProjectsToolbar: TPanel;
    GlowEffect1: TGlowEffect;
    GlowEffect3: TGlowEffect;
    pQuestionsButtons: TPanel;
    pQuestionsMultiview: TPanel;
    pProjectsMultiview: TPanel;
    MenuItem1: TMenuItem;
    miOpenLocal: TMenuItem;
    aOpenInWindowsExplorer: TAction;
    aSaveQuestionChanges: TAction;
    aCancelQuestionChanges: TAction;
    miEditProject: TMenuItem;
    miActivateProject: TMenuItem;
    aSetProjectAsActive: TAction;
    MenuItem2: TMenuItem;
    aCopyToFinalQuestions: TAction;
    aMoveToFinalQuestions: TAction;
    aCopyToShortieQuestions: TAction;
    aMoveToShortieQuestions: TAction;
    bSettings: TButton;
    aGoToSettings: TChangeTabAction;
    tiSettings: TTabItem;
    ToolBar1: TToolBar;
    Panel1: TPanel;
    lSettings: TLabel;
    GlowEffect4: TGlowEffect;
    bGoBackFromSettings: TButton;
    bCancelChangesSettings: TButton;
    aSaveChangesSettings: TAction;
    aCancelChangesSettings: TAction;
    Layout2: TLayout;
    lSettingsFibbageXLPath: TLabel;
    eSettingsFibbageXLPath: TEdit;
    bSettingsFibbageXLPath: TButton;
    aGetGamePath: TAction;
    aSaveProjectAndClose: TAction;
    cbShowCategoryDuplicatedInfo: TCheckBox;
    cbShowDialogAboutTooFewSuggestions: TCheckBox;
    rDim: TRectangle;
    cbShowDialogAboutTooFewShortieQuestions: TCheckBox;
    Layout4: TLayout;
    bSettingsFibbage3PP4Path: TButton;
    lSettingsFibbage3PP4Path: TLabel;
    eSettingsFibbage3PP4Path: TEdit;
    Layout5: TLayout;
    bSettingsFibbageXLPP1Path: TButton;
    lSettingsFibbagePP1Path: TLabel;
    eSettingsFibbageXLPP1Path: TEdit;
    miMigrate: TMenuItem;
    miMigrateToFibbageXL: TMenuItem;
    miMigrateToFibbage3: TMenuItem;
    aMigrateToFibbageXL: TAction;
    aMigrateToFibbage3: TAction;
    MenuItem4: TMenuItem;
    aMigrateToFibbageXLPartyPack1: TAction;
    aSaveProjectAndInitialize: TAction;
    Layout6: TLayout;
    bSettingsFibbage4PP9Path: TButton;
    lSettingsFibbage4PP9Path: TLabel;
    eSettingsFibbage4PP9Path: TEdit;
    sbxQuestions: TScrollBox;
    frmEditQuestion: TFrmEditQuestion;
    Layout3: TLayout;
    lAudioOutput: TLabel;
    cbAudioOutput: TComboBox;
    Layout7: TLayout;
    cbAudioInput: TComboBox;
    lAudioInput: TLabel;
    DXAudioIn1: TDXAudioIn;
    DSAudioOut1: TDSAudioOut;
    miCopyTo: TMenuItem;
    miMoveTo: TMenuItem;
    procedure lDarkModeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lvEditAllItemsUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure bHomeButtonClick(Sender: TObject);
    procedure bQuestionsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure aRemoveQuestionsExecute(Sender: TObject);
    procedure aAddQuestionExecute(Sender: TObject);
    procedure aEditQuestionExecute(Sender: TObject);
    procedure pmQuestionsPopup(Sender: TObject);
    procedure aNewProjectExecute(Sender: TObject);
    procedure aSaveProjectExecute(Sender: TObject);
    procedure aImportProjectExecute(Sender: TObject);
    procedure bGoToHomeClick(Sender: TObject);
    procedure lDarkModeOptionsClick(Sender: TObject);
    procedure sDarkModeOptionsSwitch(Sender: TObject);
    procedure sDarkModeSwitch(Sender: TObject);
    procedure aRemoveProjectsExecute(Sender: TObject);
    procedure aInitializeProjectExecute(Sender: TObject);
    procedure aEditProjectNameExecute(Sender: TObject);
    procedure pmProjectsPopup(Sender: TObject);
    procedure aRemoveProjectsAllDataExecute(Sender: TObject);
    procedure aRemoveProjectsJustLastInfoExecute(Sender: TObject);
    procedure aSaveProjectAsExecute(Sender: TObject);
    procedure aOpenInWindowsExplorerExecute(Sender: TObject);
    procedure aSaveQuestionChangesExecute(Sender: TObject);
    procedure mDisableEnter(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure aSetProjectAsActiveExecute(Sender: TObject);
    procedure aSaveChangesSettingsExecute(Sender: TObject);
    procedure aCancelChangesSettingsExecute(Sender: TObject);
    procedure bSettingsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure aSaveProjectAndCloseExecute(Sender: TObject);
    procedure bSettingsFibbageXLPathClick(Sender: TObject);
    procedure bSettingsFibbageXLPP1PathClick(Sender: TObject);
    procedure bSettingsFibbage3PP4PathClick(Sender: TObject);
    procedure aSaveProjectAndInitializeExecute(Sender: TObject);
    procedure bSettingsFibbage4PP9PathClick(Sender: TObject);
    procedure cbAudioOutputChange(Sender: TObject);
    procedure cbAudioInputChange(Sender: TObject);
    procedure sbxQuestionsCalcContentBounds(Sender: TObject;
      var ContentBounds: TRectF);
  private
    FAppCreated: Boolean;
    FChangingTab: Boolean;
    FQuestionsChanged: Boolean;
    FContent: TFibbageContent;

    FSelectedQuestion: TFibbageQuestion;
    FSelectedConfiguration: TContentConfiguration;

    FLastQuestionProjects: TLastQuestionsLoader;

    FLastClickedItem: TQuestionScrollItem;
    FLastClickedItemToEdit: TQuestionScrollItem;

    FLastClickedConfiguration: TProjectScrollItem;
    FLastClickedConfigurationToEdit: TProjectScrollItem;

    FQuestionVisItems: TQuestionScrollItems;

    FProjectVisItems: TProjectScrollItems;

    FActiveQuestionsType: string;

    procedure OnUnhandledException(Sender: TObject; E: Exception);
    procedure GoToQuestionDetails;

    procedure AddLastChoosenProject;
    procedure InitializeLastQuestionProjects;
    procedure SetButtonPressed;

    procedure GoToAllQuestions;
    procedure GoToHome;
    procedure GoToSettings;

    procedure PrepareMultiViewButtons(AActTab: TAppTab);
    procedure OnProjectItemDoubleClick(Sender: TObject);
    procedure OnProjectItemMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);

    procedure SetDarkMode(AEnabled: Boolean);
    function GetProjectName(out AName: string): Boolean;
    function GetGameType(out AType: TGameType): Boolean;
    function GetProjectPath(out APath: string): Boolean;
    function GetDestinationPath(out APath: string): Boolean;
    procedure ProcessInitializeProject;
    procedure ClearPreviousQuestions;
    procedure RemoveProjects;
    procedure InitializeContentTask;
    procedure PostContentInitialized;
    procedure PreContentInitialized;
    procedure OnPostSaveAs;
    procedure OnPreSaveAs;
    procedure SaveProc;
    procedure OnPostSave;
    procedure OnPreSave;
    procedure OnRemoveProjectEnd;
    procedure OnRemoveProjectStart;
    procedure ActivateProjectProc;
    procedure StopSplash;
    procedure StartSplash;
    function GetFibbageXLPath(out APath: string): Boolean;
    function GetFibbage3Path(out APath: string): Boolean;
    function GetFibbage4Path(out APath: string): Boolean;
    procedure OnPostSaveClose;
    procedure OnPostSaveInitialize;
    procedure ProcessKeyDown_Questions(var Key: Word; Shift: TShiftState);
    procedure ProcessKeyDown_QuestionsProject(var Key: Word;
      Shift: TShiftState);
    procedure RefreshProjectFormActions;
    procedure RefreshQuestionsFormActions;
    function IsCategoryDuplicated: Boolean;
    function GetFirstQuestionWithDuplicatedCategory(out AType, ACategory: string; out AQuestion: TFibbageQuestion): Boolean;
    function GetFirstQuestionWithTooFewSuggestions(out AType: string; out AQuestion: TFibbageQuestion): Boolean;
    function ShowInfoAboutDuplicatedCategories(const AInfo: string): Boolean;
    function ShowInfoAboutTooFewSuggestions(const AInfo: string): Boolean;
    function ShowInfoAboutTooFewShortieQuestions(const AInfo: string): Boolean;
    function ShowInfoAboutMissingBlanks(const AInfo: string): Boolean;
    function IsTooFewSuggestions: Boolean;
    function GetSingleQuestionSuggestions: string;
    function IsMissingBlanks(out AError: string): Boolean;
    function CheckForDuplicatedCategoriesPreSave: Boolean;
    function CheckForTooFewSuggestions: Boolean;
    function ShouldSaveProject: Boolean;
    function CheckForTooFewShortieQuestions: Boolean;
    procedure InsertNewProject(AConfig: TContentConfiguration);
    function CheckIfFinalQuestionForFibbage3Ok: Boolean;
    function CheckIfFinalQuestionForFibbage4Ok: Boolean;
    function ShowSimpleInfoWithQuestion(const AInfo: string): Boolean;
    procedure ShowSimpleInfo(const AInfo: string);

    procedure SetActiveQuestionsType(const AType: string);
    procedure OnQuestionTypeButtonClick(Sender: TObject);
    procedure OnBeforeQuestionTypeChanged;
    procedure OnAfterQuestionTypeChanged;
    procedure OnQuestionItemMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OnQuestionItemDoubleClick(Sender: TObject);
    procedure FillAudioDevices;
    procedure OnCancelSingleQuestionClick(Sender: TObject);
    procedure OnSaveSingleQuestionClick(Sender: TObject);
    function AddQuestionScrollItem(AQuestion: TFibbageQuestion): TQuestionScrollItem;
    procedure SwitchHighlightQuestionItem(AItem: TQuestionScrollItem; AClearOthers: Boolean);
    procedure UpdateMoveCopyOptions;
    procedure OnCopyQuestionTo(Sender: TObject);
    procedure OnMoveQuestionTo(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

procedure TFrmMain.aAddQuestionExecute(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  var question := FContent.CreateNewQuestion(FActiveQuestionsType);
  sbxQuestions.BeginUpdate;
  try
    FLastClickedItemToEdit := AddQuestionScrollItem(question);
    SwitchHighlightQuestionItem(FLastClickedItemToEdit, True);
  finally
    sbxQuestions.EndUpdate;
  end;
  sbxQuestions.ScrollBy(0, -MaxInt);
  aEditQuestion.Execute;
end;

procedure TFrmMain.aCancelChangesSettingsExecute(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  GoToHome;
end;

procedure TFrmMain.AddLastChoosenProject;
begin
  FLastQuestionProjects.BeginUpdate;
  try
    FLastQuestionProjects.Add(FSelectedConfiguration);
  finally
    FLastQuestionProjects.EndUpdate;
  end;
end;

function TFrmMain.AddQuestionScrollItem(AQuestion: TFibbageQuestion): TQuestionScrollItem;
begin
  Result := TQuestionScrollItem.CreateItem(sbxQuestions, AQuestion);
  Result.Parent := sbxQuestions;
  Result.Align := TAlignLayout.Top;
  Result.Position.Y := MaxInt;
  Result.OnMouseDown := OnQuestionItemMouseDown;
  Result.OnDblClick := OnQuestionItemDoubleClick;

  FQuestionVisItems.Add(Result);
end;

procedure TFrmMain.aEditProjectNameExecute(Sender: TObject);
begin
  if not Assigned(FLastClickedConfiguration) then
    Exit;

  var name := FLastClickedConfiguration.OrgConfiguration.GetName;
  rDim.Visible := True;
  var dlg := TGetTextDlg.Create(Self);
  try
    if not dlg.GetText('Enter project name:', name) then
      Exit;

    var doSave := name <> FLastClickedConfiguration.OrgConfiguration.GetName;

    FLastClickedConfiguration.OrgConfiguration.SetName(name);
    FLastClickedConfiguration.RefreshData;
    if doSave then
      FLastClickedConfiguration.OrgConfiguration.Save(FLastClickedConfiguration.OrgConfiguration.GetPath);
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

procedure TFrmMain.aEditQuestionExecute(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  if not Assigned(FLastClickedItemToEdit) then
    Exit;

  FSelectedQuestion := FLastClickedItemToEdit.OrgQuestion;
  FLastClickedItemToEdit.Selected := True;

  frmEditQuestion.EditQuestion(FSelectedQuestion);

  GoToQuestionDetails;
end;

function TFrmMain.GetDestinationPath(out APath: string): Boolean;
begin
  Result := SelectDirectory('Select destination directory', '', APath);
end;

function TFrmMain.GetFibbage3Path(out APath: string): Boolean;
begin
  Result := SelectDirectory('Select Fibbage3 directory', '', APath);
end;

function TFrmMain.GetFibbage4Path(out APath: string): Boolean;
begin
  Result := SelectDirectory('Select Fibbage4 directory', '', APath);
end;

function TFrmMain.GetFibbageXLPath(out APath: string): Boolean;
begin
  Result := SelectDirectory('Select FibbageXL directory', '', APath);
end;

procedure TFrmMain.aImportProjectExecute(Sender: TObject);
var
  str: string;
  gameType: TGameType;
begin
  var cfg := TContentConfiguration.Create;
  try
    while True do
    begin
      if not GetProjectPath(str) then
        Exit;
      if cfg.Initialize(str) then
        Break;
      if not GetGameType(gameType) then
        Exit;
      if not TContentPathChecker.IsValid(str, gameType) then
      begin
        ShowMessage('Invalid path, needed directories for this game not found');
        Continue;
      end;
      if (gameType = TGameType.Fibbage4PartyPack9) and DirectoryExists(System.IOUtils.TPath.Combine(str, 'en')) then
        cfg.SetPath(System.IOUtils.TPath.Combine(str, 'en'));

      if not GetProjectName(str) then
        Exit;

      cfg.SetName(str);
      cfg.SetGameType(gameType);

      Break;
    end;

    InsertNewProject(cfg);
    cfg := nil;

    aInitializeProject.Execute;
  finally
    cfg.Free;
  end;
end;

procedure TFrmMain.aInitializeProjectExecute(Sender: TObject);
begin
  if Assigned(FContent) and FQuestionsChanged then
  begin
    TDialogService.MessageDialog('Save changes?', TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel], TMsgDlgBtn.mbCancel, 0,
      procedure (const AResult: TModalResult)
      begin
        case AResult of
          mrYes:
          begin
            aSaveProjectAndInitialize.Execute;
            Exit;
          end;
          mrCancel: Exit;
        end;
        ProcessInitializeProject;
      end);
  end
  else
    ProcessInitializeProject;
end;

procedure TFrmMain.ProcessInitializeProject;
begin
  FQuestionsChanged := False;
  FSelectedConfiguration := nil;
  for var item in FProjectVisItems do
    if item.Selected then
    begin
      FSelectedConfiguration := item.OrgConfiguration;
      Break;
    end;

  if not Assigned(FSelectedConfiguration) then
  begin
    LogE('ProcessInitializeProject selected configuration not assigned, selected count: %d/%d', [FProjectVisItems.SelectedCount, FProjectVisItems.Count]);
    Exit;
  end;
  ClearPreviousQuestions;
  TAppConfig.GetInstance.LastEditPath := FSelectedConfiguration.GetPath;

  TAsyncAction.Create(PreContentInitialized, PostContentInitialized, InitializeContentTask).Start;
end;

procedure TFrmMain.PreContentInitialized;
begin
  aiContentLoading.Enabled := True;
  pLoading.Visible := True;
  mvHomeOptions.HideMaster;
end;

procedure TFrmMain.PostContentInitialized;
begin
  try
    gplQuestions.ControlCollection.Clear;
    var types := FContent.GetEditableTypes;
    try
      for var idx := 0 to types.Count - 1 do
      begin
        var button := TButton.Create(Self);
        button.Parent := gplQuestions;
        button.Align := TAlignLayout.Client;
        button.Text := types[idx];
        button.StaysPressed := True;
        button.OnClick := OnQuestionTypeButtonClick;
      end;
    finally
      types.Free;
    end;

    SetActiveQuestionsType((gplQuestions.Controls[0] as TButton).Text);

    AddLastChoosenProject;
  finally
    GoToAllQuestions;
    pLoading.Visible := False;
    aiContentLoading.Enabled := False;
    FLastClickedItemToEdit := nil;
    aRemoveQuestions.Enabled := False;
    lProjectQuestions.Text := Format('Questions - %s', [FSelectedConfiguration.GetName]);
  end;
end;

procedure TFrmMain.InitializeContentTask;
begin
  FreeAndNil(FContent);
  case FSelectedConfiguration.GetGameType of
    FibbageXL: FContent := TFibbageXLContent.Create(FSelectedConfiguration);
    // TODO
  end;
  FContent.Initialize;
end;

procedure TFrmMain.ClearPreviousQuestions;
begin
  sbxQuestions.BeginUpdate;
  try
    while FQuestionVisItems.Count > 0 do
    begin
      var item := FQuestionVisItems.ExtractAt(0);
      FreeAndNil(item);
    end;
  finally
    sbxQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.aNewProjectExecute(Sender: TObject);
var
  str: string;
  gameType: TGameType;
begin
  var cfg := TContentConfiguration.Create;
  cfg.NewContent := True;
  if not GetProjectName(str) then
    Exit;
  if not GetGameType(gameType) then
    Exit;
  if not GetProjectPath(str) then
    Exit;

  cfg.SetName(str);
  cfg.SetPath(str);
  cfg.SetGameType(gameType);
  cfg.Save(cfg.GetPath);

  InsertNewProject(cfg);

  aInitializeProject.Execute;
end;

procedure TFrmMain.aOpenInWindowsExplorerExecute(Sender: TObject);
begin
  for var item in FProjectVisItems do
    if item.Selected then
      ShellExecute(WindowHandleToPlatform(Handle).Wnd, PChar('explore'), PChar(item.OrgConfiguration.GetPath), nil, nil, SW_SHOWNORMAL);
end;

procedure TFrmMain.OnRemoveProjectStart;
begin
  pLoading.Visible := True;
  aiContentLoading.Enabled := True;
  sbxProjects.BeginUpdate;
  FLastQuestionProjects.BeginUpdate;
end;

procedure TFrmMain.OnRemoveProjectEnd;
begin
  for var idx := FProjectVisItems.Count - 1 downto 0 do
  begin
    if not FProjectVisItems[idx].Selected then
      Continue;

    var item := FProjectVisItems.ExtractAt(idx);
    FreeAndNil(item);
  end;
  FLastQuestionProjects.EndUpdate;
  sbxProjects.EndUpdate;

  pLoading.Visible := False;
  aiContentLoading.Enabled := False;
end;

procedure TFrmMain.aRemoveProjectsAllDataExecute(Sender: TObject);
begin
  var list := TList<TContentConfiguration>.Create;
  for var idx := 0 to FProjectVisItems.Count - 1 do
    if FProjectVisItems[idx].Selected then
      list.Add(FProjectVisItems[idx].OrgConfiguration);

  TAsyncAction.Create(
    OnRemoveProjectStart, OnRemoveProjectEnd, procedure
      begin
        try
          for var item in list do
          begin
            TDirectory.Delete(item.GetPath, True);
            FLastQuestionProjects.Remove(item);
          end;
        finally
          list.Free;
        end;
      end).Start
end;

procedure TFrmMain.aRemoveProjectsExecute(Sender: TObject);
var
  closeContent: Boolean;
begin
  closeContent := False;
  for var item in FProjectVisItems do
    if item.Selected then
      if item.OrgConfiguration = FSelectedConfiguration then
      begin
        closeContent := True;
        Break;
      end;

  if closeContent then
  begin
    TDialogService.MessageDialog('You are trying to remove currently open project. Continue?',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
        begin
          RemoveProjects;

          ClearPreviousQuestions;
          FContent := nil;
          FSelectedConfiguration := nil;
          bQuestions.Enabled := False;
        end;
      end);
  end
  else
    RemoveProjects;
end;

procedure TFrmMain.RemoveProjects;
begin
  TDialogService.MessageDialog('Do you also want to remove questions?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel], TMsgDlgBtn.mbCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
        aRemoveProjectsAllData.Execute
      else if AResult = mrNo then
        aRemoveProjectsJustLastInfo.Execute
      else
        Exit;
      aRemoveProjects.Enabled := False;
    end);
end;

procedure TFrmMain.aRemoveProjectsJustLastInfoExecute(Sender: TObject);
begin
  var list := TList<TContentConfiguration>.Create;
  for var idx := 0 to FProjectVisItems.Count - 1 do
    if FProjectVisItems[idx].Selected then
      list.Add(FProjectVisItems[idx].OrgConfiguration);

  TAsyncAction.Create(
    OnRemoveProjectStart, OnRemoveProjectEnd, procedure
      begin
        try
          for var item in list do
            FLastQuestionProjects.Remove(item);
        finally
          list.Free;
        end;
      end).Start;
end;

procedure TFrmMain.aRemoveQuestionsExecute(Sender: TObject);
begin
  sbxQuestions.BeginUpdate;
  try
    for var idx := FQuestionVisItems.Count - 1 downto 0 do
    begin
      if not FQuestionVisItems[idx].Selected then
        Continue;
      var item := FQuestionVisItems.ExtractAt(idx);
      FContent.RemoveQuestion(FActiveQuestionsType, item.OrgQuestion);
      FreeAndNil(item);
    end;
  finally
    FLastClickedItemToEdit := nil;
    aRemoveQuestions.Enabled := False;
    sbxQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.aSaveChangesSettingsExecute(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  TAppConfig.GetInstance.FibbageXLPath := eSettingsFibbageXLPath.Text;
  TAppConfig.GetInstance.FibbageXLPartyPack1Path := eSettingsFibbageXLPP1Path.Text;
  TAppConfig.GetInstance.Fibbage3PartyPack4Path := eSettingsFibbage3PP4Path.Text;
  TAppConfig.GetInstance.Fibbage4PartyPack9Path := eSettingsFibbage4PP9Path.Text;
  TAppConfig.GetInstance.ShowInfoAboutDuplicatedCategories := cbShowCategoryDuplicatedInfo.IsChecked;
  TAppConfig.GetInstance.ShowInfoAboutTooFewSuggestions := cbShowDialogAboutTooFewSuggestions.IsChecked;
  TAppConfig.GetInstance.ShowInfoAboutTooFewShortieQuestions := cbShowDialogAboutTooFewShortieQuestions.IsChecked;

  GoToHome;
end;

procedure TFrmMain.aSaveProjectAndCloseExecute(Sender: TObject);
begin
  if not ShouldSaveProject then
    Exit;

  FQuestionsChanged := False;
  TAsyncAction.Create(OnPreSave, OnPostSaveClose, SaveProc).Start;
end;

procedure TFrmMain.aSaveProjectAndInitializeExecute(Sender: TObject);
begin
  if not ShouldSaveProject then
    Exit;

  FQuestionsChanged := False;
  TAsyncAction.Create(OnPreSave, OnPostSaveInitialize, SaveProc).Start;
end;

procedure TFrmMain.OnPostSaveClose;
begin
  OnPostSave;
  Close;
end;

procedure TFrmMain.OnPostSaveInitialize;
begin
  OnPostSave;
  ProcessInitializeProject;
end;

procedure TFrmMain.aSaveProjectAsExecute(Sender: TObject);
var
  path: string;
begin
  if not ShouldSaveProject then
    Exit
  else if not GetDestinationPath(path) then
    Exit;

  FSelectedConfiguration.SetPath(path);

  TAsyncAction.Create(OnPreSaveAs, OnPostSaveAs, SaveProc).Start;
end;

procedure TFrmMain.OnPreSaveAs;
begin
  pLoading.Visible := True;
  aiContentLoading.Enabled := True;
end;

procedure TFrmMain.OnPostSaveAs;
begin
  AddLastChoosenProject;
  InitializeLastQuestionProjects;
  aRemoveProjects.Enabled := False;

  pLoading.Visible := False;
  aiContentLoading.Enabled := False;
  FQuestionsChanged := False;
end;

function TFrmMain.GetGameType(out AType: TGameType): Boolean;
begin
  rDim.Visible := True;
  var dlg := TGetGameTypeDlg.Create(Self);
  try
    Result := dlg.GetGameType(AType);
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

function TFrmMain.GetFirstQuestionWithDuplicatedCategory(out AType,
  ACategory: string; out AQuestion: TFibbageQuestion): Boolean;
begin
  Result := FContent.HasDuplicatedCategory(AType, ACategory, AQuestion);
end;

function TFrmMain.GetFirstQuestionWithTooFewSuggestions(out AType: string;
  out AQuestion: TFibbageQuestion): Boolean;
begin
  Result := FContent.GetQuestionWithTooFewSuggestions(AType, AQuestion);
end;

procedure TFrmMain.SaveProc;
begin
  FContent.Save;
end;

function TFrmMain.CheckForDuplicatedCategoriesPreSave: Boolean;
var
  question: TFibbageQuestion;
  qType: string;
  qCategory: string;
begin
  Result := True;
  if TAppConfig.GetInstance.ShowInfoAboutDuplicatedCategories and GetFirstQuestionWithDuplicatedCategory(qType, qCategory, question) then
    if not ShowInfoAboutDuplicatedCategories(Format('Found questions with the same category "%s", you might experience the same category during "Pick category" part in the game. Continue?', [qCategory])) then
    begin
      SetActiveQuestionsType(qType);
      GoToAllQuestions;
      FQuestionVisItems.Select(question);
      sbxQuestions.ViewportPosition := TPointF.Create(0, FQuestionVisItems.Selected.Top);
      FLastClickedItemToEdit := FQuestionVisItems.Selected;
      Result := False;
    end;
end;

function TFrmMain.CheckForTooFewShortieQuestions: Boolean;
var
  qType: string;
  minCnt: UInt32;
begin
  Result := True;

  if FContent.HasTooFewShortieQuestions(qType, minCnt) and (not ShowInfoAboutTooFewShortieQuestions(
    Format('Too few shortie questions. Game may freeze on start or during gameplay. A minimum of %u questions is required. Continue?', [minCnt]))) then
  begin
    SetActiveQuestionsType(qType);
    GoToAllQuestions;
    sbxQuestions.ViewportPosition := TPointF.Zero;
    Result := False;
  end;
end;

function TFrmMain.CheckForTooFewSuggestions: Boolean;
var
  qType: string;
  question: TFibbageQuestion;
begin
  Result := True;
  if TAppConfig.GetInstance.ShowInfoAboutTooFewSuggestions and GetFirstQuestionWithTooFewSuggestions(qType, question) then
    if not ShowInfoAboutTooFewSuggestions('Found question with too few suggestions, the game can freeze because of this. The optimal number of suggestions is 17 (Max number of players * 2 + 1). Continue?') then
    begin
      SetActiveQuestionsType(qType);
      GoToAllQuestions;
      FQuestionVisItems.Select(question);
      sbxQuestions.ViewportPosition := TPointF.Create(0, FQuestionVisItems.Selected.Top);
      FLastClickedItemToEdit := FQuestionVisItems.Selected;
      Result := False;
    end;
end;

function TFrmMain.CheckIfFinalQuestionForFibbage3Ok: Boolean;
begin
  Result := False;
//  var firstBlank := mSingleItemQuestion.Text.IndexOf('<BLANK>');
//  var secondBlank := mSingleItemQuestion.Text.IndexOf('<BLANK>', firstBlank + 1);
//
//  if (firstBlank = -1) or (secondBlank = -1) then
//  begin
//    ShowSimpleInfo('Question is missing at least two <BLANK> entries, question won''t work');
//    Exit;
//  end;
//
//  if (not mSingleItemAnswer.Text.IsEmpty) and (not mSingleItemAnswer.Text.Contains('|')) then
//  begin
//    ShowSimpleInfo('Answer is missing | (it should look like this: answer_part1|answer_part2), question won''t work');
//    Exit;
//  end;
//
//  var sl := TStringList.Create;
//  try
//    sl.CommaText := mSingleItemAlternateSpelling.Text;
//    for var idx := 0 to sl.Count - 1 do
//      if not sl[idx].Contains('|') then
//      begin
//        ShowSimpleInfo(Format('Alternate spelling (%s) is missing | (it should look like this: altspell_part1|altspell_part2), question won''t work', [sl[idx]]));
//        Exit;
//      end;
//
//    sl.CommaText := mSingleItemSuggestions.Text;
//    for var idx := 0 to sl.Count - 1 do
//      if not sl[idx].Contains('|') then
//      begin
//        ShowSimpleInfo(Format('Suggestion (%s) is missing | (it should look like this: sugg_part1|sugg_part2), question won''t work', [sl[idx]]));
//        Exit;
//      end;
//  finally
//    sl.Free;
//  end;
//  Result := True;
end;

function TFrmMain.CheckIfFinalQuestionForFibbage4Ok: Boolean;
begin
  Result := False;
//  var blankPos := mSingleItemQuestion.Text.IndexOf('{{BLANK}}');
//  if blankPos = -1 then
//  begin
//    ShowSimpleInfo('Question is missing {{BLANK}} entry, question won''t work');
//    Exit;
//  end;
//
//  blankPos := mSingleItemQuestion2.Text.IndexOf('{{BLANK}}');
//  if blankPos = -1 then
//  begin
//    ShowSimpleInfo('Question2 is missing {{BLANK}} entry, question won''t work');
//    Exit;
//  end;
//
//  Result := True;
end;

function TFrmMain.ShouldSaveProject: Boolean;
begin
  Result := False;
  if not CheckForDuplicatedCategoriesPreSave then
    Exit;
  if not CheckForTooFewSuggestions then
    Exit;
  if not CheckForTooFewShortieQuestions then
    Exit;

  Result := True;
end;

procedure TFrmMain.aSaveProjectExecute(Sender: TObject);
begin
  if not ShouldSaveProject then
    Exit;

  TAsyncAction.Create(OnPreSave, OnPostSave, SaveProc).Start;
end;

function TFrmMain.IsTooFewSuggestions: Boolean;
begin
  Result := FContent.HasTooFewSuggestions(FActiveQuestionsType, FSelectedQuestion);
end;

function TFrmMain.IsCategoryDuplicated: Boolean;
begin
  Result := FContent.HasDuplicatedCategory(FActiveQuestionsType, FSelectedQuestion);
end;

function TFrmMain.IsMissingBlanks(out AError: string): Boolean;
begin
  Result := FContent.HasMissingBlanks(FActiveQuestionsType, FSelectedQuestion, AError);
end;

function TFrmMain.ShowInfoAboutTooFewShortieQuestions(
  const AInfo: string): Boolean;
var
  dontAskAgain: Boolean;
begin
  Result := False;
  rDim.Visible := True;
  var dlg := TUserDialog.Create(Self);
  try
    if dlg.MakeInfo(AInfo, dontAskAgain) then
    begin
      Result := True;
      if dontAskAgain then
        TAppConfig.GetInstance.ShowInfoAboutTooFewShortieQuestions := False;
    end;
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

function TFrmMain.ShowInfoAboutTooFewSuggestions(const AInfo: string): Boolean;
var
  dontAskAgain: Boolean;
begin
  Result := False;
  rDim.Visible := True;
  var dlg := TUserDialog.Create(Self);
  try
    if dlg.MakeInfo(AInfo, dontAskAgain) then
    begin
      Result := True;
      if dontAskAgain then
        TAppConfig.GetInstance.ShowInfoAboutTooFewSuggestions := False;
    end;
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

procedure TFrmMain.ShowSimpleInfo(const AInfo: string);
begin
  rDim.Visible := True;
  var dlg := TUserDialog.Create(Self);
  try
    dlg.MakeSimpleInfo(AInfo)
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

function TFrmMain.ShowSimpleInfoWithQuestion(const AInfo: string): Boolean;
begin
  rDim.Visible := True;
  var dlg := TUserDialog.Create(Self);
  try
    Result := dlg.MakeSimpleInfoWithResult(AInfo);
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

function TFrmMain.ShowInfoAboutDuplicatedCategories(const AInfo: string): Boolean;
var
  dontAskAgain: Boolean;
begin
  Result := False;
  rDim.Visible := True;
  var dlg := TUserDialog.Create(Self);
  try
    if dlg.MakeInfo(AInfo, dontAskAgain) then
    begin
      Result := True;
      if dontAskAgain then
        TAppConfig.GetInstance.ShowInfoAboutDuplicatedCategories := False;
    end;
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

function TFrmMain.ShowInfoAboutMissingBlanks(const AInfo: string): Boolean;
var
  dontAskAgain: Boolean;
begin
  Result := False;
  rDim.Visible := True;
  var dlg := TUserDialog.Create(Self);
  try
    if dlg.MakeInfo(AInfo, dontAskAgain) then
    begin
      Result := True;
      if dontAskAgain then
        TAppConfig.GetInstance.ShowInfoAboutMissingBlanks := False;
    end;
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

function TFrmMain.GetSingleQuestionSuggestions: string;
begin
  var suggestions := TStringList.Create;
  try
    suggestions.StrictDelimiter := True;
    suggestions.Delimiter := ',';
//    suggestions.DelimitedText := mSingleItemSuggestions.Text.Replace(', ', ',').Trim;

    for var idx := suggestions.Count - 1 downto 0 do
    begin
      suggestions[idx] := suggestions[idx].Trim;
      if suggestions[idx].IsEmpty then
        suggestions.Delete(idx);
    end;
    Result := suggestions.DelimitedText;
  finally
    suggestions.Free;
  end;
end;

procedure TFrmMain.aSaveQuestionChangesExecute(Sender: TObject);
var
  error: string;
begin
  if FChangingTab then
    Exit;

  if TAppConfig.GetInstance.ShowInfoAboutDuplicatedCategories and IsCategoryDuplicated then
    ShowInfoAboutDuplicatedCategories('Found question with the same category, you might experience the same category during "Pick category" part in the game.');

  if TAppConfig.GetInstance.ShowInfoAboutTooFewSuggestions and IsTooFewSuggestions then
    ShowInfoAboutTooFewSuggestions('Too few suggestions, the game can freeze because of this. The optimal number of suggestions is 17 (Max number of players * 2 + 1).');

  if TAppConfig.GetInstance.ShowInfoAboutMissingBlanks and IsMissingBlanks(error) then
    ShowInfoAboutMissingBlanks(error);

  FQuestionsChanged := True;

  sbxQuestions.BeginUpdate;
  try
    FLastClickedItemToEdit.RefreshData;
    FLastClickedItemToEdit.Resize;
  finally
    sbxQuestions.EndUpdate;
  end;

  GoToAllQuestions;
end;

procedure TFrmMain.aSetProjectAsActiveExecute(Sender: TObject);
var
  path: string;
begin
  for var item in FProjectVisItems do
    if item.Selected then
    begin
      FSelectedConfiguration := item.OrgConfiguration;
      Break;
    end;

  case FSelectedConfiguration.GetGameType of
    TGameType.FibbageXL:
      begin
        if TAppConfig.GetInstance.FibbageXLPath.IsEmpty then
          if GetFibbageXLPath(path) then
            TAppConfig.GetInstance.FibbageXLPath := path
          else
            Exit;
      end;
    TGameType.FibbageXLPartyPack1:
      begin
        if TAppConfig.GetInstance.FibbageXLPartyPack1Path.IsEmpty then
          if GetFibbageXLPath(path) then
            TAppConfig.GetInstance.FibbageXLPartyPack1Path := path
          else
            Exit;
      end;
    TGameType.Fibbage3PartyPack4:
      begin
        if TAppConfig.GetInstance.Fibbage3PartyPack4Path.IsEmpty then
          if GetFibbage3Path(path) then
            TAppConfig.GetInstance.Fibbage3PartyPack4Path := path
          else
            Exit;
      end;
    TGameType.Fibbage4PartyPack9:
      begin
        if TAppConfig.GetInstance.Fibbage4PartyPack9Path.IsEmpty then
          if GetFibbage4Path(path) then
            TAppConfig.GetInstance.Fibbage4PartyPack9Path := path
          else
            Exit;
      end;

  end;

  TAsyncAction.Create(StartSplash, StopSplash, ActivateProjectProc).Start;
end;

procedure TFrmMain.StartSplash;
begin
  pLoading.Visible := True;
  aiContentLoading.Enabled := True;
end;

procedure TFrmMain.OnAfterQuestionTypeChanged;
begin
  pLoading.Visible := False;
  aiContentLoading.Enabled := False;
end;

procedure TFrmMain.OnBeforeQuestionTypeChanged;
begin
  pLoading.Visible := True;
  aiContentLoading.Enabled := True;
end;

procedure TFrmMain.OnCancelSingleQuestionClick(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  GoToAllQuestions;
end;

procedure TFrmMain.OnCopyQuestionTo(Sender: TObject);
begin
  if not (Sender is TMenuItem) then
    Exit;

  var destType := (Sender as TMenuItem).Text;
  for var idx := 0 to FQuestionVisItems.Count - 1 do
  begin
    if not FQuestionVisItems[idx].Selected then
      Continue;

    FContent.CopyQuestion(destType, FQuestionVisItems[idx].OrgQuestion);
  end;
end;

procedure TFrmMain.OnMoveQuestionTo(Sender: TObject);
begin
  if not (Sender is TMenuItem) then
    Exit;

  sbxQuestions.BeginUpdate;
  try
    var destType := (Sender as TMenuItem).Text;
    for var idx := FQuestionVisItems.Count - 1 downto 0 do
    begin
      if not FQuestionVisItems[idx].Selected then
        Continue;

      FContent.MoveQuestion(FActiveQuestionsType, destType, FQuestionVisItems[idx].OrgQuestion);

      var item := FQuestionVisItems.ExtractAt(idx);
      FreeAndNil(item);
    end;
  finally
    sbxQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.StopSplash;
begin
  pLoading.Visible := False;
  aiContentLoading.Enabled := False;
end;

procedure TFrmMain.ActivateProjectProc;
var
  destPath: string;
begin
  case FSelectedConfiguration.GetGameType of
    TGameType.FibbageXL:
      destPath := System.IOUtils.TPath.Combine(TAppConfig.GetInstance.FibbageXLPath, 'content');
    TGameType.FibbageXLPartyPack1:
      destPath := System.IOUtils.TPath.Combine(TAppConfig.GetInstance.FibbageXLPartyPack1Path, 'content');
    TGameType.Fibbage3PartyPack4:
      destPath := System.IOUtils.TPath.Combine(TAppConfig.GetInstance.Fibbage3PartyPack4Path, 'content');
    TGameType.Fibbage4PartyPack9:
      destPath := System.IOUtils.TPath.Combine(TAppConfig.GetInstance.Fibbage4PartyPack9Path, 'content', 'en');
  end;

  try
    TProjectActivator.Activate(FSelectedConfiguration, destPath);
  except
    on E: EActivateError do
      ShowSimpleInfo(E.Message);
  end;
end;

procedure TFrmMain.OnPreSave;
begin
  pLoading.Visible := True;
  aiContentLoading.Enabled := True;
end;

procedure TFrmMain.OnPostSave;
begin
  pLoading.Visible := False;
  aiContentLoading.Enabled := False;
  FQuestionsChanged := False;
end;

procedure TFrmMain.bQuestionsClick(Sender: TObject);
begin
  GoToAllQuestions;
end;

procedure TFrmMain.sbxQuestionsCalcContentBounds(Sender: TObject;
  var ContentBounds: TRectF);
begin
  ContentBounds.Top := 0;
  ContentBounds.Bottom := pQuestionsButtons.Height + ToolBar2.Height; {fix for last question not showing}
  for var idx := 0 to FQuestionVisItems.Count - 1 do
    ContentBounds.Bottom := ContentBounds.Bottom + FQuestionVisItems[idx].Height + FQuestionVisItems[idx].Margins.Top + FQuestionVisItems[idx].Margins.Bottom;
end;

procedure TFrmMain.sDarkModeOptionsSwitch(Sender: TObject);
begin
  SetDarkMode(sDarkModeOptions.IsChecked);
end;

procedure TFrmMain.sDarkModeSwitch(Sender: TObject);
begin
  SetDarkMode(sDarkMode.IsChecked);
end;

function TFrmMain.GetProjectPath(out APath: string): Boolean;
begin
  Result := SelectDirectory('Select content directory', '', APath);
end;

function TFrmMain.GetProjectName(out AName: string): Boolean;
begin
  rDim.Visible := True;
  var dlg := TGetTextDlg.Create(Self);
  try
    Result := dlg.GetText('Enter new project name:', AName);
  finally
    dlg.Free;
    rDim.Visible := False;
  end;
end;

procedure TFrmMain.OnSaveSingleQuestionClick(Sender: TObject);
begin
  aSaveQuestionChanges.Execute;
end;

procedure TFrmMain.OnProjectItemDoubleClick(Sender: TObject);
begin
  Log('OnProjectItemDoubleClick');
  if FChangingTab then
    Exit;

  aInitializeProject.Execute;
end;

procedure TFrmMain.OnProjectItemMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if FChangingTab then
    Exit;
  if not (Sender is TProjectScrollItem) then
    Exit;

  FLastClickedConfigurationToEdit := Sender as TProjectScrollItem;

  if Button = TMouseButton.mbRight then
  begin
    FLastClickedConfiguration := Sender as TProjectScrollItem;
    sbxProjects.BeginUpdate;
    try
      if not (Sender as TProjectScrollItem).Selected then
      begin
        FProjectVisItems.ClearSelection;
        (Sender as TProjectScrollItem).Selected := True;
      end;
    finally
      sbxProjects.EndUpdate;
    end;
    pmProjects.Popup(Screen.MousePos.X, Screen.MousePos.Y);
  end
  else if ssDouble in Shift then
  begin
    FProjectVisItems.ClearSelection;
    (Sender as TProjectScrollItem).Selected := True;
  end
  else if ssShift in Shift then
  begin
    var fIdx := 0;
    var sIdx := FProjectVisItems.IndexOf(Sender as TProjectScrollItem);
    if Assigned(FLastClickedConfiguration) then
      fIdx := FProjectVisItems.IndexOf(FLastClickedConfiguration);

    if fIdx > sIdx then
    begin
      var tmp := fIdx;
      fIdx := sIdx;
      sIdx := tmp;
    end;

    for var idx := 0 to FProjectVisItems.Count - 1 do
      FProjectVisItems[idx].Selected := (idx >= fIdx) and (idx <= sIdx);
  end
  else
  begin
    FLastClickedConfiguration := Sender as TProjectScrollItem;
    if ssCtrl in Shift then
      (Sender as TProjectScrollItem).Selected := not (Sender as TProjectScrollItem).Selected
    else
    begin
      for var item in FProjectVisItems do
        if item = Sender then
          item.Selected := not item.Selected
        else
          item.Selected := False;
    end;
  end;

  if not (Sender as TProjectScrollItem).Selected then
    FLastClickedConfigurationToEdit := nil;

  var selCnt := FProjectVisItems.SelectedCount;
  aRemoveProjects.Enabled :=  selCnt > 0;
  aRemoveProjects.Text := IfThen(selCnt > 1, 'Remove projects', 'Remove project');
end;

procedure TFrmMain.OnQuestionItemDoubleClick(Sender: TObject);
begin
  if FChangingTab then
    Exit;
  if not (Sender is TQuestionScrollItem) then
    Exit;
  Log('OnQuestionItemDoubleClick');

  FLastClickedItemToEdit := Sender as TQuestionScrollItem;
  aEditQuestion.Execute;
end;

procedure TFrmMain.OnQuestionItemMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Log('OnQuestionItemMouseDown');
  if FChangingTab then
    Exit;
  if not (Sender is TQuestionScrollItem) then
    Exit;

  FLastClickedItemToEdit := Sender as TQuestionScrollItem;
  if Button = TMouseButton.mbRight then
  begin
    FLastClickedItem := Sender as TQuestionScrollItem;
    if not FLastClickedItem.Selected then
      SwitchHighlightQuestionItem(Sender as TQuestionScrollItem, True);
    pmQuestions.Popup(Screen.MousePos.X, Screen.MousePos.Y);
  end
  else if ssDouble in Shift then
    SwitchHighlightQuestionItem(Sender as TQuestionScrollItem, True)
  else if ssShift in Shift then
  begin
    var fIdx := 0;
    var sIdx := FQuestionVisItems.IndexOf(Sender as TQuestionScrollItem);
    if Assigned(FLastClickedItem) then
      fIdx := FQuestionVisItems.IndexOf(FLastClickedItem);

    if fIdx > sIdx then
    begin
      var tmp := fIdx;
      fIdx := sIdx;
      sIdx := tmp;
    end;

    for var idx := 0 to FQuestionVisItems.Count - 1 do
      FQuestionVisItems[idx].Selected := (idx >= fIdx) and (idx <= sIdx);
  end
  else
  begin
    FLastClickedItem := Sender as TQuestionScrollItem;
    if ssCtrl in Shift then
      SwitchHighlightQuestionItem(Sender as TQuestionScrollItem, False)
    else
      SwitchHighlightQuestionItem(Sender as TQuestionScrollItem, True);
  end;

  if not (Sender as TQuestionScrollItem).Selected then
    FLastClickedItemToEdit := nil;

  var selCnt := FQuestionVisItems.SelectedCount;
  aRemoveQuestions.Enabled := selCnt > 0;
  aRemoveQuestions.Text := IfThen(selCnt > 1, 'Remove questions', 'Remove question');
end;

procedure TFrmMain.OnQuestionTypeButtonClick(Sender: TObject);
begin
  SetActiveQuestionsType((Sender as TButton).Text);
end;

procedure TFrmMain.OnUnhandledException(Sender: TObject; E: Exception);
begin
  ShowSimpleInfo(Format('Unhandled exception, %s/%s', [E.Message, E.ClassName]));
end;

procedure TFrmMain.PrepareMultiViewButtons(AActTab: TAppTab);
begin
  mvHomeOptions.BeginUpdate;
  try
    bQuestions.Enabled := Assigned(FContent);
  finally
    mvHomeOptions.EndUpdate;
  end;
end;

procedure TFrmMain.FillAudioDevices;
var
  idx: Integer;
  itemWidth: Single;
  itemIndex: Integer;
begin
  itemWidth := 0.0;
  itemIndex := 0;
  cbAudioOutput.Items.BeginUpdate;
  try
    cbAudioOutput.Items.Clear;
    for idx := 0 to DSAudioOut1.DeviceCount - 1 do
    begin
      cbAudioOutput.Items.Add(DSAudioOut1.DeviceName[idx]);
      if DSAudioOut1.DeviceName[idx].Equals(TAppConfig.GetInstance.OutputDeviceName) then
        itemIndex := idx;
      if itemWidth < cbAudioOutput.Canvas.TextWidth(DSAudioOut1.DeviceName[idx]) then
        itemWidth := cbAudioOutput.Canvas.TextWidth(DSAudioOut1.DeviceName[idx]);
    end;
    if cbAudioOutput.Items.Count > 0 then
      cbAudioOutput.ItemIndex := itemIndex;
    cbAudioOutput.ItemWidth := Max(itemWidth, cbAudioOutput.Width);
    cbAudioOutput.ItemHeight := cbAudioOutput.Canvas.TextHeight('Yy');
  finally
    cbAudioOutput.Items.EndUpdate;
  end;

  itemWidth := 0;
  itemIndex := 0;
  cbAudioInput.Items.BeginUpdate;
  try
    cbAudioInput.Items.Clear;
    for idx := 0 to DXAudioIn1.DeviceCount - 1 do
    begin
      cbAudioInput.Items.Add(DXAudioIn1.DeviceName[idx]);
      if DXAudioIn1.DeviceName[idx].Equals(TAppConfig.GetInstance.InputDeviceName) then
        itemIndex := idx;
      if itemWidth < cbAudioInput.Canvas.TextWidth(DXAudioIn1.DeviceName[idx]) then
        itemWidth := cbAudioInput.Canvas.TextWidth(DXAudioIn1.DeviceName[idx]);
    end;
    if cbAudioInput.Items.Count > 0 then
      cbAudioInput.ItemIndex := itemIndex;
    cbAudioInput.ItemWidth := Max(itemWidth, cbAudioInput.Width);
    cbAudioInput.ItemHeight := cbAudioInput.Canvas.TextHeight('Yy');
  finally
    cbAudioInput.Items.EndUpdate;
  end;
end;

procedure TFrmMain.RefreshProjectFormActions;
begin
  var selCnt := FProjectVisItems.SelectedCount;

  aRemoveProjects.Text := IfThen(selCnt > 1, 'Remove projects', 'Remove project');
  aRemoveProjects.Enabled := selCnt > 0;
  aEditProjectName.Enabled := Assigned(FLastClickedConfigurationToEdit) and (selCnt = 1);
  aOpenInWindowsExplorer.Visible := selCnt > 0;
  aInitializeProject.Enabled := selCnt = 1;
  aSetProjectAsActive.Visible := selCnt > 0;
  aSetProjectAsActive.Enabled := selCnt = 1;
  MenuItem1.Visible := aOpenInWindowsExplorer.Visible or aSetProjectAsActive.Visible;
  miMigrate.Enabled := selCnt = 1;
  aMigrateToFibbageXL.Enabled := miMigrate.Enabled and Assigned(FLastClickedConfigurationToEdit) and (FLastClickedConfiguration.OrgConfiguration.GetGameType <> TGameType.FibbageXL);
  aMigrateToFibbageXLPartyPack1.Enabled := miMigrate.Enabled and Assigned(FLastClickedConfigurationToEdit) and (FLastClickedConfiguration.OrgConfiguration.GetGameType <> TGameType.FibbageXLPartyPack1);
  aMigrateToFibbage3.Enabled := miMigrate.Enabled and Assigned(FLastClickedConfigurationToEdit) and (FLastClickedConfiguration.OrgConfiguration.GetGameType <> TGameType.Fibbage3PartyPack4);
end;

procedure TFrmMain.RefreshQuestionsFormActions;
begin
  var selCnt := FQuestionVisItems.SelectedCount;
  aRemoveQuestions.Text := IfThen(selCnt > 1, 'Remove questions', 'Remove question');
  aRemoveQuestions.Enabled := selCnt > 0;
  aEditQuestion.Enabled := Assigned(FLastClickedItemToEdit) and (selCnt = 1);
end;

procedure TFrmMain.pmProjectsPopup(Sender: TObject);
begin
  RefreshProjectFormActions;
end;

procedure TFrmMain.pmQuestionsPopup(Sender: TObject);
begin
  RefreshQuestionsFormActions;
end;

procedure TFrmMain.GoToAllQuestions;
begin
  FChangingTab := True;
  try
    aGoToAllQuestions.Execute;
  finally
    FChangingTab := False;
  end;
  PrepareMultiViewButtons(atQuestions);
end;

procedure TFrmMain.GoToHome;
begin
  FChangingTab := True;
  try
    aGoToHome.Execute;
  finally
    FChangingTab := False;
  end;
  PrepareMultiViewButtons(atHome);
end;

procedure TFrmMain.bGoToHomeClick(Sender: TObject);
begin
  GoToHome;
end;

procedure TFrmMain.bHomeButtonClick(Sender: TObject);
begin
  GoToHome;
end;

procedure TFrmMain.bSettingsClick(Sender: TObject);
begin
  GoToSettings;
end;

procedure TFrmMain.bSettingsFibbage3PP4PathClick(Sender: TObject);
var
  path: string;
begin
  if not GetFibbage3Path(path) then
    Exit;

  eSettingsFibbage3PP4Path.Text := path;
end;

procedure TFrmMain.bSettingsFibbage4PP9PathClick(Sender: TObject);
var
  path: string;
begin
  if not GetFibbage4Path(path) then
    Exit;

  eSettingsFibbage4PP9Path.Text := path;
end;

procedure TFrmMain.bSettingsFibbageXLPathClick(Sender: TObject);
var
  path: string;
begin
  if not GetFibbageXLPath(path) then
    Exit;

  eSettingsFibbageXLPath.Text := path;
end;

procedure TFrmMain.bSettingsFibbageXLPP1PathClick(Sender: TObject);
var
  path: string;
begin
  if not GetFibbageXLPath(path) then
    Exit;

  eSettingsFibbageXLPP1Path.Text := path;
end;

procedure TFrmMain.GoToSettings;
begin
  FChangingTab := True;
  try
    FillAudioDevices;
    eSettingsFibbageXLPath.Text := TAppConfig.GetInstance.FibbageXLPath;
    eSettingsFibbageXLPP1Path.Text := TAppConfig.GetInstance.FibbageXLPartyPack1Path;
    eSettingsFibbage3PP4Path.Text := TAppConfig.GetInstance.Fibbage3PartyPack4Path;
    eSettingsFibbage4PP9Path.Text := TAppConfig.GetInstance.Fibbage4PartyPack9Path;
    cbShowCategoryDuplicatedInfo.IsChecked := TAppConfig.GetInstance.ShowInfoAboutDuplicatedCategories;
    cbShowDialogAboutTooFewSuggestions.IsChecked := TAppConfig.GetInstance.ShowInfoAboutTooFewSuggestions;
    cbShowDialogAboutTooFewShortieQuestions.IsChecked := TAppConfig.GetInstance.ShowInfoAboutTooFewShortieQuestions;

    aGoToSettings.Execute;
  finally
    FChangingTab := False;
  end;
end;

procedure TFrmMain.SwitchHighlightQuestionItem(AItem: TQuestionScrollItem; AClearOthers: Boolean);
begin
  for var item in FQuestionVisItems do
    if item = AItem then
      item.Selected := not item.Selected
    else if AClearOthers then
      item.Selected := False;
end;

procedure TFrmMain.UpdateMoveCopyOptions;
begin
  for var idx := miCopyTo.ItemsCount - 1 downto 0 do
  begin
    var item := miCopyTo.Items[idx];
    miCopyTo.RemoveObject(item);
    FreeAndNil(item);
  end;
  for var idx := miMoveTo.ItemsCount - 1 downto 0 do
  begin
    var item := miMoveTo.Items[idx];
    miMoveTo.RemoveObject(item);
    FreeAndNil(item);
  end;

  var types := FContent.GetEditableTypes;
  try
    for var idx := 0 to types.Count - 1 do
    begin
      if types[idx] = FActiveQuestionsType then
        Continue;

      var copyItem := TMenuItem.Create(Self);
      copyItem.Text := types[idx];
      copyItem.OnClick := OnCopyQuestionTo;
      miCopyTo.AddObject(copyItem);

      var moveItem := TMenuItem.Create(Self);
      moveItem.Text := types[idx];
      moveItem.OnClick := OnMoveQuestionTo;
      miMoveTo.AddObject(moveItem);
    end;
  finally
    types.Free;
  end;
end;

procedure TFrmMain.cbAudioInputChange(Sender: TObject);
begin
  if FChangingTab then
    Exit;
  TAppConfig.GetInstance.InputDeviceName := cbAudioInput.Items[cbAudioInput.ItemIndex];
end;

procedure TFrmMain.cbAudioOutputChange(Sender: TObject);
begin
  if FChangingTab then
    Exit;
  TAppConfig.GetInstance.OutputDeviceName := cbAudioOutput.Items[cbAudioOutput.ItemIndex];
end;

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FQuestionsChanged then
  begin
    var res := False;
    TDialogService.MessageDialog('Save changes?', TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel], TMsgDlgBtn.mbCancel, 0,
      procedure (const AResult: TModalResult)
      begin
        case AResult of
          mrYes: aSaveProjectAndClose.Execute;
          mrNo: res := True;
        end;
      end);
    CanClose := res;
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Randomize;
  Application.OnException := OnUnhandledException;

  FQuestionVisItems := TQuestionScrollItems.Create;

  frmEditQuestion.OnCancelClick := OnCancelSingleQuestionClick;
  frmEditQuestion.OnSaveClick := OnSaveSingleQuestionClick;

  PrepareMultiViewButtons(atHomeBeforeImport);

  FProjectVisItems := TProjectScrollItems.Create(sbxProjects);

  sDarkMode.IsChecked := TAppConfig.GetInstance.DarkModeEnabled;

  tcEditTabs.ActiveTab := tiQuestionProjects;

  FLastQuestionProjects := TLastQuestionsLoader.Create;
  FLastQuestionProjects.Initialize;
  InitializeLastQuestionProjects;

  if FLastQuestionProjects.Count = 0 then
    mvHomeOptions.ShowMaster;

  FAppCreated := True;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  Log('Destroying');
  FContent.Free;
  FLastQuestionProjects.Free;
  FQuestionVisItems.Free;
  FProjectVisItems.Free;
  Log('Destroyed');
end;

procedure TFrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if tcEditTabs.ActiveTab = tiQuestionProjects then
    ProcessKeyDown_QuestionsProject(Key, Shift)
  else if tcEditTabs.ActiveTab = tiQuestions then
    ProcessKeyDown_Questions(Key, Shift)
end;

procedure TFrmMain.ProcessKeyDown_QuestionsProject(var Key: Word; Shift: TShiftState);
begin
  if Key = vkDown then
  begin
    if FProjectVisItems.Selected = nil then
      Exit;

    if FProjectVisItems.Selected = FProjectVisItems[FProjectVisItems.Count - 1] then
      sbxProjects.ViewportPosition := TPointF.Zero
    else
      sbxProjects.ScrollBy(0, -FProjectVisItems.Selected.Height);
    FProjectVisItems.SelectNext;
    FLastClickedConfigurationToEdit := FProjectVisItems.Selected;
  end
  else if Key = vkUp then
  begin
    if FProjectVisItems.Selected = nil then
      Exit;

    if FProjectVisItems.Selected = FProjectVisItems[0] then
      sbxProjects.ViewportPosition := TPointF.Create(0, MaxInt)
    else
      sbxProjects.ScrollBy(0, FProjectVisItems.Selected.Height);
    FProjectVisItems.SelectPrev;
    FLastClickedConfigurationToEdit := FProjectVisItems.Selected;
  end
  else if Key = vkRight then
    if FProjectVisItems.SelectedCount = 1 then
    begin
      RefreshProjectFormActions;
      aInitializeProject.Execute;
    end;
end;

procedure TFrmMain.ProcessKeyDown_Questions(var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = vkA) then
  begin
    FQuestionVisItems.SelectAll;
    Exit;
  end;

  if Key = vkDown then
  begin
    if FQuestionVisItems.Selected = nil then
      Exit;

    if FQuestionVisItems.Selected = FQuestionVisItems.Last then
      sbxQuestions.ViewportPosition := TPointF.Zero
    else
      sbxQuestions.ScrollBy(0, -FQuestionVisItems.Selected.Height);
    FQuestionVisItems.SelectNext;
    FLastClickedItemToEdit := FQuestionVisItems.Selected;
  end
  else if Key = vkUp then
  begin
    if FQuestionVisItems.Selected = nil then
      Exit;

    if FQuestionVisItems.Selected = FQuestionVisItems[0] then
      sbxQuestions.ViewportPosition := TPointF.Create(0, MaxInt)
    else
      sbxQuestions.ScrollBy(0, FQuestionVisItems.Selected.Height);
    FQuestionVisItems.SelectPrev;
    FLastClickedItemToEdit := FQuestionVisItems.Selected;
  end
  else if Key = vkRight then
    if FQuestionVisItems.SelectedCount = 1 then
    begin
      RefreshQuestionsFormActions;
      aEditQuestion.Execute;
    end;
end;

procedure TFrmMain.FormResize(Sender: TObject);
begin
  if ClientHeight < 480 then
    ClientHeight := 480;

  if ClientWidth < 640 then
    ClientWidth := 640;
end;

procedure TFrmMain.GoToQuestionDetails;
begin
  FChangingTab := True;
  try
    aGoToQuestionDetails.Execute;
  finally
    FChangingTab := False;
  end;
end;

procedure TFrmMain.InitializeLastQuestionProjects;
begin
  sbxProjects.BeginUpdate;
  try
    while FProjectVisItems.Count > 0 do
    begin
      var item := FProjectVisItems.ExtractAt(0);
      FreeAndNil(item);
    end;

    for var item in FLastQuestionProjects.Configurations do
    begin
      var pItem := TProjectScrollItem.CreateItem(sbxProjects, item);
      pItem.Parent := sbxProjects;
      pItem.Align := TAlignLayout.Top;
      pItem.Position.Y := MaxInt;
      pItem.OnMouseDown := OnProjectItemMouseDown;
      pItem.OnDblClick := OnProjectItemDoubleClick;
      FProjectVisItems.Add(pItem);
    end;
  finally
    sbxProjects.EndUpdate;
  end;
end;

procedure TFrmMain.InsertNewProject(AConfig: TContentConfiguration);
begin
  sbxProjects.BeginUpdate;
  try
    FProjectVisItems.ClearSelection;
    var pItem := TProjectScrollItem.CreateItem(sbxProjects, AConfig);
    pItem.Parent := sbxProjects;
    pItem.Align := TAlignLayout.Top;
    pItem.Position.Y := -999;
    pItem.OnMouseDown := OnProjectItemMouseDown;
    pItem.OnDblClick := OnProjectItemDoubleClick;
    FLastClickedConfigurationToEdit := pItem;
    FProjectVisItems.Add(pItem);
    pItem.Selected := True;
    aRemoveProjects.Enabled := True;
  finally
    sbxProjects.EndUpdate;
  end;
end;

procedure TFrmMain.lDarkModeClick(Sender: TObject);
begin
  sDarkMode.IsChecked := not sDarkMode.IsChecked;
end;

procedure TFrmMain.lDarkModeOptionsClick(Sender: TObject);
begin
  sDarkModeOptions.IsChecked := not sDarkModeOptions.IsChecked;
end;

procedure TFrmMain.SetActiveQuestionsType(const AType: string);
begin
  FActiveQuestionsType := AType;
  UpdateMoveCopyOptions;

  SetButtonPressed;

  ClearPreviousQuestions;

  sbxQuestions.BeginUpdate;
  try
    FContent.ForEachQuestion(AType,
      procedure(AQuestion: TFibbageQuestion)
      begin
        AddQuestionScrollItem(AQuestion);
      end);
  finally
    sbxQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.SetButtonPressed;
begin
  for var item in gplQuestions.Controls do
    if item is TButton then
      (item as TButton).IsPressed := (item as TButton).Text = FActiveQuestionsType;
end;

procedure TFrmMain.SetDarkMode(AEnabled: Boolean);
begin
  sDarkMode.IsChecked := AEnabled;
  sDarkModeOptions.IsChecked := AEnabled;

  if AEnabled then
    StyleBook := sbDarkStyle
  else
    StyleBook := sbLightStyle;

  if FAppCreated then
    TAppConfig.GetInstance.DarkModeEnabled := AEnabled;
end;

procedure TFrmMain.lvEditAllItemsUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  var baseLV := Sender as TListView;

  var qDrawable := AItem.View.FindDrawable('Question') as TListItemText;
  var aDrawable := AItem.View.FindDrawable('Answer') as TListItemText;
  var sDrawable := AItem.View.FindDrawable('Suggestions') as TListItemText;
  var cdDrawable := AItem.View.FindDrawable('CategoryDetails') as TListItemText;

  if (not Assigned(qDrawable)) or (not Assigned(aDrawable)) or (not Assigned(sDrawable)) or (not Assigned(cdDrawable)) then
    Exit;

  baseLV.Canvas.Font.Assign(qDrawable.Font);

  cdDrawable.Height := baseLV.Canvas.TextHeight('Yy');
  cdDrawable.PlaceOffset.Y := 3;
  cdDrawable.PlaceOffset.X := 5;

  var R := RectF(0, 0, baseLV.Width - baseLV.ItemSpaces.Left - baseLV.ItemSpaces.Right, 10000);
  baseLV.Canvas.MeasureText(R, AItem.Data['Question'].ToString, True, [], qDrawable.TextAlign, qDrawable.TextVertAlign);
  qDrawable.Height := R.Height;
  qDrawable.PlaceOffset.Y := cdDrawable.PlaceOffset.Y + cdDrawable.Height + 10;

  aDrawable.Height := baseLV.Canvas.TextHeight('Yy');
  aDrawable.PlaceOffset.Y := qDrawable.PlaceOffset.Y + qDrawable.Height + 5;

  sDrawable.Height := baseLV.Canvas.TextHeight('Yy');
  sDrawable.PlaceOffset.Y := aDrawable.PlaceOffset.Y + aDrawable.Height + 5;

  qDrawable.Width := baseLV.Width;
  aDrawable.Width := baseLV.Width;
  sDrawable.Width := baseLV.Width;
  cdDrawable.Width := baseLV.Width - cdDrawable.PlaceOffset.X;

  AItem.Height := Round(sDrawable.PlaceOffset.Y + sDrawable.Height + 6);
end;

procedure TFrmMain.mDisableEnter(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    Key := 0;
end;

{ TQuestionScrollItem }

constructor TQuestionScrollItem.CreateItem(AOwner: TComponent; AQuestion: TFibbageQuestion);
begin
  inherited Create(AOwner);

  StyleLookup := 'rScrollItemStyle';
  HitTest := True;

  FOrgQuestion := AQuestion;
  
  FDetails := TLabel.Create(AOwner);
  FDetails.Parent := Self;
  FDetails.Align := TAlignLayout.MostTop;
  FDetails.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style, TStyledSetting.FontColor];
  FDetails.TextSettings.Font.Size := 13;
  FDetails.Margins.Left := 10;
  FDetails.Margins.Right := 10;
  FDetails.Margins.Top := 10;
  FDetails.StyleLookup := 'listboxitemdetaillabel';

  FQuestion := TLabel.Create(AOwner);
  FQuestion.Parent := Self;
  FQuestion.Align := TAlignLayout.Top;
  FQuestion.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style, TStyledSetting.FontColor];
  FQuestion.TextAlign := TTextAlign.Center;
  FQuestion.TextSettings.Font.Size := 18;
  FQuestion.Margins.Left := 15;
  FQuestion.Margins.Right := 5;
  FQuestion.StyleLookup := 'listboxitemlabel';

  RefreshData;
end;

procedure TQuestionScrollItem.RefreshData;
begin
  var preview := FOrgQuestion.GetPreview;
  FDetails.Text := preview.Header;
  FQuestion.Text := preview.Question;
end;

procedure TQuestionScrollItem.Resize;
begin
  inherited;
  FDetails.Canvas.Font.Assign(FDetails.Font);
  FDetails.Height := Ceil(FDetails.Canvas.TextHeight('Yy'));

  FQuestion.Canvas.Font.Assign(FQuestion.Font);
  var R := RectF(0, 0, Width - FQuestion.Margins.Left - FQuestion.Margins.Right, 10000);
  FQuestion.Canvas.MeasureText(R, FQuestion.Text, True, [], TTextAlign.Center);
  FQuestion.Height := Ceil(R.Height + FQuestion.Margins.Top + FQuestion.Margins.Bottom);

  Height := Ceil((2 * FDetails.Height) + FDetails.Margins.Top + FDetails.Margins.Bottom +
      FQuestion.Height + FQuestion.Margins.Top + FQuestion.Margins.Bottom);
end;

procedure TQuestionScrollItem.SetSelected(const Value: Boolean);
begin
  FSelected := Value;
  if FSelected then
    StyleLookup := 'rScrollItemSelectedStyle'
  else
    StyleLookup := 'rScrollItemStyle';
end;

{ TQuestionScrollItems }

procedure TQuestionScrollItems.ClearSelection;
begin
  for var item in Self do
    item.Selected := False;
end;

procedure TQuestionScrollItems.Select(AQuestion: TFibbageQuestion);
begin
  for var item in Self do
    item.Selected := item.OrgQuestion = AQuestion;
end;

procedure TQuestionScrollItems.SelectAll;
begin
  for var item in Self do
    item.Selected := True;
end;

function TQuestionScrollItems.Selected: TQuestionScrollItem;
begin
  for var item in Self do
    if item.Selected then
      Exit(item);
  Result := nil;
end;

function TQuestionScrollItems.SelectedCount: Integer;
begin
  Result := 0;
  for var item in Self do
    if item.Selected then
      Inc(Result);
end;

procedure TQuestionScrollItems.SelectNext;
begin
  for var idx := 0 to Count - 1 do
    if Self[idx].Selected then
    begin
      ClearSelection;
      if idx = Count - 1 then
        Self[0].SetSelected(True)
      else
        Self[idx + 1].SetSelected(True);
      Break;
    end;
end;

procedure TQuestionScrollItems.SelectPrev;
begin
  for var idx := 0 to Count - 1 do
    if Self[idx].Selected then
    begin
      ClearSelection;
      if idx = 0 then
        Self[Count - 1].SetSelected(True)
      else
        Self[idx - 1].SetSelected(True);
      Break;
    end;
end;

{ TProjectScrollItem }

constructor TProjectScrollItem.CreateItem(AOwner: TComponent; AConfiguration: TContentConfiguration);
begin
  inherited Create(AOwner);

  StyleLookup := 'rScrollItemStyle';
  HitTest := True;

  FOrgConfiguration := AConfiguration;

  FName := TLabel.Create(AOwner);
  FName.Parent := Self;
  FName.Align := TAlignLayout.Client;
  FName.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style, TStyledSetting.FontColor];
  FName.TextAlign := TTextAlign.Center;
  FName.TextSettings.Font.Size := 18;
  FName.WordWrap := False;
  FName.Margins.Left := 10;
  FName.Margins.Right := 10;
  FName.Margins.Top := 15;
  FName.Margins.Bottom := 10;
  FName.StyleLookup := 'listboxitemlabel';

  FPath := TLabel.Create(AOwner);
  FPath.Parent := Self;
  FPath.Align := TAlignLayout.Bottom;
  FPath.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style, TStyledSetting.FontColor];
  FPath.TextAlign := TTextAlign.Leading;
  FPath.TextSettings.Font.Size := 13;
  FPath.Margins.Left := 15;
  FPath.Margins.Right := 5;
  FPath.Margins.Bottom := 5;
  FPath.WordWrap := False;
  FPath.StyleLookup := 'listboxitemdetaillabel';

  RefreshData;
end;

procedure TProjectScrollItem.RefreshData;
begin
  FName.Text := Format('%s (%s)', [FOrgConfiguration.GetName, FOrgConfiguration.GetGameType.ToString]);
  FPath.Text := FOrgConfiguration.GetPath;
end;

procedure TProjectScrollItem.Resize;
begin
  inherited;

  FName.Canvas.Font.Assign(FName.Font);
  var wantedHeight := Ceil(FName.Canvas.TextHeight('Yy'));

  FPath.Canvas.Font.Assign(FPath.Font);
  wantedHeight := wantedHeight + Ceil(FPath.Canvas.TextHeight('Yy'));

  Height := wantedHeight + FPath.Margins.Top + FPath.Margins.Bottom +
    FName.Margins.Top + FName.Margins.Bottom
end;

procedure TProjectScrollItem.SetSelected(const Value: Boolean);
begin
  FSelected := Value;
  if FSelected then
    StyleLookup := 'rScrollItemSelectedStyle'
  else
    StyleLookup := 'rScrollItemStyle';
end;

{ TProjectScrollItems }

procedure TProjectScrollItems.ClearSelection;
begin
  for var item in Self do
    item.Selected := False;
end;

constructor TProjectScrollItems.Create(AOwner: TCustomScrollBox);
begin
  inherited Create;
  FOwnerScroll := AOwner;
end;

procedure TProjectScrollItems.SelectAll;
begin
  for var item in Self do
    item.Selected := True;
end;

function TProjectScrollItems.Selected: TProjectScrollItem;
begin
  for var item in Self do
    if item.Selected then
      Exit(item);
  Result := nil;
end;

function TProjectScrollItems.SelectedCount: Integer;
begin
  Result := 0;
  for var item in Self do
    if item.Selected then
      Inc(Result);
end;

procedure TProjectScrollItems.SelectNext;
begin
  for var idx := 0 to Count - 1 do
    if Self[idx].Selected then
    begin
      ClearSelection;
      if idx = Count - 1 then
        Self[0].SetSelected(True)
      else
        Self[idx + 1].SetSelected(True);
      Break;
    end;
end;

procedure TProjectScrollItems.SelectPrev;
begin
  for var idx := 0 to Count - 1 do
    if Self[idx].Selected then
    begin
      ClearSelection;
      if idx = 0 then
        Self[Count - 1].SetSelected(True)
      else
        Self[idx - 1].SetSelected(True);
      Break;
    end;
end;

initialization

  GrijjyLog.Connect(TAppConfig.GetInstance.LogBroker, TAppConfig.GetInstance.LogService);

end.
