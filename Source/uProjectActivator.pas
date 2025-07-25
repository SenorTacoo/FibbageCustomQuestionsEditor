﻿unit uProjectActivator;

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
  var content := TFibbageContent.Create;
  try
    content.Initialize(AConfig);
    content.Save(APath, [soActivatingProject]);
  finally
    content.Free;
  end;
end;

end.
