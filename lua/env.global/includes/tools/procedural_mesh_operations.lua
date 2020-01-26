
local optypes = {
    extrude = {
        icon = "textures/gui/panel_icons/extrude.png",
        name = "Extrude",
        params = {
            shift = {
                type = "float",
                default = 0,
            },
            mode = {
                type = "string",
                default = "normal",
            },
            merge = {
                type = "bool",
                default = false,
            }
        },
        operate = function(model, cam, wdir, op)  
            op.shift = model:GetVNPDrag(cam,wdir)  
        end
    },
    inset = {
        icon = "textures/gui/panel_icons/inset.png",
        name = "Inset",
        params = {
            amount = {
                type = "float",
                default = 0,
            },
            extrude = {
                type = "float",
                default = 0,
            },
            chamfer = {
                type = "float",
                default = 0,
            },
            scale = {
                type = "float",
                default = 1,
            },
            group = {
                type = "bool",
                default = false
            },
            nolimits = {
                type = "bool",
                default = false
            },
            edgemode = {
                type = "bool",
                default = false
            },
            partmode = {
                type = "bool",
                default = false
            }
        },
        operate = function(model, cam, wdir, op)  
            op.amount = model:GetVNPDrag(cam,wdir)  
        end
    },
    tesselate = {
        icon = "textures/gui/panel_icons/tesselate.png",
        name = "Tesselate",
        params = {
            times = {
                type = "float",
                default = 1,
            }, 
        },
        operate = function(model, cam, wdir, op)  
            local dv = model:GetVNPDrag(cam,wdir) 
            op.times = math.Clamp(dv,1,3) 
        end
    },
    stairs = {
        icon = "textures/gui/panel_icons/staircase.png",
        name = "Create stairs",
        params = {
            stepheight = {
                type = "float",
                default = 0.1,
            }, 
            height = {
                type = "float",
                default = 1
            },
            leftside = {
                type = "bool",
                default = false,
            },
            rightside = {
                type = "bool",
                default = false,
            },
            bottom = {
                type = "bool",
                default = false,
            }, 
            dropside = {
                type = "bool",
                default = false,
            }
            
        },
        operate = function(model, cam, wdir, op)  
            local dv = model:GetVNPDrag(cam,wdir) 
            op.height = dv
        end
    },
    ngon = {
        icon = "textures/gui/panel_icons/ngon.png",
        name = "Place N-Gon",
        params = {
            pos = {
                type = "vector",
                default = {0,0,0}
            },
            r = {
                type = "float",
                default = 1
            },
            axis = {
                type = "vector",
                default = {0,1,0}
            },
            sides = {
                type = "float",
                default = 8
            }
        },
        place = function(model, cam, trace, op)  
            if trace.Hit then
                op.pos = VectorJ(model:GetNode():GetLocalCoordinates(trace.Space:GetNode() ,trace.Position))
            end
        end,
        operate = function(model, cam, wdir, op)  
            local dv = model:GetVNPDrag(cam,wdir) 
            op.r = math.Clamp(dv,1,3) 
        end
    },
    material = { 
        icon = "textures/gui/panel_icons/texture.png",
        name = "Set material",
        params = {
            material = {
                type = "string",
                default = "textures/debug/uv_checker.json"
            }
        },
        applyonclick = true
    },
    merge = { 
        icon = "textures/gui/panel_icons/merge.png",
        name = "Merge faces",
        params = { 
            placeholder = {
                default = 0
            }
        },
        applyonclick = true
    },
    remove = { 
        icon = "textures/gui/panel_icons/delete.png",
        name = "Remove faces",
        params = { 
            placeholder = {
                default = 0
            }
        },
        applyonclick = true
    },
    split = {
        
        icon = "textures/gui/panel_icons/split.png",
        name = "Split faces",
        params = { 
            steps = {
                type = "float",
                default = 1
            },
            stype = {
                default = "constant"
            },
            size = {
                default =  {0,0}
            },
            side = {
                 default ="first", 
            }
            
        },
        operate = function(model, cam, wdir, op)  
            local dv = model:GetVNPDrag(cam,wdir) 
            op.size =  {-math.Clamp(dv,0.000001,1),0}
        end
    },
    bridge = {
        icon = "textures/gui/panel_icons/split.png",
        name = "Make bridge between selected faces",
        params = { 
            rotate = {
                type = "float",
                default = 0
            }
        },
        applyonclick = true
    },
    structure = {
        icon = "textures/gui/panel_icons/split.png",
        name = "Apply structure to faces",
        params = { 
            path = {
                type = "string",
                default = "forms/levels/sdm/arch/parts/bookshelf.dnmd"
            },
            inputname = {
                type = "string",
                default = "face"
            }
        },
        applyonclick = true
    }
} 

for k,v in pairs(optypes) do
    MEAddOPType(k,v)
end