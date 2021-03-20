green_style = {
    button = {
        type = "button",
        textcolor = "#FFFFFF",
        states = {
            idle = {
                color = "#006266"
            },
            hover = {
                color = "#009432"
            },
            pressed = { 
                color = "#A3CB38"
            }  
        }
    },
    panel = {
        type = "panel",
        color = "#1B1464"
    },
    window = {
        _sub_header = { 
            states = {
                idle = {
                    color = "#006266",
                    color2 = "#009432"
                },
                hover = {
                    color = "#006266",
                    color2 = "#009432"
                },
                pressed = { 
                    color = "#009432"
                }  
            },
            state = 'idle',
        },  
        _sub_bc = {
            texture = "textures/gui/cross.png",
            states = {
                idle = {
                    color = "#202020"
                },
                hover = {
                    color = "#FF0000"
                },
                pressed = { 
                    color = "#FFFFFF"
                }  
            },
            state = 'idle',
            --textonly = true,
            --text = 'X'
        }
    }
}