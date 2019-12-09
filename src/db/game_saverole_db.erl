%%%-------------------------------------------------------------------
%%% @author anyongbo
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 一月 2019 19:28
%%%-------------------------------------------------------------------
-module(game_saverole_db).
-author("anyongbo").
%% API
-export([create_player/4]).
-export([load_one_roleinfo/1,load_one_roleinfo/2,load_one_roleinfo/3,load_roleid/2,load_roleid/2,load_roleshowinfo/3,update_roleinfo_by_key_new/3,
    load_roleshowinfo_open/2,load_roleshowinfo_open/3,load_roleshowinfo_open/4,load_multiplayer_infos/2,
    load_multiplayer_infos/3,load_multiplayer_infos/5, get_role_count/1]).
-export([update_role_info/1,update_roleinfo_by_key/3,delete_one_role/3]).


-include("commondatastruct.hrl").
-include("playerdatastruct.hrl").
-include("role_table_struct.hrl").

%% 新建角色
create_player(UserID,ServerID,UserName, Parameters) ->
    Info = proplists:get_value(info, Parameters),
    Sex = proplists:get_value(sex, Parameters),
%%    lager:debug("CreatePlayer: ~p~n",[{UserID, ServerID, UserName, Info}]),
    SID =  proplists:get_value( serverID , Info ) ,
    %Name = proplists:get_value(rolename,Info),
    Name = game_tool:to_binary(integer_to_list(game_tool:datetime_to_timestamp(calendar:local_time()))++integer_to_list(rand:uniform(10000))),
    Player = #playersaveinfo{ version = ?PLAYER_VERSION, username = UserName, name = Name, sex = Sex,lastSaveTime = game_tool:local_seconds(),
        dailyLimitVersion = 0, userid = UserID,lastRefreshTime = game_tool:local_seconds(),figureid = game_config:get_player_birth_figureid(),sys_email_vsn= game_email:get_sys_email_vsn()},
    PlayerPopList = game_tool:record_to_proplist(Player,record_info(fields, playersaveinfo)),
    [_|TempPlayer] = PlayerPopList,
    TempPlayer1 = lists:sort(TempPlayer),
    % 出生给张卡牌
    BirthCardID = game_config:get_player_birth_give_card(),
    [_,BirthCard] = game_item:create_item(BirthCardID,1),
    NewBirthCard = lists:keyreplace(panelPos,1,BirthCard,{panelPos,?Kit_Card0}),
    %% 出生默认装备神翼
%%    MagicWingID = game_config:get_magicwing_birth_equip(),
%%    [_,BirthMagicWing] = game_item:create_item(MagicWingID,1),
%%    NewBirthMagicWing = lists:keyreplace(panelPos,1,BirthMagicWing,{panelPos,?Kit_MagicWing0}),
    LuckyDrawInfo = #luckydraw{},
    [_|LuckyDrawInfo2]  =  game_tool:record_to_proplist(LuckyDrawInfo,record_info(fields, luckydraw)),

    Kmbssaveinfo = #kmbssaveinfo{},
    [_|Kmbssaveinfo2]  =  game_tool:record_to_proplist(Kmbssaveinfo,record_info(fields, kmbssaveinfo)),
    TempPlayer11 = lists:keyreplace(kmbsSaveInfo,1,TempPlayer1,{kmbsSaveInfo,Kmbssaveinfo2}),
    TempPlayer2 = lists:keyreplace(goldLuckyDraw,1,TempPlayer11,{goldLuckyDraw,LuckyDrawInfo2}),
    TempPlayer3 = lists:keyreplace(jewelLuckyDraw,1,TempPlayer2,{jewelLuckyDraw,LuckyDrawInfo2}),
%%    TempPlayer5 = lists:keyreplace(cardBagItems,1,TempPlayer4,{cardBagItems,[BirthCard]}),
    TempPlayer6 = lists:keyreplace(equipItems,1,TempPlayer3,{equipItems,[NewBirthCard]}),
    TempPlayer7 = lists:keyreplace(birthserverid,1,TempPlayer6,{birthserverid,  SID }),
    TempPlayer77 = game_player_battle:refresh_newplayer_battleinfo(TempPlayer7),
    %=========================================
    %% 检测是否已经创建过角色
    Selector = #{ <<"userobjectid">>=>UserID , <<"serverID">>=>ServerID ,<<"info.birthserverid">>=>SID } ,
    RoleNum = count( ?RoleShowTableCollection , Selector ) ,
    Result =
        if
            RoleNum > 0 ->
                roleexist;
            true->
                ServerID_list =  integer_to_list( game_tool:get_serverid() ),
                Selector1 = #{ <<"info.name">>=>Name } ,
                RoleNum1 = count( ?RoleShowTableCollection , Selector1 ) ,
