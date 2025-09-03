module ws_frame
    implicit none
contains

    subroutine encode_frame(message, frame, frame_len)
        character(len=*), intent(in) :: message
        integer, intent(out) :: frame(:)       ! use default integer
        integer, intent(out) :: frame_len
        integer :: len_msg, i, idx
        integer :: mask(4)
        integer :: msg_byte
        real :: r

        call random_seed()
        len_msg = len_trim(message)
        frame_len = 6 + len_msg  ! 2 header + 4 mask + payload

        ! Generate 4 random bytes for mask
        do i = 1,4
            call random_number(r)
            mask(i) = int(r*255)
        end do

        ! FIN + text opcode
        frame(1) = 129

        ! Mask bit set + payload length (messages < 126 bytes)
        frame(2) = len_msg + 128  ! 0x80 mask bit

        ! Put mask in frame
        do i = 1,4
            frame(2+i) = mask(i)
        end do

        ! Mask and append payload
        do i = 1,len_msg
            idx = mod(i-1,4) + 1
            msg_byte = iachar(message(i:i))
            frame(6+i) = ieor(msg_byte, mask(idx))
        end do
    end subroutine

    subroutine decode_frame(frame, frame_len, message)
        integer, intent(in) :: frame(:)
        integer, intent(in) :: frame_len
        character(len=*), intent(out) :: message
        integer :: payload_len, i, idx
        integer :: mask(4)
        integer :: byte

        ! Only handle masked payload <126 bytes
        payload_len = iand(frame(2), 127)  ! remove mask bit
        mask = frame(3:6)

        ! Decode payload
        do i = 1,payload_len
            idx = mod(i-1,4) + 1
            byte = ieor(frame(6+i), mask(idx))
            message(i:i) = achar(byte)
        end do
    end subroutine

end module
