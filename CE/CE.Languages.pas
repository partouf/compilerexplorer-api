unit CE.Languages;

interface

uses
  CE.Interfaces,
  CE.RESTBase,
  CE.Types,
  System.SysUtils,
  System.JSON;

type
  TCELanguagesFromRest = class(TCERESTBase, ICELanguages)
  protected
    function GetLanguagesFromJson(const Json: TJsonArray): TCELanguages;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetLanguages(const Callback: TProc<TCELanguages>);
  end;

implementation

uses
  System.Generics.Collections, System.Generics.Defaults;

{ TCELanguages }

constructor TCELanguagesFromRest.Create;
begin
  inherited Create;

  FRestRequest.Resource := 'api/languages';
end;

destructor TCELanguagesFromRest.Destroy;
begin
  inherited;
end;

procedure TCELanguagesFromRest.GetLanguages(const Callback: TProc<TCELanguages>);
begin
  FRestRequest.ExecuteAsync(
    procedure
    var
      Languages: TCELanguages;
    begin
      Languages := GetLanguagesFromJson(FRestResponse.JSONValue as TJSONArray);
      FHasReceivedData := True;

      Callback(Languages);
    end,
    False,
    True,
    procedure(Error: TObject)
    begin
      FHasErrors := True;
    end
  );
end;

function TCELanguagesFromRest.GetLanguagesFromJson(const Json: TJsonArray): TCELanguages;
var
  Lang: TJsonValue;
  LangObject: TJSONObject;
begin
  Result := TCELanguages.Create;

  for Lang in Json do
  begin
    LangObject := (Lang as TJsonObject);

    Result.Add(
      TCELanguage.Create(
        LangObject.GetValue('id').Value,
        LangObject.GetValue('name').Value,
        LangObject.GetValue('example').Value
      )
    );
  end;

  Result.Sort(
    TDelegatedComparer<TCELanguage>.Create(
      function(const A, B: TCELanguage): Integer
      begin
        Result := CompareStr(A.LanguageName, B.LanguageName);
      end));
end;

end.
