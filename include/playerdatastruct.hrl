%%%-------------------------------------------------------------------
%%% @author guofengwei
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%服务器存档信息
%%%客户端会有一份对应的表结构
%%%文件名相同 PlayerDataStruct.cs
%%%不要保存其他结构到本文件
%%% @end
%%% Created : 29. 十月 2014 14:48
%%%-------------------------------------------------------------------
-author("guofengwei").
-ifndef(__PLAYERDATASTRUCT_HRL__).
-define(__PLAYERDATASTRUCT_HRL__,1).

%% -------------------------------------------------
%% 用户的一些信息
%% -------------------------------------------------
-record(user_status,{
    id = '',      %% 用户id
    username,    %% 用户名
    mac,         %% 机器码
    roleobjectid = '',%% 角色id
    heartbeat,   %%心跳
    timeRef,
    logintime,
    roleinfo,   %% playersaveinfo的proplist
    pid,
    online,
    serverid,
    scenedropInfo,   %%保存的场景掉落信息，在进入战斗场景是需要保存
    friendpkinfo,   %% 与好友切磋保存的好友信息
    savejjcranking1to5Info,
    saveplundercityInfoList = [],
    saveplundercityInfo = [],
    saveemailInfo,
    saveCampaignInfo = [],        %%战役信息
    saveCardTrainInfo = [],         %%武将培养信息 [{id, 卡牌的mongoid},{info，cardTrain}]
    moneytreeInfo,
    lkkitousenWinID,                %%保存一个一骑当千活动胜利的进度id，领取宝箱是判断
    lkkitousenBagList,               %%一骑当千活动宝箱信息
    selecttransportationfoodList = [],       %% 当前刷新出来的运粮活动的列表 记录的是 rolemongoid
    plunderingtransportationfoodnum,    %% 抢粮是先把被抢粮对象的粮草数记录下来
    plundertransportationtoken = 0,         %% 抢粮活动进入战斗时分配的token
    multiserverkofavpoint = 0,          %% 跨服3v3对手平均战力
    multiserverkoftoken = 0,          %% 跨服3v3随机校验值
    lkkbosstoken = 0,                   %% 单骑挑战随机校验值
    exitcode = 0,                        %% 100001 表示被踢下线了 100002 主动下线  %% 100003表示被GM踢
    % add by Maserk 2016/3/24 9377数据中心log ==========================================
    ip , %%客户端Ip
    accountname = [],%登录账户名
    platform,  % 平台类型 2是android 1是IOS
    resolution , %分辨率
    os ,%操作系统
    networktype,%网络类型
    macId, %唯一ID
    model,%机型,
    sessionId ,   %每次游戏的会话ID
    % ==========================================
  % add by Maserk 2016/7/6 9377数据中心log ==========================================
    channelname, %渠道标示
    productslug ,%产品标示
  % ==========================================
    realNameAuth=0 ,% 实名认证状态,
    multiserverChatLastTime  = 0 , %,%上一次 跨服聊天时间
    preRegGiftStatus = 0 , %预注册领奖状态
    platformRegData= 0 ,%平台注册时间
    mft_internalToken = -1 , %逐鹿中原内政校验码
    mft_internalEventSceneID = -1, %逐鹿中原内政事件id
    mapserver_info ,%保存的玩家场景信息 参看 #player_mapinfo{}
    cheat_monitor=[],        %% 玩家作弊检测模块
    %%缓存好友列表,只在第一次请求时从数据库读取所有数据 add by GY 2019/5/8
    cacheFriendList = []
}).

-record(cardTrain,
{
    hp,
    atk,
    mdef,
    pdef
}).

%% -------------------------------------------------
%% 武将数据结构
%% -------------------------------------------------
-record(cardsaveinfo,{
    id,                     %%道具id
    mongodbID,              %%mongodb生成的ID，保证道具唯一性
    equiptype = -1,         %%可用武器类型
    curNum = 0,             %%当前数量
    cardLevel = 0,          %%武将等级
    cardAdvLevel = 0,       %%武将星级
    cardStarLevel = 0,      %%武将品级
    cardSkillLevel = 0,     %%老的觉醒等级，先留着吧
    cardCGState = 0,        %%老的化神等级，先留着吧
    cardExp = 0,            %%武将经验
    haveCard = 0,           %%是否已合成
    panelPos = -1,          %%上阵的位置
    patrnerLevel0 = 0,      %%将缘等级，0代表未激活
    patrnerLevel1 = 0,
    patrnerLevel2 = 0,
    patrnerLevel3 = 0,
    patrnerLevel4 = 0,
    patrnerLevel5 = 0,
    onlycardbattleinfo,     %%player_battle_info战斗数据，卡牌自身属性数据信息
    allbattleinfo,          %%继承队伍属性后的总属性数据信息
    cardequipitems = [],     %%武将装备列表
    cardskillInts = []      %%武将技能列表
}).

