unit CE.Interfaces;

interface

uses
  CE.Types,
  CE.ClientState,
  System.SysUtils,
  System.Generics.Collections;

type
  ICELanguages = interface
    ['{71A30B67-D3E8-4E76-912B-40638109B40A}']

    procedure GetLanguages(const Callback: TProc<TCELanguages>);
  end;

  ICECompilers = interface
    ['{58888319-35F7-4F7D-950F-EA035A7419F6}']

    procedure GetCompilers(const LanguageId: string; const Callback: TProc<TCECompilers>);
  end;

  ICELibraries = interface
    ['{923B7084-D352-4537-B0A3-5FA56DEB54EE}']

    procedure GetLibraries(const LanguageId: string; const Callback: TProc<TCELibraries>);
  end;

  ICECompile = interface
    ['{C6E283C2-6A38-444E-859E-F3F0A66571F0}']

    procedure Compile(const LanguageId: string; const CompilerId: string; const Code: string; const Arguments: string; const SelectedLibraries: TList<TCELibraryVersion>; const Callback: TProc<TCECompileResult>);
  end;

  ICELinkInfo = interface
    ['{84FC3CEA-BC28-47C5-8400-58D3013FEAB6}']

    procedure GetClientState(const Uri: string; const Callback: TProc<TCEClientState>);
  end;

  ICELinkSaver = interface
    ['{549909F6-941F-4AD5-A3DF-DB451E62DE25}']

    procedure Save(const LanguageId: string; const CompilerId: string; const Code: string; const Arguments: string; const SelectedLibraries: TList<TCELibraryVersion>; const Callback: TProc<string>);
  end;

const
  UrlCompilerExplorer = 'https://godbolt.org/beta';

implementation


end.
