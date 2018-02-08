ruleset wovyn_base {
  meta {
    name "Lab 3 - Wovyn"
    author "Melanie Lambson"
    logging on
  }

  rule process_heartbeat {
    select when wovyn heartbeat genericThing
    pre {
      never_used = event:attrs().klog("attrs")
    }
    send_directive("say", {"payload": never_used})
  }

}
