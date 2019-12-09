%%%-------------------------------------------------------------------
%%% @author anyongbo
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 十月 2018 17:27
%%%-------------------------------------------------------------------
-module(common_tool). 
-author("anyongbo").

%% API
-compile(export_all).


seed()->
    rand:seed(exs1024).

-spec uniform(N :: pos_integer()) -> X :: pos_integer().
uniform(N) ->
    rand:uniform(N).

now()->
    erlang:timestamp().

json_encode( Object ) ->
    jsone:encode( Object ) .
json_encode( Object  , Options ) ->
    jsone:encode( Object  , Options ) .
json_decode( Json_IoStr ) ->
    jsone:decode( Json_IoStr ) .
json_decode( Json_IoStr  , Options ) ->
    jsone:decode( Json_IoStr , Options ) .
%% 向上取整
ceil(N) ->
    T = trunc(N),
    case N == T of
        true -> T;
        false -> 1+T
    end.

%% 向下取整
floor(N) ->
    T = trunc(N),
    case N<T of
        true ->T -1;
        _ -> T
    end.
record_to_proplist(Record, Fields)->
  record_to_proplist(Record, Fields, '__record').

record_to_proplist(Record, Fields, TypeKey)
  when tuple_size(Record) - 1 =:= length(Fields) ->
  lists:zip([TypeKey | Fields], tuple_to_list(Record)).

binary_concat(List) ->
    binary_concat(<<>>, List).


binary_concat(B,[H|T])->
    Tail = to_binary(H),
    binary_concat(<<B/binary,Tail/binary>>,T);
binary_concat(B,_) ->
    B.



to_binary(Term) ->
    if
        is_binary(Term) ->
            Term;
        is_atom(Term) ->
            atom_to_binary(Term, utf8);
        is_integer(Term) ->
            integer_to_binary(Term);
        is_list(Term) ->
            list_to_binary(Term);
        is_tuple(Term) ->
            List = tuple_to_list(Term),
            binary_concat([to_binary(Item) || Item <- List]);
        true ->
            Term
    end.

to_integer(Term) ->
    if
        is_binary(Term) ->
            binary_to_integer(Term);
        is_integer(Term) ->
            Term;
        is_list(Term) ->
            list_to_integer(Term);
        true ->
            Term
    end.

to_list(Term) ->
    if
        is_binary(Term) ->
            binary_to_list(Term);
        is_integer(Term) ->
            integer_to_list(Term);
        is_list(Term) ->
            Term;
        true ->
            Term
    end.

to_atom(Value) ->
    if
        is_binary(Value) ->
            binary_to_atom(Value,utf8 );
        is_atom(Value) ->
            Value;
        is_list(Value) ->
            list_to_atom(Value);
        true->
            Value
    end.

goodbye() ->
    case get(gproc_key) of
        undefined ->
            ok;
        L ->
            lists:foreach(
                fun(X) ->
                    try gproc:unreg(X) of
                        _ -> ok
                    catch
                        _:_:Stacktrace ->
                            lager:error("game_tool goodbye ~p~n",[{Stacktrace}]) ,
                            skip
                    end
                end,
                L
            )
    end.

get_time_now() ->
    {M, S, _} = os:timestamp(),
    M * 1000000 + S.

to_json_term(Result) ->
    Result.

%%seneMsg_to_all_client(MsgName,Paramters)->
%%    ChildServers = ets:tab2list(?GS_SERVER_RECORD),
%%    lists:foreach( fun(X) ->
%%        gen_server:cast({worldserver_client_genserver,proplists:get_value(servernode,X)}
%%                        ,{recivemsg,MsgName,Paramters})
%%        end
%%        ,  ChildServers).

update_lists(List,Value,Key )->
    F1 = fun(X)->
        GetValue_F1 =  proplists:get_value( Key , X ) ,
        GetValue2_F1 =  proplists:get_value( Key , Value ) ,
        GetValue_F1=:=GetValue2_F1
         end,
    IsHave = lists:any( F1 , List) ,
    if IsHave=:=true->
            F=fun(X)->
                GetValue =  proplists:get_value( Key , X ) ,
                GetValue2 =  proplists:get_value( Key , Value ) ,
                if
                    GetValue =:= GetValue2->
                        Value;
                    true->
                        X
                end
              end,
            lists:map(F , List );
        true->
            lists:append(List,[Value])
    end.




