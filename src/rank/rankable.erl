-module(rankable).
-autor("Wang.dongjun").

%target
%This module is dedicated to providing a higher performance sorting function based on the ordered_set type ets. Under the report file,
% you can see the specific data of the experimental data performance cpu time.

%function args
% Rankpos1 第一 排序字段
% Rankpos1 is the first priority ranking basis,
%rankpos2 第二排序字段，当第一排序字段相同时，使用 第二排序字段排序
% rankpos2 is the first ranking basis.
%DataList 是有待 被排序的 原始数据  类型是list， list内部是  tuple类型或 record类型 或  poplist类型结构
%DataList is Waiting for the basic data of the sort, struct: [tuple...] or [[tuple]...]
%RankNum  例如 1000，代表 只返回前1000名， 也可以传 all 代表，返回全部数据排行，
%RankNum is How many before you need to return the ranking data
%如果 需要 自定义 ets名字，则 传入此值
%EtsName Store ets name for sorting data

-define(TEMP_ETS,['rankable_0','rankable_1','rankable_2','rankable_3','rankable_4','rankable_5','rankable_6','rankable_7','rankable_8','rankable_9','rankable_10']).

-export([rk/2,rk/3,rk/4,rk/5]).                       %返回list 排行数据后，会删除 用于排序的ets 回收内存-      %The  functions will reback  rank result(list),and delete rank ets.
-export([rank/2,rank/3,rank/4,rank/5]).               %返回  {EtsName,SameData} 排序的ets名字，和第一排序字段相同的数据list 或者返回false     %The  functions will reback rank ets name,and will not delete rank ets until you execute a delete function.
-export([rk/6]).                                      %以上 的排序 搜索基于这个函数   %%All of the above functions depend on this Funtion.
%下面的函数 是 对ets 操作的包装，可以不使用这些函数，直接  使用ets本身的api，比如 ets：lookup 等等
%The following functions is for ets by name, you also can don't use these ones, and use ets:insert ets:delete  ..etc.
-export([ add/2,
  del/2,
  first/1,
  last/1,
  ranklist/1,
  del_ets/1
]).
-export([loop_rank_tuple/7,loop_rank_list/7]).
-compile(nowarn_unused_function).
%---------------------------------------------------------------------------------
rk(DataList,RankNum)->
  rk(get_rankable_ets_name(),DataList,true,RankNum,1,2).
rk(DataList,RankNum,RankPos1,RankPos2)->
  rk(get_rankable_ets_name(),DataList,true,RankNum,RankPos1,RankPos2).

rk(EtsName,DataList,RankNum)->
  rk(EtsName,DataList,true,RankNum,1,2).
rk(EtsName,DataList,RankNum,RankPos1,RankPos2)->
  rk(EtsName,DataList,true,RankNum,RankPos1,RankPos2).

rank(DataList,RankNum)->
  rk(get_rankable_ets_name(),DataList,false,RankNum,1,2).
rank(DataList,RankNum,RankPos1,RankPos2)->
  rk(get_rankable_ets_name(),DataList,false,RankNum,RankPos1,RankPos2).

rank(EtsName,DataList,RankNum)->
  rk(EtsName,DataList,false,RankNum,1,2).
rank(EtsName,DataList,RankNum,RankPos1,RankPos2)->
  rk(EtsName,DataList,false,RankNum,RankPos1,RankPos2).

rk(_EtsName,[],true,_RankNum,_RankPos1,_RankPos2)->
  [];
rk(_EtsName,[],false,_RankNum,_RankPos1,_RankPos2)->
  false;