%% -------------------------------------------------
%% 道具信息
%% 暂定所有卡牌相关属性添加card前缀
%% -------------------------------------------------
-record(itemsaveinfo,{
    id,             %%道具id
    mongodbID,      %%mongodb生成的ID，保证道具唯一性
    itemtype = -1,       %道具类型
    equiptype = -1,      %武器类型
    baseLevel = 0,      %%强化等级
    baseLevelExp = 0,   %%法宝和饰品升到下一级，剩余的经验，升品的时候清0
    advLevel = 0,       %%
    quenchStar = 0,
    qualityLevel = 0, %%装备品级
    curNum = 0,         %%当前数量
    haveCard = 0,          %%是否已合成
    panelPos = -1,         %%面板中的位置，
    intensifyCost = 0,  %% 装备强化消耗金钱数/卡牌进阶、觉醒、化神消耗金钱
    auenchexp = 0 , %淬星经验(实际星级根据表查询)
    auenchcastinfo=[], % 淬星消耗物品信息[ [key ,value]]
    starlevel = 0,
    magicattr = []
}).


% add by Seven 2019/9/16 魔剑魔法属性存档结构
-record( magicsword ,
{
    id,
    type, %类型
    level %星级
}).

% add by Seven 2019/9/18 游历进度存档结构
-record( tourData ,
{
    sceneId,
    progress = [], %类型
    awardLevel = [] %星级奖励领取标记
}).

% add by Masker 2016/8/2 神兵结构
-record( godweaponsaveinfo ,
{
    id, %神兵ID
    activeState = 0 , %激活状态  0为没激活 1为激活
    
    starLevel  = 0,  %星级
    
    attachEvilLevel=0 %洗练等级
}).

%% -------------------------------------------------
%% 场景战斗信息
%% -------------------------------------------------
-record(scenesaveinfo,{
    id,                     %%场景id
    passNum,       %%当天的过关次数
    starIndex,                %%过关星级类信息
    intraday_buy_count         %%当天的购买次数
    %total_buy_count            %%购买过场景通关次数的总数量
}).

%% -------------------------------------------------
%% 好友请求信息
%% -------------------------------------------------
-record(friendrequestinfo,{
    userID,     %% 请求的人的UserID
    mongoID,
    userName    %% 请求的人的名字
}).

%% -------------------------------------------------
%% 好友信息
%% -------------------------------------------------
-record(friendsaveinfo,{
    userID,         %% UserID
    mongoID,
    name,
    receivegiftflag = 0,    %%收礼标记 0今天未被送 1今天已被送  2已领取
    presentgiftflag = 0,    %%送礼标记 0未送  1已送
	receivetime = 0
}).

%% -------------------------------------------------
%% 好友通知信息
%% 1-好友与你切磋，胜利
%% 2-好友与你切磋，失败
%% 3-竞技场失败
%% 4-竞技场失败，但排名不变
%% 5-竞技场胜利
%% 6-你与好友切磋，胜利
%% 7-你与好友切磋，失败
%% 8-解除好友关系
%% -------------------------------------------------
-record(friendnoticeinfo,{
    noticeType,     %% 通知类型
    userName,       %% 对方名字
    contentInt = [],     %% 记录一个int值List
    noticeTime      %% 通知的时间
}).
%% -------------------------------------------------
%% 竞技场通知信息
%% 3-竞技场失败
%% 4-竞技场失败，但排名不变
%% 5-竞技场胜利
%% -------------------------------------------------
-record(jjcnoticeinfo,{
    noticeType,     %% 通知类型
    otherRoleInfo = [{userName,''},{contentInt,[]},{noticeTime,0},{cardinfolist,[]}],
    meRoleInfo = [{userName,''},{contentInt,[]},{noticeTime,0},{cardinfolist,[]}]
%%    userName,       %% 对方名字
%%    contentInt = [],     %% 记录一个int值List
%%    noticeTime,      %% 通知的时间
%%    cardinfolist = []   %%记录对方玩家卡牌信息 卡牌id 卡牌等级 卡牌星级 卡牌升品等级
}).

-record(jjcnoticeroleinfo,{
    userName,       %% 名字
    contentInt = [],     %% 记录一个int值List
    noticeTime,      %% 通知的时间
    cardinfolist = []   %%记录玩家卡牌信息 卡牌id 卡牌等级 卡牌星级 卡牌升品等级
}).

