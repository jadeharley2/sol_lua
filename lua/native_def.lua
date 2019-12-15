if true then return end
--globals
debug = {}
console = {}
addons = {}
module = {}
bor = function() end
band = function() end
bnot = function() end
br = function() end
bl = function() end
---create new vector
---@return Vector
---@param x number
---@param y number
---@param z number
Vector = function(x, y, z) end
---create new plane
---@return Plane
Plane = function() end
---lerp between vectors
---@return Vector
---@param a Vector
---@param b Vector
---@param amount number
LerpVector = function(a, b, amount) end
---clamp vector values
---@return Vector
---@param n Vector
---@param min Vector
---@param max Vector
ClampVector = function(n, min, max) end
matrix = {}
Point = function() end
---lerp between vectors
---@return Point
---@param a Point
---@param b Point
---@param amount number
LerpPoint = function(a, b, amount) end
---clamp vector values
---@return Point
---@param n Point
---@param min Point
---@param max Point
ClampPoint = function(n, min, max) end
ColorToHSV = function() end
HSVToColor = function() end
engine = {}
ClipboardGetText = function() end
ClipboardSetText = function() end
---client-server data transfer
network = {}
file = {}
input = {}
cstring = {}
CStringSub = function() end
CStringLen = function() end
CStringSplit = function() end
zlib = {}
---create oriented bounding box
BoundingBox = function() end
json = {}
test_component = {}
ents = {}
---add node to origin list
---@param node Entity
AddOrigin = function(node) end
---remove node from origin list
---@param node Entity
RemoveOrigin = function(node) end
---get all origin nodes
---@return table
GetOriginList = function() end
---set renderer current camera
---@param camera Camera
SetCamera = function(camera) end
---get renderer current camera
---@return Camera
GetCamera = function() end
---get 3d perlin noise value at pos
---@return number
---@param position Vector
PerlinNoise = function(position) end
---get current system time of day in seconds
---@return number
CurTime = function() end
---checks if entity is valid(not null && not despawned)
---@param node Entity
IsValidEnt = function(node) end
procedural = {}
minecraft = {}
constraint = {}
render = {}
panel = {}
GetViewportSize = function() end
ispanel = function() end
framecapture = {}
flowbase = {}
vr = {}
generator = {}
forms = {}
item = {}
---gets local player actor
---@return Entity
LocalPlayer = function() end
---get entity by id
---@return Entity
Entity = function() end
classifier = {}

