--[[
    Filename:    shader.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-03-17 10:17:04
    Description: File description
--]]

--[[
		老照片Shader 
--]]
local pszFragSource = 
"\n\
	#ifdef GL_ES 								 																		\n\
		precision mediump float; 					 																	\n\
	#endif 																												\n\
																														\n\
	varying vec2 v_texCoord; 					 																		\n\
	varying vec4 v_fragmentColor; 																						\n\
																														\n\
	void main(void) 							 																		\n\
	{ 											 																		\n\
		// vec3( 0.299, 0.587, 0.114 ) 是RGB转YUV的参数值，生成灰色图														\n\
		float MixColor = dot(texture2D(CC_Texture0, v_texCoord).rgb, vec3(0.299, 0.587, 0.114));							\n\
		// 使用灰色图进行颜色混合																							\n\
		vec4 blendColor = vec4( 1.2, 1.0, 0.8, 1.0 ); // 调整这个值以修改最终混合色值										\n\
		gl_FragColor = vec4(MixColor * blendColor.r, MixColor * blendColor.g, MixColor * blendColor.b, texture2D(CC_Texture0, v_texCoord).a);	\n\
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