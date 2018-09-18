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

  TCECompileResult = class
  protected
    FSuccessful: Boolean;
    FCompilerOutput: string;
  public
    property Successful: Boolean read FSuccessful;
    property CompilerOutput: string read FCompilerOutput;

    constructor Create(const Success: Boolean; const Output: string);
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

constructor TCECompileResult.Create(const Success: Boolean; const Output: string);
begin
  FSuccessful := Success;
  FCompilerOutput := Output;
end;

end.
