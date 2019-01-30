unit CE.RESTBase;

interface

uses
  REST.Client,
  System.SysUtils,
  IPPeerClient,
  CE.Interfaces;

type
  TCERESTBase = class(TInterfacedObject, ICERestBase)
  protected
    FHasReceivedData: Boolean;
    FHasErrors: Boolean;

    FRestResponse: TRESTResponse;
    FRestRequest: TRESTRequest;
    FRestClient: TRESTClient;

    FErrorCallback: TProc<string>;

    procedure ReportError(const ErrorMessage: string); overload;
    procedure ReportError(const ErrorObject: TObject); overload;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetErrorCallback(const Callback: TProc<string>);

    property HasErrors: Boolean
      read FHasErrors;
  end;

implementation

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

procedure TCERESTBase.ReportError(const ErrorMessage: string);
begin
  FHasErrors := True;
  if Assigned(FErrorCallback) then
  begin
    FErrorCallback(ErrorMessage);
  end;
end;

procedure TCERESTBase.ReportError(const ErrorObject: TObject);
begin
  if ErrorObject is Exception then
  begin
    ReportError(Exception(ErrorObject).Message);
  end
  else
  begin
    ReportError(ErrorObject.ClassName);
  end;
end;

procedure TCERESTBase.SetErrorCallback(const Callback: TProc<string>);
begin
  FErrorCallback := Callback;
end;

end.