%% -------------------------------------------------
%% 属性信息
%% -------------------------------------------------
-record(effectinfo,{
    ef_hp_a_0=0,            % 血量加法
    ef_hp_m_1=0,            % 血量乘法
    ef_atk_a_2=0,           % 攻击加法
    ef_atk_m_3=0,           % 攻击乘法
    ef_pdef_a_4=0,          % 物防加法
    ef_pdef_m_5=0,          % 物防乘法
    ef_mdef_a_6=0,          % 法防加法
    ef_mdef_m_7=0,          % 法防乘法
    ef_ratehit_a_16=0,      % 命中加法
    ef_ratehit_m_17=0,      % 命中乘法
    ef_ratedog_a_18=0,      % 闪避加法
    ef_ratedog_m_19=0,      % 闪避乘法
    ef_luckrate_a_20=0,     % 暴击加法
    ef_luckrate_m_21=0,     % 暴击乘法
    ef_luckyvalue_a_22=0,  % 暴击伤害系数 加法
    ef_luckrate_s_30=0,     % 暴击减免加法
    ef_luckrate_d_31=0,     % 暴击减免乘法
    ef_luckyreduce_a_38=0,  % 暴击伤害减免系数 乘法
    ef_damagedeepen_m_752=0,    % 造成的伤害加深
    ef_damagereduce_m_753=0,  % 受到的伤害减免
    ef_pvp_damagedeepen_m_754=0,    % pvp造成的伤害加深
    ef_pvp_damagereduce_m_755=0  % pvp受到的伤害减免

}).

%% -------------------------------------------------
%% 抢粮通知信息结构
%% 1-你抢夺别人，成功
%% 2-你抢夺别人，失败
%% 3-别人抢夺你，成功
%% 4-别人抢夺你，失败
%% -------------------------------------------------
-record(plundernoticeinfo,{
    noticeType,     %% 通知类型
    plunderInfo,       %% 对方信息
    contentInt = [],     %% 记录一个int值List
    noticeTime      %% 通知的时间
}).

%%--------------------------------------------------------------------
%% create by  guofw 2018/5/16 14:20
%% @doc
%% 最简单的玩家信息
%% 装备信息都没有，只为了显示名字，称号等文字信息
%% @spec
%% @end
%%--------------------------------------------------------------------
-record(tinyplayersaveinfo,{
    mongodbID = 0,                  %%角色ID
    name = <<"default">>,           %%角色名
    sex = 0,                        %%职业
    level = 0,                      %%等级
    titleEquipList=[] ,             %%装备的称号
    equipItems=[] ,                 %%上阵卡牌列表
    armyinfo = [],                  %%军团信息
    serverID=0                      %%服务器ID
}).

%地图服务器玩家必要信息 结构可以直接序列化成 client 的playersaveinfo结构
-record(mapplayerinfo,{
    name = <<"default">>,           %%角色名
    sex = 0,            %%性别
    equipItems = [],    %%装备位
    weapontype = 0,     %% 武器类型
    magicWeaponDao = 0,% 主角神兵使用的双刀
    magicWeaponGong = 0,% 主角神兵使用的弓箭
    battleinfo = [],
    titleEquipList=[] ,%装备的称号
    armyinfo = [],%军团信息
    serverID=0
}).

%% -------------------------------------------------
%% 查看其他用户的信息
%% -------------------------------------------------
-record(otherplayersaveinfo,{
    name = <<"default">>,           %%角色名
    sex = 0,            %%性别
    level = 1,          %%等级
    advlevel = 0,       %%进阶等级
    equipItems = [],    %%装备位
    weapontype = 0,     %% 武器类型
    magicWeaponDao = 0,% 主角神兵使用的双刀
    magicWeaponGong = 0,% 主角神兵使用的弓箭
    destinyList = [],   %% 天命属性
    battleinfo = [],
    items = []    ,%% 所有时装，加拥有激活属性
    titleEquipList=[] ,%装备的称号
    godweaponBag =[], %神兵背包
    %%增加军团、主线进度、精英进度、过关斩将最大进度
    %%Add By Lance 2016年11月23日
    armyinfo = [],%军团信息
    mainProgerss = 0,%主线进度
    campaignProgerss = 19999,%精英进度
    biographiesProgerss = 39999,%% 列传关卡进度
    lkkitousenMaxProcess = 0,%过关斩将最大进度
    vipLevel = 0, %VIP等级
    serverID=0, %serverID
    changegodstate=0           %%化神经节
}).