% 8区时间 返回的是秒数
local_seconds() ->
    {MegaSecs,Secs,_MicroSecs}=os:timestamp(),
    1000000*MegaSecs + Secs + 8*60*60.
%%%--------------------------------------------------------
%% 根据一个日期获得上一个周几的日期，如果这个日期就是周几就返回这个日期
%%%--------------------------------------------------------
get_last_week_data(Year,Month,Day,LastWeek) ->
    NowWeek = calendar:day_of_the_week(Year,Month,Day),
    SpaceDays =
        if LastWeek > NowWeek ->
            NowWeek + 7 - LastWeek;
            true ->
                NowWeek - LastWeek
        end,
    NowDays = calendar:date_to_gregorian_days(Year,Month,Day),
    calendar:gregorian_days_to_date(NowDays-SpaceDays).

%%%--------------------------------------------------------
%% 根据一个日期获得下一个周几的日期，如果这个日期就是周几就返回这个日期
%%%--------------------------------------------------------
get_next_week_data(Year,Month,Day,NextWeek) ->
    NowWeek = calendar:day_of_the_week(Year,Month,Day),
    SpaceDays =
        if NextWeek < NowWeek ->
            NextWeek + 7 - NowWeek;
            true ->
                NextWeek - NowWeek
        end,
    NowDays = calendar:date_to_gregorian_days(Year,Month,Day),
    calendar:gregorian_days_to_date(NowDays+SpaceDays).

%获得本周一0点的时间戳
get_thisweek1_timestamp()->
    {{Y,M,D},{H,Mi,S}} = calendar:local_time(),
    NowTimestamp = local_seconds(),
    Week = calendar:day_of_the_week(Y,M,D),
    Week1Timestamp = NowTimestamp - ( Week-1 ) * 86400 - H * 60* 60 - Mi * 60 - S,
    Week1Timestamp.

get_current_datetime_string() ->
  {{Y,M,D},{H,MM,S}} = calendar:local_time(),
  [Y2,M2,D2,H2,MM2,S2] = lists:map( fun(X) ->  integer_to_list(X) end,[Y,M,D,H,MM,S] ),
  Y2++"-"++M2++"-"++D2++" "++ H2++":"++MM2++":"++S2.


%add by Masker 2016/5/13 时间戳 转时间  标准时间 可以和local_seconds 配合使用
timestamp_to_datatimeString( TimeStamp)->
  {{Y,M,D},{H,MM,S}}= calendar:gregorian_seconds_to_datetime( TimeStamp +
    calendar:datetime_to_gregorian_seconds( {{1970,1,1} , {0,0,0}})) ,
  [Y2,M2,D2,H2,MM2,S2] = lists:map( fun(X) ->  integer_to_list(X) end,[Y,M,D,H,MM,S] ),
  Y2++"-"++M2++"-"++D2++" "++ H2++":"++MM2++":"++S2.
-spec timestamp_to_datatime(non_neg_integer()) -> calender:datetime().
timestamp_to_datatime(TimeStamp)->
  calendar:gregorian_seconds_to_datetime( TimeStamp +
    calendar:datetime_to_gregorian_seconds( {{1970,1,1} , {0,0,0}})) .
%add by Masker 2016/5/26 时间转时间戳
-spec datetime_to_timestamp(calender:datetime()) -> non_neg_integer().
datetime_to_timestamp(DataTime)->
  %DataTime =  {{Y,M,D},{H,MM,S}}
  calendar:datetime_to_gregorian_seconds( DataTime ) -
    calendar:datetime_to_gregorian_seconds( {{1970 ,1,1} , { 0,0,0}} ) .


