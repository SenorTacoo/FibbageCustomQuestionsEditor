unit uProjectActivator;

interface

uses
  uFibbageContent,
  uCategoriesLoader,
  uPathChecker,
  uQuestionsLoader,
  uInterfaces;

type
  TProjectActivator = class
  public
    class procedure Activate(AConfig: IContentConfiguration; const APath: string);
  end;

implementation

{ TProjectActivator }

class procedure TProjectActivator.Activate(AConfig: IContentConfiguration;
  const APath: string);
begin
  // TODO XL 3 ???
  var content := TFibbageContent.Create;
  try
    content.Initialize(AConfig);

    content.Save(APath, [soDoNotSaveConfig]);
  finally
    content.Free;
  end;
end;

end.