--libraries
debug = {
    FindMetaTable = function() end,
    GetAPIInfo = function() end,
    AddAPIInfo = function() end,
    UpdateDefFile = function() end,
    Timer = function() end,
    Msg = function() end,
    ConsoleGet = function() end,
    ConsoleLastUpdate = function() end,
    GetHashString = function() end,
    Delayed = function() end,
    DelayedTimer = function() end,
    ProfilerBegin = function() end,
    ProfilerEnd = function() end,
    time = function() end,
    ShapeCreate = function() end,
    ShapeDestroy = function() end,
    ShapeBoxCreate = function() end,
    ShapePrimCreate = function() end,
    WebLoad = function() end,
    ReqFile = function() end,
    PC_Orientation = function() end,
}
console = {
    AddCmd = function() end,
    Call = function() end,
    Set = function() end,
    AutoComplete = function() end,
}
addons = {
    ---enable addon
    ---@param id name
    Enable = function(id) end,
    ---disable addon
    ---@param id name
    Disable = function(id) end,
    ---get loaded addons
    ---@return table
    GetLoaded = function() end,
    ---get installed addons
    ---@return table
    GetAll = function() end,
}
module = {
    Require = function() end,
}
matrix = {
    ---identity matrix
    ---@return Matrix
    Identity = function() end,
    ---scaling matrix
    ---@return Matrix
    ---@param amount number
    Scaling = function(amount) end,
    ---scaling matrix
    ---@return Matrix
    ---@param amount Vector
    Translation = function(amount) end,
    ---scaling matrix
    ---@return Matrix
    ---@param p number
    ---@param y number
    ---@param r number
    Rotation = function(p, y, r) end,
    ---rotate around axis matrix
    ---@return Matrix
    ---@param axis Vector
    ---@param degrees number
    AxisRotation = function(axis, degrees) end,
    ---lerp matrices
    Lerp = function() end,
    ---create LookAt matrix
    LookAt = function() end,
    ---create LookAt matrix
    Perspective = function() end,
}
engine = {
    Exit = function() end,
    PausePhysics = function() end,
    ResumePhysics = function() end,
    ---deprecated
    SaveAvailable = function() end,
    GetStateList = function() end,
    LoadState = function() end,
    SaveState = function() end,
    ClearState = function() end,
    SaveNode = function() end,
    LoadNode = function() end,
    LoadMap = function() end,
    DeclareVariable = function() end,
    ---send entity by string address
    ---@param node Entity
    ---@param address string
    SendTo = function(node, address) end,
    SendToAnchor = function() end,
    Create = function() end,
    AddDEnumValue = function() end,
}
---client-server data transfer
network = {
    ---connect to server
    Connect = function() end,
    ---disconnect from server
    Disconnect = function() end,
    ---check connection
    IsConnected = function() end,
    ChatSay = function() end,
    CallServer = function() end,
    ---request control assign
    RequestAssignNode = function() end,
    RequestUnassignNode = function() end,
    CanBeControlled = function() end,
    ---get node assigned connection
    AssignedTo = function() end,
}
file = {
    Write = function() end,
    WriteLines = function() end,
    Read = function() end,
    ReadLines = function() end,
    GetFiles = function() end,
    GetDirectories = function() end,
    Exists = function() end,
    GetExtension = function() end,
    GetDirectory = function() end,
    GetFileName = function() end,
    GetFileNameWE = function() end,
    GetFileDependencies = function() end,
    GetFileTree = function() end,
    SetCustomReloadDirectory = function() end,
    GetLoadedAssets = function() end,
}
input = {
    WindowActive = function() end,
    MouseWheel = function() end,
    KeyPressed = function() end,
    CharPressed = function() end,
    leftMouseButton = function() end,
    rightMouseButton = function() end,
    middleMouseButton = function() end,
    getMousePosition = function() end,
    setMousePosition = function() end,
    GetKeyboardBusy = function() end,
    SetKeyboardBusy = function() end,
    getInterfaceMousePos = function() end,
    MouseIsHoveringAboveGui = function() end,
    SetCursorHidden = function() end,
    GetCursorHidden = function() end,
}
cstring = {
    sub = function() end,
    len = function() end,
    split = function() end,
    find = function() end,
    replace = function() end,
}
zlib = {
    deflate = function() end,
    inflate = function() end,
}
json = {
    ---from disk json to lua table
    ---@return table
    ---@param file string
    Read = function(file) end,
    ---from (lua table or memory json) to disk json
    ---@param file string
    ---@param data table
    Write = function(file, data) end,
    ---from disk json to memory json
    ---@return JSON
    ---@param file string
    Load = function(file) end,
    ---from lua table to memory json
    ---@return JSON
    ---@param data table
    ToJson = function(data) end,
    ---from memory json to lua table
    ---@return table
    ---@param data JSON
    FromJson = function(data) end,
    ---from string to memory json
    ---@return JSON
    ---@param text string
    FromText = function(text) end,
}
test_component = {
    Create = function() end,
    AddType = function() end,
    GetType = function() end,
    ---add component info table
    ---@param type string
    ---@param info table
    AddInfo = function(type, info) end,
    ---get component info table
    ---@return table
    ---@param type string
    GetInfo = function(type) end,
}
ents = {
    ---get all loaded nodes
    ---@return table
    GetAll = function() end,
    ---get node by its global name
    ---@return Entity
    ---@param name string
    GetByName = function(name) end,
    ---get node by seed
    ---@return Entity
    ---@param seed number
    GetById = function(seed) end,
    ---create new node
    ---@return Entity
    ---@param type string
    Create = function(type) end,
    ---create new universe [deprecated]
    ---@return Entity
    CreateUniverse = function() end,
    ---create new camera node (special)
    ---@return Camera
    CreateCamera = function() end,
    ---spawn preset in node
    ---@param path string
    SpawnPreset = function(path) end,
    ---add node type
    ---@param name string
    ---@param metatable table
    AddType = function(name, metatable) end,
    ---get node type by name
    ---@return table
    ---@param name string
    GetType = function(name) end,
    ---get all SENT types
    ---@return table
    GetTypeList = function() end,
    ---reload node type by name
    ---@param name string
    LoadType = function(name) end,
    ---convert data to entity
    ---@return Entity
    ---@param data JSON
    FromData = function(data) end,
    ---change SENT type
    ---@return Entity
    ---@param ent Entity
    ---@param Newtype string
    ChangeType = function(ent, Newtype) end,
    ---create spatial link
    ---@param left Entity
    ---@param right Entity
    ---@param world Matrix
    CreateWorldLink = function(left, right, world) end,
}
procedural = {
    ---...
    ---@return ProceduralBuilderScriptAdapter
    Builder = function() end,
}
minecraft = {
    ---...
    ---@return McRegion
    ---@param path string
    LoadRegion = function(path) end,
    ---...
    ---@return McRegion
    ---@param path string
    LoadRegionAsync = function(path) end,
}
constraint = {
    Ballsocket = function() end,
    RevoluteAngular = function() end,
    NoRotation = function() end,
    DistanceJoint = function() end,
    DistanceLimit = function() end,
    SwivelHingeAngular = function() end,
    Twist = function() end,
    Weld = function() end,
    NoCollide = function() end,
    GetConstraints = function() end,
    GetConstrainedEnts = function() end,
    Break = function() end,
}
render = {
    SetGroupMode = function() end,
    SetGroupBounds = function() end,
    GetGroupPerfomance = function() end,
    GetTypePerfomance = function() end,
    ---@return RenderParameters
    RenderParameters = function() end,
    ---@return RenderParameters
    CurrentRenderParameters = function() end,
    ---@return RenderParameters
    GlobalRenderParameters = function() end,
    SetGlobalRenderParameters = function() end,
    SetRenderBounds = function() end,
    SetCurrentEnvmap = function() end,
    ClearShadowMaps = function() end,
    DCISetEnabled = function() end,
    DCIRequestRedraw = function() end,
    DCIGetDrawable = function() end,
    GetDrawablesByScreenBox = function() end,
}
panel = {
    Create = function() end,
    AddType = function() end,
    GetType = function() end,
    GetTypeList = function() end,
    LoadType = function() end,
    GetLocalPos = function() end,
    GetTopElement = function() end,
    SetCursor = function() end,
}
framecapture = {
    ---...
    ---@param value Action`1
    add_OnFrameCaptured = function(value) end,
    ---...
    ---@param value Action`1
    remove_OnFrameCaptured = function(value) end,
    ---...
    ---@param dirname string
    ---@param fps number
    StartCapture = function(dirname, fps) end,
    ---...
    StopCapture = function() end,
    ---callback args: obj:number
    ---@param callback Function
    SetOnFrameCaptured = function(callback) end,
}
flowbase = {
    ---...
    ---@return Flow
    ---@param n JsonNode
    CompileJson = function(n) end,
    ---...
    ---@return Flow
    ---@param fn string
    CompileFile = function(fn) end,
    ---...
    ---@return JsonNode
    ---@param name string
    GetMethodInfo = function(name) end,
    ---...
    ---@return JsonNode
    GetMethodList = function() end,
}
vr = {
    IsEnabled = function() end,
    GetHead = function() end,
    GetEyeL = function() end,
    GetEyeR = function() end,
    GetCurrentEye = function() end,
}
generator = {
    Add = function() end,
    Reload = function() end,
}
forms = {
    GetForm = function() end,
    GetList = function() end,
    GetData = function() end,
    SetData = function() end,
    Create = function() end,
}
item = {
    ---...
    ---@return Item
    ---@param formid string
    Spawn = function(formid) end,
}
classifier = {
    ---...
    ---@return ClassifierPipe
    CLPipe = function() end,
}