%add by Masker 2016/8/31
get_activity_time( NumWeek , StartWeek , EndWeek ) ->
    { Data , { _ , _ , _ }} = calendar:local_time(),
    {NowY,NowM,_NowD } = Data ,
    NowTimestamp =  datetime_to_timestamp( calendar:local_time()  ) ,
    MouthStartDate =  {{ NowY, NowM , 1 }  , {0,0,0}},
    MouthStartWeek  = calendar:day_of_the_week( { NowY, NowM , 1 } ) ,%当前时间这个月1号 是星期几
    MouthStartTimestamp = datetime_to_timestamp( MouthStartDate  ), %当前时间这个月1号的时间戳
    NumWeekTimestamp = MouthStartTimestamp + 86400*7*(NumWeek-1) , %当前时间这个月1号的时间戳 加上 第几周 要经过的周的秒数
    DiffMondayTimestamp = ( MouthStartWeek-1 ) *86400 , %自己这个礼拜周1 差了多少秒
    StartActMondayTimestamp = NumWeekTimestamp - DiffMondayTimestamp , %要开启活动的这周的周1 时间戳
    StartTimestamp = StartActMondayTimestamp + ( StartWeek-1)*86400 , %活动开启日时间戳
    EndTimestamp = StartActMondayTimestamp + ( EndWeek ) *86400 ,  %活动结束日时间戳
    {{StartY,StartM,StartD},{_H,_MM,_S}} =  timestamp_to_datatime( StartTimestamp) ,
    {{EndY,EndM,EndD},{_H,_MM,_S}} =  timestamp_to_datatime( EndTimestamp) ,
    BeginDay = StartY*10000 + StartM*100 + StartD,
    EndDay = EndY*10000 + EndM*100 + EndD,
          if
            NowTimestamp >= StartTimestamp ,  NowTimestamp =< EndTimestamp->
                { BeginDay , EndDay , 0 } ;
            NowTimestamp >= StartActMondayTimestamp ,  NowTimestamp < StartTimestamp->
                {  BeginDay , EndDay , 1 } ;
            true->
              { BeginDay , EndDay , 0 }
          end.

%不能跨周
get_activity_time( StartWeek , EndWeek ) ->
    { Data , { _ , _ , _ }} = calendar:local_time(),
    {NowY,NowM,NowD } = Data ,
    NowWeek  = calendar:day_of_the_week( { NowY, NowM , NowD } ) ,%当前时间这个月1号 是星期几
    {InterValStartDay1,InterValEndDay1} =
        if NowWeek > EndWeek   ->
            %算下一次的开始时间
            InterValStartDay = 7+StartWeek - NowWeek,
            InterValEndDay = 7+EndWeek  - NowWeek,
            {InterValStartDay,InterValEndDay};
            true ->
                %活动已经开始了或者没开始，都返回这周活动的时间
                InterValStartDay = StartWeek - NowWeek,
                InterValEndDay = EndWeek  - NowWeek,
                {InterValStartDay,InterValEndDay}
        end,
    NowTimestamp = datetime_to_timestamp( calendar:local_time()  ), %当前时间这个月1号的时间戳
    BeginTimestamp = NowTimestamp + InterValStartDay1 * 86400,
    EndTimestamp = NowTimestamp + InterValEndDay1 * 86400+86400, %结束时间加1天
    {{StartY,StartM,StartD},{_H,_MM,_S}} =  timestamp_to_datatime( BeginTimestamp) ,
    {{EndY,EndM,EndD},{_H,_MM,_S}} =  timestamp_to_datatime( EndTimestamp) ,
    BeginDay = StartY*10000 + StartM*100 + StartD,
    EndDay = EndY*10000 + EndM*100 + EndD,
    { BeginDay , EndDay}.



get_activity_time( InitDay , SpaceDay , BeginWeek , EndWeek ) ->
  InitY = InitDay div 10000,
  InitM = InitDay rem 10000 div 100,
  InitD = InitDay rem 100,
  InitDays = calendar:date_to_gregorian_days(InitY,InitM,InitD),
  {{NowY,NowM,NowD},{_,_,_}} = calendar:local_time(),
  NowDays = calendar:date_to_gregorian_days(NowY,NowM,NowD),
  if NowDays < InitDays ->
    %% 不到参照时间
    {-1,-1};
    true ->
      %% 这一轮活动开始参照时间
      NowInitDays = NowDays - ((NowDays - InitDays) rem SpaceDay),
      {NowInitY,NowInitM,NowInitD} = calendar:gregorian_days_to_date(NowInitDays),
      %% 这一轮活动开始结束时间
      {BeginY,BeginM,BeginD} = common_tool:get_next_week_data(NowInitY,NowInitM,NowInitD,BeginWeek),
      {EndY,EndM,EndD} = common_tool:get_next_week_data(BeginY,BeginM,BeginD,EndWeek),
      BeginDay = BeginY*10000 + BeginM*100 + BeginD,
      EndDay = EndY*10000 + EndM*100 + EndD,
      NowDay = NowY*10000 + NowM*100 + NowD,
      if NowDay >= BeginDay,NowDay =< EndDay ->
        %% 在活动日期内，返回活动开始结束时间
        {BeginDay,EndDay};
        true ->
          {-1, -1}
      end
  end.
