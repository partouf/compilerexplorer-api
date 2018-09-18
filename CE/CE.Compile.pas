unit CE.Compile;

interface

uses
  CE.RESTBase,
  CE.Interfaces,
  CE.Types,
  System.JSON,
  System.SysUtils;

type
  TCECompileViaREST = class(TCERESTBase, ICECompile)
  protected
    function CreateJSONCompileRequest(const Code: string; const Arguments: string): TJSONObject;
    function GetCompileResultFromJson(const JSON: TJSONObject): TCECompileResult;
  public
    procedure Compile(const LanguageId, CompilerId, Code: string; const Callback: TProc<TCECompileResult>);
  end;

implementation

uses
  REST.Types;

{ TCECompileViaREST }

procedure TCECompileViaREST.Compile(const LanguageId, CompilerId, Code: string; const Callback: TProc<TCECompileResult>);
begin
  FRestRequest.Resource := 'api/compiler/' + CompilerId + '/compile';
  FRestRequest.Method := TRESTRequestMethod.rmPOST;
  FRestRequest.Body.ClearBody;

  FRestRequest.Body.Add(CreateJSONCompileRequest(Code, ''));

  FRestRequest.ExecuteAsync(
    procedure
    var
      CompileResult: TCECompileResult;
    begin
      CompileResult := GetCompileResultFromJson(FRestResponse.JSONValue as TJSONObject);
      FHasReceivedData := True;

      Callback(CompileResult);
    end,
    False,
    True,
    procedure(Error: TObject)
    begin
      FHasErrors := True;
    end
  );
end;

function TCECompileViaREST.CreateJSONCompileRequest(const Code, Arguments: string): TJSONObject;
var
  Options: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('source', Code);

  Options := TJSONObject.Create;
  Options.AddPair('userArguments', Arguments);

  Result.AddPair('options', Options);
end;

function TCECompileViaREST.GetCompileResultFromJson(const JSON: TJSONObject): TCECompileResult;
begin
  Result := TCECompileResult.Create(
    Json.GetValue('code').Value = '0',
    ''
  );
end;

end.