--classes
---@class Timer
meta_Timer = {
    Start = function() end,
    Stop = function() end,
    Reset = function() end,
    Restart = function() end,
    ElapsedMs = function() end,
    ElapsedTicks = function() end,
    IsRunning = function() end,
}
---@class Task
meta_Task = {
    Stop = function() end,
    IsRunning = function() end,
}
---@class Vector
meta_Vector = {
    ---vector length
    ---@return number
    Length = function() end,
    ---squared vector length
    ---@return number
    LengthSquared = function() end,
    ---normalized vector
    ---@return Vector
    Normalized = function() end,
    ---distance between two vectors
    ---@return number
    ---@param other Vector
    Distance = function(other) end,
    ---squared distance between two vectors
    ---@return number
    ---@param other Vector
    DistanceSquared = function(other) end,
    ---dot product
    ---@return number
    ---@param other Vector
    Dot = function(other) end,
    ---cross product
    ---@return Vector
    ---@param other Vector
    Cross = function(other) end,
    ---rotate vector by pyr
    ---@return Vector
    ---@param pyr_degrees Vector
    Rotate = function(pyr_degrees) end,
    ---angle to second vector
    ---@return number
    ---@param other Vector
    Angle = function(other) end,
    ---transform coordinate Vector by Matrix
    ---@return Vector
    ---@param transformation Matrix
    TransformC = function(transformation) end,
    ---transform normal Vector by Matrix
    ---@return Vector
    ---@param transformation Matrix
    TransformN = function(transformation) end,
    ---to {x,y,z}
    ---@return Table
    ToTable = function() end,
}
---@class Plane
meta_Plane = {
    Intersect = function() end,
    Project = function() end,
    DotCoordinate = function() end,
}
---@class Matrix
meta_Matrix = {
    ---transpose matrix
    ---@return Matrix
    Transposed = function() end,
    ---invert matrix
    ---@return Matrix
    Inversed = function() end,
    ---mirror matrix
    ---@return Matrix
    Mirrored = function() end,
    ---forward direction
    ---@return Vector
    Forward = function() end,
    ---backward direction
    ---@return Vector
    Backward = function() end,
    ---right direction
    ---@return Vector
    Right = function() end,
    ---left direction
    ---@return Vector
    Left = function() end,
    ---up direction
    ---@return Vector
    Up = function() end,
    ---down direction
    ---@return Vector
    Down = function() end,
    ---translation
    ---@return Vector
    Position = function() end,
    ---rotation radians
    ---@return Vector
    Rotation = function() end,
}
---@class Client
meta_Client = {
    Table = {},
    Tag = {},
    GetName = function() end,
    SendStartupNodes = function() end,
    SendLua = function() end,
    SendMessage = function() end,
    SendFile = function() end,
    SendFiles = function() end,
    SendCurrentState = function() end,
    Call = function() end,
    Id = function() end,
    LoadAddress = function() end,
    AssignNode = function() end,
    UnassignNode = function() end,
}
---@class Compression
meta_Compression = {
}
---@class Collidable
meta_Collidable = {
    ---containment test
    ---@return number
    ---@param target any
    Contains = function(target) end,
}
---@class JSON
meta_JSON = {
    ---convert to text
    ---@return string
    ToText = function() end,
    ---read json node
    ---@return any
    ---@param key string
    Read = function(key) end,
    ---write json node
    ---@param key string
    ---@param value any
    Write = function(key, value) end,
    ---add json node
    ---@param value any
    Add = function(value) end,
    ---get node type
    ---@return number
    Type = function() end,
    ---clear node
    Clear = function() end,
}
---@class Component
meta_Component = {
    ---enable/disable component
    ---@param enabled boolean
    Enable = function(enabled) end,
    ---is component enabled
    ---@return boolean
    IsEnabled = function() end,
    ---component type
    ---@return number
    GetType = function() end,
    ---component type
    ---@return string
    GetTypename = function() end,
    ---component parent node
    ---@return Entity
    GetNode = function() end,
}
---scripted component
---@class SComponent
meta_SComponent = {
    GetTable = function() end,
    SetTable = function() end,
}
---@class Entity
meta_Entity = {
    ---spawn node
    Spawn = function() end,
    ---remove node
    Despawn = function() end,
    ---spawn new node and add it to current world state
    Create = function() end,
    ---despwan and remove node from current world state
    Destroy = function() end,
    ---invoke onentry function
    Enter = function() end,
    ---invoke onleave function
    Leave = function() end,
    ---eject node from its parent
    Eject = function() end,
    ---despawn all children nodes
    UnloadSubs = function() end,
    ---convert entity to data
    ---@return JSON
    ToData = function() end,
    ---add tag to node
    ---@param type number
    AddTag = function(type) end,
    ---remove tag from node
    ---@param type number
    RemoveTag = function(type) end,
    ---check tag on node
    ---@return boolean
    ---@param type number
    HasTag = function(type) end,
    ---get list of node tags
    ---@return table
    GetTags = function() end,
    ---copy tags to target
    ---@param target Entity
    CopyTags = function(target) end,
    ---add component to node
    ---@return Component
    ---@param type number
    AddComponent = function(type) end,
    ---remove given component from node
    ---@param component Component
    RemoveComponent = function(component) end,
    ---remove all components of type from node
    ---@param type number
    RemoveComponents = function(type) end,
    ---get first component of type from node
    ---@return Component
    ---@param type number
    GetComponent = function(type) end,
    ---get all node components
    ---@return Component
    GetComponents = function() end,
    ---add event listener function for event type
    ---@param type number
    ---@param name string
    ---@param method function
    AddEventListener = function(type, name, method) end,
    ---remove event listener function for event type 
    ---@param type number
    ---@param name string
    RemoveEventListener = function(type, name) end,
    ---send event of type to node with given arguments
    ---@return any
    ---@param type number
    ---@param ... any
    SendEvent = function(type, ...) end,
    AddNativeEventListener = function() end,
    RemoveNativeEventListener = function() end,
    ---emit sound from node
    ---@param soundpath string
    ---@param volume number
    ---@param pitch number
    EmitSound = function(soundpath, volume, pitch) end,
    ---emit sound from node
    ---@param soundpath string
    ---@param volume number
    ---@param pitch number
    EmitSoundLoop = function(soundpath, volume, pitch) end,
    ---get node lua type
    ---@return string
    GetClass = function() end,
    ---get node hierarchy children
    ---@return table
    GetChildren = function() end,
    ---get node children by name
    ---@return Entity
    ---@param name String
    ---@param returnmany boolean
    ---@param recursive boolean
    GetByName = function(name, returnmany, recursive) end,
    ---get node parent of given node type
    ---@return Entity
    ---@param type number
    GetParentWith = function(type) end,
    ---get node parent with given flag
    ---@return Entity
    ---@param flag number
    GetParentWithFlag = function(flag) end,
    ---get node parent with given component type
    ---@return Entity  Component
    ---@param flag number
    GetParentWithComponent = function(flag) end,
    ---get node hierarchy
    ---@return table
    GetHierarchy = function() end,
    ---checks if target has this node in its hierarchy
    ---@return bool
    IsParentOf = function() end,
    ---get node's universe
    ---@return Entity
    GetTop = function() end,
    ---node seed
    Seed = {},
    ---node name
    Name = {},
    ---node global name
    GlobalName = {},
    ---node parent
    Parent = {},
    ---node absolute metric size
    Sizepower = {},
    ---node position relative to parent
    Pos = {},
    ---metric node position relative to parent
    AbsPos = {},
    ---node angle relative to parent
    Ang = {},
    ---node scale relative to its AMS
    Scale = {},
    ---node position, rotation and scale from matrix
    World = {},
    ---node lua table
    Table = {},
    ---node parameter (VARTYPE_*)
    Parameter = {},
    ---load mode 
    LoadMode = {},
    ---do not save flag
    Donotsave = {},
    ---copy params to target
    ---@param target Entity
    CopyParameters = function(target) end,
    ---does not go away with parent node
    SelfContained = {},
    Atransform = {},
    ---enables position based parent change check
    UpdateSpace = {},
    ---enables in/out transition for other nodes
    SpaceEnabled = {},
    ---enables Think() calls
    Updating = {},
    ---enables children cleanup on Exit() call
    UnloadOnExit = {},
    ---networked double by given key
    NWDouble = {},
    ---networked vector by given key
    NWVector = {},
    ---get other node coordinates in this node coordinate system
    ---@return Vector
    ---@param target Entity
    GetLocalCoordinates = function(target) end,
    ---get other node world matrix in this node coordinate system
    ---@return Matrix
    ---@param target Entity
    GetLocalSpace = function(target) end,
    ---get distance to other node in metres
    ---@return number
    ---@param target Entity
    GetDistance = function(target) end,
    ---get distance to other node in metres^2
    ---@return number
    ---@param target Entity
    GetDistanceSq = function(target) end,
    ---get forward(X-) direction from node rotation
    ---@return Vector
    Forward = function() end,
    ---get right(Z+) direction from node rotation
    ---@return Vector
    Right = function() end,
    ---get up(Y+) direction from node rotation
    ---@return Vector
    Up = function() end,
    ---modify node angles with rotation around given axis and angle
    ---@param axis Vector
    ---@param angle number
    RotateAroundAxis = function(axis, angle) end,
    ---modify node angles with rotation around given axis and angle in inverse
    ---@param axis Vector
    ---@param angle number
    TRotateAroundAxis = function(axis, angle) end,
    ---set node angles to 'look at node' rotation
    ---@param target Entity
    LookAt = function(target) end,
    ---copy angle from other node
    ---@param target Entity
    CopyAng = function(target) end,
    ---@return Matrix
    GetMatrixAng = function() end,
    ---prints node hierarchy to console
    PrintHierarchy = function() end,
    ---update all world matrices
    UpdateWorld = function() end,
    ---perform simple raytrace in parent node space from node position and given direction
    ---@return Vector
    ---@param direction Vector
    ---@param filter table
    Trace = function(direction, filter) end,
}
---@class Constraint
meta_Constraint = {
    GetType = function() end,
    Break = function() end,
}
---render parameters
---@class RenderParameters
meta_RenderParameters = {
    ---triangles cull direction
    CullMode = {},
    ---clip plane
    ---@param enabled boolean
    ---@param normal Vector
    ---@param distance number
    SetClipPlane = function(enabled, normal, distance) end,
    ---set render group sequence
    SetRenderGroup = function() end,
    ---set render group sequence
    SetRenderGroups = function() end,
}
---@class Panel
meta_Panel = {
    Add = function() end,
    Remove = function() end,
    Replace = function() end,
    Clear = function() end,
    Show = function() end,
    Close = function() end,
    GetTop = function() end,
    IsOpened = function() end,
    Dock = {},
    GetScreenPos = function() end,
    GetLocalCursorPos = function() end,
    GetChildren = function() end,
    GetTotalScaleMul = function() end,
    CanRaiseMouseEvents = {},
    Table = {},
    Parent = {},
    Pos = {},
    Rotation = {},
    Size = {},
    MinSize = {},
    ScaleMul = {},
    Bounds = {},
    Color = {},
    Alpha = {},
    Visible = {},
    Text = {},
    TextColor = {},
    Font = {},
    TextOnly = {},
    TextAlignment = {},
    TextCutMode = {},
    Multiline = {},
    LineHeight = {},
    LineSpacing = {},
    Autowrap = {},
    Texture = {},
    TextureScale = {},
    AlignTo = function() end,
    UpdateLayout = function() end,
    ClipEnabled = {},
    State = {},
    AddState = function() end,
    AddStates = function() end,
    Anchors = {},
    Padding = {},
    Margin = {},
    AutoSize = {},
    Page = {},
    GetPageCount = function() end,
    SetUseGlobalScale = function() end,
    SetCurve = function() end,
    EndColor = {},
    AddPoint = function() end,
    RemovePoint = function() end,
    ClearPoints = function() end,
    GetPoints = function() end,
}

