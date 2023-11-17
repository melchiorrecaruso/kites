unit previewfrm;

{$mode ObjFPC}{$H+}

interface

uses
  classes, sysutils, forms, controls, graphics, dialogs, comctrls, extctrls;

type

  { tpreviewform }

  tpreviewform = class(tform)
    image: timage;
    imagelist: timagelist;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  previewform: tpreviewform;

implementation

{$R *.lfm}

{ tpreviewform }

procedure tpreviewform.formcreate(sender: tobject);
begin
  imagelist.getbitmap(0, image.picture.bitmap);
end;

end.

