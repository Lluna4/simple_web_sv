import std/net
import std/strutils
import json

proc main() =
    let sock = newSocket(AF_INET, SOCK_STREAM)
    let configfile = open("config.json")
    var jsonObject = readAll(configfile)
    let parsedObject = parseJson(jsonObject)

    let address = parsedObject["ip"].getStr()
    let port = parsedObject["port"].getInt()
    echo address
    echo port
        
    sock.bindAddr(Port(port), "")
    sock.listen()

    var clientfd: Socket
    var buffer : string

    sock.accept(clientfd)
    echo "client accepted"
    try:
        discard clientfd.recv(buffer, 2048, 5)
    except TimeoutError:
        discard
    echo buffer
    
    var instruct = buffer[0 .. 2]
    echo instruct
    
    case instruct:
        of "GET":
            var rq = buffer[4 .. ^1]
            rq = rq.split(' ')[0]
            echo rq
            if rq == "/":
                var response = "HTTP/1.0 200 OK\r\nContent-Type: $1\r\nConnection: close\r\nServer: Luna\r\n\r\n$2" % ["text/html", ""]
                clientfd.send(response)
                clientfd.send(readFile(parsedObject["default"].getStr()))
                clientfd.close()
main()