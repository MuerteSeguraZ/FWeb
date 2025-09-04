program main
    use ws_client
    use sockets
    implicit none
    integer :: sock
    character(len=1024) :: msg
    integer :: op

    call connect_ws("localhost", 8765, "/", sock)

    call send_ws(sock, "HELLO FROM FORTRAN LOL")  ! text frame
    call send_ping(sock)                           ! ping frame

    ! receive pong or other frames
    call recv_ws(sock, msg, op)

    ! initiate close handshake
    call send_ws(sock, "", 8)

    ! wait for server's close frame
    call recv_ws(sock, msg, op)

    ! now TCP can be safely closed
    call tcp_close(sock)
end program
