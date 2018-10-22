unit CE.LinkInfo;

interface

uses
  CE.Interfaces, CE.RESTBase, CE.Types, CE.ClientState, System.SysUtils;

type
  TCELinkInfo = class(TCERESTBase, ICELinkInfo)
  public
    procedure GetClientState(const Uri: string; const Callback: TProc<TCEClientState>);
  end;

implementation

uses
  System.JSON, System.StrUtils, FMX.Types;

{ TCELinkInfo }

procedure TCELinkInfo.GetClientState(const Uri: string; const Callback: TProc<TCEClientState>);
begin
  FRestClient.BaseURL := Uri;

  FRestClient.BaseURL := FRestClient.BaseURL.Replace('/z/', '/api/shortlinkinfo/').Replace('/resetlayout/', '/api/shortlinkinfo/');

  FRestRequest.ExecuteAsync(
    procedure
    var
      State: TCEClientState;
    begin
      State := TCEClientState.Create;
      State.LoadFromJson(FRestResponse.JSONValue as TJSONObject);

      FHasReceivedData := True;

      Callback(State);
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