rk(EtsName,DataList,IsBack,RankNum,RankPos1,RankPos2) when RankPos1 >0 andalso RankPos2 >0->
  %ets:new(EtsName,[public,ordered_set,named_table,{keypos,RankPos1}]),
  ets:new(EtsName,[public,ordered_set,named_table]),
  SameData = do_rank(EtsName,DataList,RankNum,RankPos1,RankPos2),
  case IsBack of
     true ->
        case  ets:info(EtsName,size) >= RankNum of
          true ->
            NewSameData=[];
          false ->
            NewSameData=SameData
        end,
       SortList = [{_,Info}|_Lst]=lists:reverse(ets:tab2list(EtsName)),
       Mod = get_rank_mod(Info),
       %io:format("*************:~p~n",[{Mod,SortList,1,NewSameData,RankNum,[],RankPos1,RankPos2}]),
        Data =
        case RankNum of
          all->
            ?MODULE:Mod(SortList,1,NewSameData,length(DataList),[],RankPos1,RankPos2);
          _->
            ?MODULE:Mod(SortList,1,NewSameData,RankNum,[],RankPos1,RankPos2)
        end,
       %io:format("**************************:::~p~n",[length(Data)]),
       ets:delete(EtsName),
       Data;
     false ->
       {EtsName,SameData}
  end.
do_rank(EtsName,[ListInfo|_Lst]=DataList,all,RankPos1,RankPos2)when is_list(ListInfo)->
  loop_rk_list(EtsName,DataList,[],RankPos1,RankPos2);
do_rank(EtsName,[ListInfo|_Lst]=DataList,RankNum,RankPos1,RankPos2)when is_list(ListInfo)->
  loop_rk_list(EtsName,DataList,RankNum,[],RankPos1,RankPos2);
do_rank(EtsName,[TupleInfo|_Lst]=DataList,all,RankPos1,RankPos2)when is_tuple(TupleInfo)->
  loop_rk_tuple(EtsName,DataList,[],RankPos1,RankPos2);
do_rank(EtsName,[TupleInfo|_Lst]=DataList,RankNum,RankPos1,RankPos2)when is_tuple(TupleInfo)->
  loop_rk_tuple(EtsName,DataList,RankNum,[],RankPos1,RankPos2).

loop_rk_tuple(_EtsName,[],Acc,_RankPos1,_RankPos2)->
  Acc;
loop_rk_tuple(EtsName,[TupleInfo|DataList],Acc,RankPos1,RankPos2)->
  Key =element(RankPos1,TupleInfo),
  case  ets:lookup(EtsName,Key)  of
    []->
      ets:insert(EtsName,{Key,TupleInfo}),
      loop_rk_tuple(EtsName,DataList,Acc,RankPos1,RankPos2);
    _->
      loop_rk_tuple(EtsName,DataList,[{Key,TupleInfo}|Acc],RankPos1,RankPos2)
  end.

loop_rk_tuple(_EtsName,[],_RankNum,Acc,_RankPos1,_RankPos2)->
  Acc;
loop_rk_tuple(EtsName,[TupleInfo|DataList],0,Acc,RankPos1,RankPos2)->
  FirstKey= ets:first(EtsName),
  Key =element(RankPos1,TupleInfo),
  case  Key < FirstKey of
    true ->
      loop_rk_tuple(EtsName,DataList,0,Acc,RankPos1,RankPos2);
    false ->
      case  ets:lookup(EtsName,Key)  of
        []->
          ets:insert(EtsName,{Key,TupleInfo}),
          ets:delete(EtsName,FirstKey),
          loop_rk_tuple(EtsName,DataList,0,Acc,RankPos1,RankPos2);
        _->
          loop_rk_tuple(EtsName,DataList,0,[{Key,TupleInfo}|Acc],RankPos1,RankPos2)
      end
  end;
