%%%-------------------------------------------------------------------
%%% @author anyongbo
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 一月 2019 17:10
%%%-------------------------------------------------------------------
-author("anyongbo").
-include("dbCommonFun.hrl").

%% 东离剑项目拆分存档，把存档拆分成为5张表，分别是显示信息表（需要同步给其他人的信息）,道具信息表，活动信息表，好友信息表，其他信息表
%% 用于优化存档的写入速度问题

%% 显示信息字段名 所有的查询条件都应该在这个list里面，其他几个表只用_id做查询
-define( RoleShowInfo , [roleid,userid,name,sex,level,advlevel,equipItems,weapontype,magicWeaponDao,magicWeaponGong, destinyList,
                                            battleinfo,titleEquipList,godweaponBag,armyinfo,mainProgerss,chapterAwardList, mainStoryProgress,campaignProgerss,biographiesProgerss,lkkitousenMaxProcess,
                                            vipLevel,changegodstate,fashionList,lastSaveTime,skillPointinfo,birthserverid,figureid,tourData]).
%%道具信息字段名
-define( RoleItemsInfo,[ roleid,cardBagItems,items,surpassBagItems,godweaponBag ] ).

%%活动信息字段名
-define( RoleActivityInfo ,[ roleid,holidayinfo,dailyLimitVersion,dailyLimitScore,dailyLimitList,achievementList,totalAchievement,
    datebehaviorList,passTeamBattleLevel,dailyBattleProgress,towerResetFlag,curTowerProgress,passTowerMs,towerInfoList,towerRewardFlag,towerGroup,towerRepairFlag ]).

%%好友信息字段名
-define( RoleFriendInfo,[ roleid,friendList,friendRequestList,friendNoticeList,haveFriendNotice,friendPKList,onedayFriendPKCount,onedayBuyFriendPK ]).

