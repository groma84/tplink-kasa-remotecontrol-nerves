defmodule TextDisplay do
  use GenServer

  require Logger

  @me __MODULE__

  # CLIENT
  def start_link(_) do
    Logger.info("start_link")

    GenServer.start_link(@me, :noargs, name: @me)
  end

  def writeFirstLine(text) do
    GenServer.cast(@me, {:writeFirstLine, text})
  end

  def writeSecondLine(text) do
    GenServer.cast(@me, {:writeSecondLine, text})
  end

  def writeThirdLine(text) do
    GenServer.cast(@me, {:writeThirdLine, text})
  end

  # SERVER
  @impl true
  def init(_) do
    self() |> send(:load_font)
    {:ok, %{first_line: "", second_line: "", third_line: "", font: nil}}
  end

  @impl true
  def handle_info(:load_font, state) do
    {:ok, font} = Chisel.Font.load("/var/cu12.bdf")
    Logger.info("TextDisplay: font loaded")
    {:noreply, %{state | font: font}}
  end

  @impl true
  def handle_cast( {:writeFirstLine, text}, state) do
    new_state = %{ state | first_line: text }
    write(state.font, text, state.second_line, state.third_line)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast( {:writeSecondLine, text}, state) do
    new_state = %{ state | second_line: text }
    write(state.font, state.first_line, text, state.third_line)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast( {:writeSecondThirdLine, text}, state) do
    new_state = %{ state | third_line: text }
    write(state.font, state.first_line, state.second_line, text)
    {:noreply, new_state}
  end

  defp write(font, first_line, second_line, third_line) do
    Display.clear()
    {_, _} = Chisel.Renderer.draw_text(first_line, 0, 0, font, &put_pixel/2)
    {_, _} = Chisel.Renderer.draw_text(second_line, 0, 24, font, &put_pixel/2)
    {_, _} = Chisel.Renderer.draw_text(third_line, 0, 48, font, &put_pixel/2)
    Display.display()
  end

  defp put_pixel(x, y) do
    Display.put_pixel(x, y)
  end
end
