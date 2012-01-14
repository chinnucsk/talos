%% -*- tab-width: 4;erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% -------------------------------------------------------------------
%%
%% talos: Distributed Testing Framework
%%
%% Copyright (c) 2012 Basho Technologies, Inc. All Rights Reserved.
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
%% -------------------------------------------------------------------
-module(ssh_sftp_x).

-define(BLOCK_SIZE, 1048576). %% 1 MB

%% Extensions for ssh_sftp module
-export([file_exists/2,
         cp_to/3]).

file_exists(ChannelPid, Filename) ->
    case ssh_sftp:read_file_info(ChannelPid, Filename) of
        {ok, _} ->
            true;
        _ ->
            false
    end.

cp_to(ChannelPid, LocalFilename, RemoteFilename) ->
    %% TODO: copy by block instead of reading whole file into memory
    case file:read_file(LocalFilename) of
        {ok, Data} ->
            case ssh_sftp:write_file(ChannelPid, RemoteFilename, Data) of
                ok ->
                    ok;
                {error, Reason} ->
                    {error, {remote, Reason}}
            end;
        {error, Reason} ->
            {error, {local, Reason}}
    end.
