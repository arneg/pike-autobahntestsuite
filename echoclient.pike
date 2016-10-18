void end() {
    werror("Done.\n");
    exit(0);
}

void update_reports() {
    object con = Protocols.WebSocket.Connection();

    con->onclose = end;

    if (!con->connect("ws://127.0.0.1:9001/updateReports?agent=Pike")) {
        werror("Could not connect.\n");
        exit(1);
    }

}

void incoming_init(object frame, object from) {
    int max = (int)frame->text;
    from->close();
    Case(0, max);
}

class Case {
    int num, max;

    void create(int num, int max) {
        this::num = num;
        this::max = max;

        object con = Protocols.WebSocket.Connection();

        werror("Doing text %d/%d... ", num, max);

        con->onclose = onclose;
        con->onmessage = Protocols.WebSocket.defragment(incoming, con);

        if (!con->connect("ws://127.0.0.1:9001/runCase?agent=Pike&case="+(string)num)) {
            werror("Could not connect.\n");
            exit(1);
        }
    }

    void onclose(object from) {
        werror("done.\n");
        if (num < max) {
            Case(num+1, max);
        } else {
            update_reports();
        }
    }

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
}

int main(int argc, array(string) argv) {
    object con = Protocols.WebSocket.Connection();

    con->onmessage = Protocols.WebSocket.defragment(incoming_init, con);
    if (!con->connect("ws://127.0.0.1:9001/getCaseCount")) {
        werror("Could not connect.\n");
        return 0;
    }

    return -1;
}