%% -------------------------------------------------
%% 用户的存档信息
%% -------------------------------------------------
-record(playersaveinfo,{
    %↘↘↘↘↘↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↙↙↙↙
    %→→→→→ version 必须与 PLAYER_VERSION 保持一致 ←←←←←
    %↗↗↗↗↗↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↖↖↖↖
    version = 6 ,        %%存档版本号 改存档要加这个版本号
    roleid = 0,      %% roleid
    userid = 0,
    name = <<"default">>,           %%角色名
    username = <<"default">>,         %%账号名
    regid = <<"default">>,                %%JPush推送设备ID
    sex=0,            %%性别
    level=1,          %%等级
    advlevel = 0,     %%进阶等级
    exp=0,            %%经验值 只会存当前等级的经验值
    money=0,          %%金币
    gold=0,           %%通宝
    silvernote = 0,     %%银票
    energy = 60,         %%体力
    mainProgerss = 0,   %%主关卡进度
    mainStoryProgress = 1, %% 主线剧情任务进度
    campaignProgerss = 19999,   %% 精英调整关卡进度
    newPlayerGuide = 1,     %% 新手引导进度
    lastPlayerGuide = 0,    %% 最后的引导进度
    guideInfos = [],        %% 已完成的引导列表
    freeshakemoneytreeTime = 0 ,%%恢复摇钱树的时间
    accumulateSignTime = 0,      %%累计登录记录时间
    lastSaveTime = 0,         %%最后的存盘时间
    sceneInfos = [], %%过关信息 scene_info
    equipItems = [],  %%装备位
    cardBagItems = [],          %%卡牌背包
    items = [],                 %%道具背包
    fashionList = [],       %% 时装背包
    surpassBagItems = [],       %%超包
    goldLuckyDraw = [], %%luckydraw的list
    jewelLuckyDraw = [], %%luckydraw的list
    lastContinueLuckyDrawFreeTime = 0,  %% 上一次十连抽免费抽奖时间 屏蔽相关功能
    battleinfo,          % 战斗信息 player_battle_info
    luckydrawPoint = 0,  %% 秘钱
    %jjcRanked = -1, % 竞技场排名
    jjcMoney = 0,     % 竞技场金币,荣誉
    onedayJionJjcCount = 0, % 今天参加jjc的次数
    onedayBuyJjcCount = 0,  % 今天购买jjc次数的次数
    weapontype = 0, % 武器类型
    magicWeaponDao = 0,% 主角神兵使用的双刀
    magicWeaponGong = 0,% 主角神兵使用的弓箭
    vipExp = 0,             % vip经验
    vipLevel = 0 ,           % vip等级
    vipAward = 0,            % vip奖励领取 1bit对应1个等级是否领取 1 表示已经领过第一级VIP奖励
    citySiegeTokenNum = 60,      % 攻城令数量
    citySiegePlunderNum    = 2,    % 掠夺次数
    citySiegeMoney      = 0,    % 功勋
    citySiegeProgerss = 0,      % 攻城略地攻占城池信息
    citySiegeLevel=[[{citytype,0},{citylevel,1}],[{citytype,1},{citylevel,1}],[{citytype,2},{citylevel,1}],[{citytype,3},{citylevel,1}],[{citytype,4},{citylevel,1}]] ,%% 已经攻打过的城池的等级信息[{citytype,0},{citylevel,1}]
    dailyBattleProgress = [],  %% 每日任务进度
    dailyLimitVersion = 0,      %每日任务更新版本号
    dailyLimitScore = 0,        %每日任务积分
    dailyLimitList = [],       % 每天次数限定的行为集合
    achievementList =[],        % 成就列表  proplist achievement_info
    totalAchievement = 0,         % 总成就点
    currentCampaingID=-1,           %玩家当前所处战役场景-客户端没有
    bountyTask=[],               %玩家身上的赏金任务ID
    bountyMoney = 0,                 %%玩家身上的赏金代币，官银
    eatbunsflag = [-1, -1, -1],            %吃包子的标识 位操作  0 没有  1 上午的吃了 2 下午的吃了 3 都吃了
    lastAutoRefreshWanderShopTime = 0,      %%最后一次自动刷新黑石商人商品的时间
    wanderShopList = [],                    %%黑市商人商品list
    sceneawardInfos = [],
    chapterawardInfos = [],
    campaignchapterawardInfos = [],
    lkkitousenPoint = 0,            %% 神铁
    lkkitousenProcess = 0,
    lkkitousenRefreshCount = 0,
    lkkitousenMaxProcess = 0,
    signinid = 0,                   %% 签到的次数
    signingroupid = 1,               %% 签到的循环组id
    lastsignintime = 0,
    grandtotalsignintime = 0,        %%累计签到天数
    grandtotalsigninstate = 0,       %%累计签到领取标记位置
    flashsalestopday = 0,                     %%限时商店的时间
    flashsaleflaglist = [],                %%限时商店购买标记proplist [{index,1},{count,1}]
    discountsalestopday = 0,            %% 折扣商店的时间
    discountSaleFlagList = [],          %% 折扣商店购买标记
    bountytokencount = 20,              %%悬赏令令牌
    daytotalfinishbountynum = 0,
    daytotalfinishbountystarnum = 0,
    acquiregiftboxidlist = [],           %% 已经领取过的奖品码groupid数组
    monthcardlist = [],                  %% 月卡福利结构month_card
    friendList = [],                    %% 好友列表
    friendRequestList = [],             %% 好友请求列表
    friendNoticeList = [],              %% 好友通知列表
    haveFriendNotice = 0,               %% 是否有新好友通知
    onedayFriendPKCount = 0,    % 今天进行好友切磋的次数
    onedayBuyFriendPK = 0,  % 今天购买好友切磋次数的次数
    friendPKList = [],      % 今日切磋过的好友列表
    vipeverydaywelfareFlag,               %% vip每日领奖标识 在升级vip的时候会重置
    lastBeginRecoverEnergytime = 0,     %% 上一次恢复体力的时间
    toLastRecoverEnergyTime = 0,        %% 距离上一次恢复体力的时间差，客户端据此和本地时间推算上一次恢复体力的时间
    lastBeginRecoverBountytokentime = 0, %% 上一次恢复悬赏令的时间
    toLastRecoverBountyTime = 0,        %% 距离上一次恢复悬赏令的时间差
    lastBeginRecovercitySiegeTokentime = 0,  %% 上一次恢复攻城令的时间
    toLastRecoverSiegeTime = 0,              %% 距离上一次恢复攻城略地令牌的时间差
    lastBeginRecovercitySiegePlundertime = 0,  %% 上一次恢复攻城略地掠夺次数的时间
    transportationfoodenemy= [],              %%　抢粮活动仇人列表
    activityawardflaglist = [],                  %% 每天领取活动的标记list
    firstpayflaglist = [],                  %% 首次充值的标记(废弃)
    newFirstPayFlagList = [],               %% 首次充值的标记 充值表ID和充值时间
    beginningAwardInfo = [],                %% 开服七天活动记录
    equipcompose_luckpointlist = [],        %% 装备合成幸运值列表
    refreshStartCostCount = 1,              %% //add by Masker 2016/2/2 增加悬赏刷星消耗倍率
    destinyList = [],       %% 天命信息
    loopsigndays = 0,       %%七天签到累计时间
    loopsigngetawarddays = 0,               %%七天签到累计领奖时间
    lastloopsigndate = 0,   %%上次7天签到日期
    lkkitousenPasstimelist = [],            % add by Masker 2016/2/26 一骑当千 每关通关时间
    % add by Masker 2016/3/3 军团相关存档
    armyinfo=[{armyId,0},{armname,<<"default">>},{armyexittime,0},{applist,[]}],
    armyPoint =0,           %军团个人贡献，军团贡献
    armyForeverItem = [],   %% 已购买的军团永久商店物品
    armyWarAward = [],      %% 已领取的军团战事击破奖励
    buygoldsingleawardversion = 0,
    buygoldsingleawardfinishflag = [],       %%单充可领取标记
    buygoldsingleawardgetflag = 0,          %%单充领取标记
    buygoldweekawardversion = 0,
    buygoldweekawardfinishflag = [],       %%至尊签到可领取标记
    buygoldweekawardgetflag = 0,          %%至尊签到领取标记
    buygoldaccumulateawardversion = 0,
    buygoldaccumulateawardfinishflag = 0,   %%累充可领取标记
    buygoldaccumulateawardgetflag = 0,      %%累充领取标记
    plunderNoticeList = [], %% 抢粮通知列表
    havePlunderNotice = 0 , %% 是否有新抢粮通知
    dailyAwardData=[] ,
    lastRefreshTime = 0,    %% 上一次清空跨天信息的时间
    kofPoint = 0,           %% 龙虎令
    multiServerjjcMoney = 0, %% 龙钻
    getNewserverFundList = [],      %% 新服基金已领奖励列表
    lkkBuffList = [],       %% 一骑当千buff列表
    firstpaygift = 0  ,     %%是否首冲红利 0->没有 1->有
    getfirstpaygiftDate =0,         %%首冲红利领取时间20140101
    groupPruchaseCoupon = 0,        %% 跨服团购代金券 单词有拼错了  拼错了 拼错了拼错了拼错了拼错了拼错了拼错了拼错了
    lastgroupPurchaseEndTime = 0 ,  %%跨服团购的结束时间 清空代金券用
    titlelist=[],           %拥有的称号id
    titleEquipList=[],      %装备的称号id
    datebehaviorList =[],   %日期行为表
    giveJssgMoney = 0,
    vip3gift = 0 ,          %vip3奖励
    vip2gift = 0,            %30元VIP奖励
    vipgift = 0,            %任意VIP奖励
	  holidayinfo=[],
    rewardinfo=[],
    rewardScore = 0,
	  shakemoneylevel = 1,    %摇钱树等级
    bossComeontime = 0, % boss来袭信息
    bossComeonID =[],
    bossComeonKilledID = [],
    lkkBossProgerss = 0,     %%单骑挑战BOSS进度
    chanelname=[],%渠道标示
    %%评论界面相关参数
    openRatePanel_times = 0,    %%打开评论界面次数
    lastMinorVersion = 0,     %%上次客户端版本
    rateState = 0,        %%有没有评论过   0没有1有
    rateAwardState = 0  ,   %%有没有领取奖励  0 没有 1已领取
    multiserver_jjc_Count = 0, %可跨服JJC挑战次数
    multiserver_jjc_histroyIndex = -1 ,%跨服JJC 历史最高成绩 排名
    multiserver_jjc_histroyType = -1 ,%跨服JJC 历史最高成绩 排名组别
    last_multiserver_jjc_recoverTime = 0 ,  %上一次恢复跨服JJC的时间    update by Masker 2017/7/12 概念改成 开始恢复次数的基准时间 0代表没有在倒计时中
    godweaponBag = [] , %神兵背包 所有神兵的存储位置
    warcontribution = 0  ,%战功 跨服沙场点兵 ,
    warcontributionshop = [] ,  %战功商店 物品信息列表
    lastrefreshwarcontributionshoptime = 0  ,%最后免费刷战功商店时间\
    multiserver_vie_pk_count =0,
    jjchistroytoprank = -1,     %把竞技场的历史最高的等级保存到存档里 -1未上榜
    lastGetYbnum = 0,
    costgolddailyawardfinishflag = 0,       %%单日累计消费可领取标记
    costgolddailyawardgetflag = 0,          %%单日累计消费领取标记
    costgoldaccumulateawardversion = 0,
    costgoldaccumulateawardfinishflag = 0,   %%累计消费可领取标记
    costgoldaccumulateawardgetflag = 0,      %%累计消费领取标记
    birthserverid = <<"0">>,
    mergerAwardInfo=[],
    %%add by Lance 2016年12月29日 增加跨服竞技相关信息
    playerMultiserverKofInfo=[{multiserverKofKillNum,0},{multiserverKofWinNum,0},{multiserverKofTotalNum,0}],
    %% add by blackcat 修改3v3服务器信息没清除的bug，特殊处理清除下个人的3v3信息，加一个是否清除额标记
    clearkof3v3buginfo = 1,
    %add by Masker 2017/6/22 诸侯声望
    fightThronePoint = 0 ,
    %add by Masker 2017/7/12 上一次跨服竞技 初始次数给的时间
    lastMultiserverJJCBeginrevTime = 0 ,
    %add by Makser 2017/7/20 逐鹿中原荣誉商店
    lastAutoRefreshFTFameShopTime = 0 ,
    'FTFameShopList' = [],
    %add by zhang 2017/8/4  列传关卡  64
    biographiesProgerss = 39999,
    biographieschapterawardInfos = [],
    %% 存储标记的列表
    playerFlagList = [],
    passTeamBattleLevel= [],
    lastArmyBoardOpenTime = 0,   %% 上次打开军团留言时间，红点用，设计上比较重要，从PlayerLocalInfo移到PlayerSaveInfo
    rewardActivityBeginDay = 0 , %%最后一次参加的犒赏三军活动的开始时间 ,
    mulFightThroneSearch = [{ activitiBegin , 0 } , { lastRefreshtime , 0 } ,  { count , 0 }] , %逐鹿中原搜索相关属性
    mulFightThroneInternal = [{ activitiBegin , 0 } , { lastRefreshtime , 0 } ,  { count , 0 }], %逐鹿中原内政相关属性
    changegodstate=0,           %%化神经节
    changegodprogress=-1,       %%化神副本进度
    changegodscenes=[],         %%已经通关的副本
    jjcNoticeList = [],         %%竞技场战报
    havejjcNotice = 0,          %%竞技场通知已读标记
    jjcdailyList = [{jjcdailyIntegral,0},{alreadyReceive,[]}],       %%jjcdailyIntegral 竞技场每日积分 alreadyReceive 每日积分已领奖励
    kmbsSaveInfo = [],               %%仗剑除妖系统的信息结构kmbssaveinfo的proplist
    skillPointinfo = [{skillpointnum,35},{lastreftime,0}], %%玩家技能点存档结构
    transfoodseachtime = 0,
    transfoodPoint = 0,
    figureid,  %% 外形id
    allstorealreadybuylist = [[{type,2},{alreadybuylist,[]},{refpoint,0}],
        [{type,3},{alreadybuylist,[]},{refpoint,0}]], %%商店购买记录[{type,2},{alreadybuylist,[]},{refpoint,10}]
    tourData = [],
    chapterAwardList = [],      %% 剧情章节领奖标记
    sys_email_vsn=0,            %系统邮件版本儿号
    towerResetFlag = 0,         %% 爬塔活动——每日重置次数
    curTowerProgress = 0,       %% 爬塔活动——当前进度
    passTowerMs = 0,            %% 爬塔活动——通关时间
    towerInfoList = [],         %% 爬塔活动——关卡信息列表
    towerRewardFlag = [],       %% 爬塔活动——宝箱领取标记
    towerGroup = 0,             %% 爬塔活动——组
    towerRepairFlag = 0         %% 爬塔活动——数据修复标记，1是需要修复
}).

