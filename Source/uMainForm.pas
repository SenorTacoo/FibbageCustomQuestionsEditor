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
  Data.Bind.ObjectScope, FMX.Platform, uQuestionsLoader, System.Math,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Media,
  ACS_Classes, ACS_DXAudio, ACS_Vorbis, ACS_Converters, ACS_Wave,
  NewACDSAudio, System.Generics.Collections, uRecordForm, FMX.ListBox, 
  System.Messaging, System.DateUtils, uLog, uCategoriesLoader,
  FMX.Menus, System.StrUtils, uGetTextDlg, FMX.Objects, FMX.DialogService, uAsyncAction,
  uContentConfiguration, uFibbageContent, uProjectActivator, uLastQuestionsLoader,
  FMX.Effects, Winapi.Windows, Winapi.ShellAPI, FMX.Platform.Win, Grijjy.CloudLogging,
  uUserDialog, uGetGameTypeDlg;

type
  TQuestionScrollItem = class(TPanel)
  private
    FDetails: TLabel;
    FQuestion: TLabel;
    FOrgQuestion: IQuestion;
    FOrgCategory: ICategory;
    FSelected: Boolean;
    procedure SetSelected(const Value: Boolean);
  protected
    procedure Resize; override;
  public
    constructor CreateItem(AOwner: TComponent; AQuestion: IQuestion);
    procedure RefreshData;

    property Selected: Boolean read FSelected write SetSelected;
    property OrgQuestion: IQuestion read FOrgQuestion;
    property OrgCategory: ICategory read FOrgCategory;
  end;

  TQuestionScrollItems = class(TList<TQuestionScrollItem>)
  public
    procedure ClearSelection;
    procedure SelectAll;
    function SelectedCount: Integer;
    procedure SelectNext;
    procedure SelectPrev;
    function Selected: TQuestionScrollItem;
    procedure SelectQuestionWithId(AId: Integer);
  end;

  TProjectScrollItem = class(TPanel)
  private
    FName: TLabel;
    FPath: TLabel;
    FOrgConfiguration: IContentConfiguration;
    FSelected: Boolean;
    procedure SetSelected(const Value: Boolean);
  protected
    procedure Resize; override;
  public
    constructor CreateItem(AOwner: TComponent; AConfiguration: IContentConfiguration);

    procedure RefreshData;

    property Selected: Boolean read FSelected write SetSelected;
    property OrgConfiguration: IContentConfiguration read FOrgConfiguration;
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
    tiShortieQuestions: TTabItem;
    tiEditSingleItem: TTabItem;
    aiContentLoading: TAniIndicator;
    lyDarkMode: TLayout;
    sDarkMode: TSwitch;
    lDarkMode: TLabel;
    aGoToQuestionDetails: TChangeTabAction;
    lySingleItemControls: TLayout;
    lySingleItemQuestion: TLayout;
    pSingleItemQuestion: TPanel;
    lSingleItemQuestion: TLabel;
    mSingleItemQuestion: TMemo;
    lySingleItemAnswer: TLayout;
    pSingleItemAnswer: TPanel;
    lSingleItemAnswer: TLabel;
    mSingleItemAnswer: TMemo;
    lySingleItemAlternateSpelling: TLayout;
    pSingleItemAlternateSpelling: TPanel;
    lSingleItemAlternateSpelling: TLabel;
    mSingleItemAlternateSpelling: TMemo;
    lySingleItemSuggestions: TLayout;
    pSingleItemSuggestions: TPanel;
    lSingleItemSuggestions: TLabel;
    mSingleItemSuggestions: TMemo;
    lySingleItemPossibleAnswers: TLayout;
    sSingleItemPossibleAnswers: TSplitter;
    Splitter1: TSplitter;
    lySingleItemAudio: TLayout;
    pSingleItemAudio: TPanel;
    lSingleItemAudio: TLabel;
    tiFinalQuestions: TTabItem;
    aGoToFinalQuestions: TChangeTabAction;
    aGoToShortieQuestions: TChangeTabAction;
    tiQuestions: TTabItem;
    tcQuestions: TTabControl;
    aGoToAllQuestions: TChangeTabAction;
    GridPanelLayout1: TGridPanelLayout;
    bSingleItemQuestionAudio: TButton;
    bSingleItemCorrectAudio: TButton;
    pSingleItemId: TPanel;
    lSingleItemId: TLabel;
    pSingleItemCategory: TPanel;
    lSingleItemCategory: TLabel;
    lySingleItemId: TLayout;
    lySingleItemCategory: TLayout;
    eSingleItemId: TEdit;
    eSingleItemCategory: TEdit;
    sbLightStyle: TStyleBook;
    sbDarkStyle: TStyleBook;
    tiQuestionProjects: TTabItem;
    aGoToHome: TChangeTabAction;
    bQuestions: TButton;
    sbxShortieQuestions: TVertScrollBox;
    sbxFinalQuestions: TVertScrollBox;
    tbQuestionProjects: TToolBar;
    lProjects: TLabel;
    ToolBar2: TToolBar;
    lProjectQuestions: TLabel;
    ToolBar3: TToolBar;
    lNewQuestion: TLabel;
    gplQuestions: TGridPanelLayout;
    bShortieQuestions: TButton;
    bFinalQuestions: TButton;
    bNewProject: TButton;
    lineTabs: TLine;
    miAddQuestion: TMenuItem;
    miEditQuestion: TMenuItem;
    miRemoveQuestions: TMenuItem;
    aRemoveQuestions: TAction;
    aAddQuestion: TAction;
    pmShortieQuestions: TPopupMenu;
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
    pQuestionToolbar: TPanel;
    pQuestionsToolbar: TPanel;
    pProjectsToolbar: TPanel;
    GlowEffect1: TGlowEffect;
    GlowEffect3: TGlowEffect;
    pQuestionsButtons: TPanel;
    GlowEffect5: TGlowEffect;
    pQuestionsMultiview: TPanel;
    pProjectsMultiview: TPanel;
    MenuItem1: TMenuItem;
    miOpenLocal: TMenuItem;
    aOpenInWindowsExplorer: TAction;
    bCancelQuestionChanges: TButton;
    bSaveQuestionChanges: TButton;
    aSaveQuestionChanges: TAction;
    aCancelQuestionChanges: TAction;
    miEditProject: TMenuItem;
    miActivateProject: TMenuItem;
    aSetProjectAsActive: TAction;
    MenuItem2: TMenuItem;
    miCopyToFinal: TMenuItem;
    MenuItem3: TMenuItem;
    pmFinalQuestions: TPopupMenu;
    MenuItem7: TMenuItem;
    miCopyToShorties: TMenuItem;
    miMoveToShorties: TMenuItem;
    aCopyToFinalQuestions: TAction;
    aMoveToFinalQuestions: TAction;
    aCopyToShortieQuestions: TAction;
    aMoveToShortieQuestions: TAction;
    miAddFinalQuestion: TMenuItem;
    miEditFinalQuestion: TMenuItem;
    miRemoveFinalQuestions: TMenuItem;
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
    Layout3: TLayout;
    bRefreshQuestionId: TButton;
    aSaveProjectAndClose: TAction;
    lyFamilyFilter: TLayout;
    lyCategoryData: TLayout;
    lyQuestionData: TLayout;
    lFamilyFriendly: TLabel;
    sFamilyFriendly: TSwitch;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
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
    Action1: TAction;
    bSpecialQuestions: TButton;
    bPersonalShortieQuestions: TButton;
    tiSpecialQuestions: TTabItem;
    tiPersonalShortieQuestions: TTabItem;
    sbxSpecialQuestions: TVertScrollBox;
    sbxPersonalShortieQuestions: TVertScrollBox;
    procedure lDarkModeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lvEditAllItemsUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure bSingleItemQuestionAudioClick(Sender: TObject);
    procedure bSingleItemCorrectAudioClick(Sender: TObject);
    procedure bSingleItemBumperAudioClick(Sender: TObject);
    procedure bHomeButtonClick(Sender: TObject);
    procedure bQuestionsClick(Sender: TObject);
    procedure bShortieQuestionsClick(Sender: TObject);
    procedure bFinalQuestionsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure aRemoveQuestionsExecute(Sender: TObject);
    procedure aAddQuestionExecute(Sender: TObject);
    procedure aEditQuestionExecute(Sender: TObject);
    procedure pmShortieQuestionsPopup(Sender: TObject);
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
    procedure aCancelQuestionChangesExecute(Sender: TObject);
    procedure mDisableEnter(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure aSetProjectAsActiveExecute(Sender: TObject);
    procedure aCopyToFinalQuestionsExecute(Sender: TObject);
    procedure aMoveToFinalQuestionsExecute(Sender: TObject);
    procedure aCopyToShortieQuestionsExecute(Sender: TObject);
    procedure aMoveToShortieQuestionsExecute(Sender: TObject);
    procedure aSaveChangesSettingsExecute(Sender: TObject);
    procedure aCancelChangesSettingsExecute(Sender: TObject);
    procedure bSettingsClick(Sender: TObject);
    procedure bRefreshQuestionIdClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure aSaveProjectAndCloseExecute(Sender: TObject);
    procedure lFamilyFriendlyClick(Sender: TObject);
    procedure bSettingsFibbageXLPathClick(Sender: TObject);
    procedure bSettingsFibbageXLPP1PathClick(Sender: TObject);
    procedure bSettingsFibbage3PP4PathClick(Sender: TObject);
  private
    FAppCreated: Boolean;
    FChangingTab: Boolean;
    FQuestionsChanged: Boolean;
    FContent: IFibbageContent;

    FSelectedQuestion: IQuestion;
    FSelectedCategory: ICategory;
    FSelectedConfiguration: IContentConfiguration;
    FActiveConfiguration: IContentConfiguration;

    FLastQuestionProjects: ILastQuestionProjects;

    FLastClickedItem: TQuestionScrollItem;
    FLastClickedItemToEdit: TQuestionScrollItem;

    FLastClickedConfiguration: TProjectScrollItem;
    FLastClickedConfigurationToEdit: TProjectScrollItem;

    FShortieVisItems: TQuestionScrollItems;
    FFinalVisItems: TQuestionScrollItems;
    FSpecialVisItems: TQuestionScrollItems;
    FPersonalShortieVisItems: TQuestionScrollItems;

    FProjectVisItems: TProjectScrollItems;

    procedure GoToQuestionDetails;
    procedure AddLastChoosenProject;
    procedure InitializeLastQuestionProjects;
    procedure SetButtonPressed(AButton: TButton);
    procedure DisableButton(AButton: TButton);

    procedure GoToFinalQuestions;
    procedure GoToShortieQuestions;
    procedure GoToSpecialQuestions;
    procedure GoToPersonalShortieQuestions;

    procedure GoToAllQuestions;
    procedure GoToHome;
    procedure GoToSettings;

    procedure PrepareMultiViewButtons(AActTab: TAppTab);
    procedure OnProjectItemDoubleClick(Sender: TObject);
    procedure OnProjectItemMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OnShortieQuestionItemDoubleClick(Sender: TObject);
    procedure OnFinalQuestionItemDoubleClick(Sender: TObject);
    procedure OnShortieQuestionItemMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure OnFinalQuestionItemMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure RemoveSelectedShortieQuestions;
    procedure RemoveSelectedFinalQuestions;

    procedure FillFinalScrollBox;
    procedure FillShortiesScrollBox;
    procedure FillSpecialScrollBox;
    procedure FillPersonalShortiesScrollBox;

    procedure RefreshSelectedFinalQuestion;
    procedure RefreshSelectedShortieQuestion;
    procedure CreateNewFinalQuestion;
    procedure CreateNewShortieQuestion;
    procedure SetDarkMode(AEnabled: Boolean);
    function GetProjectName(out AName: string): Boolean;
    function GetGameType(out AType: TGameType): Boolean;
    function GetProjectPath(out APath: string): Boolean;
    procedure ProcessInitializeProject;
    procedure ClearPreviousData;
    procedure ClearPreviousProjects;
    procedure UpdateQuestionsGridView;
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
    procedure OnRemoveProject;
    procedure OnRemoveProjectFullWipe;
    procedure ActivateProjectProc;
    procedure OnActivateEnd;
    procedure OnActivateStart;
    function GetFibbageXLPath(out APath: string): Boolean;
    function GetFibbage3Path(out APath: string): Boolean;
    procedure OnPostSaveClose;
    procedure ProcessKeyDown_Questions(var Key: Word; Shift: TShiftState);
    procedure ProcessKeyDown_QuestionsProject(var Key: Word;
      Shift: TShiftState);
    procedure RefreshProjectFormActions;
    procedure RefreshQuestionsFormActions;
    function IsCategoryDuplicated: Boolean;
    function ShowInfoAboutDuplicatedCategories(const AInfo: string): Boolean;
    function ShowInfoAboutTooFewSuggestions(const AInfo: string): Boolean;
    function ShowInfoAboutTooFewShortieQuestions(const AInfo: string): Boolean;
    function IsTooFewSuggestions: Boolean;
    function GetSingleQuestionSuggestions: string;
    function GetFirstDuplicatedCategoryQuestionId(out AIsShortie: Boolean; out AId: Integer): Boolean;
    function GetFirstTooFewSuggestionsQuestionId(out AIsShortie: Boolean;
      out AId: Integer): Boolean;
    function CheckForDuplicatedCategoriesPreSave: Boolean;
    function CheckForTooFewSuggestions: Boolean;
    function ShouldSaveProject: Boolean;
    function CheckForTooFewShortieQuestions_PartyPack1: Boolean;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

const
  OPTIMAL_NR_OF_SUGGESTIONS = 17;
  PARTY_PACK_1_MIN_NR_OF_SHORTIE_QUESTIONS = 6;

implementation

{$R *.fmx}

procedure TFrmMain.aAddQuestionExecute(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  if tcQuestions.ActiveTab = tiShortieQuestions then
    CreateNewShortieQuestion
  else
    CreateNewFinalQuestion;

  lNewQuestion.Text := 'New question';
  GoToQuestionDetails;
end;

procedure TFrmMain.aCancelChangesSettingsExecute(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  GoToHome;
end;

procedure TFrmMain.aCancelQuestionChangesExecute(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  GoToAllQuestions;
end;

procedure TFrmMain.aCopyToFinalQuestionsExecute(Sender: TObject);
var
  newQuestion: IQuestion;
begin
  sbxFinalQuestions.BeginUpdate;
  try
    for var item in FShortieVisItems do
      if item.Selected then
      begin
        FContent.CopyToFinalQuestions(item.OrgQuestion, newQuestion);

        var qItem := TQuestionScrollItem.CreateItem(sbxFinalQuestions, newQuestion);
        qItem.Parent := sbxFinalQuestions;
        qItem.Align := TAlignLayout.Top;
        qItem.Position.Y := MaxInt;
        qItem.OnMouseDown := OnFinalQuestionItemMouseDown;
        qItem.OnDblClick := OnFinalQuestionItemDoubleClick;
        FFinalVisItems.Add(qItem);
      end;
  finally
    sbxFinalQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.aCopyToShortieQuestionsExecute(Sender: TObject);
var
  newQuestion: IQuestion;
begin
  sbxShortieQuestions.BeginUpdate;
  try
    for var item in FFinalVisItems do
      if item.Selected then
      begin
        FContent.CopyToShortieQuestions(item.OrgQuestion, newQuestion);

        var qItem := TQuestionScrollItem.CreateItem(sbxShortieQuestions, newQuestion);
        qItem.Parent := sbxShortieQuestions;
        qItem.Align := TAlignLayout.Top;
        qItem.Position.Y := MaxInt;
        qItem.OnMouseDown := OnShortieQuestionItemMouseDown;
        qItem.OnDblClick := OnShortieQuestionItemDoubleClick;
        FShortieVisItems.Add(qItem);
      end;
  finally
    sbxShortieQuestions.EndUpdate;
  end;
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
  if not Assigned(FLastClickedItemToEdit) then
    Exit;

  FSelectedQuestion := FLastClickedItemToEdit.OrgQuestion;
  FSelectedCategory := FLastClickedItemToEdit.OrgCategory;
  FLastClickedItemToEdit.Selected := True;

  lNewQuestion.Text := 'Edit question';
  GoToQuestionDetails;
end;

function TFrmMain.GetFibbage3Path(out APath: string): Boolean;
begin
  Result := SelectDirectory('Select Fibbage3 directory', '', APath);
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
  var cfg: IContentConfiguration := TContentConfiguration.Create;

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

    if not GetProjectName(str) then
      Exit;

    cfg.SetName(str);
    cfg.SetGameType(gameType);
    cfg.Save(cfg.GetPath);

    Break;
  end;

  sbxProjects.BeginUpdate;
  try
    FProjectVisItems.ClearSelection;
    var pItem := TProjectScrollItem.CreateItem(sbxProjects, cfg);
    pItem.Parent := sbxProjects;
    pItem.Align := TAlignLayout.Top;
    pItem.Position.Y := -999;
    pItem.OnMouseDown := OnProjectItemMouseDown;
    pItem.OnDblClick := OnProjectItemDoubleClick;
    FLastClickedConfigurationToEdit := pItem;
    FProjectVisItems.Add(pItem);
    pItem.Selected := True;
  finally
    sbxProjects.EndUpdate;
  end;

  aInitializeProject.Execute;
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
          mrYes: aSaveProject.Execute;
          mrCancel: Exit;
        end;
        ProcessInitializeProject;
      end);
  end
  else
    ProcessInitializeProject;
end;

procedure TFrmMain.aMoveToFinalQuestionsExecute(Sender: TObject);
begin
  sbxShortieQuestions.BeginUpdate;
  sbxFinalQuestions.BeginUpdate;
  try
    for var idx := FShortieVisItems.Count - 1 downto 0 do
    begin
      var item := FShortieVisItems[idx];
      if not item.Selected then
        Continue;

      FContent.MoveToFinalQuestions(item.OrgQuestion);

      var qItem := TQuestionScrollItem.CreateItem(sbxFinalQuestions, item.OrgQuestion);
      qItem.Parent := sbxFinalQuestions;
      qItem.Align := TAlignLayout.Top;
      qItem.Position.Y := MaxInt;
      qItem.OnMouseDown := OnFinalQuestionItemMouseDown;
      qItem.OnDblClick := OnFinalQuestionItemDoubleClick;
      FFinalVisItems.Add(qItem);

      item := FShortieVisItems.ExtractAt(idx);
      FreeAndNil(item);
    end;
  finally
    sbxFinalQuestions.EndUpdate;
    sbxShortieQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.aMoveToShortieQuestionsExecute(Sender: TObject);
begin
  sbxShortieQuestions.BeginUpdate;
  sbxFinalQuestions.BeginUpdate;
  try
    for var idx := FFinalVisItems.Count - 1 downto 0 do
    begin
      var item := FFinalVisItems[idx];
      if not item.Selected then
        Continue;

      FContent.MoveToShortieQuestions(item.OrgQuestion);

      var qItem := TQuestionScrollItem.CreateItem(sbxShortieQuestions, item.OrgQuestion);
      qItem.Parent := sbxShortieQuestions;
      qItem.Align := TAlignLayout.Top;
      qItem.Position.Y := MaxInt;
      qItem.OnMouseDown := OnShortieQuestionItemMouseDown;
      qItem.OnDblClick := OnShortieQuestionItemDoubleClick;
      FShortieVisItems.Add(qItem);

      item := FFinalVisItems.ExtractAt(idx);
      FreeAndNil(item);
    end;
  finally
    sbxFinalQuestions.EndUpdate;
    sbxShortieQuestions.EndUpdate;
  end;
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
  ClearPreviousData;
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
    FillShortiesScrollBox;
    FillFinalScrollBox;

    if FSelectedConfiguration.GetGameType = TGameType.Fibbage3PartyPack4 then
    begin
      FillSpecialScrollBox;
      FillPersonalShortiesScrollBox;
    end;

    AddLastChoosenProject;
  finally
    GoToAllQuestions;
    pLoading.Visible := False;
    aiContentLoading.Enabled := False;
    FLastClickedItemToEdit := nil;
    aRemoveQuestions.Enabled := False;
    bSpecialQuestions.Visible := FSelectedConfiguration.GetGameType = TGameType.Fibbage3PartyPack4;
    bPersonalShortieQuestions.Visible := FSelectedConfiguration.GetGameType = TGameType.Fibbage3PartyPack4;
    UpdateQuestionsGridView;
    lProjectQuestions.Text := Format('Questions - %s', [FSelectedConfiguration.GetName]);
  end;
end;

procedure TFrmMain.InitializeContentTask;
begin
  FContent := TFibbageContent.Create;
  FContent.Initialize(FSelectedConfiguration);
end;

procedure TFrmMain.ClearPreviousData;
begin
  sbxShortieQuestions.BeginUpdate;
  try
    while FShortieVisItems.Count > 0 do
    begin
      var item := FShortieVisItems.ExtractAt(0);
      FreeAndNil(item);
    end;
  finally
    sbxShortieQuestions.EndUpdate;
  end;

  sbxFinalQuestions.BeginUpdate;
  try
    while FFinalVisItems.Count > 0 do
    begin
      var item := FFinalVisItems.ExtractAt(0);
      FreeAndNil(item);
    end;
  finally
    sbxFinalQuestions.EndUpdate;
  end;

  sbxSpecialQuestions.BeginUpdate;
  try
    while FSpecialVisItems.Count > 0 do
    begin
      var item := FSpecialVisItems.ExtractAt(0);
      FreeAndNil(item);
    end;
  finally
    sbxSpecialQuestions.EndUpdate;
  end;

  sbxPersonalShortieQuestions.BeginUpdate;
  try
    while FPersonalShortieVisItems.Count > 0 do
    begin
      var item := FPersonalShortieVisItems.ExtractAt(0);
      FreeAndNil(item);
    end;
  finally
    sbxPersonalShortieQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.ClearPreviousProjects;
begin
  sbxFinalQuestions.BeginUpdate;
  try
    while FProjectVisItems.Count > 0 do
    begin
      var item := FProjectVisItems.ExtractAt(0);
      FreeAndNil(item);
    end;
  finally
    sbxFinalQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.aNewProjectExecute(Sender: TObject);
var
  str: string;
  gameType: TGameType;
begin
  var cfg: IContentConfiguration := TContentConfiguration.Create;
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

  sbxProjects.BeginUpdate;
  try
    FProjectVisItems.ClearSelection;
    var pItem := TProjectScrollItem.CreateItem(sbxProjects, cfg);
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

procedure TFrmMain.OnRemoveProject;
begin
  for var idx := 0 to FProjectVisItems.Count - 1 do
  begin
    if not FProjectVisItems[idx].Selected then
      Continue;

    FLastQuestionProjects.Remove(FProjectVisItems[idx].OrgConfiguration);
  end;
end;

procedure TFrmMain.OnRemoveProjectFullWipe;
begin
  for var idx := 0 to FProjectVisItems.Count - 1 do
  begin
    if not FProjectVisItems[idx].Selected then
      Continue;
    TDirectory.Delete(FProjectVisItems[idx].OrgConfiguration.GetPath, True);
    FLastQuestionProjects.Remove(FProjectVisItems[idx].OrgConfiguration);
  end;
end;

procedure TFrmMain.aRemoveProjectsAllDataExecute(Sender: TObject);
begin
  TAsyncAction.Create(OnRemoveProjectStart, OnRemoveProjectEnd, OnRemoveProjectFullWipe).Start
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

          ClearPreviousData;
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
  TAsyncAction.Create(OnRemoveProjectStart, OnRemoveProjectEnd, OnRemoveProject).Start;
end;

procedure TFrmMain.aRemoveQuestionsExecute(Sender: TObject);
begin
  if tcQuestions.ActiveTab = tiShortieQuestions then
    RemoveSelectedShortieQuestions
  else
    RemoveSelectedFinalQuestions;
end;

procedure TFrmMain.aSaveChangesSettingsExecute(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  TAppConfig.GetInstance.FibbageXLPath := eSettingsFibbageXLPath.Text;
  TAppConfig.GetInstance.FibbageXLPartyPack1Path := eSettingsFibbageXLPP1Path.Text;
  TAppConfig.GetInstance.Fibbage3PartyPack4Path := eSettingsFibbage3PP4Path.Text;
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

procedure TFrmMain.OnPostSaveClose;
begin
  OnPostSave;
  Close;
end;

procedure TFrmMain.aSaveProjectAsExecute(Sender: TObject);
var
  path: string;
begin
  if not ShouldSaveProject then
    Exit
  else if not GetProjectPath(path) then
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

function TFrmMain.GetFirstTooFewSuggestionsQuestionId(out AIsShortie: Boolean; out AId: Integer): Boolean;
begin
  Result := False;
  for var idx := 0 to FContent.Questions.ShortieQuestions.Count - 1 do
  begin
    var fQuestion := FContent.Questions.ShortieQuestions[idx];
    var suggestions := TStringList.Create;
    try
      suggestions.StrictDelimiter := True;
      suggestions.DelimitedText := fQuestion.GetSuggestions;
      if suggestions.Count < OPTIMAL_NR_OF_SUGGESTIONS then
      begin
        AIsShortie := True;
        AId := fQuestion.GetId;
        Exit(True);
      end;
    finally
      suggestions.Free;
    end;
  end;

  for var idx := 0 to FContent.Questions.FinalQuestions.Count - 1 do
  begin
    var fQuestion := FContent.Questions.FinalQuestions[idx];
    var suggestions := TStringList.Create;
    try
      suggestions.StrictDelimiter := True;
      suggestions.DelimitedText := fQuestion.GetSuggestions;
      if suggestions.Count < OPTIMAL_NR_OF_SUGGESTIONS then
      begin
        AIsShortie := False;
        AId := fQuestion.GetId;
        Exit(True);
      end;
    finally
      suggestions.Free;
    end;
  end;
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

function TFrmMain.GetFirstDuplicatedCategoryQuestionId(out AIsShortie: Boolean; out AId: Integer): Boolean;
begin
  Result := False;
  for var idx := 0 to FContent.Questions.ShortieQuestions.Count - 2 do
    for var jdx := idx + 1 to FContent.Questions.ShortieQuestions.Count - 1 do
    begin
      var fQuestion := FContent.Questions.ShortieQuestions[idx];
      var sQuestion := FContent.Questions.ShortieQuestions[jdx];

      if fQuestion.GetCategory.Equals(sQuestion.GetCategory) then
      begin
        AIsShortie := True;
        AId := fQuestion.GetId;
        Exit(True);
      end;
    end;

  for var idx := 0 to FContent.Questions.FinalQuestions.Count - 2 do
    for var jdx := idx + 1 to FContent.Questions.FinalQuestions.Count - 1 do
    begin
      var fQuestion := FContent.Questions.FinalQuestions[idx];
      var sQuestion := FContent.Questions.FinalQuestions[jdx];

      if fQuestion.GetCategory.Equals(sQuestion.GetCategory) then
      begin
        AIsShortie := False;
        AId := fQuestion.GetId;
        Exit(True);
      end;
    end;
end;

procedure TFrmMain.SaveProc;
begin
  FContent.Save;
end;

function TFrmMain.CheckForDuplicatedCategoriesPreSave: Boolean;
var
  isShortie: Boolean;
  qId: Integer;
begin
  Result := True;
  if TAppConfig.GetInstance.ShowInfoAboutDuplicatedCategories and GetFirstDuplicatedCategoryQuestionId(isShortie, qId) then
    if not ShowInfoAboutDuplicatedCategories('Found questions with the same category, you might experience the same category during "Pick category" part in the game. Continue?') then
    begin
      GoToAllQuestions;

      if isShortie then
      begin
        GoToShortieQuestions;
        FShortieVisItems.SelectQuestionWithId(qId);
        sbxShortieQuestions.ViewportPosition := TPointF.Create(0, FShortieVisItems.Selected.Top);
        FLastClickedItemToEdit := FShortieVisItems.Selected;
      end
      else
      begin
        GoToFinalQuestions;
        FFinalVisItems.SelectQuestionWithId(qId);
        sbxFinalQuestions.ViewportPosition := TPointF.Create(0, FFinalVisItems.Selected.Top);
        FLastClickedItemToEdit := FFinalVisItems.Selected;
      end;
      Result := False;
    end;
end;

function TFrmMain.CheckForTooFewShortieQuestions_PartyPack1: Boolean;
begin
  Result := True;

  if FContent.Questions.ShortieQuestions.Count < PARTY_PACK_1_MIN_NR_OF_SHORTIE_QUESTIONS then
    if not ShowInfoAboutTooFewShortieQuestions(
      Format('Too few shortie questions. FibbageXL from PartyPack1 will freeze on start. A minimum of %u questions is required. Continue?', [PARTY_PACK_1_MIN_NR_OF_SHORTIE_QUESTIONS])) then
    begin
      GoToAllQuestions;
      GoToShortieQuestions;
      Result := False;
    end;
end;

function TFrmMain.CheckForTooFewSuggestions: Boolean;
var
  isShortie: Boolean;
  qId: Integer;
begin
  Result := True;
  if TAppConfig.GetInstance.ShowInfoAboutTooFewSuggestions and GetFirstTooFewSuggestionsQuestionId(isShortie, qId) then
    if not ShowInfoAboutTooFewSuggestions('Found question with too few suggestions, the game can freeze because of this. The optimal number of suggestions is 17 (Max number of players * 2 + 1). Continue?') then
    begin
      GoToAllQuestions;

      if isShortie then
      begin
        GoToShortieQuestions;
        FShortieVisItems.SelectQuestionWithId(qId);
        sbxShortieQuestions.ViewportPosition := TPointF.Create(0, FShortieVisItems.Selected.Top);
        FLastClickedItemToEdit := FShortieVisItems.Selected;
      end
      else
      begin
        GoToFinalQuestions;
        FFinalVisItems.SelectQuestionWithId(qId);
        sbxFinalQuestions.ViewportPosition := TPointF.Create(0, FFinalVisItems.Selected.Top);
        FLastClickedItemToEdit := FFinalVisItems.Selected;
      end;
      Result := False;
    end;
end;

function TFrmMain.ShouldSaveProject: Boolean;
begin
  Result := False;
  if not CheckForDuplicatedCategoriesPreSave then
    Exit;
  if not CheckForTooFewSuggestions then
    Exit;
  if not CheckForTooFewShortieQuestions_PartyPack1 then
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
  var suggestions := TStringList.Create;
  try
    suggestions.StrictDelimiter := True;
    suggestions.Delimiter := ',';
    suggestions.DelimitedText := GetSingleQuestionSuggestions;
    Result := suggestions.Count < OPTIMAL_NR_OF_SUGGESTIONS;
  finally
    suggestions.Free;
  end;
end;

function TFrmMain.IsCategoryDuplicated: Boolean;
var
  allQuestions: TList<IQuestion>;
begin
  Result := False;
  if eSingleItemCategory.Text.Trim.IsEmpty then
    Exit;

  if FSelectedQuestion.GetQuestionType = qtShortie then
    allQuestions := FContent.Questions.ShortieQuestions
  else
    allQuestions := FContent.Questions.FinalQuestions;

  for var question in allQuestions do
    if question = FSelectedQuestion then
      Continue
    else if SameText(question.GetCategory, eSingleItemCategory.Text.Trim) then
      Exit(True);
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

procedure TFrmMain.UpdateQuestionsGridView;
begin
  gplQuestions.BeginUpdate;
  try
    gplQuestions.ColumnCollection[0].Value := 100;
    gplQuestions.ColumnCollection[1].Value := 50;

    if bSpecialQuestions.Visible then
      gplQuestions.ColumnCollection[2]. Value := 33.33333333
    else
      gplQuestions.ColumnCollection[2].Value := 0;
    if bPersonalShortieQuestions.Visible then
      gplQuestions.ColumnCollection[3].Value := 25
    else
      gplQuestions.ColumnCollection[3].Value := 0;
  finally
    gplQuestions.EndUpdate;
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

function TFrmMain.GetSingleQuestionSuggestions: string;
begin
  var suggestions := TStringList.Create;
  try
    suggestions.StrictDelimiter := True;
    suggestions.Delimiter := ',';
    suggestions.DelimitedText := mSingleItemSuggestions.Text.Replace(', ', ',').Trim;

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
begin
  if FChangingTab then
    Exit;

  if TAppConfig.GetInstance.ShowInfoAboutDuplicatedCategories and IsCategoryDuplicated then
    if not ShowInfoAboutDuplicatedCategories('Found question with the same category, you might experience the same category during "Pick category" part in the game. Continue?') then
      Exit;

  if TAppConfig.GetInstance.ShowInfoAboutTooFewSuggestions and IsTooFewSuggestions then
    if not ShowInfoAboutTooFewSuggestions('Too few suggestions, the game can freeze because of this. The optimal number of suggestions is 17 (Max number of players * 2 + 1). Continue?') then
      Exit;

  FQuestionsChanged := True;

  FSelectedQuestion.SetQuestion(mSingleItemQuestion.Text.Trim);
  FSelectedQuestion.SetAnswer(mSingleItemAnswer.Text.Trim);
  FSelectedQuestion.SetAlternateSpelling(mSingleItemAlternateSpelling.Text.Replace(', ', ',').Trim);
  FSelectedQuestion.SetSuggestions(GetSingleQuestionSuggestions);

  FSelectedCategory.SetId(StrToInt(eSingleItemId.Text));
  FSelectedCategory.SetCategory(eSingleItemCategory.Text.Trim);
  FSelectedCategory.SetIsFamilyFriendly(sFamilyFriendly.IsChecked);
  FSelectedQuestion.SetCategoryObj(FSelectedCategory);

  if FSelectedQuestion.GetQuestionType = qtShortie then
    RefreshSelectedShortieQuestion
  else
    RefreshSelectedFinalQuestion;

  GoToAllQuestions;
end;

procedure TFrmMain.aSetProjectAsActiveExecute(Sender: TObject);
var
  path: string;
begin
  for var item in FProjectVisItems do
    if item.Selected then
    begin
      FActiveConfiguration := item.OrgConfiguration;
      Break;
    end;

  case FActiveConfiguration.GetGameType of
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
  end;

  TAsyncAction.Create(OnActivateStart, OnActivateEnd, ActivateProjectProc).Start;
end;

procedure TFrmMain.OnActivateStart;
begin
  pLoading.Visible := True;
  aiContentLoading.Enabled := True;
end;

procedure TFrmMain.OnActivateEnd;
begin
  pLoading.Visible := False;
  aiContentLoading.Enabled := False;
end;

procedure TFrmMain.ActivateProjectProc;
var
  destPath: string;
begin
  case FActiveConfiguration.GetGameType of
    TGameType.FibbageXL:
      destPath := System.IOUtils.TPath.Combine(TAppConfig.GetInstance.FibbageXLPath, 'content');
    TGameType.FibbageXLPartyPack1:
      destPath := System.IOUtils.TPath.Combine(TAppConfig.GetInstance.FibbageXLPartyPack1Path, 'content');
    TGameType.Fibbage3PartyPack4:
      destPath := System.IOUtils.TPath.Combine(TAppConfig.GetInstance.Fibbage3PartyPack4Path, 'content');
  end;

  TProjectActivator.Activate(FActiveConfiguration, destPath);
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

procedure TFrmMain.bRefreshQuestionIdClick(Sender: TObject);
begin
  eSingleItemId.Text := FContent.Categories.GetAvailableId.ToString;
end;

procedure TFrmMain.RemoveSelectedShortieQuestions;
begin
  sbxShortieQuestions.BeginUpdate;
  try
    for var idx := FShortieVisItems.Count - 1 downto 0 do
      if FShortieVisItems[idx].Selected then
      begin
        var item := FShortieVisItems.ExtractAt(idx);
        FContent.RemoveShortieQuestion(item.OrgQuestion);
        FreeAndNil(item);
      end;
  finally
    FLastClickedItemToEdit := nil;
    aRemoveQuestions.Enabled := False;
    sbxShortieQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.sDarkModeOptionsSwitch(Sender: TObject);
begin
  SetDarkMode(sDarkModeOptions.IsChecked);
end;

procedure TFrmMain.sDarkModeSwitch(Sender: TObject);
begin
  SetDarkMode(sDarkMode.IsChecked);
end;

procedure TFrmMain.RemoveSelectedFinalQuestions;
begin
  sbxFinalQuestions.BeginUpdate;
  try
    for var idx := FFinalVisItems.Count - 1 downto 0 do
      if FFinalVisItems[idx].Selected then
      begin
        var item := FFinalVisItems.ExtractAt(idx);
        FContent.RemoveFinalQuestion(item.OrgQuestion);
        FreeAndNil(item);
      end;
  finally
    FLastClickedItemToEdit := nil;
    aRemoveQuestions.Enabled := False;
    sbxFinalQuestions.EndUpdate;
  end;
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

procedure TFrmMain.OnShortieQuestionItemDoubleClick(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  Log('OnShortieQuestionItemDoubleClick');
  aEditQuestion.Execute;
end;

procedure TFrmMain.OnFinalQuestionItemDoubleClick(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  Log('OnFinalQuestionItemDoubleClick');
  aEditQuestion.Execute;
end;

procedure TFrmMain.OnFinalQuestionItemMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Log('OnFinalQuestionItemMouseDown');
  if FChangingTab then
    Exit;
  if not (Sender is TQuestionScrollItem) then
    Exit;

  FLastClickedItemToEdit := Sender as TQuestionScrollItem;

  if Button = TMouseButton.mbRight then
  begin
    FLastClickedItem := Sender as TQuestionScrollItem;
    sbxFinalQuestions.BeginUpdate;
    try
      if not (Sender as TQuestionScrollItem).Selected then
      begin
        FFinalVisItems.ClearSelection;
        (Sender as TQuestionScrollItem).Selected := True;
      end;
    finally
      sbxFinalQuestions.EndUpdate;
    end;
    pmFinalQuestions.Popup(Screen.MousePos.X, Screen.MousePos.Y);
  end
  else if ssDouble in Shift then
  begin
    FFinalVisItems.ClearSelection;
    (Sender as TQuestionScrollItem).Selected := True;
  end
  else if ssShift in Shift then
  begin
    var fIdx := 0;
    var sIdx := FFinalVisItems.IndexOf(Sender as TQuestionScrollItem);
    if Assigned(FLastClickedItem) then
      fIdx := FFinalVisItems.IndexOf(FLastClickedItem);

    if fIdx > sIdx then
    begin
      var tmp := fIdx;
      fIdx := sIdx;
      sIdx := tmp;
    end;

    for var idx := 0 to FFinalVisItems.Count - 1 do
      FFinalVisItems[idx].Selected := (idx >= fIdx) and (idx <= sIdx);
  end
  else
  begin
    FLastClickedItem := Sender as TQuestionScrollItem;
    if ssCtrl in Shift then
      (Sender as TQuestionScrollItem).Selected := not (Sender as TQuestionScrollItem).Selected
    else
    begin
      for var item in FFinalVisItems do
        if item = Sender then
          item.Selected := not item.Selected
        else
          item.Selected := False;
    end;
  end;
  if not (Sender as TQuestionScrollItem).Selected then
    FLastClickedItemToEdit := nil;

  var selCnt := FFinalVisItems.SelectedCount;
  aRemoveQuestions.Enabled :=  selCnt > 0;
  aRemoveQuestions.Text := IfThen(selCnt > 1, 'Remove questions', 'Remove question');
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

procedure TFrmMain.OnShortieQuestionItemMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  Log('OnShortieQuestionItemMouseDown');
  if FChangingTab then
    Exit;
  if not (Sender is TQuestionScrollItem) then
    Exit;

  FLastClickedItemToEdit := Sender as TQuestionScrollItem;

  if Button = TMouseButton.mbRight then
  begin
    FLastClickedItem := Sender as TQuestionScrollItem;
    sbxShortieQuestions.BeginUpdate;
    try
      if not (Sender as TQuestionScrollItem).Selected then
      begin
        FShortieVisItems.ClearSelection;
        (Sender as TQuestionScrollItem).Selected := True;
      end;
    finally
      sbxShortieQuestions.EndUpdate;
    end;
    pmShortieQuestions.Popup(Screen.MousePos.X, Screen.MousePos.Y);
  end
  else if ssDouble in Shift then
  begin
    FShortieVisItems.ClearSelection;
    (Sender as TQuestionScrollItem).Selected := True;
  end
  else if ssShift in Shift then
  begin
    var fIdx := 0;
    var sIdx := FShortieVisItems.IndexOf(Sender as TQuestionScrollItem);
    if Assigned(FLastClickedItem) then
      fIdx := FShortieVisItems.IndexOf(FLastClickedItem);

    if fIdx > sIdx then
    begin
      var tmp := fIdx;
      fIdx := sIdx;
      sIdx := tmp;
    end;

    for var idx := 0 to FShortieVisItems.Count - 1 do
      FShortieVisItems[idx].Selected := (idx >= fIdx) and (idx <= sIdx);
  end
  else
  begin
    FLastClickedItem := Sender as TQuestionScrollItem;
    if ssCtrl in Shift then
      (Sender as TQuestionScrollItem).Selected := not (Sender as TQuestionScrollItem).Selected
    else
    begin
      for var item in FShortieVisItems do
        if item = Sender then
          item.Selected := not item.Selected
        else
          item.Selected := False;
    end;
  end;

  if not (Sender as TQuestionScrollItem).Selected then
    FLastClickedItemToEdit := nil;

  var selCnt := FShortieVisItems.SelectedCount;
  aRemoveQuestions.Enabled :=  selCnt > 0;
  aRemoveQuestions.Text := IfThen(selCnt > 1, 'Remove questions', 'Remove question');
end;

procedure TFrmMain.PrepareMultiViewButtons(AActTab: TAppTab);
begin
  mvHomeOptions.BeginUpdate;
  try
    bQuestions.Enabled := AActTab <> atHomeBeforeImport;
  finally
    mvHomeOptions.EndUpdate;
  end;
end;

procedure TFrmMain.FillShortiesScrollBox;
begin
  sbxShortieQuestions.BeginUpdate;
  try
    for var item in FContent.Questions.ShortieQuestions do
    begin
      var qItem := TQuestionScrollItem.CreateItem(sbxShortieQuestions, item);
      qItem.Parent := sbxShortieQuestions;
      qItem.Align := TAlignLayout.Top;
      qItem.Position.Y := MaxInt;
      qItem.OnMouseDown := OnShortieQuestionItemMouseDown;
      qItem.OnDblClick := OnShortieQuestionItemDoubleClick;
      FShortieVisItems.Add(qItem);
    end;
  finally
    sbxShortieQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.FillSpecialScrollBox;
begin
  sbxSpecialQuestions.BeginUpdate;
  try
    for var item in FContent.Questions.SpecialQuestions do
    begin
      var qItem := TQuestionScrollItem.CreateItem(sbxSpecialQuestions, item);
      qItem.Parent := sbxSpecialQuestions;
      qItem.Align := TAlignLayout.Top;
      qItem.Position.Y := MaxInt;
//      qItem.OnMouseDown := OnShortieQuestionItemMouseDown;
//      qItem.OnDblClick := OnShortieQuestionItemDoubleClick;
      FSpecialVisItems.Add(qItem);
    end;
  finally
    sbxSpecialQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.FillFinalScrollBox;
begin
  sbxFinalQuestions.BeginUpdate;
  try
    for var item in FContent.Questions.FinalQuestions do
    begin
      var qItem := TQuestionScrollItem.CreateItem(sbxFinalQuestions, item);
      qItem.Parent := sbxFinalQuestions;
      qItem.Align := TAlignLayout.Top;
      qItem.Position.Y := MaxInt;
      qItem.OnMouseDown := OnFinalQuestionItemMouseDown;
      qItem.OnDblClick := OnFinalQuestionItemDoubleClick;
      FFinalVisItems.Add(qItem);
    end;
  finally
    sbxFinalQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.FillPersonalShortiesScrollBox;
begin
  sbxPersonalShortieQuestions.BeginUpdate;
  try
    for var item in FContent.Questions.PersonalShortieQuestions do
    begin
      var qItem := TQuestionScrollItem.CreateItem(sbxPersonalShortieQuestions, item);
      qItem.Parent := sbxPersonalShortieQuestions;
      qItem.Align := TAlignLayout.Top;
      qItem.Position.Y := MaxInt;
//      qItem.OnMouseDown := OnShortieQuestionItemMouseDown;
//      qItem.OnDblClick := OnShortieQuestionItemDoubleClick;
      FPersonalShortieVisItems.Add(qItem);
    end;
  finally
    sbxPersonalShortieQuestions.EndUpdate;
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
end;

procedure TFrmMain.RefreshQuestionsFormActions;
var
  selCnt: Integer;
begin
  if tcQuestions.ActiveTab = tiShortieQuestions then
    selCnt := FShortieVisItems.SelectedCount
  else if tcQuestions.ActiveTab = tiFinalQuestions then
    selCnt := FFinalVisItems.SelectedCount
  else if tcQuestions.ActiveTab = tiSpecialQuestions then
    selCnt := FSpecialVisItems.SelectedCount
  else if tcQuestions.ActiveTab = tiPersonalShortieQuestions then
    selCnt := FPersonalShortieVisItems.SelectedCount
  else
  begin
    Assert(False);
    Exit;
  end;

  aRemoveQuestions.Text := IfThen(selCnt > 1, 'Remove questions', 'Remove question');
  aRemoveQuestions.Enabled := selCnt > 0;
  aEditQuestion.Enabled := Assigned(FLastClickedItemToEdit) and (selCnt = 1);

  if tcQuestions.ActiveTab = tiShortieQuestions then // TODO
  begin
    aCopyToFinalQuestions.Enabled := selCnt > 0;
    aMoveToFinalQuestions.Enabled := selCnt > 0;
  end
  else if tcQuestions.ActiveTab = tiFinalQuestions then
  begin
    aCopyToShortieQuestions.Enabled := selCnt > 0;
    aMoveToShortieQuestions.Enabled := selCnt > 0;
  end
  else
    Assert(False);
end;

procedure TFrmMain.pmProjectsPopup(Sender: TObject);
begin
  RefreshProjectFormActions;
end;

procedure TFrmMain.pmShortieQuestionsPopup(Sender: TObject);
begin
  RefreshQuestionsFormActions;
end;

procedure TFrmMain.CreateNewShortieQuestion;
begin
  FContent.AddShortieQuestion;
  FSelectedQuestion := FContent.Questions.ShortieQuestions.Last;
  FSelectedCategory := FSelectedQuestion.GetCategoryObj;

  sbxShortieQuestions.BeginUpdate;
  try
    FShortieVisItems.ClearSelection;
    var qItem := TQuestionScrollItem.CreateItem(sbxShortieQuestions, FSelectedQuestion);
    qItem.Parent := sbxShortieQuestions;
    qItem.Align := TAlignLayout.Top;
    qItem.Position.Y := MaxInt;
    qItem.OnMouseDown := OnShortieQuestionItemMouseDown;
    qItem.OnDblClick := OnShortieQuestionItemDoubleClick;
    FLastClickedItemToEdit := qItem;
    qItem.Selected := True;
    aRemoveQuestions.Enabled := True;
    FShortieVisItems.Add(qItem);
  finally
    sbxShortieQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.DisableButton(AButton: TButton);
begin
  for var item in [bShortieQuestions, bFinalQuestions, bSpecialQuestions, bPersonalShortieQuestions] do
    item.Enabled := item <> AButton;
end;

procedure TFrmMain.CreateNewFinalQuestion;
begin
  FContent.AddFinalQuestion;
  FSelectedQuestion := FContent.Questions.FinalQuestions.Last;
  FSelectedCategory := FSelectedQuestion.GetCategoryObj;

  sbxFinalQuestions.BeginUpdate;
  try
    FFinalVisItems.ClearSelection;
    var qItem := TQuestionScrollItem.CreateItem(sbxFinalQuestions, FSelectedQuestion);
    qItem.Parent := sbxFinalQuestions;
    qItem.Align := TAlignLayout.Top;
    qItem.Position.Y := MaxInt;
    qItem.OnMouseDown := OnFinalQuestionItemMouseDown;
    qItem.OnDblClick := OnFinalQuestionItemDoubleClick;
    FLastClickedItemToEdit := qItem;
    qItem.Selected := True;
    aRemoveQuestions.Enabled := True;
    FFinalVisItems.Add(qItem);
  finally
    sbxFinalQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.bFinalQuestionsClick(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  LogEnter(Self, 'bFinalQuestionsClick');
  GoToFinalQuestions;
  LogExit(Self, 'bFinalQuestionsClick');
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

procedure TFrmMain.GoToFinalQuestions;
begin
  SetButtonPressed(bFinalQuestions);
  sbxFinalQuestions.BeginUpdate;
  try
    FFinalVisItems.ClearSelection;
    FLastClickedItemToEdit := nil;
    aRemoveQuestions.Enabled := FFinalVisItems.SelectedCount > 0;
  finally
    sbxFinalQuestions.EndUpdate;
  end;
  FChangingTab := True;
  try
    aGoToFinalQuestions.Execute;
  finally
    FChangingTab := False;
  end;

  DisableButton(bFinalQuestions);
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

procedure TFrmMain.GoToPersonalShortieQuestions;
begin

end;

procedure TFrmMain.bGoToHomeClick(Sender: TObject);
begin
  GoToHome;
end;

procedure TFrmMain.RefreshSelectedShortieQuestion;
begin
  sbxShortieQuestions.BeginUpdate;
  try
    for var item in FShortieVisItems do
      if item.OrgQuestion = FSelectedQuestion then
      begin
        item.RefreshData;
        item.Resize;
      end;
  finally
    sbxShortieQuestions.EndUpdate;
  end;
end;

procedure TFrmMain.RefreshSelectedFinalQuestion;
begin
  sbxFinalQuestions.BeginUpdate;
  try
    for var item in FFinalVisItems do
      if item.OrgQuestion = FSelectedQuestion then
      begin
        item.RefreshData;
        item.Resize;
      end;
  finally
    sbxFinalQuestions.EndUpdate;
  end;
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

procedure TFrmMain.bShortieQuestionsClick(Sender: TObject);
begin
  if FChangingTab then
    Exit;

  LogEnter(Self, 'bShortieQuestionsClick');
  GoToShortieQuestions;
  LogExit(Self, 'bShortieQuestionsClick');
end;

procedure TFrmMain.GoToSettings;
begin
  FChangingTab := True;
  try
    eSettingsFibbageXLPath.Text := TAppConfig.GetInstance.FibbageXLPath;
    eSettingsFibbageXLPP1Path.Text := TAppConfig.GetInstance.FibbageXLPartyPack1Path;
    eSettingsFibbage3PP4Path.Text := TAppConfig.GetInstance.Fibbage3PartyPack4Path;
    cbShowCategoryDuplicatedInfo.IsChecked := TAppConfig.GetInstance.ShowInfoAboutDuplicatedCategories;
    cbShowDialogAboutTooFewSuggestions.IsChecked := TAppConfig.GetInstance.ShowInfoAboutTooFewSuggestions;
    cbShowDialogAboutTooFewShortieQuestions.IsChecked := TAppConfig.GetInstance.ShowInfoAboutTooFewShortieQuestions;

    aGoToSettings.Execute;
  finally
    FChangingTab := False;
  end;
end;

procedure TFrmMain.GoToShortieQuestions;
begin
  SetButtonPressed(bShortieQuestions);
  sbxShortieQuestions.BeginUpdate;
  try
    FShortieVisItems.ClearSelection;
    FLastClickedItemToEdit := nil;
    aRemoveQuestions.Enabled := FShortieVisItems.SelectedCount > 0;
  finally
    sbxShortieQuestions.EndUpdate;
  end;
  FChangingTab := True;
  try
    aGoToShortieQuestions.Execute;
  finally
    FChangingTab := False;
  end;
  DisableButton(bShortieQuestions);
end;

procedure TFrmMain.GoToSpecialQuestions;
begin

end;

procedure TFrmMain.bSingleItemBumperAudioClick(Sender: TObject);
begin
  rDim.Visible := True;
  var form := TRecordForm.Create(Self);
  try
    form.EditBumperAudio(FSelectedQuestion);
  finally
    form.Free;
    rDim.Visible := False;
  end;
end;

procedure TFrmMain.bSingleItemCorrectAudioClick(Sender: TObject);
begin
  rDim.Visible := True;
  var form := TRecordForm.Create(Self);
  try
    form.EditAnswerAudio(FSelectedQuestion);
  finally
    form.Free;
    rDim.Visible := False;
  end;
end;

procedure TFrmMain.bSingleItemQuestionAudioClick(Sender: TObject);
begin
  rDim.Visible := True;
  var form := TRecordForm.Create(Self);
  try
    form.EditQuestionAudio(FSelectedQuestion);
  finally
    form.Free;
    rDim.Visible := False;
  end;
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

  PrepareMultiViewButtons(atHomeBeforeImport);

  FProjectVisItems := TProjectScrollItems.Create(sbxProjects);

  FShortieVisItems := TQuestionScrollItems.Create;
  FFinalVisItems := TQuestionScrollItems.Create;
  FSpecialVisItems := TQuestionScrollItems.Create;
  FPersonalShortieVisItems := TQuestionScrollItems.Create;

  sDarkMode.IsChecked := TAppConfig.GetInstance.DarkModeEnabled;

  tcEditTabs.ActiveTab := tiQuestionProjects;
  tcQuestions.ActiveTab := tiShortieQuestions;

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
  FShortieVisItems.Free;
  FFinalVisItems.Free;
  FProjectVisItems.Free;
  FSpecialVisItems.Free;
  FPersonalShortieVisItems.Free;
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
    if tcQuestions.ActiveTab = tiShortieQuestions then
      FShortieVisItems.SelectAll
    else if tcQuestions.ActiveTab = tiFinalQuestions then
      FFinalVisItems.SelectAll
    else if tcQuestions.ActiveTab = tiSpecialQuestions then
      FSpecialVisItems.SelectAll
    else if tcQuestions.ActiveTab = tiPersonalShortieQuestions then
      FPersonalShortieVisItems.SelectAll
    else
      Assert(False);
  end;

  if Key = vkDown then
  begin
    if tcQuestions.ActiveTab = tiShortieQuestions then
    begin
      if FShortieVisItems.Selected = nil then
        Exit;

      if FShortieVisItems.Selected = FShortieVisItems[FShortieVisItems.Count - 1] then
        sbxShortieQuestions.ViewportPosition := TPointF.Zero
      else
        sbxShortieQuestions.ScrollBy(0, -FShortieVisItems.Selected.Height);
      FShortieVisItems.SelectNext;
      FLastClickedItemToEdit := FShortieVisItems.Selected;
    end
    else if tcQuestions.ActiveTab = tiFinalQuestions then
    begin
      if FFinalVisItems.Selected = nil then
        Exit;

      if FFinalVisItems.Selected = FFinalVisItems[FFinalVisItems.Count - 1] then
        sbxShortieQuestions.ViewportPosition := TPointF.Zero
      else
        sbxShortieQuestions.ScrollBy(0, -FFinalVisItems.Selected.Height);
      FFinalVisItems.SelectNext;
      FLastClickedItemToEdit := FFinalVisItems.Selected;
    end
    else if tcQuestions.ActiveTab = tiSpecialQuestions then
    begin
      if FSpecialVisItems.Selected = nil then
        Exit;

      if FSpecialVisItems.Selected = FSpecialVisItems.Last then
        sbxSpecialQuestions.ViewportPosition := TPointF.Zero
      else
        sbxSpecialQuestions.ScrollBy(0, -FSpecialVisItems.Selected.Height);
      FSpecialVisItems.SelectNext;
      FLastClickedItemToEdit := FSpecialVisItems.Selected;
    end
    else if tcQuestions.ActiveTab = tiPersonalShortieQuestions then
    begin
      if FPersonalShortieVisItems.Selected = nil then
        Exit;

      if FPersonalShortieVisItems.Selected = FFinalVisItems.Last then
        sbxPersonalShortieQuestions.ViewportPosition := TPointF.Zero
      else
        sbxPersonalShortieQuestions.ScrollBy(0, -FPersonalShortieVisItems.Selected.Height);
      FPersonalShortieVisItems.SelectNext;
      FLastClickedItemToEdit := FPersonalShortieVisItems.Selected;
    end
    else
      Assert(False);
  end
  else if Key = vkUp then
  begin
    if tcQuestions.ActiveTab = tiShortieQuestions then
    begin
      if FShortieVisItems.Selected = nil then
        Exit;

      if FShortieVisItems.Selected = FShortieVisItems[0] then
        sbxShortieQuestions.ViewportPosition := TPointF.Create(0, MaxInt)
      else
        sbxShortieQuestions.ScrollBy(0, FShortieVisItems.Selected.Height);
      FShortieVisItems.SelectPrev;
      FLastClickedItemToEdit := FShortieVisItems.Selected;
    end
    else if tcQuestions.ActiveTab = tiFinalQuestions then
    begin
      if FFinalVisItems.Selected = nil then
        Exit;

      if FFinalVisItems.Selected = FFinalVisItems[0] then
        sbxFinalQuestions.ViewportPosition := TPointF.Create(0, MaxInt)
      else
        sbxFinalQuestions.ScrollBy(0, FFinalVisItems.Selected.Height);
      FFinalVisItems.SelectPrev;
      FLastClickedItemToEdit := FFinalVisItems.Selected;
    end
    else if tcQuestions.ActiveTab = tiSpecialQuestions then
    begin
      if FSpecialVisItems.Selected = nil then
        Exit;

      if FSpecialVisItems.Selected = FSpecialVisItems.First then
        sbxSpecialQuestions.ViewportPosition := TPointF.Create(0, MaxInt)
      else
        sbxSpecialQuestions.ScrollBy(0, FSpecialVisItems.Selected.Height);
      FSpecialVisItems.SelectPrev;
      FLastClickedItemToEdit := FSpecialVisItems.Selected;
    end
    else if tcQuestions.ActiveTab = tiPersonalShortieQuestions then
    begin
      if FPersonalShortieVisItems.Selected = nil then
        Exit;

      if FPersonalShortieVisItems.Selected = FPersonalShortieVisItems.First then
        sbxPersonalShortieQuestions.ViewportPosition := TPointF.Create(0, MaxInt)
      else
        sbxPersonalShortieQuestions.ScrollBy(0, FPersonalShortieVisItems.Selected.Height);
      FPersonalShortieVisItems.SelectPrev;
      FLastClickedItemToEdit := FPersonalShortieVisItems.Selected;
    end
    else
      Assert(False);
  end
  else if Key = vkRight then
    if ((tcQuestions.ActiveTab = tiShortieQuestions) and (FShortieVisItems.SelectedCount = 1)) or
       ((tcQuestions.ActiveTab = tiFinalQuestions) and (FFinalVisItems.SelectedCount = 1)) or
       ((tcQuestions.ActiveTab = tiSpecialQuestions) and (FSpecialVisItems.SelectedCount = 1)) or
       ((tcQuestions.ActiveTab = tiPersonalShortieQuestions) and (FPersonalShortieVisItems.SelectedCount = 1)) then
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
  mSingleItemQuestion.Text := FSelectedQuestion.GetQuestion;
  mSingleItemAnswer.Text := FSelectedQuestion.GetAnswer;
  mSingleItemAlternateSpelling.Text :=  FSelectedQuestion.GetAlternateSpelling.Replace(',', ', ');
  mSingleItemSuggestions.Text := FSelectedQuestion.GetSuggestions.Replace(',', ', ');
  eSingleItemId.Text := FSelectedCategory.GetId.ToString;
  eSingleItemCategory.Text := FSelectedCategory.GetCategory;
  sFamilyFriendly.IsChecked := FSelectedCategory.GetIsFamilyFriendly;

  FChangingTab := True;
  try
    aGoToQuestionDetails.Execute;
  finally
    FChangingTab := False;
  end;
  PrepareMultiViewButtons(atSingleQuestion);

  eSingleItemCategory.SetFocus;
end;

procedure TFrmMain.InitializeLastQuestionProjects;
begin
  var items := FLastQuestionProjects.GetAll;
  sbxProjects.BeginUpdate;
  try
    ClearPreviousProjects;
    for var item in items do
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
    items.Free;
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

procedure TFrmMain.lFamilyFriendlyClick(Sender: TObject);
begin
  sFamilyFriendly.IsChecked := not sFamilyFriendly.IsChecked;
end;

procedure TFrmMain.SetButtonPressed(AButton: TButton);
begin
  for var item in [bShortieQuestions, bFinalQuestions, bSpecialQuestions, bPersonalShortieQuestions] do
    item.IsPressed := item = AButton;
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

constructor TQuestionScrollItem.CreateItem(AOwner: TComponent; AQuestion: IQuestion);
begin
  inherited Create(AOwner);

  StyleLookup := 'rScrollItemStyle';
  HitTest := True;

  FOrgQuestion := AQuestion;
  FOrgCategory := AQuestion.GetCategoryObj;

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
  FDetails.Text := Format('Id: %d, Category: %s', [FOrgCategory.GetId, FOrgCategory.GetCategory]);
  FQuestion.Text := FOrgQuestion.GetQuestion;
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

procedure TQuestionScrollItems.SelectQuestionWithId(AId: Integer);
begin
  for var question in Self do
    if question.OrgQuestion.GetId = AId then
    begin
      ClearSelection;
      question.SetSelected(True);
      Break;
    end;
end;

{ TProjectScrollItem }

constructor TProjectScrollItem.CreateItem(AOwner: TComponent; AConfiguration: IContentConfiguration);
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
  FName.Text := FOrgConfiguration.GetName;
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
