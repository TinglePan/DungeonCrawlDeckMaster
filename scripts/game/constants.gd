extends Object
class_name Constants

const DEFAULT_DAMP_RATIO: float = 1.0
const EPSILON: float = 0.001
const MOUSE_CLICK_THRESHOLD: int = 200  # milliseconds
const MOUSE_HOLD_THRESHOLD: int = 500  # milliseconds
const MOUSE_CLICK_DISTANCE_THRESHOLD: float = 4.0
const MOUSE_DOUBLE_CLICK_THRESHOLD: int = 400  # milliseconds
const MOUSE_DRAG_DISTANCE_THRESHOLD: float = MOUSE_CLICK_DISTANCE_THRESHOLD
const MOUSE_DRAG_DELTA_TIME_THRESHOLD: int = 1000  # milliseconds
const SMOOTH_TIME_MOD: float = 0.2 # NOTE: I copied smooth damp from Unity, but it takes about 5x longer to converge, so I scale down smooth time to compensate
const DEFAULT_SMOOTH_TIME: float = 0.1
const DRAG_MOVE_SMOOTH_TIME: float = DEFAULT_SMOOTH_TIME
const DRAG_Z_INDEX: int = 1000