unit CE.Compilers;

interface

uses
  CE.Interfaces,
  CE.RESTBase,
  CE.Types,
  System.JSON,
  System.SysUtils;

type
  TCECompilersFromRest = class(TCERESTBase, ICECompilers)
  protected
    function GetCompilersFromJson(const Json: TJsonArray): TCECompilers;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetCompilers(const LanguageId: string; const Callback: TProc<TCECompilers>);
  end;

implementation

uses
  System.Generics.Collections;

{ TCECompilers }

constructor TCECompilersFromRest.Create;
begin
  inherited Create;
end;

destructor TCECompilersFromRest.Destroy;
begin
  inherited;
end;

procedure TCECompilersFromRest.GetCompilers(const LanguageId: string; const Callback: TProc<TCECompilers>);
begin
  FRestRequest.Resource := 'api/compilers/' + LanguageId;

  FRestRequest.ExecuteAsync(
    procedure
    var
      Compilers: TCECompilers;
    begin
      Compilers := GetCompilersFromJson(FRestResponse.JSONValue as TJSONArray);

      Callback(Compilers);
    end,
    False,
    True,
    procedure(Error: TObject)
    begin
      ReportError(Error);
    end
  );
end;

function TCECompilersFromRest.GetCompilersFromJson(const Json: TJsonArray): TCECompilers;
var
  Compiler: TJsonValue;
  CompilerObject: TJSONObject;
begin
  Result := TCECompilers.Create;

  for Compiler in Json do
  begin
    CompilerObject := (Compiler as TJsonObject);

    Result.Add(
      TCECompiler.Create(
        CompilerObject.GetValue('id').Value,
        CompilerObject.GetValue('name').Value
      )
    );
  end;

  FHasReceivedData := True;
end;

end.
