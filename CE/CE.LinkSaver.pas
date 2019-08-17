unit CE.LinkSaver;

interface

uses
  CE.Interfaces, CE.RESTBase, CE.Types, CE.ClientState, System.SysUtils,
  System.Generics.Collections;

type
  TCELinkSaver = class(TCERESTBase, ICELinkSaver)
  public
    constructor Create;

    procedure Save(const LanguageId: string; const CompilerId: string; const Code: string; const Arguments: string; const SelectedLibraries: TList<TCELibraryVersion>; const Callback: TProc<string>);
  end;

implementation

uses
  System.JSON, REST.Types, Underscore.Delphi.Springless;

{ TCELinkSaver }

constructor TCELinkSaver.Create;
begin
  inherited Create;

  FRestRequest.Resource := 'shortener';
  FRestRequest.Method := TRESTRequestMethod.rmPOST;
end;

procedure TCELinkSaver.Save(const LanguageId, CompilerId, Code, Arguments: string; const SelectedLibraries: TList<TCELibraryVersion>; const Callback: TProc<string>);
var
  State: TCEClientState;
  Session: TCEClientStateSession;
  Compiler: TCEClientStateCompiler;
  LibList: TList<TCEClientStateLibraryVersion>;
begin
  State := TCEClientState.Create;
  Session := TCEClientStateSession.Create;
  Compiler := TCEClientStateCompiler.Create;

  Session.Language := LanguageId;
  Session.Source := Code;

  Compiler.Id := CompilerId;
  Compiler.Arguments := Arguments;

  LibList := _.Map<TCELibraryVersion, TCEClientStateLibraryVersion>(SelectedLibraries,
    function(const Lib: TCELibraryVersion): TCEClientStateLibraryVersion
    begin
      Result := TCEClientStateLibraryVersion.Create(Lib.lib.Id, Lib.Version);
    end);
  try
    Compiler.Libs.AddRange(LibList);
  finally
    LibList.Free;
  end;

  Session.Compilers.Add(Compiler);

  State.Sessions.Add(Session);

  FRestRequest.Body.Add(State.ToJSON);

  FRestRequest.ExecuteAsync(
    procedure
    var
      Response: TJSONObject;
      StoredId: TJSONValue;
      StoredUrl: TJSONValue;
    begin
      Response := FRestResponse.JSONValue as TJSONObject;

      FHasReceivedData := True;

      StoredId := Response.GetValue('storedId');
      StoredUrl := Response.GetValue('url');

      if Assigned(StoredId) then
        Callback(StoredId.Value)
      else if Assigned(StoredUrl) then
        Callback(StoredUrl.Value)
      else
        ReportError(Response);
    end,
    False,
    True,
    procedure(Error: TObject)
    begin
      ReportError(Error);
    end
  );
end;

end.