-record( kmbssaveinfo, {
    kmbsProcess = 0,            %% 当前进度，这个每日要重置的
    kmbsMaxProcess = 0,         %% 历史最高进度
    generatedBuffList = [],     %% 生成的buff数据
    treasureListInfo = [],      %% 已经领取的宝箱list
    kmbsBuffList = [],          %% 已选bufflist,attrData
    kmbsHistoryMaxStar = 0,     %% 历史最高星数
    kmbsTodayMaxStar = 0,       %% 今日最高星数
    kmbsCurStar = 0,            %% 当前星数
    kmbsEachFloorStarInfo = [], %% floorStarInfo的proplist
    kmbsCardsStateInfo = [],    %% cardsStateInfo的proplist
    kmbsCurProgressBossHp = [], %% 当前进度的boss血量,boss个数>=1
    kmbsSkillPower = 0          %% 共用怒气值
}).

-record( buffListInfo,{
    floorIndex,
    buffData = [],
    isFinish = false
}).

-record( kmbsBuffData, {
    buffIndex,
    attrData,
    starCost,
    haveBought
}).

-record(attrData,{
    type,
    value,
    valueAdd
}).

-record(treasureListInfo, {
    floorIndex,
    freeState = false,
    rechargeableState = false,
    isFinish = false
}).

