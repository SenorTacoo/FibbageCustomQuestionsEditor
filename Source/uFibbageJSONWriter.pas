unit uFibbageJSONWriter;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON.Builders,
  System.JSON.Writers;

type
  TFibbageJSONBuilder = class
  private
    FStringWriter: TStringWriter;
    FJsonWriter: TJsonTextWriter;
    FObjectBuilder: TJsonObjectBuilder;
  public
    constructor Create;
    destructor Destroy; override;

    function BeginObject: TJSONCollectionBuilder.TPairs;

    function Build: string;
  end;

implementation

{ TFibbageJSONBuilder }

function TFibbageJSONBuilder.BeginObject: TJSONCollectionBuilder.TPairs;
begin
  Result := FObjectBuilder.BeginObject;
end;

function TFibbageJSONBuilder.Build: string;
begin
  Result := FStringWriter.ToString;
end;

constructor TFibbageJSONBuilder.Create;
begin
  inherited Create;
  FStringWriter := TStringWriter.Create;
  FJsonWriter := TJsonTextWriter.Create(FStringWriter);
  FObjectBuilder := TJsonObjectBuilder.Create(FJsonWriter);
end;

destructor TFibbageJSONBuilder.Destroy;
begin
  FObjectBuilder.Free;
  FJsonWriter.Free;
  FStringWriter.Free;
  inherited;
end;

end.
