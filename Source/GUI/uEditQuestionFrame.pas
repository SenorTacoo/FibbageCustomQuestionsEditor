unit uEditQuestionFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  uQuestionsLoader, FMX.Layouts, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, uEditableStringItemFrame, uEditableU32ItemFrame,
  uEditableBoolItemFrame, uEditableLongStringItemFrame, uEditableAudioItemFrame,
  System.Math, FMX.Effects;

type
  TFrmEditQuestion = class(TFrame)
    sbxQuestionItems: TScrollBox;
    ToolBar3: TToolBar;
    pQuestionToolbar: TPanel;
    lNewQuestion: TLabel;
    GlowEffect5: TGlowEffect;
    bSaveQuestionChanges: TButton;
    bCancelQuestionChanges: TButton;
    procedure bCancelQuestionChangesClick(Sender: TObject);
    procedure bSaveQuestionChangesClick(Sender: TObject);
  private
    FOrgQuestion: TFibbageQuestion;
    FFields: TEditableFields;
    FOnSaveClick: TNotifyEvent;
    FOnCancelClick: TNotifyEvent;

    procedure DoAddStringField(AField: TEditableStringField);
    procedure DoAddLongStringField(AField: TEditableLongStringField);
    procedure DoAddU32Field(AField: TEditableU32Field);
    procedure DoAddBoolField(AField: TEditableBoolField);
    procedure DoAddAudioField(AField: TEditableAudioField);

    procedure ProcessFillScrollBox;
    procedure ClearScrollBox;
  public
    destructor Destroy; override;

    procedure NewQuestion(AQuestion: TFibbageQuestion);
    procedure EditQuestion(AQuestion: TFibbageQuestion);

    property OnCancelClick: TNotifyEvent read FOnCancelClick write FOnCancelClick;
    property OnSaveClick: TNotifyEvent read FOnSaveClick write FOnSaveClick;
  end;

implementation

{$R *.fmx}

{ TFrmEditQuestion }

procedure TFrmEditQuestion.bCancelQuestionChangesClick(Sender: TObject);
begin
  if Assigned(FOnCancelClick) then
    FOnCancelClick(Self);
  ClearScrollBox;
end;

procedure TFrmEditQuestion.bSaveQuestionChangesClick(Sender: TObject);
begin
  FOrgQuestion.SetEditableFields(FFields);
  if Assigned(FOnSaveClick) then
    FOnSaveClick(Self);
  ClearScrollBox;
end;

procedure TFrmEditQuestion.ClearScrollBox;
begin
  for var idx := sbxQuestionItems.Content.ChildrenCount - 1 downto 0 do
  begin
    var ctrl := sbxQuestionItems.Content.Children[idx];
    sbxQuestionItems.Content.RemoveObject(ctrl);
    ctrl.Free;
  //      FreeAndNil(sbxQuestionItems.Content.Children[idx]);
  //      sbxQuestionItems.Content.RemoveObject(idx);
  end;
end;

destructor TFrmEditQuestion.Destroy;
begin
  FFields.Free;
  inherited;
end;

procedure TFrmEditQuestion.DoAddAudioField(AField: TEditableAudioField);
begin
  var frame := TFrmEditableAudioItem.Create(Self, AField);
  frame.Name := Format('editField_%d', [sbxQuestionItems.Content.ChildrenCount]);
  frame.Align := TAlignLayout.Top;
  frame.Height := Max(Canvas.TextHeight('Yy'), 50);
  frame.Parent := sbxQuestionItems;
end;

procedure TFrmEditQuestion.DoAddBoolField(AField: TEditableBoolField);
begin
  var frame := TFrmEditableBoolItem.Create(Self, AField);
  frame.Name := Format('editField_%d', [sbxQuestionItems.Content.ChildrenCount]);
  frame.Align := TAlignLayout.Top;
  frame.Height := Max(Canvas.TextHeight('Yy'), 30);
  frame.Parent := sbxQuestionItems;
end;

procedure TFrmEditQuestion.DoAddLongStringField(
  AField: TEditableLongStringField);
begin
  var frame := TFrmEditableLongStringItem.Create(Self, AField);
  frame.Name := Format('editField_%d', [sbxQuestionItems.Content.ChildrenCount]);
  frame.Align := TAlignLayout.Top;
  frame.Height := Max(Canvas.TextHeight('Yy') * 3, 90);
  frame.Parent := sbxQuestionItems;
end;

procedure TFrmEditQuestion.DoAddStringField(AField: TEditableStringField);
begin
  var frame := TFrmEditableStringItem.Create(Self, AField);
  frame.Name := Format('editField_%d', [sbxQuestionItems.Content.ChildrenCount]);
  frame.Align := TAlignLayout.Top;
  frame.Height := Max(Canvas.TextHeight('Yy'), 30);
  frame.Parent := sbxQuestionItems;
end;

procedure TFrmEditQuestion.DoAddU32Field(AField: TEditableU32Field);
begin
  var frame := TFrmEditableU32Item.Create(Self, AField);
  frame.Name := Format('editField_%d', [sbxQuestionItems.Content.ChildrenCount]);
  frame.Align := TAlignLayout.Top;
  frame.Height := Max(Canvas.TextHeight('Yy'), 30);
  frame.Parent := sbxQuestionItems;
end;

procedure TFrmEditQuestion.EditQuestion(AQuestion: TFibbageQuestion);
begin
  lNewQuestion.Text := 'Edit question';
  FOrgQuestion := AQuestion;
  FreeAndNil(FFields);
  FFields := AQuestion.GetEditableFields;
  ProcessFillScrollBox;
end;

procedure TFrmEditQuestion.NewQuestion(AQuestion: TFibbageQuestion);
begin
  lNewQuestion.Text := 'New question';
  FOrgQuestion := AQuestion;
  FreeAndNil(FFields);
  FFields := AQuestion.GetEditableFields;
  ProcessFillScrollBox;
end;

procedure TFrmEditQuestion.ProcessFillScrollBox;
begin
  sbxQuestionItems.BeginUpdate;
  try
    for var field in FFields do
    begin
      if field is TEditableStringField then
        DoAddStringField(field as TEditableStringField)
      else if field is TEditableLongStringField then
        DoAddLongStringField(field as TEditableLongStringField)
      else if field is TEditableU32Field then
        DoAddU32Field(field as TEditableU32Field)
      else if field is TEditableBoolField then
        DoAddBoolField(field as TEditableBoolField)
      else if field is TEditableAudioField then
        DoAddAudioField(field as TEditableAudioField)
      else
        Assert(False, field.ClassName);
    end;
  finally
    sbxQuestionItems.EndUpdate;
  end;
end;

end.