%%其他信息字段名
-define( RoleOtherInfo,[ roleid,
    version,
    exp,
    money,
    gold,
    silvernote,
    energy,
    newPlayerGuide,
    lastPlayerGuide,
    guideInfos,
    freeshakemoneytreeTime,
    accumulateSignTime,
    sceneInfos,
    goldLuckyDraw,
    jewelLuckyDraw,
    lastContinueLuckyDrawFreeTime,
    luckydrawPoint,
    jjcMoney,
    onedayJionJjcCount,
    onedayBuyJjcCount,
    vipExp,
    vipAward,
    citySiegeTokenNum,
    citySiegePlunderNum,
    citySiegeMoney,
    citySiegeProgerss,
    citySiegeLevel,
    currentCampaingID,
    bountyTask,
    bountyMoney,
    eatbunsflag,
    lastAutoRefreshWanderShopTime,
    wanderShopList,
    sceneawardInfos,
    chapterawardInfos,
    campaignchapterawardInfos,
    lkkitousenPoint,
    lkkitousenProcess,
    lkkitousenRefreshCount,
    lkkitousenMaxProcess,
    signinid,
    signingroupid,
    lastsignintime,
    grandtotalsignintime,
    grandtotalsigninstate,
    flashsalestopday,
    flashsaleflaglist,
    discountsalestopday,
    discountSaleFlagList,
    bountytokencount,
    daytotalfinishbountynum,
    daytotalfinishbountystarnum,
    acquiregiftboxidlist,
    monthcardlist,
    vipeverydaywelfareFlag,
    lastBeginRecoverEnergytime,
    toLastRecoverEnergyTime,
    lastBeginRecoverBountytokentime,
    toLastRecoverBountyTime,
    lastBeginRecovercitySiegeTokentime,
    toLastRecoverSiegeTime,
    lastBeginRecovercitySiegePlundertime,
    transportationfoodenemy,
    activityawardflaglist,
    firstpayflaglist,
    newFirstPayFlagList,
    beginningAwardInfo,
    equipcompose_luckpointlist,
    refreshStartCostCount,
    loopsigndays,
    loopsigngetawarddays,
    lastloopsigndate,
    lkkitousenPasstimelist,
    armyPoint,
    armyForeverItem,
    armyWarAward,
    buygoldsingleawardversion,
    buygoldsingleawardfinishflag,
    buygoldsingleawardgetflag,
    buygoldweekawardversion,
    buygoldweekawardfinishflag,
    buygoldweekawardgetflag,
    buygoldaccumulateawardversion,
    buygoldaccumulateawardfinishflag,
    buygoldaccumulateawardgetflag,
    plunderNoticeList,
    havePlunderNotice,
    dailyAwardData,
    lastRefreshTime,
    kofPoint,
    multiServerjjcMoney,
    getNewserverFundList,
    lkkBuffList,
    firstpaygift,
    getfirstpaygiftDate,
    groupPruchaseCoupon,
    lastgroupPurchaseEndTime,
    titlelist,
    giveJssgMoney,
    vip3gift,
    vip2gift,
    vipgift,
    rewardinfo,
    rewardScore,
    shakemoneylevel,
    bossComeontime,
    bossComeonID,
    bossComeonKilledID,
    lkkBossProgerss,
    chanelname,
    openRatePanel_times,
    lastMinorVersion,
    rateState,
    rateAwardState,
    multiserver_jjc_Count,
    multiserver_jjc_histroyIndex,
    multiserver_jjc_histroyType,
    last_multiserver_jjc_recoverTime,
    warcontribution,warcontributionshop,
    lastrefreshwarcontributionshoptime,
    multiserver_vie_pk_count,
    jjchistroytoprank,
    lastGetYbnum,
    costgolddailyawardfinishflag,
    costgolddailyawardgetflag,
    costgoldaccumulateawardversion,
    costgoldaccumulateawardfinishflag,
    costgoldaccumulateawardgetflag,
    mergerAwardInfo,
    playerMultiserverKofInfo,
    clearkof3v3buginfo,
    fightThronePoint,
    lastMultiserverJJCBeginrevTime,
    lastAutoRefreshFTFameShopTime,
    biographiesProgerss,
    biographieschapterawardInfos,
    playerFlagList,
    'FTFameShopList',
    lastArmyBoardOpenTime,
    rewardActivityBeginDay,
    mulFightThroneSearch,
    mulFightThroneInternal,
    changegodscenes,
    changegodprogress,
    jjcNoticeList,
    jjcdailyList,
    kmbsSaveInfo,
    transfoodseachtime,
    transfoodPoint,
    allstorealreadybuylist,
    sys_email_vsn
    ]).


%%role表的名字
-define( RoleShowTableCollection , { ?get_database(?MAINDB) , <<"RoleShowTable">> }) .
-define( RoleItemTableCollection , { ?get_database(?MAINDB) , <<"RoleItemTable">> }) .
-define( RoleActivityITableCollection , { ?get_database(?MAINDB) , <<"RoleActivityITable">> }) .
-define( RoleFriendTableCollection , { ?get_database(?MAINDB) , <<"RoleFriendTable">> }) .
-define( RoleOtherTableCollection , { ?get_database(?MAINDB) , <<"RoleOtherTable">> }) .

-define(RoleTableNames, [ roleShowTable,  roleItemTable, roleActivityITable, roleFriendTable, roleOtherTable ] ).

get_info_by_roletablename(RoleTableName) ->
    case RoleTableName of
        roleShowTable->
            ?RoleShowInfo;
        roleItemTable->
            ?RoleItemsInfo;
        roleActivityITable->
            ?RoleActivityInfo;
        roleFriendTable->
            ?RoleFriendInfo;
        roleOtherTable->
            ?RoleOtherInfo
end.

get_table_by_roletablename(RoleTableName) ->
    case RoleTableName of
        roleShowTable->
            ?RoleShowTableCollection;
        roleItemTable->
            ?RoleItemTableCollection;
        roleActivityITable->
            ?RoleActivityITableCollection;
        roleFriendTable->
            ?RoleFriendTableCollection;
        roleOtherTable->
            ?RoleOtherTableCollection
    end.
