unit uFibbage4Skeleton;

interface

uses
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  System.JSON.Builders,
  uFibbageJSONWriter;

type
  TFibbage4Skeleton = class
  private
    FSavePath: string;

    procedure DoSaveSubDir;
    procedure DoSaveJet;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Save(const APath: string);
  end;

implementation

{ TFibbage4Skeleton }

constructor TFibbage4Skeleton.Create;
begin
  inherited Create;
end;

destructor TFibbage4Skeleton.Destroy;
begin
  inherited;
end;

procedure TFibbage4Skeleton.DoSaveJet;
begin
  var dstPath := TPath.Combine(FSavePath, 'skeleton.jet');
  var fs := TFileStream.Create(dstPath, fmCreate);
  var sw := TStreamWriter.Create(fs, TEncoding.UTF8);
  var builder := TFibbageJSONBuilder.Create;
  try
    sw.OwnStream;

    builder
      .BeginObject
      .BeginArray('content')
        .BeginObject
          .Add('countrySpecific', false)
          .Add('id', '92208')
          .Add('isValid', '')
          .Add('numCopies', 29)
          .AddNull('priorGamesPlayed')
          .BeginArray('skeleton')
            .BeginObject
              .Add('type', 'RANDOM')
            .EndObject
            .BeginObject
              .Add('type', 'RANDOM')
            .EndObject
            .BeginObject
              .Add('type', 'RANDOM')
            .EndObject
            .BeginObject
              .Add('type', 'RANDOM')
            .EndObject
            .BeginObject
              .Add('type', 'RANDOM')
            .EndObject
            .BeginObject
              .Add('type', 'FINAL')
            .EndObject
          .EndArray
          .Add('title', 'GENERIC 1 (MOVIE A)')
          .Add('x', false)
        .EndObject
      .EndArray
    .EndObject;

    sw.Write(builder.Build);

  finally
    builder.Free;
    sw.Free;
  end;
end;

procedure TFibbage4Skeleton.DoSaveSubDir;
begin
  var dstPath := TPath.Combine(FSavePath, 'skeleton', '92208');
  ForceDirectories(dstPath);
  dstPath := TPath.Combine(dstPath, 'data.jet');
  var fs := TFileStream.Create(dstPath, fmCreate);
  var sw := TStreamWriter.Create(fs, TEncoding.UTF8);
  var builder := TFibbageJSONBuilder.Create;
  try
    sw.OwnStream;

    builder
      .BeginObject
        .BeginArray('fields')
          .BeginObject
            .Add('t', 'B')
            .Add('v', false)
            .Add('n', 'HasIntro')
          .EndObject
          .BeginObject
            .Add('t', 'B')
            .Add('v', false)
            .Add('n', 'HasOutro')
          .EndObject
          .BeginObject
            .Add('t', 'A')
            .Add('v', 'intro')
            .Add('n', 'Intro')
          .EndObject
          .BeginObject
            .Add('t', 'A')
            .Add('v', 'outro')
            .Add('n', 'Outro')
          .EndObject
        .EndArray
      .EndObject;

    sw.Write(builder.Build);

  finally
    builder.Free;
    sw.Free;
  end;
end;

procedure TFibbage4Skeleton.Save(const APath: string);
begin
  FSavePath := APath;
  DoSaveSubDir;
  DoSaveJet;
end;

end.