%%返回带小时的结束时间
get_activity_time_hour( StartWeek , EndWeek,EndHour) ->
    { Data , { _ , _ , _ }} = calendar:local_time(),
    {NowY,NowM,NowD } = Data ,
    NowWeek  = calendar:day_of_the_week( { NowY, NowM , NowD } ) ,%当前时间这个月1号 是星期几
    {InterValStartDay1,InterValEndDay1} =
        if NowWeek > EndWeek   ->
            %算下一次的开始时间
            InterValStartDay = 7+StartWeek - NowWeek,
            InterValEndDay = 7+EndWeek  - NowWeek,
            {InterValStartDay,InterValEndDay};
            true ->
                %活动已经开始了或者没开始，都返回这周活动的时间
                InterValStartDay = StartWeek - NowWeek,
                InterValEndDay = EndWeek  - NowWeek,
                {InterValStartDay,InterValEndDay}
        end,
    NowTimestamp = datetime_to_timestamp( calendar:local_time()  ), %当前时间这个月1号的时间戳
    BeginTimestamp = NowTimestamp + InterValStartDay1 * 86400,
    EndTimestamp = NowTimestamp + InterValEndDay1 * 86400, %结束时间加1天
    {{StartY,StartM,StartD},{_H,_MM,_S}} =  timestamp_to_datatime( BeginTimestamp) ,
    {{EndY,EndM,EndD},{_H,_MM,_S}} =  timestamp_to_datatime( EndTimestamp) ,
    BeginDay = StartY*1000000 + StartM*10000 + StartD*100,
    EndDay = EndY*1000000 + EndM*10000 + EndD*100+EndHour,
    { BeginDay , EndDay}.


get_listindex_by_Key(Key,Value,List)->
    lists:foldl( fun(Info,{Find,Index})->
        if Find == 1 ->
            {Find,Index};
            true->
                Value2 = proplists:get_value(Key,Info),
                if Value2 == Value->
                    {1,Index +1};
                    true->
                        {0,Index +1}
                end
        end
    end,{0,0},List).

is_proplist2(List) ->
    if is_list(List) ->
        [H|_] = List,
        if tuple_size(H) == 2 ->
            true;
            true->
                false
        end;
        true->
            false
    end.

%% 随机取List里的N个成员,返回随机的N个成员和Result组成的新List,新List最多Need个成员
%% ps.调用前需要自己判断List和Result的长度，否则可能达不到效果= =...
random_list_member(List,N,Need,Result) ->
    ListLength = length(List),
    if ListLength =< N ->
        lists:append(Result,List);
        true ->
            [H|T] = List,
            Random = uniform(ListLength),
            if Random =< N ->
                NewResult = lists:append(Result,[H]),
                if length(NewResult) >= Need ->
                    NewResult;
                    true ->
                        random_list_member(T,N-1,Need,NewResult)
                end;
                true ->
                    random_list_member(T,N,Need,Result)
            end
    end.

% 8区时间 返回的是当天0点的秒数
local_day_seconds() ->
    LocalSeconds = local_seconds(),
    {{_,_,_},{H,MM,S}} = calendar:local_time(),
    LocalSeconds - H*60*60 - MM*60 - S.


local_now() ->
    {MegaSecs,Secs,MicroSecs}=os:timestamp(),
    {MegaSecs,Secs + 8*60*60,MicroSecs}.

build_ServerList(CurID,MinID,List)->
    if CurID == MinID ->
        [ integer_to_binary( CurID)| List ];
        true->
            NewList = [ integer_to_binary( CurID)| List ],
            build_ServerList(CurID-1,MinID,NewList)
    end.




