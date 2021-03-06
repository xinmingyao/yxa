-module(siptest_utils).

-export([options/1, invite/1]).

options(Host) ->
    {ok, Socket} = gen_udp:open(0),
    {ok, Port} = inet:port(Socket),
    PortStr = integer_to_list(Port),
    Packet =
	"OPTIONS sip:carol@" ++ Host ++ " SIP/2.0\r\n"
	"Via: SIP/2.0/UDP " ++ Host ++ ":" ++ PortStr ++ "\r\n"
	"Max-Forwards: 70\r\n"
	"To: <sip:carol@" ++ Host ++ ">\r\n"
	"From: Alice <sip:alice@atlanta.com>;tag=1928301774\r\n"
	"Call-ID: a84b4c76e66710\r\n"
	"CSeq: 63104 OPTIONS\r\n"
	"Contact: <sip:alice@pc33.atlanta.com>\r\n"
	"\r\n",
    SendRes = gen_udp:send(Socket, Host, 5060, Packet),
    io:format("send result ~p~n", [SendRes]),
    receive %% expect something useful
	{udp, _, _, _, Data} ->
	    io:format("received udp packet:~n~s~n", [Data]);
	Else ->
	    io:format("received ~p~n", [Else])
    end,
    gen_udp:close(Socket).

invite(Host) ->
    {ok, Socket} = gen_udp:open(0),
    {ok, Port} = inet:port(Socket),
    PortStr = integer_to_list(Port),
    Packet =
	"INVITE sip:bob@" ++ Host ++ " SIP/2.0\r\n"
	"Via: SIP/2.0/UDP " ++ Host ++ ":" ++ PortStr ++ "\r\n"
	"Max-Forwards: 70\r\n"
	"To: Bob <sip:bob@" ++ Host ++ ">\r\n"
	"From: Alice <sip:alice@atlanta.com>;tag=1928301774\r\n"
	"Call-ID: a84b4c76e66710@pc33.atlanta.com\r\n"
	"CSeq: 314159 INVITE\r\n"
	"Contact: <sip:alice@pc33.atlanta.com>\r\n"
	"Content-Type: application/sdp\r\n"
	"\r\n",
    SendRes = gen_udp:send(Socket, Host, 5060, Packet),
    io:format("send result ~p~n", [SendRes]),
    receive %% expect Trying
	{udp, _, _, _, Data} ->
	    io:format("received udp packet: ~n~s~n", [Data]);
	Else ->
	    io:format("received ~p~n", [Else])
    end,
    receive %% expect 408
	{udp, _, _, _, Data2} ->
	    io:format("received udp packet: ~n~s~n", [Data2]);
	Else2 ->
	    io:format("received ~p~n", [Else2])
    end,
    gen_udp:close(Socket).
