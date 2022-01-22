program Laba1;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {Analizator},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Smokey Quartz Kamri');
  Application.CreateForm(TAnalizator, Analizator);
  Application.Run;
end.
