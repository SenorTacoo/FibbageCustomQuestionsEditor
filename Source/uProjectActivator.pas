unit uProjectActivator;

interface

uses
  uPathChecker,
  uFibbageContent,
  uContentConfiguration,
  uFibbageContentFactory,
  uInterfaces;

type
  TProjectActivator = class
  public
    class procedure Activate(AConfig: TContentConfiguration; const APath: string);
  end;

implementation

{ TProjectActivator }

class procedure TProjectActivator.Activate(AConfig: TContentConfiguration;
  const APath: string);
begin
  var content := TFibbageContentFactory.Generate(AConfig);
  try
    content.Initialize;
    content.Activate(APath);
  finally
    content.Free;
  end;
end;

end.
