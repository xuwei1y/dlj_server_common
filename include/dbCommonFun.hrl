%%%-------------------------------------------------------------------
%%% @author yinchong
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 八月 2017 10:15
%%%-------------------------------------------------------------------
-author("yinchong").
-include("dbDatastruct.hrl").

-define( get_database(DBname_Atom) , get_database(DBname_Atom)).

-spec get_database( atom()) -> binary().
get_database(DBname_Atom)->
    [{_,MainDB}] = ets:lookup(?DATABASE_VAR, DBname_Atom),
    MainDB.

insert(Collection  ,CommandDoc ) ->
    game_databasePool:insert( ?DBPOOLS , Collection , CommandDoc  , {<<"w">>, 0} )  .
insert_one( Collection  ,CommandDoc ) ->
    game_databasePool:insert( ?DBPOOLS , Collection , [CommandDoc]  , {<<"w">>, 0} )  .
update( Collection ,Selector ,CommandDoc ) ->
    game_databasePool:update( ?DBPOOLS, Collection , Selector , CommandDoc , #{} ,  {<<"w">>, 0} ) .
%Upsert = maps:get(upsert, Opts, false),
%MultiUpdate = maps:get(multi, Opts, false),
update( Collection ,Selector ,CommandDoc , Opts ) ->
    game_databasePool:update( ?DBPOOLS  , Collection , Selector , CommandDoc , Opts , {<<"w">>, 0}) .
delete(  Collection , Selector) ->
    game_databasePool:delete( ?DBPOOLS , Collection , Selector ,  {<<"w">>, 0} ) .
delete_one(  Collection , Selector) ->
    game_databasePool:delete( ?DBPOOLS , Collection , Selector  ,  {<<"w">>, 0}) .

insert_Safemod(Collection  ,CommandDoc ) ->
    game_databasePool:insert( ?DBPOOLS , Collection , CommandDoc ,{<<"w">>, 1} )  .
insert_one_Safemod(Collection  ,CommandDoc ) ->
    game_databasePool:insert( ?DBPOOLS , Collection , [CommandDoc] ,{<<"w">>, 1} )  .
update_Safemod( Collection ,Selector ,CommandDoc) ->
    game_databasePool:update( ?DBPOOLS, Collection , Selector , CommandDoc , #{} , {<<"w">>, 1} ) .
update_Safemod( Collection ,Selector ,CommandDoc , Opts ) ->
    game_databasePool:update( ?DBPOOLS  , Collection , Selector , CommandDoc , Opts , {<<"w">>, 1}) .
delete_Safemod(  Collection , Selector) ->
    game_databasePool:delete( ?DBPOOLS , Collection , Selector , {<<"w">>, 1} ) .
delete_one_Safemod(  Collection , Selector) ->
    game_databasePool:delete( ?DBPOOLS , Collection , Selector  , {<<"w">>, 1}) .

count (  Collection ) ->
    game_databasePool:count( ?DBPOOLS ,Collection  ) .
count (  Collection , Selector ) ->
    game_databasePool:count( ?DBPOOLS ,Collection , Selector   ) .
count ( Collection , Selector  , Limit) ->
    game_databasePool:count( ?DBPOOLS ,Collection , Selector , Limit  ) .
count_ReadMod (Collection  ,ReadOptions ) ->
    game_databasePool:count( ?DBPOOLS , Collection     ) .
count_ReadMod(Collection , Selector  ,ReadOptions) ->
    game_databasePool:count(?DBPOOLS , Collection , Selector    ) .
count_ReadMod( Collection , Selector  , ReadOptions , Limit) ->
    game_databasePool:count(?DBPOOLS , Collection , Selector   , Limit ) .
%默认都是 primary读取模式 除非在 初始化的 topo的时候 设置改变 %find返回的是list find_one返回的是单一数据
find(  Collection , Selector ) ->
    game_databasePool:find( ?DBPOOLS  ,Collection , Selector) .
find( Collection , Selector , Projector) ->
    game_databasePool:find( ?DBPOOLS  ,Collection , Selector , Projector) .
find( Collection , Selector , Projector , Skip) ->
    game_databasePool:find( ?DBPOOLS  ,Collection , Selector , Projector , Skip) .
find( Collection , Selector , Projector , Skip , Limit) ->
    game_databasePool:find( ?DBPOOLS  ,Collection , Selector , Projector , Skip , Limit) .
find_one( Collection , Selector ) ->
    game_databasePool:find_one( ?DBPOOLS  ,Collection , Selector) .
find_one(  Collection , Selector ,Projector) ->
    game_databasePool:find_one( ?DBPOOLS  ,Collection , Selector ,Projector ) .
find_ReadMode(  ReadMode , Collection , Selector , Projector) ->
    game_databasePool:find_ReadMode( ?DBPOOLS , ReadMode  , Collection , Selector ,Projector) .
find_ReadMode(  ReadMode , Collection , Selector , Projector, Skip, Limit) ->
    game_databasePool:find_ReadMode( ?DBPOOLS , ReadMode  , Collection , Selector ,Projector, Skip, Limit).
find_one_ReadMode( ReadMode  , Collection , Selector ,Projector) ->
    game_databasePool:find_one_ReadMode( ?DBPOOLS , ReadMode  , Collection , Selector ,Projector).