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
    function CreateJSONCompileRequest(const Code, Arguments: string; const SelectedLibraries: TList<TCELibraryVersion>): TJSONObject;
    function GetCompileResultFromJson(const JSON: TJSONObject): TCECompileResult;
  public
    procedure Compile(const LanguageId, CompilerId, Code: string; const Arguments: string; const SelectedLibraries: TList<TCELibraryVersion>; const Callback: TProc<TCECompileResult>);
  end;

implementation

uses
  REST.Types, System.StrUtils, System.Classes;

{ TCECompileViaREST }

procedure TCECompileViaREST.Compile(const LanguageId, CompilerId, Code, Arguments: string; const SelectedLibraries: TList<TCELibraryVersion>; const Callback: TProc<TCECompileResult>);
var
  JSONObj: TJSONObject;
begin
  FRestRequest.Resource := 'api/compiler/' + CompilerId + '/compile';
  FRestRequest.Method := TRESTRequestMethod.rmPOST;
  FRestRequest.Body.ClearBody;

  JSONObj := CreateJSONCompileRequest(Code, Arguments, SelectedLibraries);
  FRestRequest.Body.Add(JSONObj);

  FRestRequest.ExecuteAsync(
    procedure
    var
      CompileResult: TCECompileResult;
    begin
      JSONObj.Free;
      CompileResult := GetCompileResultFromJson(FRestResponse.JSONValue as TJSONObject);
      FHasReceivedData := True;

      Callback(CompileResult);
    end,
    False,
    True,
    procedure(Error: TObject)
    begin
      JSONObj.Free;
      ReportError(Error);
    end
  );
end;

function TCECompileViaREST.CreateJSONCompileRequest(const Code, Arguments: string; const SelectedLibraries: TList<TCELibraryVersion>): TJSONObject;
var
  Options: TJSONObject;
  Lib: TCELibraryVersion;
  Path: string;
  Libraries: TJSONArray;
  LibObj: TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.AddPair('source', Code);

  Options := TJSONObject.Create;

  Libraries := TJSONArray.Create;
  for Lib in SelectedLibraries do
  begin
    LibObj := TJSONObject.Create;
    LibObj.AddPair('id', Lib.Lib.Id);
    LibObj.AddPair('version', Lib.Version);

    Libraries.Add(LibObj);
  end;

  Options.AddPair('userArguments', Arguments);
  Options.AddPair('libraries', Libraries);

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
  Result := ReplaceStr(Result, #$1b'[01m', '');
  Result := ReplaceStr(Result, #$1b'[m', '');
  Result := ReplaceStr(Result, #$1b'[1m', '');
  Result := ReplaceStr(Result, #$1b'[0;1;30m', '');
  Result := ReplaceStr(Result, #$1b'[0;1;31m', '');
  Result := ReplaceStr(Result, #$1b'[0;1;32m', '');
  Result := ReplaceStr(Result, #$1b'[0;1;35m', '');
  Result := ReplaceStr(Result, #$1b'[01;30m', '');
  Result := ReplaceStr(Result, #$1b'[01;31m', '');
  Result := ReplaceStr(Result, #$1b'[01;32m', '');
  Result := ReplaceStr(Result, #$1b'[01;35m', '');
  Result := ReplaceStr(Result, #$1b'[K', '');
end;

function TCECompileViaREST.GetCompileResultFromJson(const JSON: TJSONObject): TCECompileResult;
begin
  Result := TCECompileResult.Create(Json.GetValue('code').Value = '0');

  PopulateOutput(Result.CompilerOutput, Json.GetValue('stdout') as TJSONArray);
  PopulateOutput(Result.CompilerOutput, Json.GetValue('stderr') as TJSONArray);

  PopulateAssembly(Result.Assembly, Json.GetValue('asm') as TJSONArray);
end;

end.
