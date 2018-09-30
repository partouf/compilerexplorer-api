unit CE.ClientState;

interface

uses
  System.Generics.Collections, System.JSON;

type
  TCEClientStateCompiler = class
  private
    FId: string;
    FOptions: string;
  public
    procedure LoadFromJson(const Compiler: TJSONObject);

    property Id: string read FId;
    property Options: string read FOptions;
  end;

  TCEClientStateSession = class
  private
    FLanguage: string;
    FSource: string;
    FCompilers: TList<TCEClientStateCompiler>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromJson(const Session: TJSONObject);

    property Language: string read FLanguage;
    property Source: string read FSource;
    property Compilers: TList<TCEClientStateCompiler> read FCompilers;
  end;

  TCEClientState = class
  private
    FSessions: TList<TCEClientStateSession>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromJson(const State: TJSONObject);

    property Sessions: TList<TCEClientStateSession> read FSessions;
  end;

implementation

{ TCEClientState }

constructor TCEClientState.Create;
begin
  FSessions := TObjectList<TCEClientStateSession>.Create;
end;

destructor TCEClientState.Destroy;
begin
  FSessions.Free;

  inherited;
end;

procedure TCEClientState.LoadFromJson(const State: TJSONObject);
var
  SessArr: TJSONArray;
  SessObj: TJSONValue;
  Session: TCEClientStateSession;
begin
  SessArr := State.GetValue('sessions') as TJSONArray;

  for SessObj in SessArr do
  begin
    Session := TCEClientStateSession.Create;
    Session.LoadFromJson(SessObj as TJSONObject);

    FSessions.Add(Session);
  end;
end;

{ TCEClientStateSession }

constructor TCEClientStateSession.Create;
begin
  FCompilers := TObjectList<TCEClientStateCompiler>.Create;
end;

destructor TCEClientStateSession.Destroy;
begin
  FCompilers.Free;

  inherited;
end;

procedure TCEClientStateSession.LoadFromJson(const Session: TJSONObject);
var
  CompArr: TJSONArray;
  CompObj: TJSONValue;
  Compiler: TCEClientStateCompiler;
begin
  FLanguage := Session.GetValue('language').Value;
  FSource := Session.GetValue('source').Value;

  CompArr := Session.GetValue('compilers') as TJSONArray;
  for CompObj in CompArr do
  begin
    Compiler := TCEClientStateCompiler.Create;
    Compiler.LoadFromJson(CompObj as TJSONObject);

    FCompilers.Add(Compiler);
  end;
end;

{ TCEClientStateCompiler }

procedure TCEClientStateCompiler.LoadFromJson(const Compiler: TJSONObject);
begin
  FId := Compiler.GetValue('id').Value;
  FOptions := Compiler.GetValue('options').Value;
end;

end.
