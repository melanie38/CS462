ruleset wovyn_base {
  meta {
    name "Lab 3 - Wovyn"
    author "Melanie Lambson"
    logging on
  }

  rule process_heartbeat {
    select when wovyn heartbeat
    pre {
      never_used = event:attrs().klog("attrs")
    }
    if event:attrs("genericThing" != null) then
      send_directive("say", {"payload": never_used})
  }

}
