%%%-------------------------------------------------------------------
%%% @author anyongbo
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 八月 2018 17:09
%%%-------------------------------------------------------------------
-module(db_task).
-author("anyongbo").

-behaviour(gen_server).
-include("db_task.hrl").

-define( MASTER_ENTITY(EntityName),  iolist_to_binary([ <<"master">>,common_tool:to_binary( EntityName)])).
-define( SECONDARY_ENTITY(EntityName),  iolist_to_binary([ <<"secondary">>,common_tool:to_binary( EntityName)])).
-define(GET(Type,EntityName), get(  if Type == master ->  ?MASTER_ENTITY(EntityName) ; true ->  ?SECONDARY_ENTITY(EntityName) end )).
-define(PUT(Type,EntityName,Value), put(  if Type == master ->  ?MASTER_ENTITY(EntityName) ; true ->  ?SECONDARY_ENTITY(EntityName) end,Value )).


%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-export([add_find_task/2,add_count_task/2,add_delete_task/2]).

-define(SERVER, ?MODULE).


-define(TRANSACTION_TIMEOUT, 5000).
-record(state, {
    dbpools,
    monitors = #{}
}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    process_flag(trap_exit, true),
    erlang:process_flag(min_bin_vheap_size,1024*1024),
    erlang:process_flag(min_heap_size,1024*1024),
    {ok, #state{dbpools = dbpools}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call({addfindtask,EntityName,FindTask}, From, State) ->
    add_find_task(EntityName, binary_to_term( FindTask),From,State);
handle_call({addcounttask,EntityName,CountTask}, From, State) ->
    add_count_task(EntityName,binary_to_term(CountTask),From,State);
handle_call({adddeletetask,EntityName,DelTask}, From, State) ->
    add_delete_task(EntityName,binary_to_term(DelTask),From,State);
handle_call({addinserttask,EntityName, InsertTask}, From, State) ->
    add_insert_task(EntityName, binary_to_term(InsertTask),From,State);
handle_call({addupdatetask,EntityName, UpdateTask}, From, State) ->
    add_update_task(EntityName, binary_to_term(UpdateTask),From,State);
handle_call({gettask,EntityName,ReadMod}, _From, State) ->
    Task =  get_task(EntityName,ReadMod,State),
    {reply,  Task, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(_Request, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_info({'DOWN', MRef, A, B, C}, State) ->
    %lager:error("-----------dbtask childprocess DOWN------------~p~n",[{MRef, A, B, C}]),
    {noreply, State};
handle_info({'EXIT', Pid, Reason}, State) ->
    %lager:error("-----------dbtask childprocess exit------------~p~n",[{Pid,Reason}]),
    {noreply, on_childprocess_exit(Pid,State)};
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #state{}) -> term()).
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
    {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

add_find_task(EntityName,FindTask) ->
    gen_server:call(?MODULE,{addfindtask,EntityName,FindTask}).

add_count_task(EntityName,CountTask) ->
    gen_server:call(?MODULE,{addcounttask,EntityName,CountTask}).

add_delete_task(EntityName,DelTask) ->
    gen_server:call(?MODULE,{adddeletetask,EntityName,DelTask}).

get_task(EntityName,ReadMod) ->
    gen_server:call(?MODULE,{gettask,EntityName,ReadMod}).


%%%===================================================================
%%% private functions
%%%===================================================================
%handle_info({Net, _Socket, Data}, State = #state{request_storage = RequestStorage}) when Net =:= tcp; Net =:= ssl ->
add_find_task(EntityName, FindTask = #findtask{type = Type},{FromPid, _} = From,State) when Type == find;Type==findone ->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName, FindTask#findtask{from = From,ref = Ref},Type,State),
    {noreply,State#state{monitors = NewMonitors}};
add_find_task(EntityName, FindTask = #findtask{type = Type},{FromPid, _} = From,State) when Type == find_sp;Type==findone_sp ->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName, FindTask#findtask{from = From,ref = Ref},Type,State),
    {noreply,State#state{monitors = NewMonitors}}.

add_count_task(EntityName, CountTask = #counttask{type = Type},{FromPid, _} = From,State) when Type == count ->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName, CountTask#counttask{from = From,ref = Ref},Type,State),
    {noreply,State#state{monitors = NewMonitors}}.
%%add_count_task(EntityName, CountTask = #counttask{type = Type},{FromPid, _} = From,State) when Type == count_sp ->
%%    Ref = erlang:monitor(process, FromPid),
%%    {NewEntityMap,NewMonitors} = add_task_(EntityName, CountTask#counttask{from = From,ref = Ref},Type,State),
%%    {noreply,State#state{secondaryPreferred_entitymap = NewEntityMap,monitors = NewMonitors}}.

add_delete_task(EntityName,DelTask = #deletetask{type = Type},{FromPid, _} = From,State) when Type == delete ;type == deleteone->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName,DelTask#deletetask{from = From,ref = Ref},Type,State),
    {reply,ok,State#state{monitors = NewMonitors}};
add_delete_task(EntityName,DelTask = #deletetask{type = Type},{FromPid, _} = From,State) when Type == delete_safe ->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName,DelTask#deletetask{from = From,ref = Ref},Type,State),
    {noreply,State#state{monitors = NewMonitors}}.

add_insert_task(EntityName,InsertTask = #inserttask{type = Type},{FromPid, _} = From,State) when Type == insert ; Type == insertone ->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName,InsertTask#inserttask{from = From,ref = Ref},Type,State),
    {reply,ok,State#state{monitors = NewMonitors}};
   %% {reply,ok,State};
add_insert_task(EntityName,InsertTask = #inserttask{type = Type},{FromPid, _} = From,State) when Type == insert_safe;Type == insertone_safe ->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName,InsertTask#inserttask{from = From,ref = Ref},Type,State),
    {noreply,State#state{monitors = NewMonitors}}.
    %{noreply,State}.

add_update_task(EntityName, UpdateTask = #updatetask{type = Type},{FromPid, _} = From,State) when Type == update ->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName, UpdateTask#updatetask{from = From,ref = Ref},Type,State),
    {reply,ok,State#state{monitors = NewMonitors}};
add_update_task(EntityName, UpdateTask = #updatetask{type = Type},{FromPid, _} = From,State) when Type == update_safe ->
    Ref = erlang:monitor(process, FromPid),
    NewMonitors = add_task_(EntityName, UpdateTask#updatetask{from = From,ref = Ref},Type,State),
    {noreply,State#state{monitors = NewMonitors}}.

add_task_(EntityName,Task,Type,State) ->
    ReadMode = get_readtype(Type),
    %EntityMap =  if ReadMode == master -> State#state.master_entitymap; true -> State#state.secondaryPreferred_entitymap end,
    Monitors = State#state.monitors,
    DB = State#state.dbpools,
    case ?GET(ReadMode,EntityName) of
        undefined ->
            %lager:debug("---------add new queue sp-------~p~n",[{EntityName,Task}]),
            Queue = queue:new(),
            ?PUT(ReadMode,EntityName,queue:in(Task,Queue)),
            Pid = spawn_link( fun() -> executeTask(EntityName,ReadMode,DB)  end ) ,
            NewMonitors = maps:put(Pid,{EntityName,ReadMode},Monitors),
            NewMonitors;
        Queue ->
            %lager:debug("---------add in queue sp-------~p~n",[{EntityName,Task}]),
            ?PUT(ReadMode,EntityName,queue:in(Task,Queue)),
            Monitors
    end.



%%delete( UseDBpool , Collection , Selector,SafeMod) ->
%%    mongo_api:delete_changeDB( UseDBpool , Collection , Selector, infinity ,SafeMod) .
%%delete_one( UseDBpool , Collection , Selector,SafeMod) ->
%%    mongo_api:delete_one_changeDB( UseDBpool , Collection , Selector, infinity,SafeMod ) .

%%------------------------------%%---------------------------------------------------%%---------------------------------------
get_task(EntityName,ReadType,State)->
    %lager:debug("------------get_task-------------~p~n",[{EntityName,ReadType}]),
    case ?GET(ReadType,EntityName) of
        undefined ->
            %lager:debug("------------not this EntityName-------------~p~n",[{EntityName,ReadType}]),
            null;
        Queue ->
            case queue:out(Queue) of
                {{value, Task}, Left} ->
                    %lager:debug("------------get_task task-------------~p~n",[{EntityName,ReadType,Task}]),
                    %NewEntityMap = maps:update(EntityName,Left,EntityMap),
                    ?PUT(ReadType,EntityName,Left),
                    term_to_binary(Task);
                {empty, _} ->
                    %lager:debug("------------get_task empty-------------~p~n",[{EntityName,ReadType}]),
                    %空了，把entityname在map中删除
                    %NewEntityMap = maps:remove(EntityName,EntityMap),
                    ?PUT(ReadType,EntityName,undefined),
                    null
            end
    end.

executeTask(EntityName,Type,DB)->
    %lager:debug("--------executeTask--------~p~n",[{self(),EntityName,Type,DB}]),
    ReadMode =  if Type == master -> primary ; true -> secondaryPreferred end,
    transaction_query(DB, fun(Worker) ->
            %从队列中取一个
            loop_get(Worker,EntityName,Type)
        end,#{ rp_mode => ReadMode }).

loop_get(Conf,EntityName,Type) ->
    case get_task(EntityName,Type) of
        null ->
            nothing;
        Task ->
            execute(Conf,binary_to_term(Task)),
            loop_get(Conf,EntityName,Type)
    end.

transaction_query(Topology, Transaction) ->
    transaction_query(Topology, Transaction, []).
transaction_query(Topology, Transaction, Options) ->
    transaction_query(Topology, Transaction, Options, ?TRANSACTION_TIMEOUT).
-spec transaction_query(pid() | atom(), fun(), proplists:proplist(), integer() | infinity) -> any().
transaction_query(Topology, Transaction, Options, Timeout) ->
    case mc_topology:get_pool(Topology, Options) of
        {ok, Pool = #{pool := C}} ->
            poolboy:transaction(C, fun(Worker) -> Transaction(Pool#{pool => Worker}) end, Timeout);
        Error ->
            Error
    end.


on_childprocess_exit(Pid,State)->
    Monitors = State#state.monitors,
    DB = State#state.dbpools,
    %lager:debug("-------------dbtask on_childprocess_exit Monitors---------~p~n",[Monitors]),
    case maps:find(Pid,Monitors) of
        {ok,{EntityName,ReadType}} ->
            %EntityMap =  if ReadType == master -> State#state.master_entitymap; true -> State#state.secondaryPreferred_entitymap end,
            %lager:debug("-------------dbtask on_childprocess_exit EntityName,EntityMap---------~p~n",[{EntityName,EntityMap}]),
            case ?GET(ReadType,EntityName) of
                undefined ->
                    State#state{monitors = maps:remove(Pid,Monitors)};
                _->
                    %还有没处理完的任务啊，在启动一次吧
                    NewPid = spawn_link( fun() -> executeTask(EntityName,ReadType,DB)  end ) ,
                    NewMonitors = maps:remove(Pid,Monitors),
                    NewMonitors1 = maps:put(NewPid,{EntityName,ReadType},NewMonitors),
                    State#state{monitors = NewMonitors1}
            end;
        error ->
            %lager:error("-------------dbtask on_childprocess_exit notfount childprocess---------~p~n",[Pid]),
            State
    end.

get_readtype(Type) ->
    if
        Type == find;Type==findone;Type==count;Type == insert;Type == insertone;Type == insert_safe;Type == insertone_safe;
            Type == delete;Type == deleteone;Type == delete_safe;Type == deleteone_safe;Type == update;Type == update_safe->
            master;
        true->
            secondaryPreferred
    end.
%%%%%%%%%%% findtask
execute( Conf , #findtask{type = Type,collection = {Db,Collection},selector = Selector,projector = Projector,skip=Skip,limit = Limit,from = From})
    when ((Type == find) or (Type == find_sp)) and (Limit == 0)->
    %lager:debug("--------execute mongo find Limit=0--------~p~n",[{Type,Conf, Collection, Selector, Projector, Skip}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Query = mongoc:find_query(Conf, Collection, Selector, Projector, Skip, 0),
    case  mc_worker_api:find(C, Query) of
        {ok,Cursor} ->
            Result = mc_cursor:rest(Cursor) ,
            mc_cursor:close(Cursor),
            reply(From,Result);
        _->
            reply(From,[])
    end;
execute( Conf , #findtask{type = Type,collection =  {Db,Collection},selector = Selector,projector = Projector,skip=Skip,limit = Limit,from = From})
    when ((Type == find) or (Type == find_sp)) and (Limit > 0)->
    %lager:debug("--------execute mongo find Limit>0--------~p~n",[{Type,Conf, Collection, Selector, Projector, Skip}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Query = mongoc:find_query(Conf, Collection, Selector, Projector, Skip, 0),
    case  mc_worker_api:find(C, Query) of
        {ok,Cursor} ->
            Result =  mc_cursor:take( Cursor , Limit )  ,
            mc_cursor:close(Cursor),
            reply(From,Result);
        _->
            reply(From,[])
    end;
execute( Conf , #findtask{type = Type,collection =  {Db,Collection},selector = Selector,projector = Projector,skip=Skip,from = From})
    when Type == findone ; Type == findone_sp->
    %lager:debug("--------execute mongo findone--------~p~n",[{Type,Conf, Collection, Selector, Projector}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Query = mongoc:find_one_query(Conf, Collection, Selector, Projector, Skip),
    Result = mc_worker_api:find_one(C, Query),
    reply(From,Result);


%%%%%%%%%%% counttask
execute( Conf , #counttask{type = Type,collection =  {Db,Collection},selector = Selector, limit = Limit, from = From})
    when Type == count->
    %lager:debug("--------execute mongo count--------~p~n",[{Type,Conf, Collection, Selector}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Query = mongoc:count_query(Conf, Collection, Selector, Limit),
    Result = mc_worker_api:count(C, Query),
%    Result = mongoc:countEx(Conf, Collection, Selector,{rp_mode, primary} , 0),
    reply(From,Result);
%%execute( Conf , #counttask{type = Type,collection =  {Db,Collection},selector = Selector, limit = Limit,from = From})
%%    when Type == count_sp->
%%    lager:debug("--------execute mongo count--------~p~n",[{Type,Conf, Collection, Selector}]),
%%    C = maps:get(pool,Conf),
%%    mc_worker_api:set_database( C , Db ) ,
%%    Query = mongoc:count_query(Conf, Collection, Selector, Limit),
%%    Result = mc_worker_api:count(C, Query),
%%    %Result = mongoc:countEx(Conf, Collection, Selector,{rp_mode, secondaryPreferred} , 0),
%%    reply(From,Result);

%%%%%%%%%%% deletetask
execute( Conf , #deletetask{type = Type,collection =  {Db,Collection},selector = Selector,from = _From})
    when Type == delete->
    %lager:debug("--------execute mongo delete--------~p~n",[{Type,Conf, Collection, Selector}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    mc_worker_api:delete(C, Collection, Selector) ;
execute( Conf , #deletetask{type = Type,collection =  {Db,Collection},selector = Selector,from = _From})
    when Type == deleteone->
    %lager:debug("--------execute mongo deleteone--------~p~n",[{Type,Conf, Collection, Selector}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    mc_worker_api:delete_one(C, Collection, Selector) ;
execute( Conf , #deletetask{type = Type,collection =  {Db,Collection},selector = Selector,from = From})
    when Type == delete_safe->
    %lager:debug("--------execute mongo safe delete--------~p~n",[{Type,Conf, Collection, Selector}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Result = mc_worker_api:delete_limit(C, Collection, Selector,0,{<<"w">>, 1}) ,
    reply(From,Result);
execute( Conf , #deletetask{type = Type,collection =  {Db,Collection},selector = Selector,from = From})
    when Type == deleteone_safe->
    %lager:debug("--------execute mongo safe deleteone--------~p~n",[{Type,Conf, Collection, Selector}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Result = mc_worker_api:delete_limit(C, Collection, Selector,1,{<<"w">>, 1}) ,
    reply(From,Result);

%%%%%%%%%%% inserttask
execute( Conf , #inserttask{type = Type,collection =  {Db,Collection},commandDoc = CommandDoc,from = _From})
    when Type == insert ; Type == insertone->
    %lager:debug("--------execute mongo insert--------~p~n",[{Type,Conf, Collection,CommandDoc}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    mc_worker_api:insert(C, Collection, CommandDoc,{<<"w">>, 0})  ;
execute( Conf , #inserttask{type = Type,collection =  {Db,Collection},commandDoc = CommandDoc,from = From})
    when Type == insert_safe ; Type == insertone_safe->
    %lager:debug("--------execute mongo safe insert--------~p~n",[{Type,Conf, Collection,CommandDoc}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Result = mc_worker_api:insert(C, Collection, CommandDoc),
    reply(From,Result);

%%%%%%%%%%% updatetask
execute( Conf , #updatetask{type = Type,collection =  {Db,Collection},selector = Selector,opts = Opts,commandDoc = CommandDoc,from = _From})
    when Type == update ->
    %lager:debug("--------execute mongo update--------~p~n",[{Type,Conf, Selector,Opts,CommandDoc}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Upsert = maps:get(upsert, Opts, false),
    MultiUpdate = maps:get(multi, Opts, false),
    mc_worker_api:update(C, Collection, Selector, CommandDoc, Upsert, MultiUpdate);
execute( Conf , #updatetask{type = Type,collection =  {Db,Collection},selector = Selector,opts = Opts,commandDoc = CommandDoc,from = From})
    when Type == insert_safe ; Type == insertone_safe->
    %lager:debug("--------execute mongo safe update--------~p~n",[{Type,Conf,Selector,Collection}]),
    C = maps:get(pool,Conf),
    mc_worker_api:set_database( C , Db ) ,
    Upsert = maps:get(upsert, Opts, false),
    MultiUpdate = maps:get(multi, Opts, false),
    Result =  mc_worker_api:update(C, Collection, Selector, CommandDoc, Upsert, MultiUpdate,{<<"w">>, 1}),
    reply(From,Result).

reply(From,Result) ->
    {Pid,_} = From,
    Alive = erlang:is_process_alive(Pid),
    if
        Alive ->
            gen_server:reply(From,Result);
        true->
            %lager:error("---------execute findone task,reply process is down ----------~p~n",[Pid]),
            nothing
    end.