--enumerations
EVENT_ANY = 1
EVENT_UPDATE = 10
EVENT_SPAWN = 11
EVENT_DESPAWN = 12
EVENT_ENTER = 13
EVENT_LEAVE = 14
EVENT_TOUCH = 15
EVENT_USE = 16
EVENT_LOAD = 17
EVENT_PARENT_CHANGED = 101
EVENT_CHILD_NEW = 110
EVENT_PARTITION_CREATE = 121
EVENT_PARTITION_COLLAPSE = 122
EVENT_PARTITION_DESTROY = 123
EVENT_GENERATOR_SETUP = 131
EVENT_GENERATOR_FINISHED = 135
EVENT_MOVE_START = 210
EVENT_MOVE_END = 211
EVENT_RENDERER_PREDRAW = 310
EVENT_RENDERER_POSTDRAW = 311
EVENT_RENDERER_PREDRAW_TARGET = 312
EVENT_RENDERER_FINISH = 320
EVENT_PHYSICS_CONTACT_CREATED = 401
EVENT_PHYSICS_CONTACT_REMOVED = 402
EVENT_PHYSICS_PAIR_TOUCHED = 411
EVENT_PHYSICS_COLLISION_STARTED = 412
EVENT_PHYSICS_COLLISION_ENDED = 413
EVENT_TRIGGER_TOUCH_START = 421
EVENT_TRIGGER_TOUCH_END = 422
EVENT_HEIGHTMAP_DATA_RECEIVED = 501
EVENT_GLOBAL_INIT = 9002
EVENT_GLOBAL_UPDATE = 9003
EVENT_GLOBAL_PREDRAW = 9004
EVENT_GLOBAL_DRAW = 9005
EVENT_GLOBAL_POSTDRAW = 9006
EVENT_INPUT_KEYDOWN = 9011
EVENT_INPUT_KEYUP = 9012
EVENT_INPUT_MOUSEDOWN = 9013
EVENT_INPUT_MOUSEUP = 9014
EVENT_INPUT_MOUSEWHEEL = 9015
EVENT_WINDOW_DRAGOVER = 10020
EVENT_WINDOW_DRAGDROP = 10021
EVENT_ANTRSYS_STATE = 332134
EVENT_EQUIP = 331011
EVENT_UNEQUIP = 331012
EVENT_UNEQUIPALL = 331013
EVENT_UNEQUIPSLOT = 331014
EVENT_DAMAGE = 321001
EVENT_HEALTH_CHANGED = 321002
EVENT_MAXHEALTH_CHANGED = 321003
EVENT_DEATH = 321004
EVENT_RESPAWN = 321005
EVENT_ITEM_TRANSFER = 8266
EVENT_ITEM_ADDED = 8267
EVENT_ITEM_TAKEN = 8268
EVENT_ITEM_DROP = 8269
EVENT_ITEM_DESTROY = 8270
EVENT_CONTAINER_SYNC = 8271
EVENT_CONTAINER_SYNC_DATA = 8272
EVENT_WIRE_SIGNAL = 111234
EVENT_SET_VEHICLE = 80002
EVENT_EXIT_VEHICLE = 80003
EVENT_ACTOR_JUMP = 81007
EVENT_CHANGE_CHARACTER = 81008
EVENT_TOOL_DROP = 81011
EVENT_RESPAWN_AT = 82033
EVENT_STATE_CHANGED = 82034
EVENT_GIVE_ITEM = 82066
EVENT_PICKUP_ITEM = 82067
EVENT_PICKUP_TOOL = 82068
EVENT_PICKUP = 82069
EVENT_ABILITY_CAST = 83001
EVENT_EFFECT_APPLY = 83002
EVENT_GIVE_ABILITY = 83003
EVENT_TAKE_ABILITY = 83004
EVENT_GESTURE_START = 83012
EVENT_GESTURE_END = 83013
EVENT_TASK_BEGIN = 84001
EVENT_TASK_RESET = 84009
EVENT_LERP_HEAD = 85001
EVENT_LOOK_AT = 85002
EVENT_SET_AI = 85011
EVENT_TOOL_FIRE = 90901
EVENT_SELECT_OPTION = 3322001
EVENT_EFFECT_BEGIN = 334201
EVENT_EFFECT_END = 334201
EVENT_INTERACT = 101032
EVENT_EDITOR_MOVE = 224980
EVENT_EDITOR_ROTATE = 224981
EVENT_EDITOR_SCALE = 224982
EVENT_EDITOR_COPY = 224983
EVENT_EDITOR_REMOVE = 224984
EVENT_DIALOG_START = 3332221
EVENT_DIALOG_END = 3332222

