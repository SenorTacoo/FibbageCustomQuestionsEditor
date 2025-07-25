unit uInterfaces;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.Generics.Collections;

type
  TSaveOption = (soActivatingProject);
  TSaveOptions = set of TSaveOption;

  TQuestionType = (qtShortie, qtFinal, qtSpecial, qtPersonalShortie, qtUnknown);

  TGameType = (FibbageXL, FibbageXLPartyPack1, Fibbage3PartyPack4, Fibbage4PartyPack9);
  TGameTypeHelper = record helper for TGameType
    function ToString: string;
  end;

  TOnContentInitialized = procedure of object;
  TOnContentError = procedure(const AMsg: string) of object;

  EActivateError = class(Exception);

implementation

{ TGameTypeHelper }

function TGameTypeHelper.ToString: string;
begin
  Result := TRttiEnumerationType.GetName(Self);
end;

end.
