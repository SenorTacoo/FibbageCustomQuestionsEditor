unit uPathChecker;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  uInterfaces;

type
  TContentPathChecker = class
  public
    class function IsValid(const APath: string; AGameType: TGameType): Boolean;
  end;


implementation

{ TContentPathChecker }

class function TContentPathChecker.IsValid(const APath: string; AGameType: TGameType): Boolean;
begin
  Result := False;
  if not DirectoryExists(APath) then
    Exit;

  case AGameType of
    FibbageXL,
    Fibbage2PartyPack2:
      begin
        if not DirectoryExists(IncludeTrailingPathDelimiter(APath) +
          IncludeTrailingPathDelimiter('fibbageshortie')) then
          Exit;

        if not DirectoryExists(IncludeTrailingPathDelimiter(APath) +
          IncludeTrailingPathDelimiter('finalfibbage')) then
          Exit;
      end;
    FibbageXLPartyPack1:
      begin
        if not DirectoryExists(IncludeTrailingPathDelimiter(APath) +
          IncludeTrailingPathDelimiter('questions')) then
          Exit;
      end;
    Fibbage3PartyPack4:
      begin
        if not DirectoryExists(IncludeTrailingPathDelimiter(APath) +
          IncludeTrailingPathDelimiter('fibbageshortie')) then
          Exit;

        if not DirectoryExists(IncludeTrailingPathDelimiter(APath) +
          IncludeTrailingPathDelimiter('finalfibbage')) then
          Exit;

        if not DirectoryExists(IncludeTrailingPathDelimiter(APath) +
          IncludeTrailingPathDelimiter('fibbagespecial')) then
          Exit;
      end;
    Fibbage4PartyPack9:
    begin
      if DirectoryExists(TPath.Combine(APath, 'en')) then
        Exit(DirectoryExists(TPath.Combine(APath, 'en', 'fibbageblankie')));

      if DirectoryExists(TPath.Combine(APath, 'fibbageblankie')) then
        Exit(True);
    end
    else
    begin
      Assert(False);
      Exit;
    end;
  end;

  Result := True;
end;

end.
