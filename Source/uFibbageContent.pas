unit uFibbageContent;

interface

uses
  uContentConfiguration,
  uInterfaces;

type
  TFibbageContent = class
  public
    function Initialize(ACfg: TContentConfiguration): Boolean;
    procedure Save(const APath: string; ASaveOptions: TSaveOptions); overload;
    procedure Save; overload;
  end;

implementation

{ TFibbageContent }

function TFibbageContent.Initialize(ACfg: TContentConfiguration): Boolean;
begin
  Result := False;
end;

procedure TFibbageContent.Save(const APath: string; ASaveOptions: TSaveOptions);
begin

end;

procedure TFibbageContent.Save;
begin
//
end;

end.
