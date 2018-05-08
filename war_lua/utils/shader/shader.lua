--[[
    Filename:    shader.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-07-22 10:17:04
    Description: File description
--]]
Shader = {}

Shader.vertDefaultSource = 
"                                       \n\
attribute vec4 a_position;              \n\
attribute vec2 a_texCoord;              \n\
attribute vec4 a_color;                 \n\
#ifdef GL_ES                            \n\
varying lowp vec4 v_fragmentColor;      \n\
varying mediump vec2 v_texCoord;        \n\
#else                                   \n\
varying vec4 v_fragmentColor;           \n\
varying vec2 v_texCoord;                \n\
#endif                                  \n\
void main()                             \n\
{                                       \n\
gl_Position = CC_PMatrix * a_position;  \n\
v_fragmentColor = a_color;              \n\
v_texCoord = a_texCoord;                \n\
 }                                      \n\
 "

Shader.shaderTab = 
{
    "浮雕","黑白","负色","边缘","老照片",
}

-- local blurStr8 = "float w[8];w[0]=0.275653;w[1]=0.136476;w[2]=0.103611;w[3]=0.065461;w[4]=0.034419;w[5]=0.015060;w[6]=0.005484;w[7]=0.001662; \n"
-- local blurStr16 = "float w[16];w[0]=0.139085;w[1]=0.073321;w[2]=0.069051;w[3]=0.062480;w[4]=0.054317;w[5]=0.045370;w[6]=0.036410;w[7]=0.028074;w[8]=0.020798;w[9]=0.014803;w[10]=0.010123;w[11]=0.006651;w[12]=0.004199;w[13]=0.002547;w[14]=0.001484;w[15]=0.000831; \n"
-- local blurStr32 = "float w[32];w[0]=0.070871;w[1]=0.037226;w[2]=0.036707;w[3]=0.035857;w[4]=0.034701;w[5]=0.033269;w[6]=0.031599;w[7]=0.029733;w[8]=0.027716;w[9]=0.025595;w[10]=0.023416;w[11]=0.021223;w[12]=0.019056;w[13]=0.016951;w[14]=0.014938;w[15]=0.013041;w[16]=0.011279;w[17]=0.009664;w[18]=0.008203;w[19]=0.006898;w[20]=0.005747;w[21]=0.004743;w[22]=0.003878;w[23]=0.003141;w[24]=0.002521;w[25]=0.002004;w[26]=0.001578;w[27]=0.001231;w[28]=0.000952;w[29]=0.000729;w[30]=0.000553;w[31]=0.000415; \n"
-- local blurStr64 = "float w[64];w[0]=0.036780;w[1]=0.018679;w[2]=0.018616;w[3]=0.018511;w[4]=0.018364;w[5]=0.018178;w[6]=0.017953;w[7]=0.017690;w[8]=0.017392;w[9]=0.017060;w[10]=0.016696;w[11]=0.016303;w[12]=0.015883;w[13]=0.015440;w[14]=0.014974;w[15]=0.014490;w[16]=0.013989;w[17]=0.013476;w[18]=0.012951;w[19]=0.012419;w[20]=0.011882;w[21]=0.011342;w[22]=0.010803;w[23]=0.010265;w[24]=0.009733;w[25]=0.009207;w[26]=0.008689;w[27]=0.008183;w[28]=0.007688;w[29]=0.007207;w[30]=0.006741;w[31]=0.006290;w[32]=0.005856;w[33]=0.005440;w[34]=0.005042;w[35]=0.004663;w[36]=0.004302;w[37]=0.003961;w[38]=0.003638;w[39]=0.003334;w[40]=0.003048;w[41]=0.002781;w[42]=0.002531;w[43]=0.002298;w[44]=0.002082;w[45]=0.001883;w[46]=0.001698;w[47]=0.001528;w[48]=0.001372;w[49]=0.001229;w[50]=0.001099;w[51]=0.000980;w[52]=0.000872;w[53]=0.000774;w[54]=0.000686;w[55]=0.000606;w[56]=0.000534;w[57]=0.000470;w[58]=0.000413;w[59]=0.000361;w[60]=0.000316;w[61]=0.000275;w[62]=0.000239;w[63]=0.000208; \n"
-- local blurStr = {{blurStr8, 8}, {blurStr16, 16}, {blurStr32, 32}, {blurStr64, 64}}
-- function Shader.getBlur1Shader(width, height, x, y, level)
--     local str = blurStr[level][1]
--     local pszFragSource = 
-- "#ifdef GL_ES \n" ..
-- "precision mediump float; \n" ..
-- "#endif \n" ..
-- "varying vec4 v_fragmentColor; \n" ..
-- "varying vec2 v_texCoord; \n" ..
-- "uniform vec2 resolution; \n"..
-- "uniform vec2 direction; \n"..
-- "uniform int radius; \n"..
-- "void main() \n" ..
-- "{ \n" ..
--     str ..
--     "gl_FragColor = texture2D(CC_Texture0, v_texCoord)*w[0]; \n" ..
--     "for (int i = 1; i < radius; i++) \n"..
--     "{ \n" ..
--       "vec2 offset = vec2(float(i)*(1.0/resolution.x)*direction.x, float(i)*(1.0/resolution.y)*direction.y); \n"..
--       "gl_FragColor += texture2D(CC_Texture0, v_texCoord + offset)*w[i]; \n"..
--       "gl_FragColor += texture2D(CC_Texture0, v_texCoord - offset)*w[i]; \n"..
--     "} \n" ..
--     "gl_FragColor.w = 1.0; \n" ..
-- "}"
--     local program = cc.GLProgram:createWithByteArrays(vertDefaultSource, pszFragSource)
--     program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
--     program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
--     program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)

