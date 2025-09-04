module ws_frame
    implicit none
contains

    ! Encode a WebSocket frame (supports text, close, ping, pong)
    subroutine encode_frame(message, frame, frame_len, opcode)
        character(len=*), intent(in) :: message
        integer, intent(out) :: frame(:)
        integer, intent(out) :: frame_len
        integer, intent(in) :: opcode
        integer :: len_msg, i, idx
        integer :: mask(4)
        integer :: msg_byte
        real :: r

        call random_seed()
        len_msg = len_trim(message)

        ! FIN=1 + opcode
        frame(1) = 128 + opcode

        ! Masked bit + payload length (assume <126 bytes)
        frame(2) = len_msg + 128

        ! Random mask key
        do i = 1, 4
            call random_number(r)
            mask(i) = int(r*255)
            frame(2+i) = mask(i)
        end do

        ! Mask and append payload
        do i = 1, len_msg
            idx = mod(i-1,4) + 1
            msg_byte = iachar(message(i:i))
            frame(6+i) = ieor(msg_byte, mask(idx))
        end do

        frame_len = 6 + len_msg
    end subroutine


    ! Decode a WebSocket frame
    subroutine decode_frame(frame, frame_len, message, opcode)
        integer, intent(in) :: frame(:)
        integer, intent(in) :: frame_len
        character(len=*), intent(out) :: message
        integer, intent(out) :: opcode
        integer :: payload_len, i
        integer :: byte, start_idx
        logical :: masked
        integer :: mask(4)

        opcode = iand(frame(1), 15)

        masked = btest(frame(2), 7)
        payload_len = iand(frame(2), 127)

        if (payload_len > len(message)) then
            print *, "Payload too large for buffer!"
            message = ""
            return
        end if

        if (masked) then
            mask = frame(3:6)
            start_idx = 7
            do i = 1, payload_len
                byte = ieor(frame(start_idx+i-1), mask(mod(i-1,4)+1))
                message(i:i) = achar(byte)
            end do
        else
            start_idx = 3
            do i = 1, payload_len
                byte = frame(start_idx+i-1)
                message(i:i) = achar(byte)
            end do
        end if

        if (payload_len < len(message)) message(payload_len+1:) = ' '
    end subroutine

end module