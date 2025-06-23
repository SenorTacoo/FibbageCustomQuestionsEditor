unit uProjectActivator;

interface

uses
  uFibbageContent,
  uCategoriesLoader,
  uQuestionsLoader,
  uInterfaces;

type
  TProjectActivator = class(TInterfacedObject, IProjectActivator)
  private
    FTempContent: IFibbageContent;
  public
    procedure Activate(AConfig: IContentConfiguration; const APath: string);
  end;

implementation

{ TProjectActivator }

procedure TProjectActivator.Activate(AConfig: IContentConfiguration;
  const APath: string);
begin
  FTempContent := TFibbageContent.Create(TFibbageCategories.Create, TQuestionsLoader.Create);
  try
    FTempContent.Initialize(AConfig);
    FTempContent.Save(APath, [soDoNotSaveConfig]);
  finally
    FTempContent := nil;
  end;
end;

end.