loop_rk_tuple(EtsName,[TupleInfo|DataList],RankNum,Acc,RankPos1,RankPos2)->
  Key =element(RankPos1,TupleInfo),
  case  ets:lookup(EtsName,Key)  of
    []->
      %io:format("loop_rk_tuple--[][][]-------:~p~n",[{ets:info(EtsName,size),RankNum,Acc}]),
      ets:insert(EtsName,{Key,TupleInfo}),
      loop_rk_tuple(EtsName,DataList,RankNum-1,Acc,RankPos1,RankPos2);
    _->
      %io:format("loop_rk_tuple--[**][**][**]-------:~p~n",[{ets:info(EtsName,size),RankNum,Acc}]),
      loop_rk_tuple(EtsName,DataList,RankNum-1,[{Key,TupleInfo}|Acc],RankPos1,RankPos2)
  end.

loop_rk_list(_EtsName,[],Acc,_RankPos1,_RankPos2)->
  Acc;
loop_rk_list(EtsName,[ListInfo|DataList],Acc,RankKey1,RankKey2)->
  case  lists:keyfind(RankKey1,1,ListInfo)  of
    {RankKey1,Key}->
      TupleInfo = {Key,ListInfo},
      case  ets:lookup(EtsName,Key)  of
        []->
          ets:insert(EtsName,TupleInfo),
          loop_rk_list(EtsName,DataList,Acc,RankKey1,RankKey2);
        _->
          loop_rk_list(EtsName,DataList,[TupleInfo|Acc],RankKey1,RankKey2)
      end;
    false->
      loop_rk_list(EtsName,DataList,Acc,RankKey1,RankKey2)
  end.

loop_rk_list(_EtsName,[],_RankNum,Acc,_RankKey1,_RankKey2)->
  Acc;
loop_rk_list(EtsName,[ListInfo|DataList],0,Acc,RankKey1,RankKey2)->
  FirstKey= ets:first(EtsName),
  case lists:keyfind(RankKey1,1,ListInfo)  of
    {RankKey1,Key}->
      case  Key < FirstKey of
        true ->
          loop_rk_list(EtsName,DataList,0,Acc,RankKey1,RankKey2);
        false ->
          case  ets:lookup(EtsName,Key)  of
            []->
              ets:insert(EtsName,{Key,ListInfo}),
              ets:delete(EtsName,FirstKey),
              loop_rk_list(EtsName,DataList,0,Acc,RankKey1,RankKey2);
            _->
              loop_rk_list(EtsName,DataList,0,[{Key,ListInfo}|Acc],RankKey1,RankKey2)
          end
      end;
    false ->
      loop_rk_list(EtsName,DataList,0,Acc,RankKey1,RankKey2)
  end;

loop_rk_list(EtsName,[ListInfo|DataList],RankNum,Acc,RankKey1,RankKey2)->
  case  lists:keyfind(RankKey1,1,ListInfo)  of
    {RankKey1,Key}->
      case  ets:lookup(EtsName,Key)  of
        []->
          %io:format("loop_rk_list--[][][]-------:~p~n",[{ets:info(EtsName,size),RankNum,Acc}]),
          ets:insert(EtsName,{Key,ListInfo}),
          loop_rk_list(EtsName,DataList,RankNum-1,Acc,RankKey1,RankKey2);
        _->
          %io:format("loop_rk_list--[**][**][**]-------:~p~n",[{ets:info(EtsName,size),RankNum,Acc}]),
          loop_rk_list(EtsName,DataList,RankNum-1,[{Key,ListInfo}|Acc],RankKey1,RankKey2)
      end;
    false ->
      loop_rk_list(EtsName,DataList,RankNum,Acc,RankKey1,RankKey2)
  end.

loop_rank_tuple([],_,_,_,Acc,_RankPos1,_RankPos2)->
  Acc;
loop_rank_tuple(_,Rank,_,RankNum,Acc,_RankPos1,_RankPos2)when Rank > RankNum ->
  Acc;
