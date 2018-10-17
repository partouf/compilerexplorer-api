unit CE.Libraries;

interface

uses
  CE.Interfaces, CE.RESTBase, System.SysUtils, CE.Types, System.JSON;

type
  TCELibrariesFromRest = class(TCERestBase, ICELibraries)
  protected
    function GetLibrariesFromJson(const LibrariesArr: TJSONArray): TCELibraries;
  public
    constructor Create;

    procedure GetLibraries(const LanguageId: string; const Callback: TProc<TCELibraries>);
  end;

implementation

{ TCELibrariesFromRest }

constructor TCELibrariesFromRest.Create;
begin
  inherited Create;
end;

procedure TCELibrariesFromRest.GetLibraries(const LanguageId: string; const Callback: TProc<TCELibraries>);
begin
  FRestRequest.Resource := '/api/libraries/' + LanguageId;

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
      FHasErrors := True;
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
begin
  Result := TCELibraries.Create;

  for LibVal in LibrariesArr do
  begin
    LibObj := LibVal as TJSONObject;

    Lib := TCELibrary.Create(
      LibObj.GetValue('id').Value,
      LibObj.GetValue('name').Value,
      LibObj.GetValue('url').Value);

    DescVal := LibObj.GetValue('description');
    if Assigned(DescVal) then
      Lib.Description := DescVal.Value;

    VersionsArr := LibObj.GetValue('versions') as TJSONArray;
    for VersionVal in VersionsArr do
    begin
      VersionObj := VersionVal as TJSONObject;

      Lib.Versions.Add(
        TCELibraryVersion.Create(
          Lib,
          VersionObj.GetValue('version').Value,
          VersionObj.GetValue('path').Value
        )
      );
    end;

    Result.Add(Lib);
  end;
end;

end.
