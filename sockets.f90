module sockets
    use iso_c_binding
    implicit none

    interface
        function connect_tcp(host, port) bind(C, name="connect_tcp")
            import :: c_int, c_char
            character(kind=c_char), dimension(*), intent(in) :: host
            integer(c_int), value :: port
            integer(c_int) :: connect_tcp
        end function

        function send_tcp(sock, buf, len) bind(C, name="send_tcp")
            import :: c_int, c_char
            integer(c_int), value :: sock
            character(kind=c_char), dimension(*), intent(in) :: buf
            integer(c_int), value :: len
            integer(c_int) :: send_tcp
        end function

        function recv_tcp(sock, buf, len) bind(C, name="recv_tcp")
            import :: c_int, c_char
            integer(c_int), value :: sock
            character(kind=c_char), dimension(*), intent(out) :: buf
            integer(c_int), value :: len
            integer(c_int) :: recv_tcp
        end function

        function close_tcp(sock) bind(C, name="close_tcp")
            import :: c_int
            integer(c_int), value :: sock
            integer(c_int) :: close_tcp
        end function
    end interface

contains

    subroutine tcp_connect(host, port, sock)
        character(len=*), intent(in) :: host
        integer, intent(in) :: port
        integer, intent(out) :: sock
        sock = connect_tcp(trim(host)//char(0), port)
        if (sock < 0) stop "Failed to connect!"
    end subroutine

    subroutine tcp_send(sock, data)
        integer, intent(in) :: sock
        character(len=*), intent(in) :: data
        integer :: ierr
        ierr = send_tcp(sock, data//char(0), len_trim(data))
    end subroutine

    subroutine tcp_recv(sock, buffer)
        integer, intent(in) :: sock
        character(len=*), intent(out) :: buffer
        integer :: ierr
        ierr = recv_tcp(sock, buffer, len(buffer))
    end subroutine

    subroutine tcp_close(sock)
        integer, intent(in) :: sock
        integer :: ierr
        ierr = close_tcp(sock)
    end subroutine
end module
