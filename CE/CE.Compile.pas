unit CE.Compile;

interface

uses
  CE.RESTBase,
  CE.Interfaces,
  CE.Types,
  System.JSON,
  System.SysUtils, System.Generics.Collections;

type
  TCECompileViaREST = class(TCERESTBase, ICECompile)
  private
    procedure PopulateOutput(const Destination: TList<TCEErrorLine>; const Source: TJSONArray);
    procedure PopulateAssembly(const AssemblyDestination: TList<TCEAssemblyLine>; const AssemblySource: TJSONArray);
    function RemoveLineColoring(const Text: string): string;
  protected
    function CreateJSONCompileRequest(const Code: string; const Arguments: string): TJSONObject;
    function GetCompileResultFromJson(const JSON: TJSONObject): TCECompileResult;
  public
    procedure Compile(const LanguageId, CompilerId, Code: string; const Arguments: string; const Callback: TProc<TCECompileResult>);
  end;

implementation

uses
  REST.Types, System.StrUtils;

{ TCECompileViaREST }

procedure TCECompileViaREST.Compile(const LanguageId, CompilerId, Code, Arguments: string; const Callback: TProc<TCECompileResult>);
begin
  FRestRequest.Resource := 'api/compiler/' + CompilerId + '/compile';
  FRestRequest.Method := TRESTRequestMethod.rmPOST;
  FRestRequest.Body.ClearBody;

  FRestRequest.Body.Add(CreateJSONCompileRequest(Code, Arguments));

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

procedure TCECompileViaREST.PopulateOutput(const Destination: TList<TCEErrorLine>; const Source: TJSONArray);
var
  LineJson: TJSONObject;
  LineIdx: Integer;
  ErrorLine: TCEErrorLine;
begin
  for LineIdx := 0 to Source.Count - 1 do
  begin
    LineJson := Source.Items[LineIdx] as TJSONObject;

    ErrorLine := TCEErrorLine.Create(RemoveLineColoring(LineJson.GetValue('text').Value));
    Destination.Add(ErrorLine);
  end;
end;

procedure TCECompileViaREST.PopulateAssembly(const AssemblyDestination: TList<TCEAssemblyLine>; const AssemblySource: TJSONArray);
var
  LineJson: TJSONObject;
  LineIdx: Integer;
  AsmLine: TCEAssemblyLine;
begin
  for LineIdx := 0 to AssemblySource.Count - 1 do
  begin
    LineJson := AssemblySource.Items[LineIdx] as TJSONObject;

    AsmLine := TCEAssemblyLine.Create(LineJson.GetValue('text').Value);

    AssemblyDestination.Add(AsmLine);
  end;
end;

function TCECompileViaREST.RemoveLineColoring(const Text: string): string;
begin
  Result := Text;
  Result := ReplaceStr(Result, #$1b'[0m', '');
  Result := ReplaceStr(Result, #$1b'[1m', '');
  Result := ReplaceStr(Result, #$1b'[0;1;32m', '');
  Result := ReplaceStr(Result, #$1b'[0;1;35m', '');
end;

function TCECompileViaREST.GetCompileResultFromJson(const JSON: TJSONObject): TCECompileResult;
begin
  Result := TCECompileResult.Create(Json.GetValue('code').Value = '0');

  PopulateOutput(Result.CompilerOutput, Json.GetValue('stdout') as TJSONArray);
  PopulateOutput(Result.CompilerOutput, Json.GetValue('stderr') as TJSONArray);

  PopulateAssembly(Result.Assembly, Json.GetValue('asm') as TJSONArray);
end;

end.
