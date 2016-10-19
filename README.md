These test scripts are supposed to be used against the [autobahn testsuite](http://autobahn.ws/testsuite/).

# Testing the Server

Start the server on port 9001

    pike echoserver.pike 9001

and then run `wstest` as

    wstest -m fuzzingclient

# Testing the Client

Start the server by running

    wstest -m fuzzingserver

and then run the pike client against it by

    pike echoclient.pike
