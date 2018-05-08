--[[
    Filename:    shader.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-03-17 10:17:04
    Description: File description
--]]

--[[
		alpha取反Shader 
--]]
local pszFragSource = 
    [[                                                      
    precision mediump float;                              
    varying vec2 v_texCoord;                              
                                                          
    void main()                                          
    {                                                      
        vec4 col = texture2D(CC_Texture0, v_texCoord.st);  
        float a = 1.0 - col.a;                                
        gl_FragColor = vec4(col.r*a, col.g*a, col.b*a, a);                  
    }
    ]]


local program = cc.GLProgram:createWithByteArrays(Shader.vertDefaultSource, pszFragSource)
program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)

program:link()
program:updateUniforms()

local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(program)
local pid = program:getProgram()
return glProgramState