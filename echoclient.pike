void end() {
    werror("Done.\n");
    exit(0);
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

void update_reports() {
    object con = Protocols.WebSocket.Connection();

    con->onclose = end;

    if (!con->connect("ws://127.0.0.1:9001/updateReports?agent=Pike")) {
        werror("Could not connect.\n");
        exit(1);
    }

}

int count;
ADT.Queue todo;
mapping running = ([]);

void start_case() {
    werror("\rDone %d/%d tests.    ", count-sizeof(todo)-sizeof(running), count);
    if (!todo->is_empty()) {
        running[Case(todo->get())] = 1;
    } else if (!sizeof(running)) {
        werror("\n");
        update_reports();
    }
}

void incoming_init(object frame, object from) {
    count = (int)frame->text;
    from->close();
    todo = ADT.Queue(@enumerate(count));
    for (int i = 0; i < 10; i++) start_case();
}

class Case {
    int num;

    void create(int num) {
        this::num = num;

        object con = Protocols.WebSocket.Connection();

        con->onclose = onclose;
        con->onmessage = incoming;

        if (!con->connect("ws://127.0.0.1:9001/runCase?agent=Pike&case="+(string)num, 0, extensions)) {
            werror("Could not connect.\n");
            exit(1);
        }
    }

    void onclose(object from) {
        m_delete(running, this);
        start_case();
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

    con->onmessage = incoming_init;
    if (!con->connect("ws://127.0.0.1:9001/getCaseCount")) {
        werror("Could not connect.\n");
        return 0;
    }

    return -1;
}
