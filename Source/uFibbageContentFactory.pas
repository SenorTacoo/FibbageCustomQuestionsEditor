unit uFibbageContentFactory;

interface

uses
  uInterfaces,
  uContentConfiguration,
  uFibbageContent,
  uFibbageXLContent,
  uFibbageXLPartyPack1Content;

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
  Result := nil;
  case AContentConfig.GetGameType of
    FibbageXL: Result := TFibbageXLContent.Create(AContentConfig);
    FibbageXLPartyPack1: Result := TFibbageXLPartyPack1Content.Create(AContentConfig);
    // TODO
  end;
end;

end.
