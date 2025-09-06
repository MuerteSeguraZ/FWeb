# Makefile for Fortran WebSocket client

FC = gfortran
CC = gcc
CFLAGS = -c
FFLAGS = -c
TARGET = fortran_ws

# Object files
OBJS = sockets.o ws_frame.o ws_handshake.o ws_client.o csockets.o

all: $(TARGET)

# Compile C helper
csockets.o: csockets.c
	$(CC) $(CFLAGS) csockets.c -o csockets.o

# Compile Fortran modules
sockets.o: sockets.f90
	$(FC) $(FFLAGS) sockets.f90

ws_frame.o: ws_frame.f90
	$(FC) $(FFLAGS) ws_frame.f90

ws_handshake.o: ws_handshake.f90
	$(FC) $(FFLAGS) ws_handshake.f90

ws_client.o: ws_client.f90
	$(FC) $(FFLAGS) ws_client.f90

# Link everything
$(TARGET): main.f90 $(OBJS)
	$(FC) main.f90 $(OBJS) -lws2_32 -o $(TARGET)

clean:
	del /Q *.o $(TARGET).exe

new:
	del /Q *.o $(TARGET).exe
	make