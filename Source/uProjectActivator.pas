unit uProjectActivator;

interface

uses
  uPathChecker,
  uFibbageContent,
  uContentConfiguration,
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
  var content := TFibbageContent.Create;
  try
    content.Initialize(AConfig);
    content.Save(APath, [soActivatingProject]);
  finally
    content.Free;
  end;
end;

end.
