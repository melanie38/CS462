ruleset wovyn_base {
  meta {
    name "Lab 3 - Wovyn"
    author "Melanie Lambson"
    logging on
  }

  rule process_heartbeat {
    select when wovyn heartbeat
    send_directive("say", {"something": "heartbeat detected"})
  }

}
