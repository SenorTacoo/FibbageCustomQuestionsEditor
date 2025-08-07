unit uFibbageContentFactory;

interface

uses
  uInterfaces,
  uContentConfiguration,
  uFibbageContent;

type
  TFibbageContentFactory = class
  public
    class function Generate(AContentConfig: TContentConfiguration): TFibbageContent;
  end;

implementation

{ TFibbageContentFactory }

class function TFibbageContentFactory.Generate(
  AContentConfig: TContentConfiguration): TFibbageContent;
begin
  case AContentConfig.GetGameType of
  FibbageXL: Result := TFibbageXLContent.Create(AContentConfig);
    // TODO
  end;
end;

end.
