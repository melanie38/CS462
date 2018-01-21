ruleset hello_world {
  meta {
    name "Hello World"
    author "Phil Windley"
    logging on
    shares hello
  }

  global {
    hello = function(obj) {
      msg = "Hello " + obj;
      msg
    }
  }

  rule hello_world {
    select when echo hello
    send_directive("say", {"something": "Hello World"})
  }

  rule hello_monkey {
    select when echo monkey
    pre {
      name = event:attr("name").klog("our passed in name: ")
    }
    send_directive("say", {"something": "Hello " + name | "Monkey")})
  }

}
