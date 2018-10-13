unit CE.LinkSaver;

interface

uses
  CE.Interfaces, CE.RESTBase, CE.Types, CE.ClientState, System.SysUtils;

type
  TCELinkSaver = class(TCERESTBase, ICELinkSaver)
  public
    constructor Create;

    procedure Save(const LanguageId: string; const CompilerId: string; const Code: string; const Arguments: string; const Callback: TProc<string>);
  end;

implementation

uses
  System.JSON, REST.Types;

{ TCELinkSaver }

constructor TCELinkSaver.Create;
begin
  inherited Create;

  FRestRequest.Resource := 'shortener';
  FRestRequest.Method := TRESTRequestMethod.rmPOST;
end;

procedure TCELinkSaver.Save(const LanguageId, CompilerId, Code, Arguments: string; const Callback: TProc<string>);
var
  State: TCEClientState;
  Session: TCEClientStateSession;
  Compiler: TCEClientStateCompiler;
begin
  State := TCEClientState.Create;
  Session := TCEClientStateSession.Create;
  Compiler := TCEClientStateCompiler.Create;

  Session.Language := LanguageId;
  Session.Source := Code;

  Compiler.Id := CompilerId;
  Compiler.Options := Arguments;

  Session.Compilers.Add(Compiler);

  State.Sessions.Add(Session);

  FRestRequest.Body.Add(State.ToJSON);

  FRestRequest.ExecuteAsync(
    procedure
    var
      Response: TJSONObject;
    begin
      Response := FRestResponse.JSONValue as TJSONObject;

      FHasReceivedData := True;

      Callback(Response.GetValue('storedId').Value);
    end,
    False,
    True,
    procedure(Error: TObject)
    begin
      FHasErrors := True;
    end
  );
end;

end.
