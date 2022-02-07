unit UI.Animated;

interface

uses
  System.Classes,
  System.UITypes,
  System.UIConsts,
  System.SysUtils,
  System.Types,
  System.Math,
  FMX.Types,
  FMX.Utils,
  FMX.Graphics,
  FMX.Ani,
  FMX.Objects,
  FMX.Controls,
  FMX.StdCtrls,
  FMX.Layouts,
  UI.GUI.Types;

type
  TBrushAnimation = class(TAnimation)
  protected
    FBrush: TBrush;
    FRect: TRectF;
    FFromColor: TAlphaColor;
    FToColor: TAlphaColor;
    FSelectedColor: TAlphaColor;
    FPoint: TPointF;
    FDuration: Single;
    FInverseDuration: Single;
    FNotInverseDelay: Single;
    FProcessColor: TAlphaColor;
    procedure SetBrush(Value: TBrush);
    procedure SetColor(const Color: TAlphaColor);
    function Bitmap: TBitmap;
    function Canvas: TCanvas;
    function AnimateRect: TRectF;
    procedure Update;
    procedure SetColors; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    class procedure Start(Target: TFmxObject; const Point: TPointF; Inverse: Boolean);
    procedure StartAnimation(const Point: TPointF);
    property Brush: TBrush read FBrush write SetBrush;
    property SelectedColor: TAlphaColor read FSelectedColor write FSelectedColor;
    property NotInverseDelay: Single read FNotInverseDelay write FNotInverseDelay;
  end;

  TBrushAnimationClass = class of TBrushAnimation;

  TRippleAnimation = class(TBrushAnimation)
  protected
    procedure ProcessAnimation; override;
  end;

  TCustomColorAnimation = class(TBrushAnimation)
  private
  protected
    procedure ProcessAnimation; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TTouchAnimation = class(TAnimation)
  protected
    FFill: TBrush;
    PaintControl: TControl;
    [weak]
    FTarget: TControl;
    FLeaveCalled: Boolean;
    FRect: TRectF;
    FFromColor: TAlphaColor;
    FToColor: TAlphaColor;
    FStartColor: TAlphaColor;
    FSelectedColor: TAlphaColor;
    FPointScale: TPointF;
    FPressingDuration: Single;
    FUnpressingDuration: Single;
    FPressingDelay: Single;
    FProcessColor: TAlphaColor;
    FNeedRepaint: Boolean;
    FXRadius: Single;
    FYRadius: Single;
    FCorners: TCorners;
    procedure SetColors;
    procedure ShowPaint;
    procedure HidePaint;
    procedure DoPaint(Canvas: TCanvas; const ARect: TRectF);
    procedure FirstFrame; override;
    procedure ProcessAnimation; override;
    procedure DoFinish; override;
    procedure Fade;
    procedure SetTarget(Target: TControl);
    procedure FreeNotification(AObject: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start(Target: TControl; P: TPointF);
    procedure Leave(Immediately: Boolean = True);
    procedure Cancel;
    property StartColor: TAlphaColor read FStartColor write FStartColor;
    property SelectedColor: TAlphaColor read FSelectedColor write FSelectedColor;
    property PressingDuration: Single read FPressingDuration write FPressingDuration;
    property UnpressingDuration: Single read FUnpressingDuration write FUnpressingDuration;
    property PressingDelay: Single read FPressingDelay write FPressingDelay;
    property Target: TControl read FTarget;
  end;

  TShapeClass = class of TShape;

  TAniObject = class(TComponent)
  private
    FShape: TShape;
    FAnimation: TBrushAnimation;
    procedure OnFinishAnimation(Sender: TObject);
    procedure ShowShape(Control: TControl);
    procedure HideShape;
  public
    constructor Create(AOwner: TComponent; ShapeClass: TShapeClass; AnimationClass: TBrushAnimationClass;
    const SelectedColor: TAlphaColor);
    procedure Start(Control: TControl; P: TPointF);
    procedure Leave;
    procedure Cancel;
    property Shape: TShape read FShape;
    property Animation: TBrushAnimation read FAnimation;
  end;

  TRectAnimations = class
  public
    class procedure AnimRectPurpleMouseIn(Sender: TObject);
    class procedure AnimRectPurpleMouseOut(Sender: TObject);
    class procedure AnimRectGrayMouseIn(Sender: TObject);
    class procedure AnimRectGrayMouseOut(Sender: TObject);
    class procedure AnimPathGrayMouseIn(Sender: TObject);
    class procedure AnimPathGrayMouseOut(Sender: TObject);
    class procedure AnimRectRedMouseIn(Sender: TObject);
    class procedure AnimRectRedMouseOut(Sender: TObject);
  end;

function CreateAnimation(Control: TControl; Brush: TBrush; AnimationClass: TBrushAnimationClass;
const SelectedColor: TAlphaColor): TBrushAnimation; overload;

procedure CreateAnimation(Shape: TShape; AnimationClass: TBrushAnimationClass; const SelectedColor: TAlphaColor;
ImmediatelyClick: Boolean = True); overload;

function GetAnimation(Target: TFmxObject): TBrushAnimation;

implementation

type
  TMouseTarget = class(TControl)
  protected
    FClicked: Boolean;
    FImmediatelyClick: Boolean;
    Animation: TBrushAnimation;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure OnFinishAnimation(Sender: TObject);
  public
    constructor Create(Shape: TShape; AnimationClass: TBrushAnimationClass);
  end;

constructor TMouseTarget.Create(Shape: TShape; AnimationClass: TBrushAnimationClass);
begin
  inherited Create(Shape);
  Align := TAlignLayout.Contents;
  AutoCapture := True;
  HitTest := True;
  Parent := Shape;
  Animation := AnimationClass.Create(Self);
  Animation.OnFinish := OnFinishAnimation;
  Animation.Brush := Shape.Fill;
  Animation.Parent := Self;
  FImmediatelyClick := True;
end;

type
  TControlAccess = class(TControl);

procedure TMouseTarget.OnFinishAnimation(Sender: TObject);
begin
  if FClicked and ParentControl.HitTest then
    TControlAccess(ParentControl).Click;
end;

procedure TMouseTarget.Click;
begin
  inherited;
  if FImmediatelyClick then
    try
      if ParentControl.HitTest then
        TControlAccess(ParentControl).Click;
      if not Assigned(Root) or (Root.Captured <> IControl(Self)) then
        MouseUp(TMouseButton.mbLeft, [], PressedPosition.X, PressedPosition.Y);
    except
      MouseUp(TMouseButton.mbLeft, [], PressedPosition.X, PressedPosition.Y);
      raise;
    end
  else
    FClicked := True;
end;

procedure TMouseTarget.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FClicked := False;
  Animation.Inverse := False;
  Animation.StartAnimation(PointF(X, Y));
  if ParentControl.HitTest then
    TControlAccess(ParentControl).MouseDown(Button, Shift, X, Y);
end;

procedure TMouseTarget.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  Animation.Inverse := True;
  Animation.StartAnimation(PointF(X, Y));
end;

procedure CreateAnimation(Shape: TShape; AnimationClass: TBrushAnimationClass; const SelectedColor: TAlphaColor;
ImmediatelyClick: Boolean);
begin
  var
  C := TMouseTarget.Create(Shape, AnimationClass);
  C.Animation.SelectedColor := SelectedColor;
  C.FImmediatelyClick := ImmediatelyClick;
end;

function CreateAnimation(Control: TControl; Brush: TBrush; AnimationClass: TBrushAnimationClass;
const SelectedColor: TAlphaColor): TBrushAnimation;
begin
  Control.AutoCapture := True;
  Result := AnimationClass.Create(Control);
  Result.Brush := Brush;
  Result.Parent := Control;
  Result.SelectedColor := SelectedColor;
end;

constructor TAniObject.Create(AOwner: TComponent; ShapeClass: TShapeClass; AnimationClass: TBrushAnimationClass;
const SelectedColor: TAlphaColor);
begin
  inherited Create(AOwner);
  FShape := ShapeClass.Create(AOwner);
  FShape.Align := TAlignLayout.None;
  FShape.Fill.Color := claWhite;
  FShape.HitTest := False;
  FShape.Stroke.Kind := TBrushKind.None;
  FShape.Stroke.Thickness := 0;
  FAnimation := CreateAnimation(FShape, FShape.Fill, AnimationClass, SelectedColor);
  FAnimation.NotInverseDelay := 0.1;
  FAnimation.OnFinish := OnFinishAnimation;
end;

procedure TAniObject.ShowShape(Control: TControl);
var SaveDisableAlign: Boolean;
begin
  if (Control <> nil) and (Control <> Shape.Parent) then
  begin
    SaveDisableAlign := TControlAccess(Control).FDisableAlign;
    TControlAccess(Control).FDisableAlign := True;
    try
      Shape.BoundsRect := Control.LocalRect;
      Control.InsertObject(0, Shape);
    finally
      TControlAccess(Control).FDisableAlign := SaveDisableAlign;
    end;
  end;
end;

procedure TAniObject.HideShape;
begin
  Shape.Parent := nil;
end;

procedure TAniObject.OnFinishAnimation(Sender: TObject);
begin
  if Animation.Inverse then
    HideShape;
end;

procedure TAniObject.Start(Control: TControl; P: TPointF);
begin
  ShowShape(Control);
  Animation.Inverse := False;
  Animation.StartAnimation(P);
end;

procedure TAniObject.Leave;
begin
  if not Animation.Inverse then
    if Shape.HasParent then
    begin
      Animation.Inverse := True;
      Animation.StartAnimation(TPointF.Zero);
    end;
end;

procedure TAniObject.Cancel;
begin
  HideShape;
  Animation.StopAtCurrent;
end;

function GetAnimation(Target: TFmxObject): TBrushAnimation;
var I: Integer;
begin
  Result := nil;
  if Target.Children <> nil then
  begin
    for I := 0 to Target.Children.Count - 1 do
      if Target.Children[I] is TMouseTarget then
        Exit(TMouseTarget(Target.Children[I]).Animation)
      else if Target.Children[I] is TBrushAnimation then
        Exit(TBrushAnimation(Target.Children[I]));
  end;
end;

function AnimatedInterpolateColor(const Start, Stop: TAlphaColor; T: Single): TAlphaColor;
begin
  if Start = claNull then
    Result := MakeColor(Stop, T)
  else if Stop = claNull then
    Result := MakeColor(Start, T)
  else
    Result := InterpolateColor(Start, Stop, T);
end;

function DrawRippleEffect(Canvas: TCanvas; const R: TRectF; const Point: TPointF; FillColor, EllipseColor: TAlphaColor;
ATime: Single): TAlphaColor;
var
  C: TRectF;
  P: TPathData;
  D: Single;
begin
  C := TRectF.Create(Point, 0, 0);
  D := ATime * MaxValue([R.Width - Point.X, Point.X, R.Height - Point.Y, Point.Y]);
  C.Inflate(D, D);
  Canvas.Fill.Kind := TBrushKind.Solid;
  if TAlphaColorRec(EllipseColor).A > 0 then
  begin
    Result := AnimatedInterpolateColor(FillColor, EllipseColor, ATime);
    if TAlphaColorRec(Result).A = 255 then
      Canvas.ClearRect(R, Result)
    else
    begin
      Canvas.ClearRect(R, 0);
      Canvas.Fill.Color := Result;
      Canvas.FillRect(R, 0, 0, AllCorners, 1);
    end;
    Canvas.Fill.Color := EllipseColor;
    Canvas.FillEllipse(C, 1);
  end
  else
  begin
    Result := MakeColor(FillColor, 1 - ATime);
    Canvas.ClearRect(R, EllipseColor);
    Canvas.Fill.Color := Result;
    P := TPathData.Create;
    P.AddRectangle(R, 0, 0, AllCorners);
    P.AddEllipse(C);
    Canvas.FillPath(P, 1);
    P.Free;
  end;
end;

constructor TBrushAnimation.Create(AOwner: TComponent);
begin
  inherited;
  FSelectedColor := claGray;
  FDuration := 0.9;
  FInverseDuration := 0.2;
  FNotInverseDelay := 0.0;
end;

procedure TBrushAnimation.Update;
begin
  if Parent is TControl then
  begin
    FBrush.Kind := TBrushKind.Bitmap;
    Bitmap.SetSize(Ceil(TControl(Parent).Width), Ceil(TControl(Parent).Height));
  end;
end;

function TBrushAnimation.Bitmap: TBitmap;
begin
  Result := FBrush.Bitmap.Bitmap;
end;

function TBrushAnimation.Canvas: TCanvas;
begin
  Result := Bitmap.Canvas;
end;

function TBrushAnimation.AnimateRect: TRectF;
begin
  Result := Bitmap.BoundsF;
end;

procedure TBrushAnimation.SetColor(const Color: TAlphaColor);
begin
  if Canvas <> nil then
  begin
    Canvas.BeginScene;
    Canvas.Clear(Color);
    Canvas.EndScene;
  end;
end;

procedure TBrushAnimation.SetBrush(Value: TBrush);
begin
  FBrush := Value;
end;

class procedure TBrushAnimation.Start(Target: TFmxObject; const Point: TPointF; Inverse: Boolean);
var Animation: TBrushAnimation;
begin
  Animation := GetAnimation(Target);
  if Assigned(Animation) then
  begin
    Animation.Inverse := Inverse;
    Animation.StartAnimation(Point);
  end;
end;

procedure TBrushAnimation.SetColors;
begin
  if Inverse then
  begin
    FFromColor := FBrush.Color;
    if Running then
      FToColor := FProcessColor
    else
      FToColor := SelectedColor;
  end
  else
  begin
    if Running then
      FFromColor := FProcessColor
    else
      FFromColor := FBrush.Color;
    FToColor := SelectedColor;
  end;
end;

procedure TBrushAnimation.StartAnimation(const Point: TPointF);
begin
  if Brush = nil then
    Exit;
  SetColors;
  Update;
  SetColor(FFromColor);
  FPoint := Point;
  if not Inverse then
  begin
    Duration := FDuration;
    Delay := NotInverseDelay;
  end
  else
  begin
    Duration := FInverseDuration;
    Delay := 0.0;
  end;
  inherited Start;
end;

procedure TRippleAnimation.ProcessAnimation;
begin
  Canvas.BeginScene;
  if not Inverse then
    FProcessColor := DrawRippleEffect(Canvas, AnimateRect, FPoint, FFromColor, FToColor,
    InterpolateExpo(CurrentTime, 0, 1, Duration, TAnimationType.&Out))
  else
  begin
    FProcessColor := AnimatedInterpolateColor(FFromColor, FToColor, NormalizedTime);
    Bitmap.Clear(FProcessColor);
  end;
  Canvas.EndScene;
end;

constructor TCustomColorAnimation.Create(AOwner: TComponent);
begin
  inherited;
  FDuration := 0.1;
  FInverseDuration := 0.2;
end;

procedure TCustomColorAnimation.ProcessAnimation;
begin
  FProcessColor := AnimatedInterpolateColor(FFromColor, FToColor, NormalizedTime);
  Canvas.BeginScene;
  Bitmap.Clear(FProcessColor);
  Canvas.EndScene;
end;

{ TTouchAnimation }
type
  TPaintControl = class(TControl)
  protected
    procedure Paint; override;
  end;

procedure TPaintControl.Paint;
begin
  TTouchAnimation(Owner).DoPaint(Canvas, LocalRect);
end;

constructor TTouchAnimation.Create(AOwner: TComponent);
begin
  inherited;
  if AOwner is TFmxObject then
    Parent := TFmxObject(AOwner);
  FFill := TBrush.Create(TBrushKind.Bitmap, claNull);
  FFill.Bitmap.WrapMode := TWrapMode.Tile;
  FStartColor := claWhite;
  FSelectedColor := $FFEDEDED;
  FPressingDelay := 0.1;
  FPressingDuration := 0.9;
  FUnpressingDuration := 0.1;
  PaintControl := TPaintControl.Create(Self);
  PaintControl.Align := TAlignLayout.Contents;
  PaintControl.HitTest := False;
end;

destructor TTouchAnimation.Destroy;
begin
  SetTarget(nil);
  FFill.Free;
  inherited;
end;

procedure TTouchAnimation.FreeNotification(AObject: TObject);
begin
  inherited;
  if AObject = FTarget then
    SetTarget(nil);
end;

procedure TTouchAnimation.SetTarget(Target: TControl);
begin

  if Target <> FTarget then
  begin

    if FTarget <> nil then
      FTarget.RemoveFreeNotify(Self);

    HidePaint;

    FTarget := Target;

    if FTarget is TRectangle then
    begin
      var
      R := TRectangle(FTarget);
      FXRadius := R.XRadius;
      FYRadius := R.YRadius;
      FCorners := R.Corners;
    end
    else
    begin
      FXRadius := 2;
      FYRadius := 2;
      FCorners := AllCorners;
    end;

    if FTarget <> nil then
      FTarget.AddFreeNotify(Self);

  end;

end;

procedure TTouchAnimation.DoPaint(Canvas: TCanvas; const ARect: TRectF);
var
  C: TCanvas;
  S: TSize;
  P: TPointF;
begin
  if not Inverse then
  begin

    if FNeedRepaint then
    begin
      S := TSize.Create(Max(FFill.Bitmap.Bitmap.Width, Ceil(ARect.Width)),
      Max(FFill.Bitmap.Bitmap.Height, Ceil(ARect.Height)));
      FFill.Bitmap.Bitmap.SetSize(S);
      C := FFill.Bitmap.Bitmap.Canvas;
      C.BeginScene;
      P := PointF(PaintControl.Width * FPointScale.X, PaintControl.Height * FPointScale.Y);
      FProcessColor := DrawRippleEffect(C, ARect, P, FFromColor, FToColor, InterpolateExpo(CurrentTime, 0, 1, Duration,
      TAnimationType.&Out));
      C.EndScene;
    end;
    Canvas.FillRect(ARect, FXRadius, FYRadius, FCorners, PaintControl.AbsoluteOpacity, FFill);
  end
  else
  begin

    FProcessColor := AnimatedInterpolateColor(FFromColor, FToColor, NormalizedTime);
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := FProcessColor;
    Canvas.FillRect(ARect, FXRadius, FYRadius, FCorners, PaintControl.AbsoluteOpacity);
  end;
  FNeedRepaint := False;
end;

procedure TTouchAnimation.FirstFrame;
begin
  ShowPaint;
end;

procedure TTouchAnimation.ProcessAnimation;
begin
  FNeedRepaint := True;
  if Assigned(PaintControl) then
    PaintControl.Repaint;
end;

procedure TTouchAnimation.DoFinish;
begin
  if Inverse then
    HidePaint
  else if FLeaveCalled then
    Fade;
end;

procedure TTouchAnimation.ShowPaint;
var SaveDisableAlign: Boolean;
begin
  if Assigned(PaintControl) and Assigned(FTarget) and (PaintControl.Parent <> FTarget) then
  begin
    SaveDisableAlign := TControlAccess(FTarget).FDisableAlign;
    TControlAccess(FTarget).FDisableAlign := True;
    try
      PaintControl.BoundsRect := FTarget.LocalRect;
      FTarget.InsertObject(0, PaintControl);
    finally
      TControlAccess(FTarget).FDisableAlign := SaveDisableAlign;
    end;
  end;
end;

procedure TTouchAnimation.HidePaint;
var SaveDisableAlign: Boolean;
begin
  if Assigned(PaintControl) and Assigned(FTarget) and (PaintControl.Parent = FTarget) then
  begin
    SaveDisableAlign := TControlAccess(FTarget).FDisableAlign;
    TControlAccess(FTarget).FDisableAlign := True;
    try
      PaintControl.Parent := nil;
    finally
      TControlAccess(FTarget).FDisableAlign := SaveDisableAlign;
    end;
  end;
end;

procedure TTouchAnimation.SetColors;
begin
  if Inverse then
  begin
    FFromColor := FStartColor;
    if Running then
      FToColor := FProcessColor
    else
      FToColor := SelectedColor;
  end
  else
  begin
    FFromColor := FStartColor;
    FToColor := SelectedColor;
  end;
end;

procedure TTouchAnimation.Start(Target: TControl; P: TPointF);
begin

  FPointScale := PointF(P.X / Target.Width, P.Y / Target.Height);

  FLeaveCalled := False;

  Inverse := False;

  SetColors;
  Duration := PressingDuration;
  Delay := PressingDelay;
  HidePaint;
  SetTarget(Target);
  inherited Start;
end;

procedure TTouchAnimation.Fade;
begin
  if Assigned(PaintControl) and PaintControl.HasParent then
  begin
    Inverse := True;
    SetColors;
    Duration := UnpressingDuration * CurrentTime / PressingDuration; // depends on completion pressed animation
    Delay := 0.0;
    inherited Start;
  end
  else
    StopAtCurrent; // stop with delay animation
end;

procedure TTouchAnimation.Leave(Immediately: Boolean);
begin
  if not FLeaveCalled then
  begin
    FLeaveCalled := True;
    if not Running or Immediately then
      Fade
    else if Assigned(PaintControl) and not PaintControl.HasParent then
      StopAtCurrent;
  end;
end;

procedure TTouchAnimation.Cancel;
begin
  FLeaveCalled := True;
  HidePaint;
  StopAtCurrent;
end;

{ TRectAnimations }

class procedure TRectAnimations.AnimPathGrayMouseIn(Sender: TObject);
var
  FObj: TFmxObject;
  FLabel: TLabel;
  FPath: TPath;
begin
  FLabel := nil;
  FPath := nil;
  for FObj in (Sender as TLayout).Children.ToArray do
    if FObj is TLabel then
      FLabel := FObj as TLabel
    else if FObj is TPath then
      FPath := FObj as TPath;
  if Assigned(FLabel) then
    FLabel.TextSettings.FontColor := CLR_GRAY_SELECTED_TEXT;
  if Assigned(FPath) then
    FPath.Fill.Color := CLR_GRAY_SELECTED_TEXT;
end;

class procedure TRectAnimations.AnimPathGrayMouseOut(Sender: TObject);
var
  FObj: TFmxObject;
  FLabel: TLabel;
  FPath: TPath;
begin
  FLabel := nil;
  FPath := nil;
  for FObj in (Sender as TLayout).Children.ToArray do
    if FObj is TLabel then
      FLabel := FObj as TLabel
    else if FObj is TPath then
      FPath := FObj as TPath;
  if Assigned(FLabel) then
    FLabel.TextSettings.FontColor := CLR_GRAY_FREE_TEXT;
  if Assigned(FPath) then
    FPath.Fill.Color := CLR_GRAY_FREE_TEXT;
end;

class procedure TRectAnimations.AnimRectGrayMouseIn(Sender: TObject);
var
  FObj: TFmxObject;
  FLabel: TLabel;
begin
  FLabel := nil;
  for FObj in (Sender as TRectangle).Children.ToArray do
    if FObj is TLabel then
    begin
      FLabel := FObj as TLabel;
      break;
    end;
  if Assigned(FLabel) then
    FLabel.TextSettings.FontColor := CLR_GRAY_SELECTED_TEXT;
end;

class procedure TRectAnimations.AnimRectGrayMouseOut(Sender: TObject);
var
  FObj: TFmxObject;
  FLabel: TLabel;
begin
  FLabel := nil;
  for FObj in (Sender as TRectangle).Children.ToArray do
    if FObj is TLabel then
    begin
      FLabel := FObj as TLabel;
      break;
    end;
  if Assigned(FLabel) then
    FLabel.TextSettings.FontColor := CLR_GRAY_FREE_TEXT;
end;

class procedure TRectAnimations.AnimRectPurpleMouseIn(Sender: TObject);
begin
  (Sender as TRectangle).Fill.Color := CLR_PURP_SELECTED;
end;

class procedure TRectAnimations.AnimRectPurpleMouseOut(Sender: TObject);
begin
  (Sender as TRectangle).Fill.Color := CLR_PURP_FREE;
end;

class procedure TRectAnimations.AnimRectRedMouseIn(Sender: TObject);
var
  FObj: TFmxObject;
  FLabel: TLabel;
begin
  FLabel := nil;
  for FObj in (Sender as TRectangle).Children.ToArray do
    if FObj is TLabel then
    begin
      FLabel := FObj as TLabel;
      break;
    end;
  if Assigned(FLabel) then
    FLabel.TextSettings.FontColor := CLR_RED_SELECTED_TEXT;
end;

class procedure TRectAnimations.AnimRectRedMouseOut(Sender: TObject);
var
  FObj: TFmxObject;
  FLabel: TLabel;
begin
  FLabel := nil;
  for FObj in (Sender as TRectangle).Children.ToArray do
    if FObj is TLabel then
    begin
      FLabel := FObj as TLabel;
      break;
    end;
  if Assigned(FLabel) then
    FLabel.TextSettings.FontColor := CLR_RED_FREE_TEXT;
end;

end.