%%                lager:debug("create_player check name ~p~n",[{Name , ServerID_list}]),
                if
                    RoleNum1>0->
                        exist ;
                    true ->
                        %得到当前库的名字
%%                        lager:debug("~p~n", [TempPlayer7]),
                        Id = mongo_id_server:object_id(),
                        IdStr = mongo_tool:objectid_to_binary_string(Id),
                        TempPlayer8 = lists:keyreplace(roleid,1,TempPlayer77,{roleid,IdStr}),
                        MapData = mongo_tool:proplist_to_mongodbMap(TempPlayer8),
                        CreatTime = game_tool:local_seconds() ,
                        NewUser = #{ <<"_id">>=>IdStr ,  <<"userobjectid">>=>UserID ,<<"serverID">>=>ServerID , <<"info">>=>MapData  ,<<"createtime">>=>CreatTime} ,
                        save_new_role(NewUser),
%%                        Res = insert_Safemod( ?RoleTableCollection , NewUser ) ,
%%                        lager:error("create_player check name ~p~n",[{Name , IdStr,Res}]),
                        Doc = mongo_tool:map_to_proplist( #{ <<"_id">>=>IdStr ,  <<"userobjectid">>=>UserID ,<<"serverID">>=>ServerID , <<"info">>=>MapData  ,<<"createtime">>=>CreatTime}) ,
                        Doc
                end
        end,

%%    lager:debug("Result ~p~n",[Result]),
    Result .

%保存玩家的一个存档
save_new_role(RoleMap) ->
    lists:foreach( fun(Name) ->  save_new_role(Name,RoleMap)        end,?RoleTableNames )    .

filter_role_info (RoleInfo,FilterList ) ->
    Map = lists:map(    fun(Key) -> { atom_to_binary(Key,utf8) ,maps:get( atom_to_binary(Key,utf8),RoleInfo) }  end,FilterList),
    mongo_tool:proplist_to_mongodbMap(Map).

%保存信息 并且使用任务队列形式，保证原子性
save_new_role(TableName,RoleMap)->
    #{ <<"info">>:=RoleInfo,<<"_id">>:=RoleId } = RoleMap,
    RoleShowInfo = filter_role_info(RoleInfo,get_info_by_roletablename(TableName)),
    NewRoleMap = maps:update( <<"info">>, RoleShowInfo,RoleMap ),
    Res = game_databasePool:insert_oneEx(RoleId,get_table_by_roletablename(TableName),NewRoleMap,true),
    if
        Res == false->
%%            lager:debug("save_player  roleShowTable check name ~p~n",[{RoleId,Res}]);
            nothing;
        true->
            nothing
    end.


%%根据条件读取单个文档，如果条件包含在多个表中，需要查询多表
-spec load_one_roleinfo(map()) -> map().
load_one_roleinfo(Selector)->
    load_one_roleinfo(Selector,#{}).
load_one_roleinfo(Selector,Projector)->
    load_one_roleinfo(Selector,Projector,primary).
%%读取存档信息Selector 条件 Projector要读取的列,需要分许查询条件，看查询条件是否带_id，不带_id的话要先把_id从showinfo表读出来，
%%其他的表只能通过_id加载
-spec load_one_roleinfo(map(),map(),atom()) -> map().
load_one_roleinfo(Selector,Projector,ReadMode)->
    SelKeys = common_tool:get_map_keys(Selector),
    Tables = get_role_tables_by_projector(Projector),
    HaveId = lists:member(<<"_id">>,SelKeys),
    case HaveId of
        true ->
            Id = maps:get(<<"_id">>,Selector),
            load_one_roleinfo_by_id(Id,Projector,Tables,ReadMode);
        false ->
            load_one_roleinfo_noid(Selector,Projector,ReadMode)
    end.

%读取存档，查询条件不带_id
load_one_roleinfo_noid(Selector,Projector,ReadMode)->
    Tables = get_role_tables_by_projector(Projector),
    %读取_id，如果有showinfo表的查询内容也一起查询出来
    {_id,ShowInfoMap} =
        case  lists:member( roleShowTable,Tables ) of
            true ->
                load_roleshowinfo(Selector,Projector,ReadMode);
            false ->
                {load_roleid(Selector,ReadMode),#{}}
        end,
    if
        _id =/= <<"0">> ->
            % 把roleshow表去除
            NewTables = lists:filter( fun(T) -> T=/= roleShowTable end,Tables),
            InfoMap = load_one_roleinfo_by_id(_id,Projector,NewTables,ReadMode),
            if
                InfoMap == notexist ->
                    notexist;
                InfoMap =/= #{} ->
                    %#{<<"info">>:=Info1 } = ShowInfoMap,
                    %#{<<"info">>:=Info2 } = InfoMap,
                    Info1 = maps:get(<<"info">>,ShowInfoMap,#{}),
                    Info2 = maps:get(<<"info">>,InfoMap,#{}),
                    NewInfo = maps:merge(Info1,Info2),
                    maps:update( <<"info">>,NewInfo, ShowInfoMap);
                true ->
                    InfoMap
            end;
        true->
            notexist
    end.

load_one_roleinfo_by_id(Id,Projector,Tables,ReadMode)->
    InfoMap =
        lists:foldl(
            fun(T, RoleInfoMap)->
                MapData = find_one_ReadMode( ReadMode,get_table_by_roletablename(T) , #{<<"_id">> => Id} , Projector ) ,
                if
                    map_size(MapData) > 0->
                        if
                            map_size(RoleInfoMap) == 0->
                                MapData;
                            true ->
                                %#{<<"info">>:=Info } = MapData,
                                Info = maps:get(<<"info">>,MapData,#{}),
                                %#{<<"info">>:=OldInfo } = RoleInfoMap,
                                OldInfo = maps:get(<<"info">>,RoleInfoMap,#{}),
                                NewInfo = maps:merge(Info,OldInfo),
                                if
                                    map_size(NewInfo) == 0->
                                        RoleInfoMap;
                                    map_size(OldInfo) == 0->
                                        maps:put( <<"info">>,NewInfo, RoleInfoMap);
                                    true ->
                                        maps:update( <<"info">>,NewInfo, RoleInfoMap)
                                end
                        end;
                    true ->
%%                        lager:error("-----------------load_one_roleinfo_by_id error ~p table not found this roleinfo ~p~n",[T,Id]),
                        RoleInfoMap
                end
            end,#{},Tables)  ,
    if
        InfoMap == #{}->
            notexist;
        true ->
            InfoMap
    end.

load_roleid(Selector,ReadMode)->
    Projector = #{ <<"_id">>=>true } ,
    RoleMapData = find_one_ReadMode( ReadMode,?RoleShowTableCollection , Selector , Projector ) ,
    if
        map_size(RoleMapData) > 0 ->
            #{ <<"_id">>:=ID } = RoleMapData ,
            ID;
        true ->
            <<"0">>
    end.


load_roleshowinfo(Selector,Projector,ReadMode) ->
    % 查询showinfo必须把_id查出来，查询其他的表时需要用到
    NewProjector = maps:remove(<<"_id">>,Projector),
    RoleMapData = load_roleshowinfo_open(Selector , NewProjector, ReadMode ) ,
    if
        map_size(RoleMapData) > 0->
            #{ <<"_id">>:=ID } = RoleMapData ,
            {ID,RoleMapData};
        true ->
            {<<"0">>,#{}}
    end.
load_roleshowinfo_open(Selector,Projector) ->
    load_roleshowinfo_open(Selector,Projector,primary).
load_roleshowinfo_open(Selector,Projector,ReadMode) ->
    find_one_ReadMode(ReadMode, ?RoleShowTableCollection , Selector , Projector ).
load_roleshowinfo_open(Selector,Projector,Skip ,Limit) ->
    find( ?RoleShowTableCollection , Selector , Projector , Skip , Limit ).


%% 获得角色数量
get_role_count(Selector) ->
    count(  ?RoleShowTableCollection , Selector ).

% 根据要读取的列分析中都要从什么表中读取数据
-spec get_role_tables_by_projector(map()) -> list().
get_role_tables_by_projector(#{})->
    ?RoleTableNames;
get_role_tables_by_projector(Projector)->
    KList = common_tool:get_map_keys(Projector),
    lists:foldl(
        fun(T,Tables) ->
            F = fun(E)  ->
                AllKey = common_tool:to_list(E),
                Pos = length("info.") + 1,
                KeyName = string:substr(AllKey, Pos),
                KeyAtom = common_tool:to_atom(KeyName),
                TableKeyAtom = common_tool:to_atom(T),
                TableNameList = get_info_by_roletablename(TableKeyAtom),
                Result = lists:member( KeyAtom , TableNameList),
                Result
                end,
            case lists:any( F, KList ) of
                true ->
                    lists:append(Tables,[T]);
                _->
                    Tables
            end
        end ,[],?RoleTableNames ).


get_role_table_by_key(Key) ->
    lists:filter(
        fun(T) ->
            lists:member( Key , get_info_by_roletablename( common_tool:to_atom(T)))
        end ,?RoleTableNames ).

%%根据条件读取多个文档，用于pk，添加好友，活动开启时读取参加活动人员信息等场合
%%把需要多人读取的信息都存在了showroleinfo表中，所有读取多人信息只读取这一张表就可以了，在后面的修改过程中也要遵守这一准则
%%原来有些需求需要读取多人完整的存档信息，9377的gm工具，现在不用了，不考虑了，如有需要，添加新的读取函数
-spec load_multiplayer_infos(map(),map(),atom()) -> list().

load_multiplayer_infos(Selector , Projector)->
    load_multiplayer_infos(Selector , Projector , primary).
load_multiplayer_infos(Selector , Projector , ReadMode)->
    find_ReadMode(ReadMode, ?RoleShowTableCollection , Selector , Projector ).
load_multiplayer_infos(Selector , Projector , Skip, Limit, ReadMode)->
    find_ReadMode(ReadMode, ?RoleShowTableCollection , Selector , Projector, Skip, Limit).


%%更新存档函数，为了减少数据库操作次数，存档改完每一天通讯消息结束后把这次一消息需要保存的数据一起存盘，但是嵌套数组结构不能支持批量修改
%%所有采取set更新所有的文档，通过消耗带宽来优化效率，这样做会大量的减少update次数，会不会引起带宽的问题
%%需要观察,如果单个表还是有update效率问题，要再次分表
%%update使用任务链模式，保持原子性
update_role_info(State)->
    if
        is_record(State,user_status) ->
            case  get(?SAVEROLEINFOKEY) of
                [] ->
                    nothing;
                SaveKey ->
                    RoleId = State#user_status.roleobjectid,
%%                    lager:debug("----------update_role_info savekey-----------~p~n",[SaveKey]),
                    SaveKey1 = lists:usort(SaveKey), % 去重
%%                    lager:debug("----------update_role_info savekey1-----------~p~n",[SaveKey1]),
                    RoleInfo = State#user_status.roleinfo,
                    SaveInfo = lists:filter( fun({K,_})->  lists:member(K,SaveKey1)  end,RoleInfo ),
                    lists:foreach( fun(T) -> update_role_info(RoleId,T,SaveInfo) end,?RoleTableNames )
            end;
        true ->
            nothing
    end.

-spec update_role_info(binary(),atom(),list())->any().
update_role_info(RoleId,TableName,SaveInfo)->
    Selector = #{<<"_id">> => RoleId},
    UpdateList =
        lists:foldl(
            fun(Key,L) ->
                case  proplists:get_value(Key,SaveInfo) of
                    undefined ->
                        L;
                    Value ->
                        TrueKey = "info." ++ atom_to_list(Key),
                        L ++ [{list_to_binary(TrueKey),Value}]
                end
            end,[],get_info_by_roletablename(TableName)),
    CommandDoc = #{<<"$set">> => mongo_tool:proplist_to_mongodbMap(UpdateList) },
    game_databasePool:updateEx(RoleId, get_table_by_roletablename(TableName), Selector,CommandDoc).


update_roleinfo_by_key(State,Key,NewValue) ->
    RoleID = State#user_status.roleobjectid,
%%    lager:debug("update_roleinfo_by_key thekey~p~n",[{RoleID,Key,NewValue}]),
    Selector = #{ <<"_id">>=>RoleID } ,
    TrueKey = "info." ++ atom_to_list(Key),
    UpdateDoc = { <<"$set">> , { list_to_binary( TrueKey) , NewValue } } ,
    [TableName] = get_role_table_by_key(Key),
    game_databasePool:updateEx(RoleID, get_table_by_roletablename(TableName), Selector,UpdateDoc).

update_roleinfo_by_key_new(RoleID,Key,NewValue) ->
%%    lager:debug("update_roleinfo_by_key thekey~p~n",[{RoleID,Key,NewValue}]),
    Selector = #{ <<"_id">>=>RoleID } ,
    TrueKey = "info." ++ atom_to_list(Key),
    UpdateDoc = { <<"$set">> , { list_to_binary( TrueKey) , NewValue } } ,
    [TableName] = get_role_table_by_key(Key),
    game_databasePool:updateEx(RoleID, get_table_by_roletablename(TableName), Selector,UpdateDoc).

delete_one_role(UserID, ServerID, SID)->
    Selector = #{<<"userobjectid">>=>UserID , <<"serverID">>=>ServerID},
    lists:foreach( fun(Name) ->
        delete(get_table_by_roletablename(Name),Selector)
                   end,?RoleTableNames ).
