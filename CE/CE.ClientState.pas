unit CE.ClientState;

interface

uses
  System.Generics.Collections, System.JSON, System.Classes;

type
  TCEClientStateCompiler = class
  private
    FId: string;
    FOptions: string;
    FSpecialOutputs: TStrings;
    FLibs: TStrings;
  public
    constructor Create;

    procedure LoadFromJson(const Compiler: TJSONObject);
    function ToJSON: TJSONObject;

    property Id: string read FId write FId;
    property Options: string read FOptions write FOptions;
    property SpecialOutputs: TStrings read FSpecialOutputs;
    property Libs: TStrings read FLibs;
  end;

  TCEClientStateSession = class
  private
    FId: Integer;
    FLanguage: string;
    FSource: string;
    FCompilers: TList<TCEClientStateCompiler>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromJson(const Session: TJSONObject);
    function ToJSON: TJSONObject;

    property Language: string read FLanguage write FLanguage;
    property Source: string read FSource write FSource;
    property Compilers: TList<TCEClientStateCompiler> read FCompilers;
  end;

  TCEClientState = class
  private
    FSessions: TList<TCEClientStateSession>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromJson(const State: TJSONObject);
    function ToJSON: TJSONObject;

    property Sessions: TList<TCEClientStateSession> read FSessions;
  end;

implementation

uses
  System.SysUtils;

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

function TCEClientState.ToJSON: TJSONObject;
var
  Session: TCEClientStateSession;
  SessArr: TJSONArray;
begin
  Result := TJSONObject.Create;
  SessArr := TJSONArray.Create;
  Result.AddPair('sessions', SessArr);

  for Session in FSessions do
  begin
    SessArr.AddElement(Session.ToJSON);
  end;
end;

{ TCEClientStateSession }

constructor TCEClientStateSession.Create;
begin
  FId := 1;
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
  FId := StrToIntDef(Session.GetValue('language').Value, 1);
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

function TCEClientStateSession.ToJSON: TJSONObject;
var
  CompArr: TJSONArray;
  Compiler: TCEClientStateCompiler;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', FId.ToString);
  Result.AddPair('language', FLanguage);
  Result.AddPair('source', FSource);

  CompArr := TJSONArray.Create;

  Result.AddPair('compilers', CompArr);

  for Compiler in FCompilers do
  begin
    CompArr.AddElement(Compiler.ToJSON);
  end;
end;

{ TCEClientStateCompiler }

constructor TCEClientStateCompiler.Create;
begin
  inherited Create;

  FSpecialOutputs := TStringList.Create;
  FLibs := TStringList.Create;
end;

procedure TCEClientStateCompiler.LoadFromJson(const Compiler: TJSONObject);
begin
  FId := Compiler.GetValue('id').Value;
  FOptions := Compiler.GetValue('options').Value;
  FLibs.Clear;
  FSpecialOutputs.Clear;
end;

function TCEClientStateCompiler.ToJSON: TJSONObject;
var
  LibsArr: TJSONArray;
  Lib: string;
  OutputArr: TJSONArray;
  Outp: string;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', FId);
  Result.AddPair('options', FOptions);

  LibsArr := TJSONArray.Create;
  for Lib in FLibs do
  begin
    LibsArr.Add(Lib);
  end;

  Result.AddPair('libs', LibsArr);

  OutputArr := TJSONArray.Create;
  for Outp in FSpecialOutputs do
  begin
    OutputArr.Add(Outp);
  end;

  Result.AddPair('specialoutputs', OutputArr);
end;

end.
