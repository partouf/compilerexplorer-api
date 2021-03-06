unit CE.Types;

interface

uses
  System.Generics.Collections, System.Classes;

type
  TCELanguage = class
  protected
    FId: string;
    FLanguageName: string;
    FExampleCode: string;
    FDefaultCompilerId: string;
  public
    constructor Create(const Id: string; const Name: string; const Example: string; const DefaultCompilerId: string);

    property Id: string read FId;
    property LanguageName: string read FLanguageName;
    property ExampleCode: string read FExampleCode;
    property DefaultCompilerId: string read FDefaultCompilerId;
  end;

  TCELibrary = class;

  TCELibraryVersion = class
  private
    FLibrary: TCELibrary;
    FPaths: TStrings;
    FVersion: string;
  public
    constructor Create(const Lib: TCELibrary; const Version: string);
    destructor Destroy; override;

    property Lib: TCELibrary read FLibrary;
    property Version: string read FVersion;
    property Paths: TStrings read FPaths;
  end;

  TCELibrary = class
  private
    FName: string;
    FId: string;
    FDescription: string;
    FVersions: TList<TCELibraryVersion>;
    FUrl: string;
  public
    constructor Create(const Id, Name, Url: string);
    destructor Destroy; override;

    property Id: string read FId;
    property Name: string read FName;
    property Description: string read FDescription write FDescription;
    property Url: string read FUrl;
    property Versions: TList<TCELibraryVersion> read FVersions;
  end;

  TCELibraries = class(TObjectList<TCELibrary>)
  public
    function GetLibraryById(const Id: string): TCELibrary;
    function GetLibraryVersion(const LibraryId: string; const Version: string): TCELibraryVersion;
  end;

  TCECompiler = class
  protected
    FCompilerId: string;
    FDescription: string;
  public
    constructor Create(const CompilerId: string; const Description: string);

    property CompilerId: string read FCompilerId;
    property Description: string read FDescription;
  end;

  TCEAssemblyLine = class
  protected
    FText: string;
  public
    property Text: string read FText;

    constructor Create(const Text: string);
  end;

  TCEErrorLine = class
  private
    FText: string;
  public
    property Text: string read FText;

    constructor Create(const Text: string);
  end;

  TCECompileResult = class
  protected
    FSuccessful: Boolean;
    FCompilerOutput: TList<TCEErrorLine>;
    FAssembly: TList<TCEAssemblyLine>;
  public
    property Successful: Boolean read FSuccessful;
    property CompilerOutput: TList<TCEErrorLine> read FCompilerOutput;
    property Assembly: TList<TCEAssemblyLine> read FAssembly;

    constructor Create(const Success: Boolean);
    destructor Destroy; override;
  end;

  TCELanguages = class(TObjectList<TCELanguage>)
  public
    function GetById(const Id: string): TCELanguage;
  end;

  TCECompilers = class(TObjectList<TCECompiler>)
  public
    function FindById(const Id: string): TCECompiler;
  end;

implementation

uses
  Underscore.Delphi.Springless;

{ TCELanguage }

constructor TCELanguage.Create(const Id, Name, Example, DefaultCompilerId: string);
begin
  FId := Id;
  FLanguageName := Name;
  FExampleCode := Example;
  FDefaultCompilerId := DefaultCompilerId;
end;

{ TCECompiler }

constructor TCECompiler.Create(const CompilerId, Description: string);
begin
  FCompilerId := CompilerId;
  FDescription := Description;
end;

{ TCECompileResult }

constructor TCECompileResult.Create(const Success: Boolean);
begin
  FSuccessful := Success;
  FCompilerOutput := TObjectList<TCEErrorLine>.Create;
  FAssembly := TObjectList<TCEAssemblyLine>.Create;
end;

destructor TCECompileResult.Destroy;
begin
  FAssembly.Free;
  FCompilerOutput.Free;
  inherited;
end;

{ TCEAssemblyLine }

constructor TCEAssemblyLine.Create(const Text: string);
begin
  FText := Text;
end;

{ TCEErrorLine }

constructor TCEErrorLine.Create(const Text: string);
begin
  FText := Text;
end;

{ TCELanguages }

function TCELanguages.GetById(const Id: string): TCELanguage;
begin
  Result := _.FindOrDefault<TCELanguage>(Self,
    function(const Language: TCELanguage): Boolean
    begin
      Result := Language.Id = Id;
    end, nil);
end;

{ TCECompilers }

function TCECompilers.FindById(const Id: string): TCECompiler;
begin
  Result := _.FindOrDefault<TCECompiler>(Self,
    function(const Compiler: TCECompiler): Boolean
    begin
      Result := Compiler.CompilerId = Id;
    end, nil);
end;

{ TCELibrary }

constructor TCELibrary.Create(const Id, Name, Url: string);
begin
  inherited Create;

  FId := Id;
  FName := Name;
  FDescription := '';
  FUrl := Url;
  FVersions := TObjectList<TCELibraryVersion>.Create;
end;

destructor TCELibrary.Destroy;
begin
  FVersions.Free;

  inherited;
end;

{ TCELibraryVersion }

constructor TCELibraryVersion.Create(const Lib: TCELibrary; const Version: string);
begin
  inherited Create;

  FLibrary := Lib;
  FVersion := Version;
  FPaths := TStringList.Create;
end;

destructor TCELibraryVersion.Destroy;
begin
  FPaths.Free;

  inherited;
end;

{ TCELibraries }

function TCELibraries.GetLibraryById(const Id: string): TCELibrary;
begin
  Result := _.FindOrDefault<TCELibrary>(Self,
    function(const Lib: TCELibrary): Boolean
    begin
      Result := Lib.Id = Id;
    end, nil);
end;

function TCELibraries.GetLibraryVersion(const LibraryId, Version: string): TCELibraryVersion;
var
  Lib: TCELibrary;
begin
  Lib := GetLibraryById(LibraryId);
  if Assigned(Lib) then
  begin
    Result := _.FindOrDefault<TCELibraryVersion>(
      Lib.Versions,
      function(const Item: TCELibraryVersion): Boolean
      begin
        Result := Item.Version = Version;
      end, nil);
  end
  else
    Result := nil;
end;

end.
