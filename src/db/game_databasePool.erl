%%%-------------------------------------------------------------------
%%% @author yinchong
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 十月 2016 10:05
%%%-------------------------------------------------------------------
-module(game_databasePool).
-author("blackcat").
-include("db_task.hrl").
%% API
%% -export([ create_ets/0 ]).

-compile(export_all).

init_databasePool( Args , RegisterName ) ->
    %{ok, List} = application:get_env(PoolName),
    Host = proplists:get_value(host,Args),
    Port = proplists:get_value(port,Args),
    Host1 = proplists:get_value(host1,Args),
    Port1 = proplists:get_value(port1,Args),
    Size = proplists:get_value(size,Args),
    UseReplset = proplists:get_value( useReplset , Args ) ,
    Max_overflow = proplists:get_value(max_overflow,Args),
    Overflow_ttl = proplists:get_value(overflow_ttl , Args , 0 ),
    Overflow_check_period = proplists:get_value(overflow_check_period , Args , 0 ),
    User = proplists:get_value(user,Args),
    Password = proplists:get_value(password,Args),
    ReplicaSetName = proplists:get_value(replicaSetName,Args , undefine ),
    Seed =
        if
            UseReplset == 0 ->
                { single, Host++":"++integer_to_list( Port) }  ;
            true->
                { rs, list_to_binary( ReplicaSetName ) , [ Host++":"++integer_to_list( Port),
                        Host1++":"++integer_to_list( Port1)] }
        end,
    %注意必须是hostname 有name用ip不行
%%     Seed =  { rs, <<"ReplicaSetName">> , [ "tl-148-PC:27017" ] } ,
    Options = [
        { name,  RegisterName },    % Name should be used for mongoc pool to be registered wit
        { register,  RegisterName },
        { pool_size, Size }, % pool size on start
        { max_overflow, Max_overflow }	,% number of overflow workers be created, when all workers from pool are busy,
        { overflow_ttl, Overflow_ttl }, % number of milliseconds for overflow workers to stay in pool before terminating
        { overflow_check_period, Overflow_check_period }, % overflow_ttl check period for workers (in milliseconds)
%%         { overflow_ttl, 1000 }, % number of milliseconds for overflow workers to stay in pool before terminating
%%         { overflow_check_period, 1000 }, % overflow_ttl check period for workers (in milliseconds)

         { localThresholdMS, 1000 }, % secondaries only which RTTs fit in window from lower RTT to lower RTT + localThresholdMS could be selected for handling user's requests

         { connectTimeoutMS, 20000 },
         { socketTimeoutMS, 100 },

         { serverSelectionTimeoutMS, 30000 }, % max time appropriate server should be select by
         { waitQueueTimeoutMS, 1000 }, % max time for waiting worker to be available in the pool

         { heartbeatFrequencyMS, 10000 },    %  delay between Topology rescans { minHeartbeatFrequencyMS, 1000 },

         { rp_mode, primary },% default ReadPreference mode - primary, secondary,2 primaryPreferred, secondaryPreferred, nearest

         { rp_tags, [] }% tags that servers shoul be tagged by for becoming candidates for server selection  (may be an empty list)
    ] ,
    WorkerOptions=
        if
            User =:= undefined , Password=:= undefined ->
                [];%  default is <<"admin">>
            true ->
                [  {login ,list_to_binary(User) } , {password , list_to_binary(Password) },
                    {w_mode, safe}, {r_mode, slave_ok}]
        end,
    { ok , _Topology } = mongoc:connect( Seed, Options, WorkerOptions ).


%%直接操作数据库，同时并发操作会有后发先至的问题，此接口不能在player上调用
insert( UseDBpool , Collection  ,CommandDoc,WC) ->
    case mongo_extend_api:insert( UseDBpool , Collection , CommandDoc ,WC)  of
        { {true , _Info },  _ListInfo } -> ok  ;
        Other-> Other
    end .

update( UseDBpool , CollDb ,Selector ,CommandDoc , Opts) ->
    case mongo_extend_api:update( UseDBpool , CollDb ,  Selector , CommandDoc , Opts )  of
        {true , _Info }-> ok ;
        Other-> Other
    end .

update( UseDBpool , CollDb ,Selector ,CommandDoc , Opts , WC ) ->
    case mongo_extend_api:update( UseDBpool  , CollDb , Selector , CommandDoc , Opts , WC ) of
        {true , _Info }-> ok ;
        Other-> Other
    end .

delete( UseDBpool , CollDb , Selector,WC) ->
    case mongo_extend_api:delete( UseDBpool , CollDb , Selector , WC ) of
        {true , _Info }-> ok ;
        Other-> Other
    end .

delete_one( UseDBpool , CollDb , Selector , WC) ->
    case mongo_extend_api:delete_one( UseDBpool , CollDb , Selector,WC )  of
        { true , _Info }-> ok ;
        Other-> Other
    end .

