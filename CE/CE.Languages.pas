unit CE.Languages;

interface

uses
  System.Generics.Defaults,
  CE.Interfaces,
  CE.RESTBase,
  CE.Types,
  System.SysUtils,
  System.JSON;

type
  TCELanguagesFromRest = class(TCERESTBase, ICELanguages)
  protected
    FCompareDelegate: IComparer<TCELanguage>;

    procedure ClearErrors;
    function GetLanguagesFromJson(const JSON: TJsonArray): TCELanguages;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetLanguages(const Callback: TProc<TCELanguages>);
  end;

implementation

uses
  System.Generics.Collections,
  Underscore.Delphi.Springless;

{ TCELanguages }

constructor TCELanguagesFromRest.Create;
begin
  inherited Create;

  FCompareDelegate := TDelegatedComparer<TCELanguage>.Create(
    function(const A, B: TCELanguage): Integer
    begin
      Result := CompareStr(A.LanguageName, B.LanguageName);
    end);

  FRestRequest.Resource := 'api/languages';
end;

destructor TCELanguagesFromRest.Destroy;
begin
  inherited;
end;

procedure TCELanguagesFromRest.ClearErrors;
begin
  FHasErrors := False;
end;

procedure TCELanguagesFromRest.GetLanguages(const Callback: TProc<TCELanguages>);
begin
  ClearErrors;

  FRestRequest.ExecuteAsync(
    procedure
    var
      Languages: TCELanguages;
    begin
      Languages := GetLanguagesFromJson(FRestResponse.JSONValue as TJsonArray);
      FHasReceivedData := True;

      Callback(Languages);
    end, False, True,
    procedure(Error: TObject)
    begin
      ReportError(Error);
    end);
end;

function TCELanguagesFromRest.GetLanguagesFromJson(const JSON: TJsonArray)
  : TCELanguages;
var
  LangObject: TJSONObject;
  DefCompiler: TJSONValue;
  DefCompilerStr: string;
  MappedList: TList<TCELanguage>;
  Lang: TJSONValue;
begin
  MappedList := TList<TCELanguage>.Create;
  for Lang in JSON do
  begin
    LangObject := (Lang as TJSONObject);

    DefCompiler := LangObject.GetValue('defaultCompiler');
    if Assigned(DefCompiler) then
      DefCompilerStr := DefCompiler.Value
    else
      DefCompilerStr := '';

    MappedList.Add(TCELanguage.Create(LangObject.GetValue('id').Value,
      LangObject.GetValue('name').Value, LangObject.GetValue('example').Value,
      DefCompilerStr));
  end;

  try
    Result := TCELanguages.Create;
    Result.AddRange(MappedList.ToArray);
    Result.Sort(FCompareDelegate);
  finally
    MappedList.Free;
  end;
end;

end.
