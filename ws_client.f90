module ws_client
    use sockets
    use ws_handshake
    use ws_frame
    implicit none
contains

    subroutine connect_ws(host, port, path, sock)
        integer, intent(out) :: sock
        character(len=*), intent(in) :: host, path
        integer, intent(in) :: port

        call tcp_connect(host, port, sock)
        call perform_handshake(sock, host, path)
    end subroutine

    subroutine tcp_send_frame(sock, frame, frame_len)
        integer, intent(in) :: sock
        integer, intent(in) :: frame(:)
        integer, intent(in) :: frame_len
        character(len=1024) :: buffer
        integer :: i

        do i = 1, frame_len
            buffer(i:i) = achar(frame(i))
        end do

        call tcp_send(sock, buffer(1:frame_len))
    end subroutine

    subroutine send_close(sock)
        integer, intent(in) :: sock
        character(len=2) :: frame
        frame(1:1) = char(128 + 8)
        frame(2:2) = char(0)
        call tcp_send(sock, frame)
    end subroutine

    subroutine send_ping(sock)
        integer, intent(in) :: sock
        call send_ws(sock, "", 9) ! Ping frame
    end subroutine

    subroutine send_pong(sock)
        integer, intent(in) :: sock
        call send_ws(sock, "", 10) ! Pong frame
    end subroutine

    subroutine tcp_recv_frame(sock, frame, frame_len)
        integer, intent(in) :: sock
        integer, intent(out) :: frame(:)
        integer, intent(out) :: frame_len
        character(len=1024) :: buffer
        integer :: i, n

        call tcp_recv(sock, buffer)
        n = len_trim(buffer)
        frame_len = n

        do i = 1, n
            frame(i) = iachar(buffer(i:i))
        end do
    end subroutine

    ! ---------- Send frame with opcode ----------
    subroutine send_ws(sock, message, opcode)
        integer, intent(in) :: sock
        character(len=*), intent(in) :: message
        integer, intent(in), optional :: opcode
        integer :: frame(1024)
        integer :: frame_len
        integer :: op

        if (present(opcode)) then
            op = opcode
        else
            op = 1   ! default text frame
        end if

        call encode_frame(message, frame, frame_len, op)
        call tcp_send_frame(sock, frame, frame_len)
    end subroutine

    ! ---------- Receive and decode ----------
    subroutine recv_ws(sock, message, opcode)
        integer, intent(in) :: sock
        character(len=1024), intent(out) :: message
        integer, intent(out), optional :: opcode
        integer :: frame(1024)
        integer :: frame_len
        integer :: op

        call tcp_recv_frame(sock, frame, frame_len)
        call decode_frame(frame, frame_len, message, op)

        if (present(opcode)) opcode = op

        select case (op)
        case (1)  ! text frame
            print *, "Received [opcode=1]:", trim(message)
        case (2)  ! binary frame
            print *, "Received [opcode=2] (binary data)"
        case (8)  ! close frame
            print *, "Received [opcode=8]: Close request"
            call send_close(sock)
        case (9) ! ping frame
            print *, "Ping received, sending pong"
            call send_pong(sock)
        case (10) ! pong frame
            print *, "Pong received"
        case default
            print *, "Received [opcode=", op, "]: (unhandled)"
        end select
end subroutine

end module
