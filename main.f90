program main
    use ws_client
    use sockets
    implicit none
    integer :: sock
    character(len=1024) :: msg

    call connect_ws("localhost", 8765, "/", sock)

    call send_ws(sock, "HELLO FROM FORTRAN LOL")
    call recv_ws(sock, msg)
    print *, "Received:", trim(msg)

    call tcp_close(sock)
end program