NTYPE_NONE = 0
NTYPE_GALAXY = 1100
NTYPE_STARSYSTEM = 1101
NTYPE_STAR = 1110
NTYPE_NEUTRONSTAR = 1111
NTYPE_BLACKHOLE = 1112
NTYPE_PLANET = 1120
NTYPE_MOON = 1130
NTYPE_ASTEROID = 1140

CTYPE_NONE = 0
CTYPE_VARIABLES = 21
CTYPE_EVENTS = 22
CTYPE_TIME = 50
CTYPE_DRAWABLE = 100
CTYPE_PARTICLESYSTEM = 101
CTYPE_PARTICLE = 102
CTYPE_MODEL = 103
CTYPE_SKYBOX = 104
CTYPE_SURFACE = 105
CTYPE_VOLUME = 106
CTYPE_SPRITETEXT = 107
CTYPE_DYNAMICMESH = 108
CTYPE_PARTICLESYSTEM2 = 109
CTYPE_CHUNKTERRAIN = 110
CTYPE_ATMOSPHERE = 111
CTYPE_SURFACEMOD = 112
CTYPE_EDITABLEMESH = 113
CTYPE_SHADOW = 120
CTYPE_CAMERA = 121
CTYPE_CUBEMAP = 122
CTYPE_INTERFACE = 123
CTYPE_HEIGHTMAP = 125
CTYPE_NAVIGATION = 127
CTYPE_LIGHT = 130
CTYPE_ORIGIN = 131
CTYPE_PARTITION2D = 201
CTYPE_PARTITION3D = 202
CTYPE_PROCEDURAL = 211
CTYPE_PROCGEN = 212
CTYPE_PHYSSPACE = 220
CTYPE_PHYSOBJ = 222
CTYPE_STATICCOLLISION = 223
CTYPE_PHYSMESH = 224
CTYPE_PHYSACTOR = 230
CTYPE_PHYSCOMPOUND = 231
CTYPE_PHYSTRIGGER = 232
CTYPE_WHEELEDVEHICLE = 233
CTYPE_ORBIT = 250
CTYPE_CONSTROT = 251
CTYPE_VELOCITY = 252
CTYPE_PATH = 253
CTYPE_PATHFOLLOW = 254
CTYPE_MESHRENDER = 261
CTYPE_MESH = 262
CTYPE_MAPDATA = 301
CTYPE_STORAGEB = 310
CTYPE_EQUIPMENT = 1324
CTYPE_HEALTH = 3414
CTYPE_STORAGE = 1314
CTYPE_VENDOR = 3240
CTYPE_WIREIO = 1315
CTYPE_ANTR_SYSTEMS = 3244

