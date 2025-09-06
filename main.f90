program main
    use ws_client
    use sockets
    implicit none

    integer :: sock
    character(len=1024) :: msg
    integer :: op

    ! Connect to WebSocket server
    call connect_ws("localhost", 8765, "/", sock)

    ! Send a text frame
    call send_ws(sock, "HELLO FROM FORTRAN LOL")

    ! Send a ping frame
    call send_ping(sock)

    ! Receive a frame (could be pong, text, etc.)
    call recv_ws(sock, msg, op)

    ! Initiate close handshake
    call send_ws(sock, "", 8)  ! opcode 8 = close

    ! Wait for server's close frame
    call recv_ws(sock, msg, op)

    ! Close the TCP socket safely
    call tcp_close(sock)

    print *, "WebSocket test finished."
end program