loop_rank_tuple([{Key,TupleInfo}|LstList]=_Data,Rank,SameData,RankNum,Acc,RankPos1,RankPos2)->
   %Key = element(1,TupleInfo),
  {SameListSort,NewSameData}=loop_same_tuple(Key,SameData,[TupleInfo],RankPos2),
  Lang = length(SameListSort),
  NewRank = Rank+Lang,
  NewAcc=loop_acc(Acc,lists:reverse(SameListSort),Rank),
  loop_rank_tuple(LstList,NewRank,NewSameData,RankNum,NewAcc,RankPos1,RankPos2).

loop_rank_list([],_,_,_,Acc,_RankPos1,_RankPos2)->
  Acc;
loop_rank_list(_,Rank,_,RankNum,Acc,_RankPos1,_RankPos2)when Rank > RankNum ->
  Acc;
loop_rank_list([{Key,ListInfo}|LstList],Rank,SameData,RankNum,Acc,RankPos1,RankPos2)->
  %Key = element(1,TupleInfo),
  {SameListSort,NewSameData}=loop_same_list(Key,SameData,[{lists:keyfind(RankPos2,1,ListInfo),ListInfo}],RankPos2),
  Lang = length(SameListSort),
  NewRank = Rank+Lang,
  NewAcc=loop_acc(Acc,lists:reverse(SameListSort),Rank),
  loop_rank_list(LstList,NewRank,NewSameData,RankNum,NewAcc,RankPos1,RankPos2).


loop_same_tuple(Key,SameData,Acc,RankPos2)->
  case  lists:keytake(Key,1,SameData) of
    false->
       {lists:keysort(RankPos2,Acc),SameData};
    {value,{Key,RankInfo},LstList}->
      loop_same_tuple(Key,LstList,[RankInfo|Acc],RankPos2)
  end.

loop_same_list(Key,SameData,Acc,RankKey2)->
  case  lists:keytake(Key,1,SameData) of
    false->
      %io:format("&&&&&&&&&&&--:~p~n",[{Key,SameData,Acc,RankKey2}]),
      {[Info||{_,Info}<- lists:keysort(1,Acc)],SameData};
    {value,{Key,RankInfo},LstList}->
      case lists:keyfind(RankKey2,1,RankInfo)  of
        {RankKey2,Key2}->
            loop_same_list(Key,LstList,[{Key2,RankInfo}|Acc],RankKey2);
         false ->
           loop_same_list(Key,LstList,[{false,RankInfo}|Acc],RankKey2)
      end
  end.

loop_acc(Acc,[],_)->
  Acc;
loop_acc(Acc,[RankInfo|LstList],Rank)->
  %loop_acc([{element(2,TupleInfo),Rank,TupleInfo}|Acc],LstList,Rank+1). for example roleid,..etc.
  %loop_acc([{Rank,TupleInfo}|Acc],LstList,Rank+1).
  loop_acc([RankInfo|Acc],LstList,Rank+1).
get_rankable_ets_name()->
  get_rankable_ets_name(?TEMP_ETS).

get_rankable_ets_name([])->
  list_to_atom("rankable_"++integer_to_list(rand:uniform(1000000)));
get_rankable_ets_name([Atom|Lst])->
  case  ets:info(Atom) of
    undefined ->
      Atom;
    _->
      get_rankable_ets_name(Lst)
  end.

add(TupleInfo,EtsName)->
  ets:insert(EtsName,TupleInfo).

del(Key,EtsName)->
  ets:delete(EtsName,Key).

first(EtsName)->
  case  ets:first(EtsName) of
    '$end_of_table'->
       [];
    Key->
      ets:lookup(EtsName,Key)
  end.

last(EtsName)->
  case  ets:last(EtsName) of
    '$end_of_table'->
      [];
    Key->
      ets:lookup(EtsName,Key)
  end.

ranklist(EtsName)->
  ets:tab2list(EtsName).

del_ets(EtsName)->
  ets:delete(EtsName).

get_rank_mod(Info)when is_tuple(Info)->
  'loop_rank_tuple';
get_rank_mod(Info)when is_list(Info)->
 'loop_rank_list'.