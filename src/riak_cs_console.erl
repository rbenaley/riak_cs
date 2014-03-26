%% ---------------------------------------------------------------------
%%
%% Copyright (c) 2007-2013 Basho Technologies, Inc.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% ---------------------------------------------------------------------

-module(riak_cs_console).

-export([
         status/1,
         cluster_info/1
        ]).

%%%===================================================================
%%% Public API
%%%===================================================================

status([]) ->
    try
        Stats = riak_cs_stats:get_stats_v2(),
        StatString = format_stats(Stats,
            ["-------------------------------------------\n",
                io_lib:format("1-minute stats for ~p~n",[node()])]),
        io:format("~s\n", [StatString])
    catch
        Exception:Reason ->
            lager:error("Status failed ~p:~p",
                [Exception, Reason]),
            io:format("Status failed, see log for details~n"),
            error
    end.


%% in progress.
cluster_info([OutFile]) ->
    try
        cluster_info:dump_local_node(OutFile)
    catch
        error:{badmatch, {error, eacces}} ->
            io:format("Cluster_info failed, permission denied writing to ~p~n", [OutFile]);
        error:{badmatch, {error, enoent}} ->
            io:format("Cluster_info failed, no such directory ~p~n", [filename:dirname(OutFile)]);
        error:{badmatch, {error, enotdir}} ->
            io:format("Cluster_info failed, not a directory ~p~n", [filename:dirname(OutFile)]);
        Exception:Reason ->
            lager:error("Cluster_info failed ~p:~p",
                [Exception, Reason]),
            io:format("Cluster_info failed, see log for details~n"),
            error
    end.

%%%===================================================================
%%% Internal functions
%%%===================================================================

format_stats([], Acc) ->
    lists:reverse(Acc);
format_stats([{Stat, V}|T], Acc) ->
    format_stats(T, [io_lib:format("~p : ~p~n", [Stat, V])|Acc]).
