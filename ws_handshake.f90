module ws_handshake
    use sockets
    implicit none
contains
    subroutine perform_handshake(sock, host, path)
        integer, intent(in) :: sock
        character(len=*), intent(in) :: host, path
        character(len=256) :: key
        character(len=1024) :: request, response

        ! Fixed base64 key for simplicity
        key = "dGhlIHNhbXBsZSBub25jZQ=="

        request = "GET " // trim(path) // " HTTP/1.1" // char(13)//char(10) // &
                  "Host: " // trim(host) // char(13)//char(10) // &
                  "Upgrade: websocket" // char(13)//char(10) // &
                  "Connection: Upgrade" // char(13)//char(10) // &
                  "Sec-WebSocket-Key: " // key // char(13)//char(10) // &
                  "Sec-WebSocket-Version: 13" // char(13)//char(10) // char(13)//char(10)

        call tcp_send(sock, request)
        print *, "Handshake request sent:"
        print *, trim(request)

        call tcp_recv(sock, response)
        print *, "Handshake response received:"
        print *, trim(response)
    end subroutine
end module
