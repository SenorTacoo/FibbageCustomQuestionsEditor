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

end.
