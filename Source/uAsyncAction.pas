﻿unit uAsyncAction;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Threading;

type
  TOnActionStart = procedure of object;
  TOnActionEnd = procedure of object;
  TActionProc = procedure of object;

  TAsyncAction = class(TThread)
  private
    FOnActionStart: TOnActionStart;
    FOnActionEnd: TOnActionEnd;
    FActionProc: TActionProc;
    FThreadWorking: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOnActionStart: TOnActionStart; AOnActionEnd: TOnActionEnd; AActionProc: TActionProc);
    destructor Destroy; override;

  end;

implementation

{ TAsyncAction }

constructor TAsyncAction.Create(AOnActionStart: TOnActionStart;
  AOnActionEnd: TOnActionEnd; AActionProc: TActionProc);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FOnActionStart := AOnActionStart;
  FOnActionEnd := AOnActionEnd;
  FActionProc := AActionProc;
end;

destructor TAsyncAction.Destroy;
begin
  while FThreadWorking do
    Sleep(100);
  inherited;
end;

procedure TAsyncAction.Execute;
begin
  FThreadWorking := True;
  try
    if Assigned(FOnActionStart) then
      TThread.Synchronize(nil,
        procedure
        begin
          FOnActionStart;
        end);
    try
      if Assigned(FActionProc) then
        FActionProc;
    finally
      if Assigned(FOnActionEnd) then
        TThread.Synchronize(nil,
          procedure
          begin
            FOnActionEnd;
          end);
    end;
  finally
    FThreadWorking := False;
  end;
end;

end.
