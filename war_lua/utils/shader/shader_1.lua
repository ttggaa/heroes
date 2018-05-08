--[[
    Filename:    shader.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-03-17 10:17:04
    Description: File description
--]]

--[[
		浮雕Shader 
--]]
local pszFragSource = 
    "                                                               \n\
    #ifdef GL_ES                                                    \n\
    precision mediump float;                                        \n\
    precision mediump int;                                          \n\
    #endif                                                          \n\
                                                                    \n\
    const vec2 texOffset = vec2( 0.005, 0.005);                     \n\
                                                                    \n\
    varying vec4 v_fragmentColor;                                   \n\
    varying vec2 v_texCoord;                                        \n\
                                                                    \n\
    const vec4 lumcoeff = vec4(0.299, 0.587, 0.114, 0);             \n\
                                                                    \n\
    void main()                                                     \n\
    {                                                               \n\
    vec2 tc0 = v_texCoord.st + vec2(-texOffset.s, -texOffset.t);    \n\
    vec2 tc1 = v_texCoord.st + vec2(         0.0, -texOffset.t);    \n\
    vec2 tc2 = v_texCoord.st + vec2(-texOffset.s,          0.0);    \n\
    vec2 tc3 = v_texCoord.st + vec2(+texOffset.s,          0.0);    \n\
    vec2 tc4 = v_texCoord.st + vec2(         0.0, +texOffset.t);    \n\
    vec2 tc5 = v_texCoord.st + vec2(+texOffset.s, +texOffset.t);            \n\
                                                                            \n\
    vec4 col0 = texture2D(CC_Texture0, tc0);                                \n\
    vec4 col1 = texture2D(CC_Texture0, tc1);                                \n\
    vec4 col2 = texture2D(CC_Texture0, tc2);                                \n\
    vec4 col3 = texture2D(CC_Texture0, tc3);                                \n\
    vec4 col4 = texture2D(CC_Texture0, tc4);                                \n\
    vec4 col5 = texture2D(CC_Texture0, tc5);                                \n\
                                                                            \n\
    vec4 sum = vec4(0.5) + (col0 + col1 + col2) - (col3 + col4 + col5);     \n\
    float lum = dot(sum, lumcoeff);                                         \n\
    gl_FragColor = vec4(lum, lum, lum, 1.0) * v_fragmentColor;              \n\
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