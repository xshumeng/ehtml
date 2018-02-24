%%%-------------------------------------------------------------------
%%% @author xshumeng <xue.shumeng@yahoo.com>
%%% @copyright (C) 2018, xshumeng
%%% @doc
%%%
%%% @end
%%% Created : 12 Feb 2018 by xshumeng <xue.shumeng@yahoo.com>
%%%-------------------------------------------------------------------
-module(html_util).
-export([parse/1, get_by_selector/2, get_by_tag/2, get_by_attr/3]).
-export([get_attrs_value/2]).
-export([to_binary/1, to_list/1]).

parse(Bin) ->
    [{undefined, undefined, [mochiweb_html:parse(Bin)]}].

%% TODO: 处理NODES结构非‘三元组’({_,_,_})的情况
get_attrs_value(Attr, Nodes) ->
    get_attrs_value(to_binary(Attr), Nodes, []).

get_attrs_value(_Attr, [], Sum) -> lists:flatten(Sum);
get_attrs_value(Attr, [{_, Attrs, _}|Nodes], Sum) ->
    AttrPairList = [Val || {Name, Val} <- Attrs, Name =:= Attr],
    get_attrs_value(Attr, Nodes, [AttrPairList | Sum]).

get_by_selector(Selector, Nodes) ->
    TokenList = [string:split(Token, ",", all) || Token <- string:split(Selector, " ", all)],
    get_by_selector_iter_tokens(TokenList, Nodes).

get_by_selector_iter_tokens([], Nodes) -> Nodes;
get_by_selector_iter_tokens([Token|Tail], Nodes) ->
    get_by_selector_iter_tokens(Tail, get_by_selector_iter_token(Token, Nodes, [])).

get_by_selector_iter_token([], _Nodes, Sum) -> lists:flatten(Sum);
get_by_selector_iter_token([Token|Tail], Nodes, Sum) ->
    Ret = get_by_selector_iter_element(Token, Nodes, []),
    get_by_selector_iter_token(Tail, Nodes, [Ret|Sum]).

get_by_selector_iter_element(_Token, [], Sum) -> lists:flatten(Sum);
get_by_selector_iter_element(Token, [{_, _, _} = Node|Nodes], Sum) ->
    Ret = case string:slice(Token, 0, 1) of
	      "." ->
		  get_by_attr("class", string:slice(Token, 1), Node);
	      "#" ->
		  get_by_attr("id", string:slice(Token, 1), Node);
	      _ ->
		  get_by_tag(Token, Node)
	  end,
    get_by_selector_iter_element(Token, Nodes, [Ret|Sum]);
get_by_selector_iter_element(Token, [_|Nodes], Sum) ->
    get_by_selector_iter_element(Token, Nodes, Sum).

get_by_tag(Tag, {_, _, Nodes}) ->
    get_by_tag(to_binary(Tag), Nodes, []).

get_by_tag(_Tag, [], Sum) -> lists:flatten(Sum);
get_by_tag(Tag, [{Tag, _, _} = Node | Nodes], Sum) ->
    get_by_tag(Tag, Nodes, [Node|Sum]);
get_by_tag(Tag, [_ | Nodes], Sum) ->
    get_by_tag(Tag, Nodes, Sum).

get_by_attr(Attr, Value, {_, _, Nodes}) ->
    get_by_attr(to_binary(Attr), to_binary(Value), Nodes, []).

get_by_attr(_Attr, _Value, [], Sum) -> lists:flatten(Sum);
get_by_attr(Attr, Value, [{_Tag, Attrs, _} = Node | Nodes], Sum) ->
    case is_match_attr(Attr, Value, Attrs) of
	true ->
	    get_by_attr(Attr, Value, Nodes, [Node|Sum]);
	false ->
	    get_by_attr(Attr, Value, Nodes, Sum)
    end;
get_by_attr(Attr, Value, [_|Nodes], Sum) -> get_by_attr(Attr, Value, Nodes, Sum).

is_match_attr(_Attr, _Value, []) ->
    false;
is_match_attr(Attr, Value, [{Attr, Value} | _Attrs]) ->
    true;
is_match_attr(Attr, Value, [_|Attrs]) ->
    is_match_attr(Attr, Value, Attrs).

to_binary(Term) when is_atom(Term) ->
    list_to_binary(atom_to_list(Term));
to_binary(Term) when is_list(Term) ->
    list_to_binary(Term);
to_binary(Term) when is_binary(Term)->
    Term.

to_list(Term) when is_atom(Term) ->
    atom_to_list(Term);
to_list(Term) when is_binary(Term) ->
    binary_to_list(Term);
to_list(Term) when is_list(Term)->
    Term.
