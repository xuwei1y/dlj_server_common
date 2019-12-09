%%%-------------------------------------------------------------------
%%% @author xuwei
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 二月 2019 20:10
%%%-------------------------------------------------------------------

-define(PLAYER_LEVEL_TABLE, player_level_table).

%装备位置
-define(Kit_Begin,?Kit_Equip_Begin).%所有装备开始位置

-define(Kit_Equip_Begin,?Kit_Equip0).%身上的装备开始位置
-define(Kit_Equip0,0).
-define(Kit_Equip1,1).
-define(Kit_Equip2,2).
-define(Kit_Equip3,3).
-define(Kit_Equip4,4).
-define(Kit_Equip5,5).
-define(Kit_Equip6,6).%%武器
-define(Kit_Equip7,7).%%魔剑剑柄
-define(Kit_Equip8,8).%%魔剑剑格
-define(Kit_Equip9,9).%%魔剑剑刃
-define(Kit_Equip_End,?Kit_Equip9).
-define(Kit_Equip_Num,?Kit_Equip_End - ?Kit_Equip_Begin + 1).

-define(Kit_Card_Begin,?Kit_Card0).%卡牌起始位置
-define(Kit_Card0,6).
-define(Kit_Card1,7).
-define(Kit_Card2,8).
-define(Kit_Card3,9).
-define(Kit_Card4,10).
-define(Kit_Card5,11).
-define(Kit_Card_End,?Kit_Card2).%卡牌结束位置
-define(Kit_Card_Num,?Kit_Card_End - ?Kit_Card_Begin + 1).

-define(Kit_Fashion_Begin,?Kit_Fashion0).%时装开始位置
-define(Kit_Fashion0,20).
-define(Kit_Fashion_End,?Kit_Fashion0).%时装结束位置
-define(Kit_Fashion_Num,?Kit_Fashion_End - ?Kit_Fashion_Begin + 1).

-define(Kit_MagicWing_Begin,?Kit_MagicWing0).%神翼开始位置
-define(Kit_MagicWing0,30).
-define(Kit_MagicWing_End,?Kit_MagicWing0).%神翼结束位置
-define(Kit_MagicWing_Num,?Kit_MagicWing_End - ?Kit_MagicWing_Begin + 1).

-define(Kit_MagicWeapon_Begin,?Kit_MagicWeapon00).%神翼开始位置
-define(Kit_MagicWeapon00,40).
-define(Kit_MagicWeapon01,41).
-define(Kit_MagicWeapon10,42).
-define(Kit_MagicWeapon11,43).
-define(Kit_MagicWeapon20,44).
-define(Kit_MagicWeapon21,45).
-define(Kit_MagicWeapon30,46).
-define(Kit_MagicWeapon31,47).
-define(Kit_MagicWeapon40,48).
-define(Kit_MagicWeapon41,49).
-define(Kit_MagicWeapon50,50).
-define(Kit_MagicWeapon51,51).
-define(Kit_MagicWeapon60,52).
-define(Kit_MagicWeapon61,53).
-define(Kit_MagicWeapon70,54).
-define(Kit_MagicWeapon71,55).
-define(Kit_MagicWeapon80,56).
-define(Kit_MagicWeapon81,57).
-define(Kit_MagicWeapon90,58).
-define(Kit_MagicWeapon91,59).
-define(Kit_MagicWeapon_End,?Kit_MagicWeapon91).%神翼结束位置
-define(Kit_MagicWeapon_Num,?Kit_MagicWeapon_End - ?Kit_MagicWeapon_Begin + 1).

-define(Kit_End,?Kit_Fashion_End).%所有装备结束位置
-define(Kit_Num,?Kit_Equip_Num + ?Kit_Card_Num + ?Kit_Fashion_Num + ?Kit_MagicWing_Num).

%% -------------------------------------------------
%% 人物经验属性表
%% -------------------------------------------------
-record(player_level_table,{
    level,          %人物等级
    exp,             %升到人物等级+1级需要的经验
    hp=0,
    atk=0,
    pdef=0,
    mdef=0,
    ratehit=0,
    ratedog=0,
    luckrate=0,
    luckvalue=0

}).


-define(MaxEmeailItems,common_tool:get_max_email_items(3)).%邮件道具槽位数量开关


%新邮件格式
-record(email, {
    rolemongodbid,
%%     version = 0,
    emailid,
    type,
    logtype,
    createtime,
    isChecked,      %% 已读、未读
    gotAward,       %% 领取状态
    createDate,
    content,
    sentrolename = null,
    accessorys = []
}).

-record(email_accessory, {
    type,
    id,
    num
}).

-record(sys_email_extras, {
    roleid,
    accessory= #email_accessory{}
}).