VARTYPE_TYPE = 81
VARTYPE_TYPENAME = 82
VARTYPE_SEED = 83
VARTYPE_ABSSIZE = 91
VARTYPE_NAME = 92
VARTYPE_GENERATOR = 93
VARTYPE_ARCHETYPE = 94
VARTYPE_POSITION = 101
VARTYPE_ROTATION = 102
VARTYPE_SCALE = 103
VARTYPE_COLOR = 104
VARTYPE_MASS = 105
VARTYPE_ALBEDO = 106
VARTYPE_RADIUS = 107
VARTYPE_TEMPERATURE = 108
VARTYPE_BRIGHTNESS = 109
VARTYPE_AMOUNT = 110
VARTYPE_MODEL = 111
VARTYPE_MODELWORLD = 112
VARTYPE_MODELSCALE = 113
VARTYPE_MODELDATA = 114
VARTYPE_ICON = 118
VARTYPE_SLOT = 119
VARTYPE_STATE = 121
VARTYPE_DIVPOWER = 201
VARTYPE_GRAVITY = 401
VARTYPE_VELOCITY = 402
VARTYPE_ANGVELOCITY = 403
VARTYPE_ORBIT = 501
VARTYPE_ORBIT_DATA = 502
VARTYPE_ATMOSPHERE = 503
VARTYPE_ATMOSPHERE_DATA = 504
VARTYPE_HYDROSPHERE = 505
VARTYPE_LUAENTTYPE = 800
VARTYPE_CHARACTER = 811
VARTYPE_FORM = 812
VARTYPE_HEALTH = 821
VARTYPE_MAXHEALTH = 822
VARTYPE_VIEWTARGET = 901
VARTYPE_BIOME = 911
VARTYPE_SCRIPTDATA = 1000
VARTYPE_EQUIPMENT = 88020
VARTYPE_STORAGE = 88010
VARTYPE_MINLEVEL = 1210001
VARTYPE_MAXLEVEL = 1210002
VARTYPE_SURFADD = 1210003
VARTYPE_SURFMUL = 1210004
VARTYPE_SURFMODE = 1210005
VARTYPE_SURFMAP = 1210006
VARTYPE_VISIBLE = 321301

