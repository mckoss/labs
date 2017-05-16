E = 0.1;

WALL_THICKNESS = 5;

// 608 Bearing - weight = 10g;
BEARING_SLOP = -0.1;
BEARING_INNER = 8;
BEARING_OUTER = 22 + BEARING_SLOP;
BEARING_HEIGHT = 7;

// US Nickel - weight = 5g
COIN_SLOP = 0.3;
COIN_OUTER = 21.3 + COIN_SLOP;
COIN_HEIGHT = 1.9;
STACK_COUNT = 3;
STACK_HEIGHT = 1.9 * STACK_COUNT;

ARM_OUTER = COIN_OUTER + 1;

COIN_CENTER = BEARING_OUTER / 2 + WALL_THICKNESS + COIN_OUTER / 2;

function coinPoly() = circleArcPoints(ARM_OUTER / 2, -60, 240, 20);

function spinnerPoly() =
    let(arm = offsetPoints([0, COIN_CENTER], coinPoly()))
    concat(arm,
           rotatePoints(120, arm),
           rotatePoints(240, arm));

echo(spinnerPoly());

polygon(spinnerPoly());

function circleArcPoints(r, start, end, steps) =
  elipseArcPoints([r, 0], [0, r], start, end, steps);

function elipseArcPoints(a, b, start, end, steps) = [
    for (i = [0 : steps - 1]) 
    let (angle = (end - start) * i / steps + start)
      cos(angle) * a + sin(angle) * b
    ];

function offsetPoints(offset, points) = [
    for (i = [0: len(points) - 1])
        points[i] + offset
    ];

function rotatePoints(theta, points) = [
    let (R = [[cos(theta), -sin(theta)],
              [sin(theta), cos(theta)]])
    for (i = [0: len(points) - 1])
        R * points[i]
    ];
