object port;

void incoming(object frame, object from) {
    switch (frame->opcode) {
    case Protocols.WebSocket.FRAME_TEXT:
        from->send_text(frame->text);
        break;
    case Protocols.WebSocket.FRAME_BINARY:
        from->send_binary(frame->data);
        break;
    }
}

void http_cb(object r) {
    r->response_and_finish(([ "error" : 404, "data" : "No such file.", "type" : "text/plain" ]));
}

array extensions = ({
#if constant(Protocols.WebSocket.permessagedeflate)
        Protocols.WebSocket.permessagedeflate(),
        Protocols.WebSocket.conformance_check
#elif constant(Protocols.WebSocket.defragment)
        Protocols.WebSocket.defragment,
        Protocols.WebSocket.conformance_check
#endif
});

void accept_cb(array(string) protocols, object request) {
    object con = request->websocket_accept(0, extensions);
    con->onmessage = incoming;
}

int main(int argc, array(string) argv) {
    int portno = (argc > 1) ? (int)argv[1] : 8080;

    port = Protocols.WebSocket.Port(http_cb, accept_cb, portno);

    write("Go to http://localhost:%d/\n", portno);

    return -1;
}