--     program:link()
--     program:updateUniforms()

--     local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(program)
--     local pid = program:getProgram()
--     glProgramState:setUniformVec2(gl.getUniformLocation(pid, "resolution"), {x=width, y=height})
--     glProgramState:setUniformVec2(gl.getUniformLocation(pid, "direction"), {x=x, y=y})
--     glProgramState:setUniformInt(gl.getUniformLocation(pid, "radius"), blurStr[level][2])
--     return glProgramState
-- end

-- function Shader.getBlur2Shader(width, height, Radius)
--     local pszFragSource = 
-- "#ifdef GL_ES \n"..
-- "precision mediump float; \n"..
-- "#endif \n"..
-- "varying vec4 v_fragmentColor; \n"..
-- "varying vec2 v_texCoord; \n"..
-- "uniform vec2 resolution; \n"..
-- "uniform float blurRadius; \n"..
-- "uniform float sampleNum; \n"..
-- "vec3 blur(vec2); \n"..
-- "void main(void) \n"..
-- "{ \n"..
--   "vec3 col = blur(v_texCoord); \n"..
--   "gl_FragColor = vec4(col, 1.0) * v_fragmentColor; \n"..
-- "} \n"..
-- "vec3 blur(vec2 p) \n"..
-- "{ \n"..
--     "if (blurRadius > 0.0 && sampleNum > 1.0) \n"..
--     "{ \n"..
--         "vec3 col = vec3(0); \n"..
--         "vec2 unit = 1.0 / resolution.xy; \n"..
--         "float r = blurRadius; \n"..
--         "float sampleStep = r / sampleNum; \n"..
--         "float count = 0.0; \n"..
--         "for(float x = -r; x < r; x += sampleStep) \n"..
--         "{ \n"..
--             "for(float y = -r; y < r; y += sampleStep) \n"..
--             "{ \n"..
--                 "float weight = (r - abs(x)) * (r - abs(y)); \n"..
--                 "col += texture2D(CC_Texture0, p + vec2(x * unit.x, y * unit.y)).rgb * weight; \n"..
--                 "count += weight; \n"..
--             "} \n"..
--         "} \n"..
--         "return col / count; \n"..
--     "} \n"..
--     "return texture2D(CC_Texture0, p).rgb; \n"..
-- "} \n"

--     local program = cc.GLProgram:createWithByteArrays(vertDefaultSource, pszFragSource)
--     program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
--     program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
--     program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)

--     program:link()
--     program:updateUniforms()

--     local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(program)
--     local pid = program:getProgram()
--     glProgramState:setUniformVec2(gl.getUniformLocation(pid, "resolution"), {x=width, y=height})
--     glProgramState:setUniformFloat(gl.getUniformLocation(pid, "blurRadius"), Radius)
--     glProgramState:setUniformFloat(gl.getUniformLocation(pid, "sampleNum"), Radius)
--     return glProgramState
-- end

-- function Shader.dtor()
    -- blurStr = nil
    -- blurStr16 = nil
    -- blurStr32 = nil
    -- blurStr64 = nil
    -- blurStr8 = nil
    -- vertDefaultSource = nil
-- end

return Shader