--[[
    Filename:    doc.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2015-04-27 16:25:40
    Description: File description
--]]

--[[
    有几个文件是在热更新后不会马上生效
    utils.init
    utils.lang.table
    utils.utf8.utf8
    utils.utf8.utf8data
    utils.shader.shader
    utils.json4lua
    utils.bitExtend
    utils.profiler.luaprofiler
    utils.security
    utils.PushUtils
    utils.ApplicationUtils
    utils.ApiUtils
    base.network.HttpManager
    base.boot.RestartManager
    base.boot.GlobalErrorCode
    base.boot.LogoView
    game.GamePreLoadRes
    base.boot.UpdateView
    game.GameStatic
--]]

--[====[
    注意事项
    1. ios和android系统对文件名大小写敏感,所以require的时候注意大小写
    2. 打ios64位包的时候注意文件编码 utf-8 不能带BOM, 否则会报错, sublime保存的时候下面会显示文件编码
    3. class 的 xxxx.dtor() 里面用于释放当前文件的local, 因为反require的时候 这些local不会释放
    4. setPosition(xx:getPosition())的效率比setPosition(cc.p(xx:getPositionX(), xx:getPositionY()))高
    5. Define and call only 'local' (!) functions within a module.
    6. 在ios64下，需要编译出64位bytecode 才可以正常运行
    7. ccui.ScrollView 里面添加的东西如果有遮罩 需要setClippingType(1)
    8. 同一路径内，不允许出现同名不同后缀的图片，例如abc.png和abc.jpg不可同时存在，转etc1的时候会冲突
    9. [\x{4e00}-\x{9fa5}] 用来匹配汉字
   10. addImageAsync 有小概率没有回调，改用createImageTask异步加载
   11. 999999999999999 - 999999999999993 这是luajit 最大位数的有效数字计算
   12. SpriteFrame使用优先原则，也就是如果发生同名，后面的不会覆盖前面的
   13. 不同平台对最大纹理尺寸的支持不同，iphone4为2048，之后的版本都是4096，android有极少机器是2048
   14. git show-ref --tag | awk '/tencent.1706/{print ":"$2}' | xargs git push origin 删除远程tag
   15. git tag | xargs git tag -d 删除本地全部tag
   16. 字符串其他写法 [[aaa]]  [=[aaaaa]=] [==[aaaaa]==] 批量注释也是同理
--]====]