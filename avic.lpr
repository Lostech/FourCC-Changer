program avic;

{$MODE Delphi}

uses
  Forms, Interfaces,
  mainunit in 'mainunit.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
