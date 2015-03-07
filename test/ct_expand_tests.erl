%%% @doc ct_expand eunit tests.
%%%
%%% Tests f_test/0, g_test/0, h_test/0 and i_test/0 are test functions from
%%% examples/ct_expand_test.erl converted to eunit tests.
%%%
%%% @end

-module(ct_expand_tests).

-compile([{parse_transform, ct_expand},
          {nowarn_unused_function, [{zip, 2},
                                    {wrap, 1},
                                    {my_fun, 0},
                                    {my_fun2, 0}]}]).

-include_lib("eunit/include/eunit.hrl").

-define(CALLED_KEY, {?MODULE, called}).
-define(CLEAR_CALLED, put(?CALLED_KEY, [])).
-define(CALLED(Function), put(?CALLED_KEY, [Function|get(?CALLED_KEY)])).
-define(CHECK_EXPANDED_NOT_CALLED, ?assertEqual([], get(?CALLED_KEY))).

f_test() ->
    T = ct_expand:term(
      [{a, 1},
       {b, ct_expand:term(
             [{ba, 1},
              {bb, ct_expand:term(2)}])}]),
    ?assertEqual([{a, 1}, {b, [{ba, 1}, {bb, 2}]}], T).

%% expand a term which calls a local function - even one which uses a fun reference.
g_test() ->
    ?CLEAR_CALLED,
    T = ct_expand:term(zip([1,2], [a,b])),
    ?CHECK_EXPANDED_NOT_CALLED,
    ?assertEqual([{{1}, {a}}, {{2}, {b}}], T).

h_test() ->
    ?CLEAR_CALLED,
    {T} = ct_expand:term(wrap(my_fun())),
    ?CHECK_EXPANDED_NOT_CALLED,
    ?assertEqual(foo, T()).

i_test() ->
    ?CLEAR_CALLED,
    T = ct_expand:term(gb_trees:insert(a_fun, my_fun2(), gb_trees:empty())),
    ?CHECK_EXPANDED_NOT_CALLED,
    [{a_fun, F}] = gb_trees:to_list(T),
    ?assertEqual({value}, F(value)).

zip([H1|T1], [H2|T2]) ->
    ?CALLED(zip),
    F = my_fun2(),
    [{F(H1),F(H2)} | zip(T1, T2)];
zip([], []) ->
    ?CALLED(zip),
    [].

wrap(X) ->
    ?CALLED(wrap),
    {X}.

my_fun() ->
    ?CALLED(my_fun),
    fun() -> foo end.

my_fun2() ->
    ?CALLED(my_fun2),
    fun wrap/1.
