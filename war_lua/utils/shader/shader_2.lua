--[[
    Filename:    shader.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-03-17 10:17:04
    Description: File description
--]]

--[[
		黑白Shader 
--]]
local pszFragSource = 
    "                                                       \n\
    precision mediump float;                                \n\
    varying vec2 v_texCoord;                                \n\
    varying vec4 v_fragmentColor;                           \n\
    const vec4 W = vec4(0.2125, 0.7154, 0.0721, 0);         \n\
                                                            \n\
    void main()                                             \n\
    {                                                       \n\
        vec4 col = texture2D(CC_Texture0, v_texCoord.st);   \n\
        float lum = dot(col, W);                            \n\
        if (0.5 < lum) {                                    \n\
        gl_FragColor = v_fragmentColor;                     \n\
        } else {                                            \n\
        gl_FragColor = vec4(0, 0, 0, col.a);}                   \n\
    }"

local program = cc.GLProgram:createWithByteArrays(Shader.vertDefaultSource, pszFragSource)
program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)

program:link()
program:updateUniforms()

local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(program)
local pid = program:getProgram()
return glProgramState