%%%-------------------------------------------------------------------
%%% @author anyongbo
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 八月 2018 20:33
%%%-------------------------------------------------------------------
-author("anyongbo").
% Collection , Selector , Projector , Skip , Limit
-record(findtask, {
    type,   %find,findone
    collection,
    selector = #{},
    projector = #{},
    skip = 0,
    limit = 0,
    from,
    ref
}).

-record(counttask,{
    type,
    collection,
    selector = #{},
    limit = 0,
    from,
    ref
}).

-record(deletetask,{
    type,
    collection,
    selector = #{},
    from,
    ref
}).

-record(inserttask,{
    type,
    collection,
    commandDoc,
    from,
    ref
}).

-record(updatetask,{
    type,
    collection,
    selector = #{},
    opts = #{},
    commandDoc,
    from,
    ref
}).