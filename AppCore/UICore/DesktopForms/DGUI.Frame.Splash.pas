unit DGUI.Frame.Splash;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts, FMX.Ani;

type
  TSplashFrame = class(TFrame)
    LogoLayout: TLayout;
    OrbisLogoPath2: TPath;
    OrbisLogoPath1: TPath;
    OrbisLogoPath3: TPath;
    MainRectangle: TRectangle;
    FloatAnimation1: TFloatAnimation;
    procedure FloatAnimation1Finish(Sender: TObject);
  private

  public

  end;

implementation

{$R *.fmx}

procedure TSplashFrame.FloatAnimation1Finish(Sender: TObject);
begin
  Self.Hide;
end;

end.
