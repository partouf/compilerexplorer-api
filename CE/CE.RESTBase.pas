unit CE.RESTBase;

interface

uses
  REST.Client,
  IPPeerClient;

type
  TCERESTBase = class(TInterfacedObject)
  protected
    FHasReceivedData: Boolean;
    FHasErrors: Boolean;

    FRestResponse: TRESTResponse;
    FRestRequest: TRESTRequest;
    FRestClient: TRESTClient;

  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  CE.Interfaces;

{ TCERESTBase }

constructor TCERESTBase.Create;
begin
  FRestResponse := TRESTResponse.Create(nil);
  FRestRequest := TRESTRequest.Create(nil);
  FRestClient := TRESTClient.Create(nil);

  FRestClient.BaseURL := UrlCompilerExplorer;
  FRestClient.HandleRedirects := True;

  FRestRequest.Client := FRestClient;
  FRestRequest.Response := FRestResponse;
  FRestRequest.SynchronizedEvents := False;

  FRestRequest.Accept := 'application/json';
end;

destructor TCERESTBase.Destroy;
begin
  FRestClient.Free;
  FRestRequest.Free;
  FRestResponse.Free;

  inherited;
end;

end.
