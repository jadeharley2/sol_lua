if true then return end
--globals
debug = {}
console = {}
---create global identifier
---@return Guid
---@param value string
Guid = function(value) end
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
---load texture from path
---@return Texture
---@param path string
---@param async boolean
LoadTexture = function(path, async) end
---create new texture
---@return Texture
---@param width number
---@param height number
---@param format number
---@param path string
CreateTexture = function(width, height, format, path) end
---create new rendertarget
---@return Texture
---@param width number
---@param height number
---@param id string
---@param type number
CreateRenderTarget = function(width, height, id, type) end
---resize rendertarget
---@param target Texture
---@param width number
---@param height number
ResizeRenderTarget = function(target, width, height) end
---create cubemap from 6 side textures
---@return Texture
---@param t1 string
---@param t2 string
---@param t3 string
---@param t4 string
---@param t5 string
---@param t6 string
EnvmapFromTextures = function(t1, t2, t3, t4, t5, t6) end
---set material property
---@param target Texture
---@param key string
---@param value any
SetMaterialProperty = function(target, key, value) end
---get material property
---@return any
---@param target Texture
---@param key string
GetMaterialProperty = function(target, key) end
---get properties
---@param target Texture
---@param keyvalues table
GetMaterialProperties = function(target, keyvalues) end
---load spritefont from path
---@return SpriteFont
---@param path string
LoadFont = function(path) end
file = {}
input = {}
---utf-16 string operations
cstring = {}
---[deprecated:use cstring.sub] trims boundary spaces from string
---@return string
---@param value string
CStringSub = function(value) end
---[deprecated:use cstring.len] gets string length in utf-16 characters
---@return number
---@param value string
CStringLen = function(value) end
---[deprecated:use cstring.split] split string by character
---@return string
---@param value string
---@param splitter string
---@param remove_empty boolean
CStringSplit = function(value, splitter, remove_empty) end
zlib = {}
---create oriented bounding box
BoundingBox = function() end
json = {}
---is value a json node?
---@return boolean
---@param value any
isjson = function(value) end
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
scriptgen = {}
forms = {}
item = {}
---gets local player actor
---@return Entity
LocalPlayer = function() end
---get entity by id
---@return Entity
Entity = function() end
classifier = {}
masterserver = {}
discord = {}

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
    GetHash = function() end,
    Delayed = function() end,
    DelayedTimer = function() end,
    ProfilerBegin = function() end,
    ProfilerEnd = function() end,
    time = function() end,
    ShapeCreate = function() end,
    ShapeDestroy = function() end,
    ShapeBoxCreate = function() end,
    ShapePrimCreate = function() end,
    ShapeLineCreate = function() end,
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
    ---@param id string
    Enable = function(id) end,
    ---disable addon
    ---@param id string
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
    GetStateImage = function() end,
    SaveNode = function() end,
    LoadNode = function() end,
    LoadMap = function() end,
    SetGameState = function() end,
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
    GetDirectoryRoots = function() end,
    GetFileRoots = function() end,
    GetFileTree = function() end,
    SetCustomReloadDirectory = function() end,
    GetLoadedAssets = function() end,
}
input = {
    ---is game window selected
    ---@return boolean
    WindowActive = function() end,
    ---current mouse wheel value
    ---@return number
    MouseWheel = function() end,
    ---is KEYS_* key pressed
    ---@return boolean
    ---@param key number
    KeyPressed = function(key) end,
    ---convert KEY_* to string
    ---@return string
    ---@param key number
    CharPressed = function(key) end,
    ---is input ACT_* action active
    ---@return boolean
    ---@param type number
    ActionActive = function(type) end,
    ---convert KEY_* to string representation
    ---@return string
    ---@param key number
    KeyData = function(key) end,
    ---get input configuration
    ---@return JSON
    GetActionMap = function() end,
    ---set input configuration
    ---@param configuration JSON
    SetActionMap = function(configuration) end,
    ---is left mouse button pressed
    ---@return boolean
    leftMouseButton = function() end,
    ---is right mouse button pressed
    ---@return boolean
    rightMouseButton = function() end,
    ---is mouse wheel button pressed
    ---@return boolean
    middleMouseButton = function() end,
    ---gets window mouse position
    ---@return Point
    getMousePosition = function() end,
    ---sets window mouse position
    ---@param position Point
    setMousePosition = function(position) end,
    ---get keyboard is busy flag
    ---@return boolean
    GetKeyboardBusy = function() end,
    ---set keyboard is busy flag
    ---@param value boolean
    SetKeyboardBusy = function(value) end,
    ---get is mouse busy 
    ---@return boolean
    GetMouseBusy = function() end,
    ---suppress interface mouse events
    ---@param value boolean
    SetMouseBusy = function(value) end,
    ---gets interface mouse position
    ---@return Vector
    getInterfaceMousePos = function() end,
    ---is cursor hovering above any gui element
    ---@return boolean
    MouseIsHoveringAboveGui = function() end,
    ---hide or show cursor
    ---@param hide boolean
    SetCursorHidden = function(hide) end,
    ---is cursor hidden
    ---@return boolean
    GetCursorHidden = function() end,
}
---utf-16 string operations
cstring = {
    ---trims boundary spaces from string
    ---@return string
    ---@param value string
    trim = function(value) end,
    ---trims trailing spaces from string
    ---@return string
    ---@param value string
    trimend = function(value) end,
    ---trims leading spaces from string
    ---@return string
    ---@param value string
    trimstart = function(value) end,
    ---gets substring
    ---@return string
    ---@param value string
    ---@param startindex number
    ---@param endindex number
    sub = function(value, startindex, endindex) end,
    ---gets string length in utf-16 characters
    ---@return number
    ---@param value string
    len = function(value) end,
    ---split string by character
    ---@return string
    ---@param value string
    ---@param splitter string
    ---@param remove_empty boolean
    split = function(value, splitter, remove_empty) end,
    ---get index of substring
    ---@return number
    ---@param value string
    ---@param sub string
    find = function(value, sub) end,
    ---replace all matches
    ---@return string
    ---@param value string
    ---@param search string
    ---@param replace string
    replace = function(value, search, replace) end,
    ---perform regex string escape
    ---@return string
    ---@param value string
    escape = function(value) end,
    ---perform regex string unescape
    ---@return string
    ---@param value string
    unescape = function(value) end,
    ---find and return regex matches
    ---@return string
    ---@param value string
    ---@param pattern string
    matches = function(value, pattern) end,
    ---find and replace regex matches
    ---@return string
    ---@param value string
    ---@param pattern string
    ---@param replacement string
    regreplace = function(value, pattern, replacement) end,
    ---trims boundary characters from string
    ---@return string
    ---@param value string
    ---@param chars string
    trimchars = function(value, chars) end,
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
    ---create new json dictionary node
    ---@return JSON
    Dict = function() end,
    ---create new json array node
    ---@return JSON
    Array = function() end,
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
    ---get all loaded worlds
    ---@return table
    GetWorlds = function() end,
    ---get node by its global name
    ---@return Entity
    ---@param name string
    GetByName = function(name) end,
    ---get node by seed
    ---@return Entity
    ---@param seed number
    GetById = function(seed) end,
    ---get node by identity
    ---@return Entity
    ---@param id Guid
    GetByGuid = function(id) end,
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
    ---create new panel
    ---@return Panel
    ---@param typename string
    ---@param state table
    ---@param parent Panel
    Create = function(typename, state, parent) end,
    ---add panel type
    ---@param typename string
    ---@param type table
    AddType = function(typename, type) end,
    ---get panel type from name
    ---@return Panel
    ---@param typename string
    GetType = function(typename) end,
    ---get panel typenames
    ---@return table
    GetTypeList = function() end,
    ---load panel type from file
    ---@param filename string
    LoadType = function(filename) end,
    ---project vector to screen
    ---@return Vector
    ---@param node Entity
    GetLocalPos = function(node) end,
    ---get panel under cursor
    ---@return Panel
    GetTopElement = function() end,
    ---set cursor type
    ---@param type number
    SetCursor = function(type) end,
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
scriptgen = {
    Add = function() end,
    Reload = function() end,
}
forms = {
    GetForm = function() end,
    GetList = function() end,
    GetData = function() end,
    SetData = function() end,
    CreateForm = function() end,
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
masterserver = {
    ---...
    ---@param callback Action`1
    GetServerlist = function(callback) end,
    ---...
    ---@param formid string
    ---@param callback Action`1
    GetForm = function(formid, callback) end,
    ---...
    ---@param callback Action`1
    GetFormlist = function(callback) end,
    ---...
    ---@param formid string
    ---@param data JsonNode
    UploadForm = function(formid, data) end,
}
discord = {
    ---...
    ---@return boolean
    get_IsActive = function() end,
    ---...
    ---@return Texture2D
    GetUserAvatar = function() end,
}

--classes
---@class Timer
meta_Timer = {
    ---@param self Timer
    Start = function(self) end,
    ---@param self Timer
    Stop = function(self) end,
    ---@param self Timer
    Reset = function(self) end,
    ---@param self Timer
    Restart = function(self) end,
    ---@param self Timer
    ElapsedMs = function(self) end,
    ---@param self Timer
    ElapsedTicks = function(self) end,
    ---@param self Timer
    IsRunning = function(self) end,
}
---@class Task
meta_Task = {
    ---@param self Task
    Stop = function(self) end,
    ---@param self Task
    IsRunning = function(self) end,
}
---@class Guid
meta_Guid = {
}
---@class Vector
meta_Vector = {
    ---vector length
    ---@return number
    ---@param self Vector
    Length = function(self) end,
    ---squared vector length
    ---@return number
    ---@param self Vector
    LengthSquared = function(self) end,
    ---normalized vector
    ---@return Vector
    ---@param self Vector
    Normalized = function(self) end,
    ---distance between two vectors
    ---@return number
    ---@param self Vector
    ---@param other Vector
    Distance = function(self, other) end,
    ---squared distance between two vectors
    ---@return number
    ---@param self Vector
    ---@param other Vector
    DistanceSquared = function(self, other) end,
    ---dot product
    ---@return number
    ---@param self Vector
    ---@param other Vector
    Dot = function(self, other) end,
    ---cross product
    ---@return Vector
    ---@param self Vector
    ---@param other Vector
    Cross = function(self, other) end,
    ---rotate vector by pyr
    ---@return Vector
    ---@param self Vector
    ---@param pyr_degrees Vector
    Rotate = function(self, pyr_degrees) end,
    ---angle to second vector
    ---@return number
    ---@param self Vector
    ---@param other Vector
    Angle = function(self, other) end,
    ---transform coordinate Vector by Matrix
    ---@return Vector
    ---@param self Vector
    ---@param transformation Matrix
    TransformC = function(self, transformation) end,
    ---transform normal Vector by Matrix
    ---@return Vector
    ---@param self Vector
    ---@param transformation Matrix
    TransformN = function(self, transformation) end,
    ---to {x,y,z}
    ---@return table
    ---@param self Vector
    ToTable = function(self) end,
    ---convert normal vector to angle vector
    ---@return Vector
    ---@param self Vector
    ---@param normal Vector
    ToAngle = function(self, normal) end,
}
---@class Plane
meta_Plane = {
    ---@param self Plane
    Intersect = function(self) end,
    ---@param self Plane
    Project = function(self) end,
    ---@param self Plane
    DotCoordinate = function(self) end,
}
---@class Matrix
meta_Matrix = {
    ---transpose matrix
    ---@return Matrix
    ---@param self Matrix
    Transposed = function(self) end,
    ---invert matrix
    ---@return Matrix
    ---@param self Matrix
    Inversed = function(self) end,
    ---mirror matrix
    ---@return Matrix
    ---@param self Matrix
    Mirrored = function(self) end,
    ---forward direction
    ---@return Vector
    ---@param self Matrix
    Forward = function(self) end,
    ---backward direction
    ---@return Vector
    ---@param self Matrix
    Backward = function(self) end,
    ---right direction
    ---@return Vector
    ---@param self Matrix
    Right = function(self) end,
    ---left direction
    ---@return Vector
    ---@param self Matrix
    Left = function(self) end,
    ---up direction
    ---@return Vector
    ---@param self Matrix
    Up = function(self) end,
    ---down direction
    ---@return Vector
    ---@param self Matrix
    Down = function(self) end,
    ---translation
    ---@return Vector
    ---@param self Matrix
    Position = function(self) end,
    ---rotation radians
    ---@return Vector
    ---@param self Matrix
    Rotation = function(self) end,
}
---@class Point
meta_Point = {
    ---vector2 length
    ---@return number
    ---@param self Point
    Length = function(self) end,
    ---squared vector2 length
    ---@return number
    ---@param self Point
    LengthSquared = function(self) end,
    ---normalized vector2
    ---@return Point
    ---@param self Point
    Normalized = function(self) end,
    ---distance between two vectors
    ---@return number
    ---@param self Point
    ---@param other Point
    Distance = function(self, other) end,
    ---squared distance between two vectors
    ---@return number
    ---@param self Point
    ---@param other Point
    DistanceSquared = function(self, other) end,
    ---dot product
    ---@return number
    ---@param self Point
    ---@param other Point
    Dot = function(self, other) end,
    ---to {x,y}
    ---@return table
    ---@param self Point
    ToTable = function(self) end,
}
---@class Client
meta_Client = {
    ---@return any
    ---@param self Client
    GetTable = function(self) end,
    ---@param self Client
    ---@param value any
    SetTable = function(self, value) end,
    ---@return any
    ---@param self Client
    GetTag = function(self) end,
    ---@param self Client
    ---@param value any
    SetTag = function(self, value) end,
    ---@param self Client
    GetName = function(self) end,
    ---@param self Client
    GetModel = function(self) end,
    ---@param self Client
    SendStartupNodes = function(self) end,
    ---@param self Client
    SendLua = function(self) end,
    ---@param self Client
    SendMessage = function(self) end,
    ---@param self Client
    SendFile = function(self) end,
    ---@param self Client
    SendFiles = function(self) end,
    ---@param self Client
    SendCurrentState = function(self) end,
    ---@param self Client
    Call = function(self) end,
    ---@param self Client
    Id = function(self) end,
    ---@param self Client
    LoadAddress = function(self) end,
    ---@param self Client
    AssignNode = function(self) end,
    ---@param self Client
    UnassignNode = function(self) end,
}
---@class Compression
meta_Compression = {
}
---@class Collidable
meta_Collidable = {
    ---containment test
    ---@return number
    ---@param self Collidable
    ---@param target any
    Contains = function(self, target) end,
}
---@class JSON
meta_JSON = {
    ---convert to text
    ---@return string
    ---@param self JSON
    ToText = function(self) end,
    ---read json node
    ---@return any
    ---@param self JSON
    ---@param key string
    Read = function(self, key) end,
    ---write json node
    ---@param self JSON
    ---@param key string
    ---@param value any
    Write = function(self, key, value) end,
    ---add json node
    ---@param self JSON
    ---@param value any
    Add = function(self, value) end,
    ---get node type
    ---@return number
    ---@param self JSON
    Type = function(self) end,
    ---clear node
    ---@param self JSON
    Clear = function(self) end,
    ---get next key,value pair
    ---@param self JSON
    Next = function(self) end,
}
---@class Component
meta_Component = {
    ---enable/disable component
    ---@param self Component
    ---@param enabled boolean
    Enable = function(self, enabled) end,
    ---is component enabled
    ---@return boolean
    ---@param self Component
    IsEnabled = function(self) end,
    ---component type
    ---@return number
    ---@param self Component
    GetType = function(self) end,
    ---component type
    ---@return string
    ---@param self Component
    GetTypename = function(self) end,
    ---component parent node
    ---@return Entity
    ---@param self Component
    GetNode = function(self) end,
    ---@param self Component
    ---@param id number
    AddTag = function(self, id) end,
    ---@param self Component
    ---@param id number
    RemoveTag = function(self, id) end,
    ---@return boolean
    ---@param self Component
    ---@param id number
    HasTag = function(self, id) end,
}
---scripted component
---@class SComponent
meta_SComponent = {
    ---@param self SComponent
    GetTable = function(self) end,
    ---@param self SComponent
    SetTable = function(self) end,
}
---@class Entity
meta_Entity = {
    ---spawn node
    ---@param self Entity
    Spawn = function(self) end,
    ---remove node
    ---@param self Entity
    Despawn = function(self) end,
    ---spawn new node and add it to current world state
    ---@param self Entity
    Create = function(self) end,
    ---despwan and remove node from current world state
    ---@param self Entity
    Destroy = function(self) end,
    ---invoke onentry function
    ---@param self Entity
    Enter = function(self) end,
    ---invoke onleave function
    ---@param self Entity
    Leave = function(self) end,
    ---eject node from its parent
    ---@param self Entity
    Eject = function(self) end,
    ---despawn all children nodes
    ---@param self Entity
    UnloadSubs = function(self) end,
    ---convert entity to data
    ---@return JSON
    ---@param self Entity
    ToData = function(self) end,
    ---add tag to node
    ---@param self Entity
    ---@param type number
    AddTag = function(self, type) end,
    ---remove tag from node
    ---@param self Entity
    ---@param type number
    RemoveTag = function(self, type) end,
    ---check tag on node
    ---@return boolean
    ---@param self Entity
    ---@param type number
    HasTag = function(self, type) end,
    ---get list of node tags
    ---@return table
    ---@param self Entity
    GetTags = function(self) end,
    ---copy tags to target
    ---@param self Entity
    ---@param target Entity
    CopyTags = function(self, target) end,
    ---add component to node
    ---@return Component
    ---@param self Entity
    ---@param type number
    AddComponent = function(self, type) end,
    ---remove given component from node
    ---@param self Entity
    ---@param component Component
    RemoveComponent = function(self, component) end,
    ---remove all components of type from node
    ---@param self Entity
    ---@param type number
    RemoveComponents = function(self, type) end,
    ---get first component of type from node
    ---@return Component
    ---@param self Entity
    ---@param type number
    GetComponent = function(self, type) end,
    ---get all node components
    ---@return Component
    ---@param self Entity
    GetComponents = function(self) end,
    ---get or add new component to node
    ---@return Component
    ---@param self Entity
    ---@param type number
    RequireComponent = function(self, type) end,
    ---add event listener function for event type
    ---@param self Entity
    ---@param type number
    ---@param name string
    ---@param method function
    AddEventListener = function(self, type, name, method) end,
    ---remove event listener function for event type 
    ---@param self Entity
    ---@param type number
    ---@param name string
    RemoveEventListener = function(self, type, name) end,
    ---send event of type to node with given arguments
    ---@return any
    ---@param self Entity
    ---@param type number
    SendEvent = function(self, type, ...) end,
    ---@param self Entity
    AddNativeEventListener = function(self) end,
    ---@param self Entity
    RemoveNativeEventListener = function(self) end,
    ---emit sound from node
    ---@param self Entity
    ---@param soundpath string
    ---@param volume number
    ---@param pitch number
    EmitSound = function(self, soundpath, volume, pitch) end,
    ---emit sound from node
    ---@param self Entity
    ---@param soundpath string
    ---@param volume number
    ---@param pitch number
    EmitSoundLoop = function(self, soundpath, volume, pitch) end,
    ---get node lua type
    ---@return string
    ---@param self Entity
    GetClass = function(self) end,
    ---get node hierarchy children
    ---@return table
    ---@param self Entity
    GetChildren = function(self) end,
    ---get node children by name
    ---@return Entity
    ---@param self Entity
    ---@param name string
    ---@param returnmany boolean
    ---@param recursive boolean
    GetByName = function(self, name, returnmany, recursive) end,
    ---get node parent of given node type
    ---@return Entity
    ---@param self Entity
    ---@param type number
    GetParentWith = function(self, type) end,
    ---get node parent with given flag
    ---@return Entity
    ---@param self Entity
    ---@param flag number
    GetParentWithFlag = function(self, flag) end,
    ---get node parent with given component type
    ---@return Entity  Component
    ---@param self Entity
    ---@param flag number
    GetParentWithComponent = function(self, flag) end,
    ---get node hierarchy
    ---@return table
    ---@param self Entity
    GetHierarchy = function(self) end,
    ---checks if target has this node in its hierarchy
    ---@return boolean
    ---@param self Entity
    IsParentOf = function(self) end,
    ---get node's universe
    ---@return Entity
    ---@param self Entity
    GetTop = function(self) end,
    ---get node identity
    ---@return Guid
    ---@param self Entity
    GetGuid = function(self) end,
    ---add to current position
    ---@param self Entity
    ---@param amount Vector
    AddPos = function(self, amount) end,
    ---gets node seed
    ---@return number
    ---@param self Entity
    GetSeed = function(self) end,
    ---sets node seed
    ---@param self Entity
    ---@param value number
    SetSeed = function(self, value) end,
    ---gets node name
    ---@return string
    ---@param self Entity
    GetName = function(self) end,
    ---sets node name
    ---@param self Entity
    ---@param value string
    SetName = function(self, value) end,
    ---gets node global name
    ---@return string
    ---@param self Entity
    GetGlobalName = function(self) end,
    ---sets node global name
    ---@param self Entity
    ---@param value string
    SetGlobalName = function(self, value) end,
    ---gets node parent
    ---@return Entity
    ---@param self Entity
    GetParent = function(self) end,
    ---sets node parent
    ---@param self Entity
    ---@param value Entity
    SetParent = function(self, value) end,
    ---gets node absolute metric size
    ---@return number
    ---@param self Entity
    GetSizepower = function(self) end,
    ---sets node absolute metric size
    ---@param self Entity
    ---@param value number
    SetSizepower = function(self, value) end,
    ---gets node position relative to parent
    ---@return Vector
    ---@param self Entity
    GetPos = function(self) end,
    ---sets node position relative to parent
    ---@param self Entity
    ---@param value Vector
    SetPos = function(self, value) end,
    ---gets metric node position relative to parent
    ---@return Vector
    ---@param self Entity
    GetAbsPos = function(self) end,
    ---sets metric node position relative to parent
    ---@param self Entity
    ---@param value Vector
    SetAbsPos = function(self, value) end,
    ---gets node angle relative to parent
    ---@return Vector
    ---@param self Entity
    GetAng = function(self) end,
    ---sets node angle relative to parent
    ---@param self Entity
    ---@param value Vector
    SetAng = function(self, value) end,
    ---gets node scale relative to its AMS
    ---@return number
    ---@param self Entity
    GetScale = function(self) end,
    ---sets node scale relative to its AMS
    ---@param self Entity
    ---@param value number
    SetScale = function(self, value) end,
    ---gets node position, rotation and scale from matrix
    ---@return Matrix
    ---@param self Entity
    GetWorld = function(self) end,
    ---sets node position, rotation and scale from matrix
    ---@param self Entity
    ---@param value Matrix
    SetWorld = function(self, value) end,
    ---gets node lua table
    ---@return table
    ---@param self Entity
    GetTable = function(self) end,
    ---sets node lua table
    ---@param self Entity
    ---@param value table
    SetTable = function(self, value) end,
    ---gets node parameter (VARTYPE_*)
    ---@return any
    ---@param self Entity
    GetParameter = function(self) end,
    ---sets node parameter (VARTYPE_*)
    ---@param self Entity
    ---@param value any
    SetParameter = function(self, value) end,
    ---gets load mode 
    ---@return number
    ---@param self Entity
    GetLoadMode = function(self) end,
    ---sets load mode 
    ---@param self Entity
    ---@param value number
    SetLoadMode = function(self, value) end,
    ---gets do not save flag
    ---@return boolean
    ---@param self Entity
    GetDonotsave = function(self) end,
    ---sets do not save flag
    ---@param self Entity
    ---@param value boolean
    SetDonotsave = function(self, value) end,
    ---copy params to target
    ---@param self Entity
    ---@param target Entity
    CopyParameters = function(self, target) end,
    ---gets does not despawn with parent node
    ---@return boolean
    ---@param self Entity
    GetSelfContained = function(self) end,
    ---sets does not despawn with parent node
    ---@param self Entity
    ---@param value boolean
    SetSelfContained = function(self, value) end,
    ---@return any
    ---@param self Entity
    GetAtransform = function(self) end,
    ---@param self Entity
    ---@param value any
    SetAtransform = function(self, value) end,
    ---gets enables position based parent change check
    ---@return boolean
    ---@param self Entity
    GetUpdateSpace = function(self) end,
    ---sets enables position based parent change check
    ---@param self Entity
    ---@param value boolean
    SetUpdateSpace = function(self, value) end,
    ---gets enables in/out transition for other nodes
    ---@return boolean
    ---@param self Entity
    GetSpaceEnabled = function(self) end,
    ---sets enables in/out transition for other nodes
    ---@param self Entity
    ---@param value boolean
    SetSpaceEnabled = function(self, value) end,
    ---gets enables Think() calls
    ---@return boolean
    ---@param self Entity
    GetUpdating = function(self) end,
    ---sets enables Think() calls
    ---@param self Entity
    ---@param value boolean
    SetUpdating = function(self, value) end,
    ---gets enables children cleanup on Exit() call
    ---@return boolean
    ---@param self Entity
    GetUnloadOnExit = function(self) end,
    ---sets enables children cleanup on Exit() call
    ---@param self Entity
    ---@param value boolean
    SetUnloadOnExit = function(self, value) end,
    ---gets networked double by given key
    ---@return number
    ---@param self Entity
    GetNWDouble = function(self) end,
    ---sets networked double by given key
    ---@param self Entity
    ---@param value number
    SetNWDouble = function(self, value) end,
    ---gets networked vector by given key
    ---@return Vector
    ---@param self Entity
    GetNWVector = function(self) end,
    ---sets networked vector by given key
    ---@param self Entity
    ---@param value Vector
    SetNWVector = function(self, value) end,
    ---get other node coordinates in this node coordinate system
    ---@return Vector
    ---@param self Entity
    ---@param target Entity
    GetLocalCoordinates = function(self, target) end,
    ---get other node world matrix in this node coordinate system
    ---@return Matrix
    ---@param self Entity
    ---@param target Entity
    GetLocalSpace = function(self, target) end,
    ---get distance to other node in metres
    ---@return number
    ---@param self Entity
    ---@param target Entity
    GetDistance = function(self, target) end,
    ---get distance to other node in metres^2
    ---@return number
    ---@param self Entity
    ---@param target Entity
    GetDistanceSq = function(self, target) end,
    ---get forward(X-) direction from node rotation
    ---@return Vector
    ---@param self Entity
    Forward = function(self) end,
    ---get right(Z+) direction from node rotation
    ---@return Vector
    ---@param self Entity
    Right = function(self) end,
    ---get up(Y+) direction from node rotation
    ---@return Vector
    ---@param self Entity
    Up = function(self) end,
    ---change parent keeping relative transforms
    ---@param self Entity
    ---@param newparent Entity
    ChangeParent = function(self, newparent) end,
    ---modify node angles with rotation around given axis and angle
    ---@param self Entity
    ---@param axis Vector
    ---@param angle number
    RotateAroundAxis = function(self, axis, angle) end,
    ---modify node angles with rotation around given axis and angle in inverse
    ---@param self Entity
    ---@param axis Vector
    ---@param angle number
    TRotateAroundAxis = function(self, axis, angle) end,
    ---set node angles to 'look at node' rotation
    ---@param self Entity
    ---@param target Entity
    LookAt = function(self, target) end,
    ---copy angle from other node
    ---@param self Entity
    ---@param target Entity
    CopyAng = function(self, target) end,
    ---@return Matrix
    ---@param self Entity
    GetMatrixAng = function(self) end,
    ---prints node hierarchy to console
    ---@param self Entity
    PrintHierarchy = function(self) end,
    ---update all world matrices
    ---@param self Entity
    UpdateWorld = function(self) end,
    ---perform simple raytrace in parent node space from node position and given direction
    ---@return Vector
    ---@param self Entity
    ---@param direction Vector
    ---@param filter table
    Trace = function(self, direction, filter) end,
}
---@class Constraint
meta_Constraint = {
    ---@param self Constraint
    GetType = function(self) end,
    ---@param self Constraint
    Break = function(self) end,
}
---render parameters
---@class RenderParameters
meta_RenderParameters = {
    ---gets triangles cull direction
    ---@return number
    ---@param self RenderParameters
    GetCullMode = function(self) end,
    ---sets triangles cull direction
    ---@param self RenderParameters
    ---@param value number
    SetCullMode = function(self, value) end,
    ---clip plane
    ---@param self RenderParameters
    ---@param enabled boolean
    ---@param normal Vector
    ---@param distance number
    SetClipPlane = function(self, enabled, normal, distance) end,
    ---set render group sequence
    ---@param self RenderParameters
    SetRenderGroup = function(self) end,
    ---set render group sequence
    ---@param self RenderParameters
    SetRenderGroups = function(self) end,
}
---@class Panel
meta_Panel = {
    ---add child panel
    ---@param self Panel
    ---@param child Panel
    Add = function(self, child) end,
    ---insert child panel at index
    ---@param self Panel
    ---@param child Panel
    ---@param index number
    Insert = function(self, child, index) end,
    ---remove child panel
    ---@param self Panel
    ---@param child Panel
    Remove = function(self, child) end,
    ---replace child panel with other
    ---@param self Panel
    ---@param oldchild Panel
    ---@param newchild Panel
    Replace = function(self, oldchild, newchild) end,
    ---remove all child panels
    ---@param self Panel
    Clear = function(self) end,
    ---add this panel to root panel and update
    ---@param self Panel
    Show = function(self) end,
    ---remove this panel from root panel
    ---@param self Panel
    Close = function(self) end,
    ---if this panel is child of root panel
    ---@param self Panel
    IsOpened = function(self) end,
    ---gets auto align side
    ---@return side:number
    ---@param self Panel
    GetDock = function(self) end,
    ---sets auto align side
    ---@param self Panel
    ---@param value side:number
    SetDock = function(self, value) end,
    ---get screen position of this panel
    ---@return Point
    ---@param self Panel
    GetScreenPos = function(self) end,
    ---get mouse cursor pos in local coordinates
    ---@return Point
    ---@param self Panel
    GetLocalCursorPos = function(self) end,
    ---get children panels
    ---@return table
    ---@param self Panel
    GetChildren = function(self) end,
    ---gets total multiplication of all parent panel scale multipliers
    ---@param self Panel
    GetTotalScaleMul = function(self) end,
    ---gets i-th char position in panel text
    ---@return Point
    ---@param self Panel
    ---@param i number
    GetCharPos = function(self, i) end,
    ---gets if mouse interaction enabled
    ---@return boolean
    ---@param self Panel
    GetCanRaiseMouseEvents = function(self) end,
    ---sets if mouse interaction enabled
    ---@param self Panel
    ---@param value boolean
    SetCanRaiseMouseEvents = function(self, value) end,
    ---gets mouse interactions
    ---@return boolean
    ---@param self Panel
    GetInteractive = function(self) end,
    ---sets mouse interactions
    ---@param self Panel
    ---@param value boolean
    SetInteractive = function(self, value) end,
    ---gets panel lua table
    ---@return table
    ---@param self Panel
    GetTable = function(self) end,
    ---sets panel lua table
    ---@param self Panel
    ---@param value table
    SetTable = function(self, value) end,
    ---gets parent panel
    ---@return Panel
    ---@param self Panel
    GetParent = function(self) end,
    ---sets parent panel
    ---@param self Panel
    ---@param value Panel
    SetParent = function(self, value) end,
    ---gets panel position inside parent
    ---@return Point
    ---@param self Panel
    GetPos = function(self) end,
    ---sets panel position inside parent
    ---@param self Panel
    ---@param value Point
    SetPos = function(self, value) end,
    ---gets panel rotation
    ---@return number
    ---@param self Panel
    GetRotation = function(self) end,
    ---sets panel rotation
    ---@param self Panel
    ---@param value number
    SetRotation = function(self, value) end,
    ---gets panel size
    ---@return Point
    ---@param self Panel
    GetSize = function(self) end,
    ---sets panel size
    ---@param self Panel
    ---@param value Point
    SetSize = function(self, value) end,
    ---gets panel minimum size
    ---@return Point
    ---@param self Panel
    GetMinSize = function(self) end,
    ---sets panel minimum size
    ---@param self Panel
    ---@param value Point
    SetMinSize = function(self, value) end,
    ---gets scale multiplier
    ---@return number
    ---@param self Panel
    GetScaleMul = function(self) end,
    ---sets scale multiplier
    ---@param self Panel
    ---@param value number
    SetScaleMul = function(self, value) end,
    ---gets position and size
    ---@return Point Point
    ---@param self Panel
    GetBounds = function(self) end,
    ---sets position and size
    ---@param self Panel
    ---@param x number
    ---@param y number
    ---@param w number
    ---@param h number
    SetBounds = function(self, x, y, w, h) end,
    ---gets panel color
    ---@return Vector
    ---@param self Panel
    GetColor = function(self) end,
    ---sets panel color
    ---@param self Panel
    ---@param value Vector
    SetColor = function(self, value) end,
    ---gets panel second color (for gradients)
    ---@return Vector
    ---@param self Panel
    GetColor2 = function(self) end,
    ---sets panel second color (for gradients)
    ---@param self Panel
    ---@param value Vector
    SetColor2 = function(self, value) end,
    ---gets panel gradient rotation
    ---@return number
    ---@param self Panel
    GetGradAngle = function(self) end,
    ---sets panel gradient rotation
    ---@param self Panel
    ---@param value number
    SetGradAngle = function(self, value) end,
    ---gets alpha blending value
    ---@return any
    ---@param self Panel
    GetAlpha = function(self) end,
    ---sets alpha blending value
    ---@param self Panel
    ---@param value any
    SetAlpha = function(self, value) end,
    ---gets is panel visible
    ---@return any
    ---@param self Panel
    GetVisible = function(self) end,
    ---sets is panel visible
    ---@param self Panel
    ---@param value any
    SetVisible = function(self, value) end,
    ---get top parent of this panel
    ---@return Panel
    ---@param self Panel
    GetTop = function(self) end,
    ---get index of this panel in parent child nodes
    ---@return number
    ---@param self Panel
    GetIndex = function(self) end,
    ---gets panel text
    ---@return string
    ---@param self Panel
    GetText = function(self) end,
    ---sets panel text
    ---@param self Panel
    ---@param value string
    SetText = function(self, value) end,
    ---gets text color
    ---@return Vector
    ---@param self Panel
    GetTextColor = function(self) end,
    ---sets text color
    ---@param self Panel
    ---@param value Vector
    SetTextColor = function(self, value) end,
    ---gets spritefont
    ---@return SpriteFont
    ---@param self Panel
    GetFont = function(self) end,
    ---sets spritefont
    ---@param self Panel
    ---@param value SpriteFont
    SetFont = function(self, value) end,
    ---gets disable background rendering
    ---@return boolean
    ---@param self Panel
    GetTextOnly = function(self) end,
    ---sets disable background rendering
    ---@param self Panel
    ---@param value boolean
    SetTextOnly = function(self, value) end,
    ---gets text alignment
    ---@return alignment:number
    ---@param self Panel
    GetTextAlignment = function(self) end,
    ---sets text alignment
    ---@param self Panel
    ---@param value alignment:number
    SetTextAlignment = function(self, value) end,
    ---gets cut from right
    ---@return boolean
    ---@param self Panel
    GetTextCutMode = function(self) end,
    ---sets cut from right
    ---@param self Panel
    ---@param value boolean
    SetTextCutMode = function(self, value) end,
    ---gets multiline text rendering
    ---@return boolean
    ---@param self Panel
    GetMultiline = function(self) end,
    ---sets multiline text rendering
    ---@param self Panel
    ---@param value boolean
    SetMultiline = function(self, value) end,
    ---gets text line height
    ---@return number
    ---@param self Panel
    GetLineHeight = function(self) end,
    ---sets text line height
    ---@param self Panel
    ---@param value number
    SetLineHeight = function(self, value) end,
    ---gets spacing between text lines
    ---@return number
    ---@param self Panel
    GetLineSpacing = function(self) end,
    ---sets spacing between text lines
    ---@param self Panel
    ---@param value number
    SetLineSpacing = function(self, value) end,
    ---gets use word wrap
    ---@return boolean
    ---@param self Panel
    GetAutowrap = function(self) end,
    ---sets use word wrap
    ---@param self Panel
    ---@param value boolean
    SetAutowrap = function(self, value) end,
    ---gets background image
    ---@return string
    ---@param self Panel
    GetTexture = function(self) end,
    ---sets background image
    ---@param self Panel
    ---@param value string
    SetTexture = function(self, value) end,
    ---gets background image scale
    ---@return Point
    ---@param self Panel
    GetTextureScale = function(self) end,
    ---sets background image scale
    ---@param self Panel
    ---@param value Point
    SetTextureScale = function(self, value) end,
    ---perform panel alignment
    ---@param self Panel
    ---@param target Panel
    ---@param self_side number
    ---@param target_side number
    AlignTo = function(self, target, self_side, target_side) end,
    ---update layout of this panel and its children
    ---@param self Panel
    UpdateLayout = function(self) end,
    ---gets rectangular clipping for child rendering
    ---@return boolean
    ---@param self Panel
    GetClipEnabled = function(self) end,
    ---sets rectangular clipping for child rendering
    ---@param self Panel
    ---@param value boolean
    SetClipEnabled = function(self, value) end,
    ---gets panel state
    ---@return state:string
    ---@param self Panel
    GetState = function(self) end,
    ---sets panel state
    ---@param self Panel
    ---@param value state:string
    SetState = function(self, value) end,
    ---add new panel state
    ---@param self Panel
    ---@param name string
    ---@param state table
    AddState = function(self, name, state) end,
    ---adds panel states from dictionary
    ---@param self Panel
    ---@param state_dictionary table
    AddStates = function(self, state_dictionary) end,
    ---gets panel position and size anchors
    ---@return alignment:number
    ---@param self Panel
    GetAnchors = function(self) end,
    ---sets panel position and size anchors
    ---@param self Panel
    ---@param value alignment:number
    SetAnchors = function(self, value) end,
    ---gets offsets for child panels docking
    ---@return left:number,top:number,right:number,bottom:number
    ---@param self Panel
    GetPadding = function(self) end,
    ---sets offsets for child panels docking
    ---@param self Panel
    ---@param value left:number,top:number,right:number,bottom:number
    SetPadding = function(self, value) end,
    ---gets separation distance from other panels
    ---@return left:number,top:number,right:number,bottom:number
    ---@param self Panel
    GetMargin = function(self) end,
    ---sets separation distance from other panels
    ---@param self Panel
    ---@param value left:number,top:number,right:number,bottom:number
    SetMargin = function(self, value) end,
    ---gets enable auto size
    ---@return x:boolean,y:boolean
    ---@param self Panel
    GetAutoSize = function(self) end,
    ---sets enable auto size
    ---@param self Panel
    ---@param value x:boolean,y:boolean
    SetAutoSize = function(self, value) end,
    ---gets text page
    ---@return page:number
    ---@param self Panel
    GetPage = function(self) end,
    ---sets text page
    ---@param self Panel
    ---@param value page:number
    SetPage = function(self, value) end,
    ---get text page count
    ---@return number
    ---@param self Panel
    GetPageCount = function(self) end,
    ---@param self Panel
    SetUseGlobalScale = function(self) end,
    ---set bezier curve points
    ---@param self Panel
    ---@param p1 Point
    ---@param p2 Point
    ---@param p3 Point
    ---@param p4 Point
    SetCurve = function(self, p1, p2, p3, p4) end,
    ---gets set curve end color
    ---@return Vector
    ---@param self Panel
    GetEndColor = function(self) end,
    ---sets set curve end color
    ---@param self Panel
    ---@param value Vector
    SetEndColor = function(self, value) end,
    ---@param self Panel
    AddPoint = function(self) end,
    ---@param self Panel
    RemovePoint = function(self) end,
    ---@param self Panel
    ClearPoints = function(self) end,
    ---@param self Panel
    GetPoints = function(self) end,
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
EVENT_TASK_END = 84002
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
EVENT_EDITOR_SPAWN_FORM = 224985
EVENT_EDITOR_WIRE = 225991
EVENT_EDITOR_UNWIRE = 225992
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
CTYPE_DYNAMICSKY = 114
CTYPE_CVOX = 115
CTYPE_SHAPEVIS = 116
CTYPE_GPUSURFACE = 117
CTYPE_SHADOW = 120
CTYPE_CAMERA = 121
CTYPE_CUBEMAP = 122
CTYPE_INTERFACE = 123
CTYPE_HEIGHTMAP = 125
CTYPE_NAVIGATION = 127
CTYPE_POSTPARAMS = 128
CTYPE_MATERIALMOD = 129
CTYPE_LIGHT = 130
CTYPE_ORIGIN = 131
CTYPE_PROJECTEDCUBEMAP = 132
CTYPE_IKCONTROLLER = 140
CTYPE_RIGANIMATOR = 141
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
CTYPE_FLOW = 260
CTYPE_MESHRENDER = 261
CTYPE_MESH = 262
CTYPE_MAPDATA = 301
CTYPE_STORAGEB = 310
CTYPE_ANTR_SYSTEMS = 3244
CTYPE_EQUIPMENT = 1324
CTYPE_HEALTH = 3414
CTYPE_STORAGE = 1314
CTYPE_VENDOR = 3240
CTYPE_WIREIO = 1315

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
VARTYPE_TARGET = 122
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
VARTYPE_CHUNKX = 921
VARTYPE_CHUNKY = 922
VARTYPE_SCRIPTDATA = 1000
VARTYPE_EQUIPMENT = 88020
VARTYPE_STORAGE = 88010
VARTYPE_AITYPE = 85031
VARTYPE_ARCHDATA = 254264
VARTYPE_MINLEVEL = 1210001
VARTYPE_MAXLEVEL = 1210002
VARTYPE_SURFADD = 1210003
VARTYPE_SURFMUL = 1210004
VARTYPE_SURFMODE = 1210005
VARTYPE_SURFMAP = 1210006
VARTYPE_STATUSEFFECTS = 84321
VARTYPE_VISIBLE = 321301

RENDERGROUP_NONE = 0
RENDERGROUP_DEEPSPACE = 100
RENDERGROUP_STARSYSTEM = 101
RENDERGROUP_PLANET = 102
RENDERGROUP_CURRENTPLANET = 103
RENDERGROUP_BACKDROP = 121
RENDERGROUP_LOCAL = 104
RENDERGROUP_RINGS = 111
RENDERGROUP_OVERLAY = 200

TAG_PHYSOBJECT = 10
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
TAG_EDITOR_NODE = 11005
TAG_ACTOR_PART = 25512
TAG_SELECTION_MENU = 3322002
TAG_REPL_FATIGUE = 10101
TAG_REPL_SLEEP = 10102
TAG_RADIAL_INTERACT = 101033

CGROUP_NONE = 0
CGROUP_DEFAULT_PHYSICS = 1
CGROUP_DEFAULT_STATICS = 2
CGROUP_NOCOLLIDE_PHYSICS = 3

ACT_MOVE_FORWARD = 10
ACT_MOVE_BACK = 11
ACT_MOVE_LEFT = 12
ACT_MOVE_RIGHT = 13
ACT_MOVE_DOWN = 14
ACT_MOVE_UP = 15
ACT_USE = 20
ACT_JUMP = 21
ACT_DUCK = 22
ACT_SPRINT = 23
ACT_FIRE = 110
ACT_ALTFIRE = 111

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
DOCK_FIXEDRIGHT = 5
DOCK_FIXEDLEFT = 6
DOCK_FIXEDTOP = 7
DOCK_FIXEDBOTTOM = 8
DOCK_FIXEDFILL = 9


--user types
---@class UserEntity : Entity
ENTITY = {}
---@class UserPanel : Panel
PANEL = {}
