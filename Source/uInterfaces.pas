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

  TGameType = (FibbageXL, FibbageXLPartyPack1, Fibbage2PartyPack2, Fibbage3PartyPack4, Fibbage4PartyPack9);
  TGameTypeHelper = record helper for TGameType
    function ToString: string;
    function ToUserString: string;
  end;

  TOnContentInitialized = procedure of object;
  TOnContentError = procedure(const AMsg: string) of object;

  EActivateError = class(Exception);

  function UnicodeEscape(const S: UnicodeString): string;

implementation

{ TGameTypeHelper }

function TGameTypeHelper.ToString: string;
begin
  Result := TRttiEnumerationType.GetName(Self);
end;

function UnicodeEscape(const S: UnicodeString): string;
var
  i: Integer;
  Ch: Char;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    Ch := S[i];
    if Ord(Ch) <= $7F then
      Result := Result + Ch
    else
      Result := Result + Format('\u%.4x', [Ord(Ch)]);
  end;
end;

function TGameTypeHelper.ToUserString: string;
begin
  case Self of
    FibbageXL: Result := 'FibbageXL';
    FibbageXLPartyPack1: Result := 'FibbageXL from The Jackbox Party Pack';
    Fibbage3PartyPack4: Result := 'Fibbage3 from The Jackbox Party Pack 4';
    Fibbage4PartyPack9: Result := 'Fibbage4 from The Jackbox Party Pack 9';
    Fibbage2PartyPack2: Result := 'Fibbage2 from The Jackbox Party Pack 2';
  end;
end;

end.