-record(floorStarInfo, {
    floorIndex,
    starNum
}).

-record( cardsStateInfo, {
    cardMongoId = <<"">>,
    cardHpPercent = 1,
    cardPowerValue = 0
}).

-record( holidayinfo , {
    id,
    type, %1行为奖励 2兑换奖励
    getTimes=0%获得奖励次数

}).

-record( rewardinfo , {
    id,
    type, %1行为奖励 2兑换奖励  3终极大奖
    getTimes=0%获得奖励次数

}).

-record( dailyAwardbehaviouData ,
{
    id  ,
    getcount
}).

%%add by Lance 2017年1月3日
-record( playerMultiserverKofInfo , {
%% 只是记录本次3v3活动的信息 每次开活动都需要重置一次
    multiserverKofKillNum = 0, %跨服3v3击杀数
    multiserverKofWinNum = 0, %跨服3v3胜场数
    multiserverKofTotalNum = 0 %跨服3v3总场数
}).

-record( army_info , {
    armyId = 0 %军团ID
    ,armname = <<"default">>
    ,armyexittime = 0%退出军团时间
    ,applist=[] %申请中的军团

 %   ,armyshopinfo=[] %军团商店个人购买信息

}).
%% -------------------------------------------------
%% 月卡福利结构
%% -------------------------------------------------
-record(month_card,{
    type,           %类型 每个类型的奖励不同
    durationofdate,   % 持续的天数
    awardFlag         % 当天的领奖标示
}).

