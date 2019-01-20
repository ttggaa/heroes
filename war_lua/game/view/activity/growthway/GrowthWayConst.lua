--[[
 	@FileName 	GrowthWayConst.lua
	@Authors 	cuiyake
	@Date    	2018-05-28 10:54:13
	@Email    	<cuiyake@playcrad.com>
	@Description   描述
--]]

GrowthWayConst = {}

--成长之路数据页
GrowthWayConst.Page = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
	[7] = 7
}

--成长之路英雄阵营数据
GrowthWayConst.HeroCamp = 
{
    [1] = {"城堡","asset/uiother/steam/shijiu.png",1.5,true,{x=885,y=317}},
    [2] = {"壁垒","asset/uiother/steam/kumuweishi.png",1.2,true,{x=885,y=317}},
    [3] = {"墓园","asset/uiother/steam/xixuegui.png",1.5,true,{x=875,y=300}},
    [4] = {"据点","asset/uiother/steam/langqi.png",1.5,true,{x=865,y=380}},
    [5] = {"地狱","asset/uiother/steam/diyulingzhu.png",1.5,true,{x=855,y=317}},
    [6] = {"塔楼","asset/uiother/steam/shenguai.png",1.5,true,{x=860,y=312}},
    [7] = {"地下城","asset/uiother/steam/yingshenren.png",1.5,true,{x=900,y=317}},
    [8] = {"要塞","asset/uiother/steam/longying.png",1.5,true,{x=955,y=325}},
    [9] = {"元素","asset/uiother/steam/mofaxianling.png",1.5,true,{x=885,y=317}}
}

 --成长之路15资质兵团数据
GrowthWayConst.First15Team = 
{
    [107] = {1.2,true,{x=868,y=307}},
    [108] = {1.5,true,{x=845,y=300}},
    [207] = {1,true,{x=875,y=310}},
    [306] = {1.5,true,{x=865,y=317}},
    [307] = {1,true,{x=885,y=315}},
    [407] = {1.2,true,{x=870,y=317}},
    [507] = {1.2,true,{x=875,y=317}},
    [606] = {1.5,true,{x=885,y=317}},
    [607] = {1,true,{x=885,y=317}},
    [707] = {1.2,true,{x=845,y=317}},
    [805] = {1.5,true,{x=845,y=255}},
    [906] = {1.4,true,{x=845,y=305}}
}

--成长之路每页默认图片
GrowthWayConst.PagePictures = 
{
    [1] = {"growthway_kaiselin.png",1,false,{x=885,y=317}},
    [2] = {"asset/uiother/steam/longying.png",1.5,true,{x=955,y=325}},
    [3] = {"asset/uiother/shero/zhenni.png",1.5,true,{x=910,y=300}},
    [4] = {"growthway_zeda.png",1,false,{x=885,y=317}},
    [5] = {"asset/uiother/steam/tianshi.png",1.2,true,{x=868,y=307}},
    [6] = {"asset/uiother/shero/monaier.png",1.4,true,{x=907,y=320}},
    [7] = {"asset/bg/global_reward2_img.png",1,true,{x=925,y=317}}

}
--成长之路元素位面Id对应的描述
GrowthWayConst.PlaneData = 
{
	[1] = "火元素位面",
	[2] = "水元素位面",
	[3] = "气元素位面",
	[4] = "土元素位面",
	[5] = "混乱元素位面"
}
--成长之路VIP称呼
GrowthWayConst.VIPStates = 
{
	[1] = "勤俭节约",
	[2] = "出手阔绰",
	[3] = "挥金如土",
	[4] = "富比王侯"
}