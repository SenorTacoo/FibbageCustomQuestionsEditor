unit uFibbageContentFactory;

interface

uses
  uInterfaces,
  uContentConfiguration,
  uFibbageContent,
  uFibbage3Content,
  uFibbageXLContent,
  uFibbage2Content,
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
    Fibbage3PartyPack4: Result := TFibbage3Content.Create(AContentConfig);
    Fibbage2PartyPack2: Result := TFibbage2Content.Create(AContentConfig);
  end;
end;

end.