%% -------------------------------------------------
%% 装备合成幸运结构
%% -------------------------------------------------
-record(equipcompose_luckpoint,{
    star,
    luckpoint
}).


%% -------------------------------------------------
%% 抽奖的存盘结构
%% -------------------------------------------------
-record(luckydraw,{
    lastFreeTime = 0,   %上一次免费抽奖的时间
    freeCount = 0,      %免费抽奖的次数
    loopLuackDrawCount1 = 0,
    loopLuackDrawCount2 = 0,
    loopLuackDrawCount3 = 0,    %循环特殊奖励的3个计数
    totalLuakDrawCount = 0     %总共的抽奖次数
}).

%% -------------------------------------------------
%% 保存的场景掉落信息，在进入战斗场景是需要保存
%% -------------------------------------------------
-record(save_drop,{
    id,             %%场景id
    token,
    tourdata,   %% 本场目标
    saveinfo
}).
%% -------------------------------------------------
%% 好友切磋的保存信息
%% -------------------------------------------------
-record(friend_pk_info,{
    userid,
    rolemongoid,
    saveinfo
}).

%% -------------------------------------------------
%% 人物到战斗信息，需要经常刷新的
%% -------------------------------------------------
-record(player_battle_info,{
    battle_point =0,        %% 战斗力评分
    hp = 0,                 %% 血
    def = 0,                %% 防御
    mdf =0,                 %% 法防
    atk  =0,                %% 攻击
    rateHit = 0,            %% 命中
    rateDog = 0,            %% 闪避
    luckRate_a = 0,         %% 暴击
    luckRate_s = 0,         %% 暴抗
    luckDamageDeepen = 0 ,  %% 暴击伤害加成系数
    damageDeepen = 0,       %% 伤害加成
    damageReduce = 0,       %% 伤害减免
    pvpDamageDeepen = 0,    %% 对人伤害加深
    pvpDamageReduce = 0     %% 对人伤害减免
}).

%% -------------------------------------------------
%% 在线用户列表的用户信息
%%　2015/1/29 blackcat 还是要保存下state 掉线后有些临时信息是需要保存的 比如过关的道具奖励信息
%% -------------------------------------------------
-record(onlineinfo_status,{
    id,
    roleid,
    logintime,
    pid,
    online,
    serverid,
    state
}).

-record(rolemongoid2usermongoid_status,{
    rolemongoid,
    usermongoid
}).

%% -------------------------------------------------
%% 每日限制结构
%% behaviorName 行为名字对应playerbehavior表
%% award 领取的次数，1表示领取1次
%% time 当天已经进行的次数
%% content 数据信息，int的list
%% content2 数据信息，[int,int]的list
%% -------------------------------------------------
-record(daily_limit_atom,{
    behaviorName,
    award,
    time,
    content,
    content2
}).

%% -----------------------------------------
%% 成就结构
%% behaviorName 行为名字对应playerbehavior表
%% award 领取的次数，对应成就表的 taskIndex列
%% time 当天已经进行的次数
-record(achievement_info,{
    behaviorName,
    award,
    time
}).


