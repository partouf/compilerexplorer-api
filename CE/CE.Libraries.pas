unit CE.Libraries;

interface

uses
  CE.Interfaces, CE.RESTBase, System.SysUtils, CE.Types, System.JSON;

type
  TCELibrariesFromRest = class(TCERestBase, ICELibraries)
  protected
    function GetLibrariesFromJson(const LibrariesArr: TJSONArray): TCELibraries;
  public
    procedure GetLibraries(const LanguageId: string; const Callback: TProc<TCELibraries>);
  end;

implementation

{ TCELibrariesFromRest }

procedure TCELibrariesFromRest.GetLibraries(const LanguageId: string; const Callback: TProc<TCELibraries>);
begin
  FRestRequest.Resource := 'api/libraries/' + LanguageId;

  FRestRequest.ExecuteAsync(
    procedure
    var
      Libraries: TCELibraries;
    begin
      Libraries := GetLibrariesFromJson(FRestResponse.JSONValue as TJSONArray);

      Callback(Libraries);
    end,
    False,
    True,
    procedure(Error: TObject)
    begin
      ReportError(Error);
    end
  );
end;

function TCELibrariesFromRest.GetLibrariesFromJson(const LibrariesArr: TJSONArray): TCELibraries;
var
  LibVal: TJSONValue;
  LibObj: TJSONObject;
  Lib: TCELibrary;
  VersionsArr: TJSONArray;
  VersionVal: TJSONValue;
  VersionObj: TJSONObject;
  DescVal: TJSONValue;
  LibVersion: TCELibraryVersion;
  PathsArr: TJSONArray;
  Path: TJSONValue;
  UrlVal: TJSONValue;
  LibUrl: string;
begin
  Result := TCELibraries.Create;

  if not Assigned(LibrariesArr) then
    Exit;

  for LibVal in LibrariesArr do
  begin
    LibObj := LibVal as TJSONObject;

    UrlVal := LibObj.GetValue('url');
    if Assigned(UrlVal) then
      LibUrl := UrlVal.Value
    else
      LibUrl := '';

    Lib := TCELibrary.Create(
      LibObj.GetValue('id').Value,
      LibObj.GetValue('name').Value,
      LibUrl);

    DescVal := LibObj.GetValue('description');
    if Assigned(DescVal) then
      Lib.Description := DescVal.Value;

    VersionsArr := LibObj.GetValue('versions') as TJSONArray;
    for VersionVal in VersionsArr do
    begin
      VersionObj := VersionVal as TJSONObject;

      LibVersion := TCELibraryVersion.Create(
          Lib,
          VersionObj.GetValue('version').Value);

      PathsArr := VersionObj.GetValue('path') as TJSONArray;
      for Path in PathsArr do
      begin
        LibVersion.Paths.Add(Path.Value);
      end;

      Lib.Versions.Add(LibVersion);
    end;

    Result.Add(Lib);
  end;
end;

end.
