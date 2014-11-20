%%% The MIT License (MIT)
%%% 
%%% Copyright (c) 2014 Marcelo Camargo
%%% 
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%% 
%%% The above copyright notice and this permission notice shall be included in
%%% all copies or substantial portions of the Software.
%%% 
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%%% THE SOFTWARE.

-module(prelude).
-export([each/2, filter/2, find/2, get_type/1, head/1, id/1, is_type/2, len/1, map/2, maximum/1, mean/1, minimum/1, 
	product/1, reject/2, reverse/1, sort/1, sum/1, tail/1, take/2, unique/1]).
-author("Marcelo Camargo").
-mail("marcelocamargo@linuxmail.org").
%%% Prelude-LS port for Erlang.


%% Applies a function to each item in the list and returns the original list. 
%% Used for side effects. 
%% (a -> Undefined) -> [a] -> [a]
each(Closure, Element) when is_function(Closure) ->
	[Closure(X) || X <- Element],
	Element;
each(_, _) -> error.

%% Returns a new list composed of the items which pass the supplied 
%% function's test.
%% (a -> Boolean) -> [a] -> [a]
filter(Closure, Element) when is_function(Closure) ->
	[X || X <- Element, Closure(X)];
filter(_, _) -> error.

%% Returns the first item in list to pass the function's test. Returns undefined
%% if all items fail the test.
find(Closure, [Head | Tail]) when is_function(Closure) ->
	case Closure(Head) of
		true  -> Head;
		false -> find(Closure, Tail)
	end;
find(_, []) -> none;
find(_, _)  -> error.

%% Returns the type of an element
%% a -> Mixed
get_type(Element) ->
	if  is_atom(Element)      -> atom;
	    is_bitstring(Element) -> bitstring;
	    is_integer(Element)   -> float;
	    is_float(Element)     -> float;
	    is_pid(Element)       -> pid;
	    is_binary(Element)    -> binary;
	    is_boolean(Element)   -> boolean;
	    is_function(Element)  -> function;
	    is_list(Element)      -> list;
	    is_port(Element)      -> port;
	    is_number(Element)    -> number;
	    is_tuple(Element)     -> tuple;
	    is_reference(Element) -> reference;
	    true -> unknown
	end.

%% The first item of the list. Returns undefined if the list is empty.
%% [a] -> Maybe a
head([Head | _]) ->
	Head;
head([]) -> none;
head(_)  -> error.

%% A function which does nothing: it simply returns its single argument.
%% Useful as a placeholder.
%% a -> a
id(X) -> X.

%% Takes a string (type name) and a value, and returns if the values if of that
%% type.
%% String -> a -> Boolean
is_type(Type, Element) when Type =/= "" ->
	T = get_type(Element),
	T =:= Type;
is_type(_, _) -> error.

%% Gives the length of a list.
%% [a] -> Number
len([_ | Tail]) -> 1 + len(Tail);
len([]) -> 0.

%% Applies a function to each item in the list, and produces a new list with
%% the results. The length of the result is the same length as the input.
%% (a -> b) -> [a] -> [b]
map(Closure, Element) when is_function(Closure) ->
	[Closure(X) || X <- Element];
map(_, _) -> error.

%% Takes a list of comparable items, and returns the largest of them.
%% [a] -> a
maximum([Head | Tail]) -> maximum(Tail, Head).

maximum([], Max)                            -> Max;
maximum([Head | Tail], Max) when Head > Max -> maximum(Tail, Head);
maximum([_    | Tail], Max)                 -> maximum(Tail, Max).

%% Gets the mean of the values in the list.
%% [Number] -> Number
mean([])   -> none;
mean(List) -> sum(List) / len(List).

%% Takes a list of comparable items, and returns the smallest of them.
%% [a] -> a
minimum([Head | Tail]) -> minimum(Tail, Head).

minimum([], Min)                            -> Min;
minimum([Head | Tail], Min) when Head < Min -> minimum(Tail, Head);
minimum([_    | Tail], Min)                 -> minimum(Tail, Min).

%% Gets the product of all the items in the list.
%% [Number] -> Number
product([])   -> 0;
product(List) -> product(List, 1).

product([], Product) -> Product;
product([Head | Tail], Product) -> product(Tail, Product * Head).

%% Like filter, but the new list is composed of all the items which fail the
%% function's test.
%% (a -> Boolean) -> [a] -> [a]
reject(Closure, Element) when is_function(Closure) ->
	[X || X <- Element, not Closure(X)];
reject(_, _) -> error.

%% Returns a new list which is the reverse of the inputted one.
%% [a] -> [a]
reverse(List) -> reverse(List, []).

reverse([Head | Tail], Result) ->
	reverse(Tail, [Head | Result]);
reverse([], Result) -> Result.

%% Sorts a list. Does not modify the input.
%% [a] -> [a]
sort([]) -> [];
sort([Head | Tail]) -> 
	sort([X || X <- Tail, X < Head]) ++ [Head] ++ sort([X || X <- Tail, X >= Head]). 

%% Sums up the values in the list.
%% [Number] -> Number
sum(List) -> sum(List, 0).

sum([], Sum) -> Sum;
sum([Head | Tail], Sum) -> sum(Tail, Head + Sum).

%% Everything but the first item of the list.
%% [a] -> [a]
tail([_ | Tail]) ->
	Tail;
tail([]) -> none;
tail(_)  -> error.

%% Returns the first n items in the list.
%% Number -> [a] -> [a]
take(N, List)     -> take(List, N, []).

take([], _, [])   -> [];
take([], _, List) -> List;
take([Head | Tail], N, List) when N > 0  -> take(Tail, N - 1, lists:append(List,[Head]));
take([_    | _   ], N, List) when N == 0 -> List.

%% Returns a new list which contains each value of the inputted list only once.
%% [a] -> [a]
unique(L) ->
    unique(L, [], []).

unique([], _, Acc) ->
    lists:reverse(Acc);
unique([X | Rest], Seen, Acc) ->
	case lists:member(X, Seen) of
		true -> unique(Rest, Seen, lists:delete(X, Acc));
		false -> unique(Rest, [X | Seen], [X | Acc])
	end.
