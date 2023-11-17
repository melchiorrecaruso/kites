program kitemodeller;

{$mode objfpc}

uses
  {$ifdef unix}{$ifdef usecthreads} cthreads, {$endif}{$endif}
  interfaces, forms, kitesolver, mainfrm, tachartlazaruspkg, previewfrm;

{$R *.res}

begin
  requirederivedformresource:=true;
  application.scaled:=true;
  application.initialize;
  application.createform(tmainform, mainform);
  application.run;
end.