RENDERGROUP_NONE = 0
RENDERGROUP_DEEPSPACE = 100
RENDERGROUP_STARSYSTEM = 101
RENDERGROUP_PLANET = 102
RENDERGROUP_CURRENTPLANET = 103
RENDERGROUP_LOCAL = 104
RENDERGROUP_RINGS = 111
RENDERGROUP_OVERLAY = 200

TAG_ENTITY = 10
TAG_CHUNKNODE = 31
TAG_GALAXY = 110
TAG_SPIRAL_GALAXY = 111
TAG_IRREGULAR_GALAXY = 112
TAG_ROUND_GALAXY = 113
TAG_STARSYSTEM = 119
TAG_CELESTIAL_BODY = 120
TAG_STAR = 121
TAG_PLANET = 122
TAG_MOON = 123
TAG_ASTEROID = 124
TAG_PLANET_SURFACE = 131
TAG_PROP = 200
TAG_ACTOR = 210
TAG_MOUNT = 211
TAG_PLAYER = 1001
TAG_NPC = 1002
TAG_WEAPON = 1003
TAG_VEHICLE = 1004
TAG_USEABLE = 2001
TAG_STOREABLE = 2002
TAG_PHYSSIMULATED = 2003
TAG_SUPPRESSNETUPDATE = 4200
TAG_DATANEEDED = 11003
TAG_EDITORNODE = 11004
TAG_SELECTION_MENU = 3322002
TAG_REPL_FATIGUE = 10101
TAG_REPL_SLEEP = 10102

CGROUP_NONE = 0
CGROUP_DEFAULT_PHYSICS = 1
CGROUP_DEFAULT_STATICS = 2
CGROUP_NOCOLLIDE_PHYSICS = 3