count ( UseDBpool , CollDb ) ->
    mongo_extend_api:count( UseDBpool ,CollDb , #{}  ) .
count ( UseDBpool , CollDb , Selector ) ->
    mongo_extend_api:count( UseDBpool ,CollDb , Selector ) .
count ( UseDBpool , CollDb , Selector , Limit) ->
    mongo_extend_api:count( UseDBpool ,CollDb , Selector , Limit  ) .

find( UseDBpool , CollDb , Selector ) ->
    mongo_extend_api:find(  UseDBpool , CollDb ,  Selector , #{}   ) .
find( UseDBpool , CollDb , Selector , Projector) ->
    mongo_extend_api:find(  UseDBpool , CollDb ,  Selector , Projector ) .
find( UseDBpool , CollDb , Selector , Projector , Skip) ->
    mongo_extend_api:find( UseDBpool , CollDb , Selector , Projector , Skip ) .
find( UseDBpool , CollDb , Selector , Projector , Skip , Limit) ->
    mongo_extend_api:find( UseDBpool , CollDb , Selector , Projector , Skip, Limit ) .

find_one( UseDBpool , CollDb , Selector ) ->
    mongo_extend_api:find_one_readmode( UseDBpool , CollDb , Selector , #{} , primary ).
find_one( UseDBpool , CollDb , Selector ,Projector) ->
    mongo_extend_api:find_one_readmode( UseDBpool , CollDb , Selector , Projector , primary) .

find_ReadMode( UseDBpool , ReadMode , CollDb , Selector , Projector) ->
    mongo_extend_api:find_readmode( UseDBpool , CollDb , Selector , Projector , ReadMode) .
find_ReadMode( UseDBpool , ReadMode , CollDb , Selector , Projector, Skip, Limit) ->
    mongo_extend_api:find_readmode( UseDBpool , CollDb , Selector , Projector, Skip, Limit , ReadMode) .
find_one_ReadMode( UseDBpool , ReadMode  , CollDb , Selector ,Projector) ->
    mongo_extend_api:find_one_readmode( UseDBpool , CollDb , Selector , Projector , ReadMode) .



%% 使用任务模块进行数据库操作，放在同时修改同一个对象出现后发先至的并发问题
findEx(EntityName, Collection , Selector ) ->
    findEx(EntityName,  Collection , Selector,#{}).
findEx(EntityName,  Collection , Selector , Projector) ->
    findEx(EntityName,  Collection , Selector,Projector,0).
findEx(EntityName,  Collection , Selector , Projector , Skip) ->
    findEx(EntityName,  Collection , Selector,Projector,Skip,0).
findEx(EntityName,  Collection , Selector , Projector , Skip , Limit) ->
    FindTask = #findtask{type = find,collection = Collection,selector = Selector,projector = Projector,skip = Skip,limit = Limit},
    gen_server:call( db_task, {addfindtask,EntityName,term_to_binary(FindTask)}).

findEx_one( EntityName,Collection , Selector ) ->
    findEx_one( EntityName,Collection ,Selector ,#{} ) .
findEx_one( EntityName,Collection , Selector ,Projector) ->
    FindTask = #findtask{type = findone,collection = Collection,selector = Selector,projector = Projector},
    gen_server:call( db_task, {addfindtask,EntityName,term_to_binary(FindTask)}).

findEx_onesp( EntityName,Collection , Selector ) ->
    findEx_one( EntityName,Collection ,Selector ,#{} ) .
findEx_onesp( EntityName,Collection , Selector ,Projector) ->
    FindTask = #findtask{type = findone_sp,collection = Collection,selector = Selector,projector = Projector},
    gen_server:call( db_task, {addfindtask,EntityName,term_to_binary(FindTask)}).

countEx (EntityName, Collection ) ->
    countEx(EntityName, Collection , #{}) .
countEx (EntityName, Collection , Selector ) ->
    countEx(EntityName, Collection ,Selector ,0  ) .
countEx (EntityName, Collection , Selector  , Limit) ->
    CountTask = #counttask{type = count,collection = Collection,selector = Selector,limit = Limit},
    gen_server:call( db_task, {addcounttask,EntityName,term_to_binary(CountTask)}).



deleteEx( EntityName , Collection , Selector,SafeMod) ->
    Type = if SafeMod -> delete_safe ; true -> delete end,
    DeleteTask = #deletetask{type = Type,collection = Collection,selector = Selector},
    gen_server:call( db_task, {adddeletetask,EntityName,DeleteTask}).
delete_oneEx( EntityName , Collection , Selector,SafeMod) ->
    Type = if SafeMod -> deleteone_safe ; true -> deleteone end,
    DeleteTask = #deletetask{type = Type,collection = Collection,selector = Selector},
    gen_server:call( db_task, {adddeletetask,EntityName,term_to_binary(DeleteTask)}).

insertEx(EntityName,Collection,CommandDoc,SafeMod)->
    Type = if SafeMod -> insert_safe ; true -> insert end,
    InsertTask = #inserttask{type = Type,collection = Collection,commandDoc = CommandDoc},
    gen_server:call( db_task, {addinserttask,EntityName,InsertTask}).
insert_oneEx(EntityName,Collection,CommandDoc,SafeMod)->
    Type = if SafeMod -> insertone_safe ; true -> insertone end,
    InsertTask = #inserttask{type = Type,collection = Collection,commandDoc = [CommandDoc]},
    gen_server:call( db_task, {addinserttask,EntityName,term_to_binary(InsertTask)}).

updateEx(EntityName, Collection ,Selector ,CommandDoc ) ->
    updateEx(EntityName, Collection ,Selector ,CommandDoc ,false).
updateEx(EntityName, Collection ,Selector ,CommandDoc ,SafeMod) ->
    updateEx(EntityName, Collection ,Selector ,CommandDoc ,#{},SafeMod).
updateEx(EntityName, Collection ,Selector ,CommandDoc ,Opts , SafeMod) ->
    Type = if SafeMod -> update_safe ; true -> update end,
    UpdateTask = #updatetask{type = Type,collection = Collection,selector = Selector,opts = Opts,commandDoc = CommandDoc},
    gen_server:call( db_task, {addupdatetask,EntityName, term_to_binary(UpdateTask)}).



