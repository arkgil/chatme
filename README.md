# Chatme

TCP chat client and server for Distributed Systems class.

## Usage

### Server

To start a server, type:
```bash
$ server/dist/server
```

### Client
To start a client:
```bash
$ client/dist/client --name <nickname> --media <path_to_media>
```

Contents of file passed as argument to `--media` will be sent to all other
clients when you type in "M" in client prompt.

--
To see additional options of both client and server, use `-h` option.
