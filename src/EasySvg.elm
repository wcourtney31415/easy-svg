module EasySvg exposing (Camera, PortView, draw)

import Color exposing (Color)
import Drawable exposing (Drawable, DrawingData, Shape(..), Transform(..))
import Html exposing (Html)
import Svg exposing (Attribute, Svg)
import TypedSvg as TS
import TypedSvg.Attributes as TSA
import TypedSvg.Types as TST


type alias PortView =
    { width : Float
    , height : Float
    }


type alias Camera =
    { centerX : Float
    , centerY : Float
    , width : Float
    , height : Float
    }


draw : PortView -> Camera -> List Drawable -> Html msg
draw portView camera drawables =
    TS.svg
        [ TSA.width (TST.num portView.width)
        , TSA.height (TST.num portView.height)
        , TSA.viewBox
            (centerToLeftX camera.centerX camera.width)
            (centerToTopY camera.centerY camera.height)
            camera.width
            camera.height
        ]
        (List.map drawShape drawables)


centerToLeftX : Float -> Float -> Float
centerToLeftX centerX width =
    centerX - width / 2


centerToTopY : Float -> Float -> Float
centerToTopY centerY height =
    centerY - height / 2


drawShape : Drawable -> Svg msg
drawShape drawable =
    let
        data =
            Drawable.getDrawingData drawable
    in
    case data.shape of
        Circle radius ->
            TS.circle
                [ TSA.r (TST.num radius)
                , TSA.transform (getTransforms data)
                , TSA.strokeWidth (TST.num (getStrokeWidth data))
                , TSA.stroke (getStrokePaint data)
                , TSA.fill (getFillPaint data)
                ]
                []

        Rectangle width height ->
            TS.rect
                [ TSA.width (TST.num width)
                , TSA.height (TST.num height)
                , TSA.transform (getRectTransforms data width height)
                , TSA.strokeWidth (TST.num (getStrokeWidth data))
                , TSA.stroke (getStrokePaint data)
                , TSA.fill (getFillPaint data)
                ]
                []

        Ellipse radiusX radiusY ->
            TS.ellipse
                [ TSA.rx (TST.num radiusX)
                , TSA.ry (TST.num radiusY)
                , TSA.strokeWidth (TST.num (getStrokeWidth data))
                , TSA.stroke (getStrokePaint data)
                , TSA.fill (getFillPaint data)
                ]
                []

        Group drawables ->
            TS.g [ TSA.transform (getTransforms data) ]
                (List.map drawShape drawables)


getStrokeWidth : DrawingData -> Float
getStrokeWidth data =
    data.outline
        |> Maybe.map Tuple.second
        |> Maybe.withDefault 0


getStrokePaint : DrawingData -> TST.Paint
getStrokePaint data =
    data.outline
        |> Maybe.map Tuple.first
        |> Maybe.map TST.Paint
        |> Maybe.withDefault TST.PaintNone


getFillPaint : DrawingData -> TST.Paint
getFillPaint data =
    data.fill
        |> Maybe.map TST.Paint
        |> Maybe.withDefault TST.PaintNone


getRectTransforms : DrawingData -> Float -> Float -> List TST.Transform
getRectTransforms data width height =
    getTransforms data ++ [ TST.Translate (-width / 2) (-height / 2) ]


getTransforms : DrawingData -> List TST.Transform
getTransforms data =
    List.map mapTransformTypes data.transforms


mapTransformTypes : Drawable.Transform -> TST.Transform
mapTransformTypes t =
    case t of
        Translate x y ->
            TST.Translate x y

        Rotate a ->
            TST.Rotate a 0 0

        Scale x y ->
            TST.Scale x y

        SkewX a ->
            TST.SkewX a

        SkewY a ->
            TST.SkewY a
