--[[
    Filename:    shader.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-03-17 10:17:04
    Description: File description
--]]

--[[
		负色Shader 
--]]
local pszFragSource = 
    "                                                   \n\
    precision mediump float;                            \n\
    varying vec2 v_texCoord;                            \n\
    varying vec4 v_fragmentColor;                       \n\
    void main()                                         \n\
    {                                                   \n\
        float T = 1.0;                                  \n\
        vec2 st = v_texCoord.st;                        \n\
        vec3 irgb = texture2D(CC_Texture0, st).rgb;     \n\
        float a = texture2D(CC_Texture0, st).a;         \n\
        vec3 neg = vec3(1., 1., 1.)-irgb;               \n\
        gl_FragColor = vec4(mix(irgb,neg, a), a);       \n\
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