%%获得道具的原子
get_award_type(Type)->
    case Type of
        1->
            money;
        2->
            gold;
        3->
            jjcpoint;
        4->
            bountyMoney;
        5->
            lkkitousenPoint;
        6->
            luckydrawPoint ;
        7->
            armypoint;
        8 ->
            silvernote;
        9->
            groupPruchaseCoupon;
        10->
            kofPoint;
        11->
            warcontribution;
        12->
            multiServerjjcMoney;
        13->
            fightThronePoint ;
        _->
            item
    end.


get_award_tuple(ItemID,ItemNum)->
    case get_award_type(ItemID) of
        item ->
            {item,ItemID,ItemNum};
        AwardType ->
            {AwardType,1,ItemNum}
    end.

decompile(Mod) ->
    {ok,{_,[{abstract_code,{_,AC}}]}} =beam_lib:chunks(code:which(Mod),[abstract_code]),
    { ok , Comtxt } = file:open( "compiletext.txt" , [write  , unicode]) ,
    io:put_chars( Comtxt , erl_prettypr:format(erl_syntax:form_list(AC)) )   ,
    file:close( Comtxt) .

-spec ( record_to_MongoMap( tuple() , [atom(),...] ) -> map() ).
record_to_MongoMap( Record , Fields ) ->
%%    Fields = record_info( fields , RecordTag ) ,
    FieldLength = length( Fields ) ,
    F = fun( Index , OutMap )->
            Field = lists:nth( Index , Fields  ) ,
            Field_Binary = atom_to_binary( Field , utf8 ) ,
            Value = erlang:element( Index+1 , Record ) ,
            NewOutputMap = maps:put( Field_Binary , Value  , OutMap ) ,
            NewOutputMap
        end ,
    lists:foldl( F , #{} , lists:seq( 1 , FieldLength )) .


clean_all_with_value(Tab,X) ->
    ets:safe_fixtable(Tab,true),
    clean_all_with_value(Tab,X,ets:first(Tab)),
    ets:safe_fixtable(Tab,false).

clean_all_with_value(_,_,'$end_of_table') ->
    true;
clean_all_with_value(Tab,X,Key) ->
    case ets:lookup(Tab,Key) of
        [{Key,X}] ->
            ets:delete(Tab,Key);
        _ ->
            true
    end,
    clean_all_with_value(Tab,X,ets:next(Tab,Key)).

map_Ets( _Name , _Fun  , '$end_of_table' )->
    ok;
map_Ets( Name , Fun  , Pos )->
    case ets:lookup( Name , Pos ) of
        []-> ok  ;
        [Info]-> Fun(Info)
    end ,
    map_Ets( Name , Fun , ets:next( Name , Pos ))  .


integer_2_boolen( 0 )->
    false ;
integer_2_boolen( 1 )->
    true  ;
integer_2_boolen( Other )->
    lager:error( "integer_2_boolen parameter is not 1or0 it is ~p~n" , [Other]) ,
    false  .

fprof(TimeoutSec) ->
    fprof:trace([start,{file,"fprof.txt"},{procs,processes() -- [whereis(fprof)]}]),
    timer:sleep(TimeoutSec),
    fprof:trace(stop),
    fprof:profile({file,"fprof.txt"}),
    fprof:analyse([{dest,"fprof.txt"},{sort,own}]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%通用排行函数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%排序函数，

-spec sort_list(List,SortFun,Count) -> {SortList} when
    List :: list(),     % 要排序的list
    SortFun :: fun(),    % 排序函数
    Count :: integer(),     % 要保留的名次
    SortList :: list().   % 结果
sort_list(List,SortFun,Count)->
    SortList =
        if length(List) > 0 ->
            lists:sort(SortFun,List);
            true ->
                []
        end,
    case Count of
        max ->
            SortList;
        _->
            {List1,_} = lists:split(Count,SortList),
            List1
    end.

%%随机函数
%% 从LookUpLists中随机RandomSize个人，SubListSize为分割list大小，为了增加效率
random_list(LookUpLists,SubListSize,RandomSize) ->
    AllLen = length(LookUpLists),
    SubList =
    if AllLen > SubListSize ->
        lists:sublist(LookUpLists,uniform(AllLen-SubListSize),SubListSize);
        true->
            LookUpLists
    end,
    RandomIndexList = random_index(RandomSize, length(SubList),[]),
    Tuple = list_to_tuple(SubList),
    lists:map(
        fun(ID)->
            erlang:element(ID,Tuple)
        end,RandomIndexList ).
random_index(AllNum,MaxValue,_RandomList) when MaxValue < AllNum ->
    [];
random_index(AllNum,MaxValue,RandomList) ->
    Size =  length(RandomList),
    if Size == AllNum ->
        RandomList;
        MaxValue / AllNum < 2 ->
            Random =
            if MaxValue == AllNum ->
                1;
                true->
                    uniform(MaxValue - AllNum + 1)
            end,
            %lists:map(fun(X) -> X+Random end, lists:duplicate(AllNum,1) );
            {Out,_} =
            lists:foldl(fun(_,{Res,Count}) ->
                {lists:append(Res,[Count+Random]),Count+1}
                        end,{[],0}, lists:duplicate(AllNum,1)),
            Out;
        true->
            Random = uniform(MaxValue),
            case  lists:any( fun(ID)->  ID==Random end,RandomList ) of
                false ->
                    NewRandomlist = lists:append(RandomList,[Random]),
                    random_index(AllNum,MaxValue,NewRandomlist);
                _->
                    random_index(AllNum,MaxValue,RandomList)
            end
    end.

get_map_keys(Map)->
    List = maps:to_list(Map),
    {KList,_} = lists:unzip(List),
    KList.

%% @spec to_hex(integer | iolist()) -> string()
%% @doc Convert an iolist to a hexadecimal string.
to_hex(0) ->
    "0";
to_hex(I) when is_integer(I), I > 0 ->
    to_hex_int(I, []);
to_hex(B) ->
    to_hex(iolist_to_binary(B), []).

%% @spec hexdigit(integer()) -> char()
%% @doc Convert an integer less than 16 to a hex digit.
hexdigit(C) when C >= 0, C =< 9 ->
    C + $0;
hexdigit(C) when C =< 15 ->
    C + $a - 10.

%% Internal API

to_hex(<<>>, Acc) ->
    lists:reverse(Acc);
to_hex(<<C1:4, C2:4, Rest/binary>>, Acc) ->
    to_hex(Rest, [hexdigit(C2), hexdigit(C1) | Acc]).

to_hex_int(0, Acc) ->
    Acc;
to_hex_int(I, Acc) ->
    to_hex_int(I bsr 4, [hexdigit(I band 15) | Acc]).

get_md5_string(Value)->
    Md5 = erlang:md5(integer_to_list(Value)),
    List = binary_to_list(Md5),
    List16 = lists:map( fun(X) ->
        Nowvalue = to_hex(X),
        if length(Nowvalue) =/= 1 ->
            Nowvalue;
            true->
                "0" ++ Nowvalue
        end
                        end,List),
    binary_to_list( list_to_binary(List16)).

jsone_KeyOpt(Keys)->
    [{keys, Keys}, {object_format, proplist}].


%% 获得proplists里的一个key的值为Value的成员
get_listmember_by_key([],_,_) ->
    [];
get_listmember_by_key(List,Key,Value) ->
    [H|T] = List,
    TempValue = proplists:get_value(Key,H,null),
    if TempValue == Value ->
        H;
        true ->
            get_listmember_by_key(T,Key,Value)
    end.
get_max_email_items(N)when N>0->
    get_max_email_items(N,"itemId","itemNum",[]);
get_max_email_items(_N)->
    [].
get_max_email_items(0,StrItemId,StrItemNum,Acc)->
    [{list_to_atom(StrItemId++"0"),list_to_atom(StrItemNum++"0")}|Acc];
get_max_email_items(N,StrItemId,StrItemNum,Acc)->
    NewAcc = [{list_to_atom(StrItemId++integer_to_list(N)),list_to_atom(StrItemNum++integer_to_list(N))}|Acc],
    get_max_email_items(N-1,StrItemId,StrItemNum,NewAcc).