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

  TCELanguages = TList<TCELanguage>;
  TCECompilers = TList<TCECompiler>;

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

end.
