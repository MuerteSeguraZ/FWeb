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

    ! Wrapper to receive TCP bytes into integer frame
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

    subroutine send_ws(sock, message)
        integer, intent(in) :: sock
        character(len=*), intent(in) :: message
        integer :: frame(1024)
        integer :: frame_len

        call encode_frame(message, frame, frame_len)
        call tcp_send_frame(sock, frame, frame_len)
    end subroutine

    subroutine recv_ws(sock, message)
        integer, intent(in) :: sock
        character(len=1024), intent(out) :: message
        integer :: frame(1024)
        integer :: frame_len, payload_len
        integer :: mask(4), i, idx, start
        integer :: byte

        call tcp_recv_frame(sock, frame, frame_len)

        payload_len = iand(frame(2), 127)

        if (iand(frame(2), 128) /= 0) then
            mask = frame(3:6)
            start = 7
            do i = 1, payload_len
            idx = mod(i-1,4) + 1
            byte = ieor(frame(start+i-1), mask(idx))
            message(i:i) = achar(byte)
        end do
    else
        start = 3
        do i = 1, payload_len
            message(i:i) = achar(frame(start+i-1))
        end do
    end if

    print *, "Received: ", trim(message(1:payload_len))
end subroutine

end module