%%------------------------------
%% 记录下摇钱树的临时信息
-record(money_tree_info,{
    free,
    gold
}).
%%------------------------------

%%------------------------------
%% 开服活动单日信息
-record(beginning_days_info,{
    day = 1,
    getAward = [],
    online = 0,
    chargeMoney = 0,
    passScene = 0,
    playerLevel = 1,
    equipLevel = 0,
    passLkk = 0,
    equipAdvLevel = 0,
    equipAdvMax = 0,
    jjcRank = 10000,
    shopRefresh = 0,
    passCampaign = 19999,
    playerBP = 0
}).

%% 合服活动单日信息
-record(merger_days_info,{
    day = 1,
    getAward = [],
    online = 0, %登录
    chargeMoney = 0,%累冲
    passScene = 0,%通关主线
    pvp = 0 ,%PVP
    jjcRank = 10000,%最高JJC排名
    shopRefresh = 0,% 云游商人刷新
    rolltree = 0 , %摇钱树
    bountyTask = 0 , % 悬赏
    playerBP = 0%最高战斗力
%%     playerLevel = 1,
%%     equipLevel = 0,
%%     passLkk = 0,
%%     equipAdvLevel = 0,
%%     equipAdvMax = 0,

%%     passCampaign = 19999,

}).

%%------------------------------
%% 一个天命信息
-record(destiny_info,{
    destinyId,
    destinyLevel
}).

%% 一类天命信息
-record(destiny_type_info,{
    destinyType,
    destinyInfoList = []
}).

%%------------------------------
-record(roleID2TableName,{
    usermongoid,
    rolemongoid,
    rolename,
    roletablename
}).

%%add by Masker 2016/2/25 一骑当千相关

-record(rolelkkioupassinfo,{
    processID ,
    processTime
}).

-record(lkkitousenPassinfo,
{
    rolemogoID,
    rolername,
    passTime,
    passMax
}).


%%add by Masker 2016-5-31 玩家有限日期行为
-record( player_date_behavior ,
{
    behaviorName ,
    startdate,
    enddate,
    id=-1 ,
    content=[],
    content_shop=[] ,%记录1个商店物品  物品索引 和购买次数的结构
    type
}
).

%%add by Masker 2017-7-17
-record( shopInfo ,
{
    itemIndex , %物品索引ID
    buyTime =-1  %购买次数
}
).


%% -----------------------------------------
%% 每日、每周单冲次数结构
%% index 对应签到index
%% finishcount 完成次数
%% getcount 领取的次数
-record( signin_count,{
    index,
    finishcount,
    awardcount
}).

%% -----------------------------------------
%% 每日历练进度单个结构
-record(dailyscene_progress,{
    id,       %% 类型
    progress, %% 进度
    isget,    %% 是否提升了进度
    lasttime, %% 上一次时间
    starInfo = []
}).



%% ---------------------------------------------------
%% 跨服组队服务器专用
-record(cowboy_Status,{
    roleid,
    heartbeat,
    timeRef,
    copysceneid,    %副本id
    multiplayerbattle_server_pid %该玩家所属的房间pid
}).

%% -------------------------------------------------
%% 跨服组队在线用户列表的用户信息
%% -------------------------------------------------
-record(msonlineinfo_status,{
    roleid,
    pid ,
    multiplayerbattle_server_pid  , %副本房间 pid 只有开始游戏以后才有
    instanceID = <<"">>%副本id
}).

%% -------------------------------------------------
%% 跨服组队战斗信息
%% -------------------------------------------------
-record(multiplayer_battleinfo,{
    roleMongoId,
    roleLevel,
    roleBattlePoint
}).
%% ---------------------------------------------------

-define(CARD_SUMMON_NUM, 10).
-define(CHANGE_ROLE_NAME_MONEY,100).
-define(CARD_MAX_ADVLEVEL,100).
-define(ADD_ENERGY_TIME,1). %每进一次打斗场景扣的体力
-define(MAX_ENERGY,120).
-define(SAVEROLEINFOKEY,saveRoleInfokey).
-define(SAVE_KEY(Key) , put( ?SAVEROLEINFOKEY,  get(saveRoleInfokey) ++ Key )).

%%-define(PLAYER_VERSION,74). %% modi by 2019/1/9 东离剑项目存档号重新初始化
%%-define(PLAYER_VERSION,1). %% 加抢粮代币和搜索次数
%%-define(PLAYER_VERSION,2). %% 增加兑换商城结构
%%-define(PLAYER_VERSION,3). %% 增加游历进度结构tourData
%%-define(PLAYER_VERSION,4). %% 增加剧情章节奖励标记chapterAwardList
%%-define(PLAYER_VERSION,5). %% 系统邮件版本号
-define(PLAYER_VERSION,6). %% 增加七罪塔活动的存盘数据



%↘↘↘↘↘↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↙↙↙↙
%→→→→→ PLAYER_VERSION 必须与 playersaveinfo 的 version 保持一致 ←←←←←
%↗↗↗↗↗↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↖↖↖↖
-endif.