KEYS_NONE = 0
KEYS_LBUTTON = 1
KEYS_RBUTTON = 2
KEYS_CANCEL = 3
KEYS_MBUTTON = 4
KEYS_XBUTTON1 = 5
KEYS_XBUTTON2 = 6
KEYS_BACK = 8
KEYS_TAB = 9
KEYS_LINEFEED = 10
KEYS_CLEAR = 12
KEYS_ENTER = 13
KEYS_RETURN = 13
KEYS_SHIFTKEY = 16
KEYS_CONTROLKEY = 17
KEYS_MENU = 18
KEYS_PAUSE = 19
KEYS_CAPSLOCK = 20
KEYS_CAPITAL = 20
KEYS_HANGULMODE = 21
KEYS_HANGUELMODE = 21
KEYS_KANAMODE = 21
KEYS_JUNJAMODE = 23
KEYS_FINALMODE = 24
KEYS_KANJIMODE = 25
KEYS_HANJAMODE = 25
KEYS_ESCAPE = 27
KEYS_IMECONVERT = 28
KEYS_IMENONCONVERT = 29
KEYS_IMEACCEPT = 30
KEYS_IMEACEEPT = 30
KEYS_IMEMODECHANGE = 31
KEYS_SPACE = 32
KEYS_PRIOR = 33
KEYS_PAGEUP = 33
KEYS_PAGEDOWN = 34
KEYS_NEXT = 34
KEYS_END = 35
KEYS_HOME = 36
KEYS_LEFT = 37
KEYS_UP = 38
KEYS_RIGHT = 39
KEYS_DOWN = 40
KEYS_SELECT = 41
KEYS_PRINT = 42
KEYS_EXECUTE = 43
KEYS_SNAPSHOT = 44
KEYS_PRINTSCREEN = 44
KEYS_INSERT = 45
KEYS_DELETE = 46
KEYS_HELP = 47
KEYS_D0 = 48
KEYS_D1 = 49
KEYS_D2 = 50
KEYS_D3 = 51
KEYS_D4 = 52
KEYS_D5 = 53
KEYS_D6 = 54
KEYS_D7 = 55
KEYS_D8 = 56
KEYS_D9 = 57
KEYS_A = 65
KEYS_B = 66
KEYS_C = 67
KEYS_D = 68
KEYS_E = 69
KEYS_F = 70
KEYS_G = 71
KEYS_H = 72
KEYS_I = 73
KEYS_J = 74
KEYS_K = 75
KEYS_L = 76
KEYS_M = 77
KEYS_N = 78
KEYS_O = 79
KEYS_P = 80
KEYS_Q = 81
KEYS_R = 82
KEYS_S = 83
KEYS_T = 84
KEYS_U = 85
KEYS_V = 86
KEYS_W = 87
KEYS_X = 88
KEYS_Y = 89
KEYS_Z = 90
KEYS_LWIN = 91
KEYS_RWIN = 92
KEYS_APPS = 93
KEYS_SLEEP = 95
KEYS_NUMPAD0 = 96
KEYS_NUMPAD1 = 97
KEYS_NUMPAD2 = 98
KEYS_NUMPAD3 = 99
KEYS_NUMPAD4 = 100
KEYS_NUMPAD5 = 101
KEYS_NUMPAD6 = 102
KEYS_NUMPAD7 = 103
KEYS_NUMPAD8 = 104
KEYS_NUMPAD9 = 105
KEYS_MULTIPLY = 106
KEYS_ADD = 107
KEYS_SEPARATOR = 108
KEYS_SUBTRACT = 109
KEYS_DECIMAL = 110
KEYS_DIVIDE = 111
KEYS_F1 = 112
KEYS_F2 = 113
KEYS_F3 = 114
KEYS_F4 = 115
KEYS_F5 = 116
KEYS_F6 = 117
KEYS_F7 = 118
KEYS_F8 = 119
KEYS_F9 = 120
KEYS_F10 = 121
KEYS_F11 = 122
KEYS_F12 = 123
KEYS_F13 = 124
KEYS_F14 = 125
KEYS_F15 = 126
KEYS_F16 = 127
KEYS_F17 = 128
KEYS_F18 = 129
KEYS_F19 = 130
KEYS_F20 = 131
KEYS_F21 = 132
KEYS_F22 = 133
KEYS_F23 = 134
KEYS_F24 = 135
KEYS_NUMLOCK = 144
KEYS_SCROLL = 145
KEYS_LSHIFTKEY = 160
KEYS_RSHIFTKEY = 161
KEYS_LCONTROLKEY = 162
KEYS_RCONTROLKEY = 163
KEYS_LMENU = 164
KEYS_RMENU = 165
KEYS_BROWSERBACK = 166
KEYS_BROWSERFORWARD = 167
KEYS_BROWSERREFRESH = 168
KEYS_BROWSERSTOP = 169
KEYS_BROWSERSEARCH = 170
KEYS_BROWSERFAVORITES = 171
KEYS_BROWSERHOME = 172
KEYS_VOLUMEMUTE = 173
KEYS_VOLUMEDOWN = 174
KEYS_VOLUMEUP = 175
KEYS_MEDIANEXTTRACK = 176
KEYS_MEDIAPREVIOUSTRACK = 177
KEYS_MEDIASTOP = 178
KEYS_MEDIAPLAYPAUSE = 179
KEYS_LAUNCHMAIL = 180
KEYS_SELECTMEDIA = 181
KEYS_LAUNCHAPPLICATION1 = 182
KEYS_LAUNCHAPPLICATION2 = 183
KEYS_OEMSEMICOLON = 186
KEYS_OEM1 = 186
KEYS_OEMPLUS = 187
KEYS_OEMCOMMA = 188
KEYS_OEMMINUS = 189
KEYS_OEMPERIOD = 190
KEYS_OEM2 = 191
KEYS_OEMQUESTION = 191
KEYS_OEM3 = 192
KEYS_OEMTILDE = 192
KEYS_OEM4 = 219
KEYS_OEMOPENBRACKETS = 219
KEYS_OEMPIPE = 220
KEYS_OEM5 = 220
KEYS_OEMCLOSEBRACKETS = 221
KEYS_OEM6 = 221
KEYS_OEMQUOTES = 222
KEYS_OEM7 = 222
KEYS_OEM8 = 223
KEYS_OEM102 = 226
KEYS_OEMBACKSLASH = 226
KEYS_PROCESSKEY = 229
KEYS_PACKET = 231
KEYS_ATTN = 246
KEYS_CRSEL = 247
KEYS_EXSEL = 248
KEYS_ERASEEOF = 249
KEYS_PLAY = 250
KEYS_ZOOM = 251
KEYS_NONAME = 252
KEYS_PA1 = 253
KEYS_OEMCLEAR = 254
KEYS_KEYCODE = 65535
KEYS_SHIFT = 65536
KEYS_CONTROL = 131072
KEYS_ALT = 262144
KEYS_MODIFIERS = -65536

CT_DISJOINT = 0
CT_CONTAINS = 1
CT_INTERSECTS = 2

BLEND_OPAQUE = 0
BLEND_ADD = 1
BLEND_SUBTRACT = 2
BLEND_ALPHA = 3

RASTER_DETPHSOLID = 0
RASTER_DETPHWIRE = 1
RASTER_NODETPHSOLID = 2
RASTER_NODETPHWIRE = 3

DEPTH_ENABLED = 0
DEPTH_DISABLED = 1
DEPTH_READ = 2
DEPTH_WRITE = 3
DEPTH_STENCIL_ENABLED = 4

RENDERMODE_DISABLED = -1
RENDERMODE_ENABLED = 0
RENDERMODE_BACKGROUND = 1

CULLMODE_NONE = 1
CULLMODE_FRONT = 2
CULLMODE_BACK = 3

RORDER_SKYBOX = -1
RORDER_SOLID = 0
RORDER_TRANSPARENT = 1
RORDER_EFFECT = 2

ALIGN_LEFT = 0
ALIGN_RIGHT = 1
ALIGN_TOP = 2
ALIGN_BOTTOM = 3
ALIGN_CENTER = 4
ALIGN_TOPLEFT = 5
ALIGN_TOPRIGHT = 6
ALIGN_BOTTOMLEFT = 7
ALIGN_BOTTOMRIGHT = 8

DOCK_NONE = -1
DOCK_RIGHT = 0
DOCK_LEFT = 1
DOCK_TOP = 2
DOCK_BOTTOM = 3
DOCK_FILL = 4

