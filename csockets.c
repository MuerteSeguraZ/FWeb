#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <winsock2.h>
#include <ws2tcpip.h>

#pragma comment(lib, "ws2_32.lib") // Not needed for MinGW GCC, but Visual Studio uses it

int connect_tcp(const char *host, int port) {
    WSADATA wsa;
    SOCKET sockfd;
    struct addrinfo hints, *res;
    char port_str[10];

    if (WSAStartup(MAKEWORD(2,2), &wsa) != 0) {
        printf("WSAStartup failed\n");
        return -1;
    }

    snprintf(port_str, sizeof(port_str), "%d", port);

    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if (getaddrinfo(host, port_str, &hints, &res) != 0) {
        printf("getaddrinfo failed\n");
        return -1;
    }

    sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    if (sockfd == INVALID_SOCKET) { printf("socket failed\n"); return -1; }

    if (connect(sockfd, res->ai_addr, (int)res->ai_addrlen) == SOCKET_ERROR) {
        printf("connect failed\n"); closesocket(sockfd); return -1;
    }

    freeaddrinfo(res);
    return (int)sockfd;
}

int send_tcp(int sock, const char *buf, int len) {
    return send((SOCKET)sock, buf, len, 0);
}

int recv_tcp(int sock, char *buf, int len) {
    int n = recv((SOCKET)sock, buf, len-1, 0);
    if (n >= 0) buf[n] = '\0';
    return n;
}

int close_tcp(int sock) {
    int res = closesocket((SOCKET)sock);
    WSACleanup();
    return res;
}
