unit CE.Interfaces;

interface

uses
  CE.Types,
  System.SysUtils;

type
  ICELanguages = interface
    ['{71A30B67-D3E8-4E76-912B-40638109B40A}']

    procedure GetLanguages(const Callback: TProc<TCELanguages>);
  end;

  ICECompilers = interface
    ['{58888319-35F7-4F7D-950F-EA035A7419F6}']

    procedure GetCompilers(const LanguageId: string; const Callback: TProc<TCECompilers>);
  end;

  ICECompile = interface
    ['{C6E283C2-6A38-444E-859E-F3F0A66571F0}']

    procedure Compile(const LanguageId: string; const CompilerId: string; const Code: string; const Arguments: string; const Callback: TProc<TCECompileResult>);
  end;

implementation


end.
