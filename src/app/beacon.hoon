  ::  beacon.hoon
::::  Requests authentication from a watcher process, %sentinel.
::
::    Registers URL(s) and requests authentication status.
::
::    Scry endpoints:
::
::    y  /                (set ship)
::
::    x  /me              url
::    x  /notyet          (set ship)
::    x  /authed          (set ship)
::    x  /burned          (set ship)
::
/-  beacon, sentinel
/+  dbug, default-agent, rudder, server, verb
/~  pages  (page:rudder [url:beacon ships:beacon] appeal:beacon)  /app/beacon
|%
+$  versioned-state
  $%  state-zero
  ==
+$  state-zero  $:
      %zero
      auto=url:beacon
      bids=ships:beacon
    ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-zero
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %.n) bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  "%beacon initialized successfully."
  :_  this
  :~  [%pass /eyre %arvo %e %connect [~ /'beacon'] %beacon]
      [%pass /eyre %arvo %e %connect [~ /'beacon-send'] %beacon]
      [%pass /eyre %arvo %e %connect [~ /'beacon-check'] %beacon]
  ==
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %zero  `this(state old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  (on-poke:default mark vase)
    ::
      %beacon-appeal
    =/  appeal  !<(?([%auto url:beacon] [%send ship:beacon] [%auth ship:beacon] [%burn ship:beacon]) vase)
    ?-    -.appeal
      ::
      ::  Set the agent's authentication URL.
        %auto
      ?>  =(our.bowl src.bowl)
      `this(auto `url:beacon`+.appeal)
      ::
      ::  Authentication for our URL has been requested.  (local only)
        %send
      ?>  =(our.bowl src.bowl)
      :_  this(bids (~(put by bids) `ship:beacon`+.appeal %clotho))
      :~  :*  %pass
              /beacon/(crip (scow %da now.bowl))
              %agent  [`ship:beacon`+.appeal %sentinel]  %watch
              /status/(scot %ud (jam auto))
      ==  ==
      ::
      ::  A URL has been approved.
        %auth
      `this(bids (~(put by bids) `ship:beacon`+.appeal %lachesis))
      ::
      ::  A URL has been disapproved.
        %burn
      `this(bids (~(put by bids) `ship:beacon`+.appeal %atropos))
    ==
  ::
    ::  %handle-http-request:  incoming from eyre
      %handle-http-request
    =+  !<([id=@ta =inbound-request:eyre] vase)
    ?:  ?|
        =(url.request.inbound-request '/beacon')
        =((crip (scag 13 (trip url.request.inbound-request))) '/beacon?rmsg=')
        ==
    ::  Main page, so return rendered page
    =;  out=(quip card _+.state)
      [-.out this(+.state +.out)]
    %.  [bowl !<(order:rudder vase) +.state]
    %-  (steer:rudder _+.state appeal:beacon)
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder +.state)
    |=  =appeal:beacon
    ^-  $@  brief:rudder
        [brief:rudder (list card) _+.state]
    =^  caz  this
      (on-poke %beacon-appeal !>(appeal))
    ['Processed succesfully.' caz +.state]
    ::  Server URL request, so parse JSON
    ?:  =(url.request.inbound-request '/beacon-send')
    ?~  body.request.inbound-request
      (bail id 'not-implemented')
    =/  injs  `@t`+:(need body.request.inbound-request)
    =/  target  `@p`(need (slaw %p (crip (weld "~" (trip (from-js (need (de-json:html injs))))))))
    (on-poke %beacon-appeal !>(`appeal:beacon`[%auth target]))
    ::  Server URL request, so parse JSON
    ?>  =(url.request.inbound-request '/beacon-check')
    ?~  body.request.inbound-request
      (bail id 'not-implemented')
    =/  injs  `@t`+:(need body.request.inbound-request)
    =/  target  `@p`(need (slaw %p (crip (weld "~" (trip (from-js (need (de-json:html injs))))))))
    =/  result  (~(gut by bids) target %atropos)
    :_  this
    %+  give-simple-payload:app:server  id
    %-  simple-payload:http
    %-  json-response:gen:server
    (to-js target ?:(=(%lachesis result) %.y %.n))
    ==
  ++  error-response
    |=  error=@t
    ^-  simple-payload:http
    =,  enjs:format
    %-  json-response:gen:server
    %+  frond  
    %error  s+error
  ++  bail
    |=  [id=@ta error=@t]
    ^-  (quip card _this)
    :_  this
    %+  give-simple-payload:app:server  id
    (error-response error)
  ++  from-js
    =,  dejs:format
    %-  ot
    :~
      [%ship so]
    ==
  ++  to-js
    |=  [=ship:beacon status=?(%.y %.n)]
    |^  ^-  json
    %-  pairs:enjs:format
    :~  :-  'ship'    s+(scot %p ship)
        :-  'status'  b+status
    ==
    --
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:default path)
      [%http-response *]
    `this
    ::
      [%status url:beacon]
    :_  this
    =/  result  (~(gut by bids) `ship:beacon`+<:path '')
    ?:  ?=(%lachesis result)
      [%give %fact ~ %beacon-appeal !>(`appeal:beacon`[%auth `ship:beacon`+<:path])]~
    [%give %fact ~ %beacon-appeal !>(`appeal:beacon`[%burn `ship:beacon`+<:path])]~
  ==
++  on-leave  on-leave:default
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?>  =(our src):bowl
  |^  ?+  path  [~ ~]
        [%y ~]            (arc ~[%clotho %lachesis %atropos])
        [%x %me ~]        ``noun+!>(auto)
        [%x %notyet ~]
          %-  alp
          %-  ~(rep by bids)
          |=  [p=[a=ship:beacon b=fate:beacon] q=(set ship:beacon)]
          ?:  ?=(%clotho b.p)  (~(put in q) a.p)  q
        [%x %authed ~]
          %-  alp
          %-  ~(rep by bids)
          |=  [p=[a=ship:beacon b=fate:beacon] q=(set ship:beacon)]
          ?:  ?=(%lachesis b.p)  (~(put in q) a.p)  q
        [%x %burned ~]
          %-  alp
          %-  ~(rep by bids)
          |=  [p=[a=ship:beacon b=fate:beacon] q=(set ship:beacon)]
          ?:  ?=(%atropos b.p)  (~(put in q) a.p)  q
        [%x %ship ship:beacon ~]
          ``noun+!>((~(get by bids) (need (slaw %p +>-.path))))
      ==
  ::  scry results
  ++  arc  |=  l=(list url:beacon)  ``noun+!>(`arch`~^(malt (turn l (late ~))))
  ++  alp  |=  s=(set ship:beacon)  ``noun+!>(s)
  ++  alf  |=  f=?           ``noun+!>(f)
  ++  ask  |=  u=(unit ?)  ?^(u (alf u.u) [~ ~])
  ::  data wrestling
  ++  nab  ~(got by bids)
  ::  set shorthands
  ++  sin  |*(s=(set) ~(has in s))
  ++  sit  |*(s=(set) ~(tap in s))
  ++  ski  |*([s=(set) f=$-(* ?)] (sy (skim (sit s) f)))
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ::  handle wire returns from agents
  ?+    wire  (on-agent:default wire sign)
      [%beacon * ~]
    ?+    -.sign  (on-agent:default wire sign)
        %watch-ack
      ?~  p.sign
        ((slog '%beacon: Subscribe succeeded!' ~) `this)
      ((slog '%beacon: Subscribe failed!' ~) `this)
      ::
        %fact
      ?+    p.cage.sign  (on-agent:default wire sign)
        :: It's a bit strange to unpack these because they return the
        :: action and the ship, which is the source already.  TODO clean up
          %beacon-appeal
        =/  action  !<(appeal:beacon q.cage.sign)
        ?+    -.action  (on-agent:default wire sign)
            %auth
          `this(bids (~(put by bids) `ship:sentinel`src.bowl %lachesis))
            %burn
          `this(bids (~(put by bids) `ship:sentinel`src.bowl %atropos))
        ==
      ==
    ==
  ==
::
++  on-arvo
|=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=([%eyre %bound *] sign-arvo)
    (on-arvo:default [wire sign-arvo])
  ?:  accepted.sign-arvo
    %-  (slog leaf+"%beacon:  endpoints bound successfully!" ~)
    `this
  %-  (slog leaf+"%beacon:  binding endpoints failed!" ~)
  `this
++  on-fail   on-fail:default
--
