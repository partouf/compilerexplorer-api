unit CE.Types;

interface

uses
  System.Generics.Collections;

type
  TCELanguage = class
  protected
    FId: string;
    FLanguageName: string;
    FExampleCode: string;
  public
    constructor Create(const Id: string; const Name: string; const Example: string);

    property Id: string read FId;
    property LanguageName: string read FLanguageName;
    property ExampleCode: string read FExampleCode;
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

{ TCELanguage }

constructor TCELanguage.Create(const Id, Name, Example: string);
begin
  FId := Id;
  FLanguageName := Name;
  FExampleCode := Example;
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
var
  Language: TCELanguage;
begin
  Result := nil;

  for Language in Self do
  begin
    if Language.Id = Id then
    begin
      Result := Language;
      Exit;
    end;
  end;
end;

{ TCECompilers }

function TCECompilers.FindById(const Id: string): TCECompiler;
var
  Compiler: TCECompiler;
begin
  Result := nil;

  for Compiler in Self do
  begin
    if Compiler.CompilerId = Id then
    begin
      Result := Compiler;
      Exit;
    end;
  end;
end;

end.
