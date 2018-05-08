function run(_type, data)
	cc = {}
	cc.c3b = function () end
	cc.Vertex3F = function () end
	cc.c4b = function () end
	require "server.functions"
	require "server.procBattle"
	local res = proc(_type, data)
	return res
end