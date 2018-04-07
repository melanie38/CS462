ruleset gossip {

  meta {
    name "Gossip Temperatures"
    author "Melanie Lambson"
  }

  global {
    state = function() {
      ent:pico_state.defaultsTo({}).put({
        "newMessage" : false,
        "lastSeenMessage" : {
          "ABCD-1234-ABCD-1234-ABCD-129B": 5
        },
        "peers" :
        [
          {
            "id" : "ABCD-1234-ABCD-1234-ABCD-125A",
            "knowsCurrentTemp" : false,
            "lastSeenMessage" : {
              "ABCD-1234-ABCD-1234-ABCD-125A": 3,
              "ABCD-1234-ABCD-1234-ABCD-129B": 5,
              "ABCD-1234-ABCD-1234-ABCD-123C": 10
            }
          },
          {
            "id" : "ABCD-1234-ABCD-1234-ABCD-125B",
            "knowsCurrentTemp" : true,
            "lastSeenMessage" : {
              "ABCD-1234-ABCD-1234-ABCD-125A": 3,
              "ABCD-1234-ABCD-1234-ABCD-129B": 5,
              "ABCD-1234-ABCD-1234-ABCD-123C": 10
            }
          },
          {
            "id" : "ABCD-1234-ABCD-1234-ABCD-125C",
            "knowsCurrentTemp" : false,
            "lastSeenMessage" : {
              "ABCD-1234-ABCD-1234-ABCD-125A": 3,
              "ABCD-1234-ABCD-1234-ABCD-129B": 5,
              "ABCD-1234-ABCD-1234-ABCD-123C": 10
            }
          }
        ]
      })
    }
    getPeer = function(state) {
      lastSeenMessage = ent:pico_state{"lastSeenMessage"}.defaultsTo({});
      peers = ent:pico_state{"peers"}.defaultsTo([]).klog("All Peers: ");

      // Filter peers who knows your current temperature and those who don't
      firstFilteredPeers = peers.collect(function(peer) {
        peer{"knowsCurrentTemp"} == true => "knows" | "ignore"
      });

      results = firstFilteredPeers{"ignore"}.klog("Peers who ignore: ");

      // Filter peers who knows your current temperature but don't have all the messages you have
      firstFilteredPeers{"knows"}.filter(function(peer) {
        peer{"lastSeenMessage"}.has(lastSeenMessage) // == false => results.append(peer)
      });

      // Choose a random peer among this list
      results[random:integer(results.length() - 1)];
    }
    prepareMessage = function(state, subscriber) {

    }
    send = function(subscriber, message) {

    }
    update = function(state) {

    }
  }

  rule start_gossip {
    select when gossip heartbeat

    pre {
      subscriber = getPeer(state).klog("Peer: ")
      m = prepareMessage(state, subscriber)
    }

    always {
      send(subscriber, m);
      update(state);
    }
  }

}
