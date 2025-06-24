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
    class function IsValid(const APath: string): Boolean;
    class function IsPartyPack1(const APath: string): Boolean;
  end;


implementation

{ TContentPathChecker }

class function TContentPathChecker.IsPartyPack1(const APath: string): Boolean;
begin
  Result := DirectoryExists(IncludeTrailingPathDelimiter(APath) +
    IncludeTrailingPathDelimiter('questions'));
end;

class function TContentPathChecker.IsValid(const APath: string): Boolean;
begin
  Result := False;
  if not DirectoryExists(APath) then
    Exit;

  if IsPartyPack1(APath) then
    Exit(True);

  if not DirectoryExists(IncludeTrailingPathDelimiter(APath) +
    IncludeTrailingPathDelimiter('fibbageshortie')) then
    Exit;

  if not DirectoryExists(IncludeTrailingPathDelimiter(APath) +
    IncludeTrailingPathDelimiter('finalfibbage')) then
    Exit;

  Result := True;
end;

end.
