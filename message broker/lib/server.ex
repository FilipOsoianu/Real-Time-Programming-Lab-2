defmodule KVServer do
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, packet: :line, active: false]
      )
    IO.inspect(socket)
    IO.puts("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client) end)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    
    {:ok, data} = :gen_tcp.recv(socket, 0)
    IO.inspect(data)
    msg_data = Jason.decode!(data)
    IO.inspect(msg_data)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

  # def handle_info({:tcp_closed,socket},state) do
  #   IO.inspect "Socket has been closed"
  #   {:noreply,state}
  # end

  # def handle_info({:tcp_error,socket,reason},state) do
  #   IO.inspect socket,label: "connection closed dut to #{reason}"
  #   {:noreply,state}
  # end
  
end
