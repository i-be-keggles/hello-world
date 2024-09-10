setscreen ("graphics:600;600")

var lineDensity : int := 15
var lineLength : int := 20

var gridSize : int := 40

type Vector2 :
    record
	x : real
	y : real
    end record

var grids : Vector2
grids.x := 15
grids.y := 15

var gradients : array 1 .. (grids.x * grids.y) div 1 of Vector2

function GridIndex (x, y : int) : int
    var _x : int := x div gridSize
    var _y : int := y div gridSize

    if _y < 1 then
	_y := 1
    end if

    var res : int := _y + _x * grids.x div 1

    %put "x: ", x, " / ", _x, "     y: ", y, " / ", _y,  "      index: ", res

    if res < upper (gradients) + 1 then
	result res
    elsif res < 1 then
	result 1
    else
	result upper (gradients)
    end if
end GridIndex

function GetGrad : Vector2
    var vec : Vector2
    var xsign : int := Rand.Int (0, 1)
    if xsign = 0 then
	vec.x := Rand.Real
    else
	vec.x := -Rand.Real
    end if
    var ysign : int := Rand.Int (0, 1)
    if ysign = 0 then
	vec.y := Rand.Real
    else
	vec.y := -Rand.Real
    end if
    result vec
end GetGrad

function lerp (x, y, n : real) : real
end lerp

function Dot (a, b : Vector2) : real
    result a.x * b.x + a.y * b.y
end Dot

function IntDirs (x, y : int) : array 1 .. 4 of Vector2
    var corners : array 1 .. 4 of Vector2
    var dirs : array 1 .. 4 of Vector2

    var ind : int := GridIndex (x, y)

    corners (1).x := (ind mod grids.y) * gridSize
    corners (1).y := (ind div grids.y) * gridSize + gridSize
    corners (2).x := (ind mod grids.y) * gridSize + gridSize
    corners (2).y := (ind div grids.y) * gridSize + gridSize
    corners (3).x := (ind mod grids.y) * gridSize
    corners (3).y := (ind div grids.y) * gridSize
    corners (4).x := (ind mod grids.y) * gridSize + gridSize
    corners (4).y := (ind div grids.y) * gridSize

    for i : 1 .. 4
	dirs (i).x := x - corners (i).x
	dirs (i).y := y - corners (i).y
    end for

    result dirs
end IntDirs

function influence (dist, grad : Vector2) : real
    result grad.x * dist.x + grad.y * dist.y
end influence

for g : 1 .. upper (gradients)
    var dir : Vector2 := GetGrad
    gradients (g) := dir
end for

function Value (x, y : int) : real
    var dots : array 1 .. 4 of real
    var dirs : array 1 .. 4 of Vector2
    dirs := IntDirs (x, y)
    for i : 1 .. 4
	dots (i) := Dot (gradients (GridIndex (x, y)), dirs (i))
    end for
    
    var fracX : real := gridSize - (x - x div gridSize * gridSize)
    var fracY : real := gridSize - (y - y div gridSize * gridSize)
    
    var AB : real := dots(1) + fracX * (dots(2) - dots(1))
    var CD : real := dots(3) + fracX * (dots(4) - dots(3))
    
    result abs((AB + fracY * (CD - AB)))
    
    %result Rand.Real
end Value

for x : 1 .. gridSize * grids.x div 1
    for y : 1 .. gridSize * grids.y div 1
	Draw.Dot (x, y, (15 * Value (x, y) + 16) div 1 mod 16 + 16)
    end for
end for

for g : 1 .. upper (gradients)
    var dir : Vector2 := gradients (g)
    var x : int := g mod grids.x div 1 * gridSize
    var y : int := g div grids.x * gridSize
    %Draw.Line (x, y, x + dir.x * lineLength div 1, y + dir.y * lineLength div 1, 44)
    %Draw.FillOval (x + dir.x * lineLength div 1, y + dir.y * lineLength div 1, 3, 3, 44)
    %Draw.FillOval (x, y, 2, 2, 44)
end for

for x : 1 .. gridSize * grids.x div 1 by gridSize
    for y : 1 .. gridSize * grids.y div 1 by gridSize
	var dirs : array 1 .. 4 of Vector2
	dirs := IntDirs (x - gridSize div 2, y- gridSize div 2)
	for i : 1 .. 4
	
	%put dirs(i).x, " / ", dirs(i).y
	
	Draw.Line(x,y, x + dirs(i).x div 1, y + dirs(i).y div 1, 40)
	end for
    end for
end for
