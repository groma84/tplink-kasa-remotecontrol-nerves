defmodule TextDisplay do
  use GenServer

  require Logger

  @me __MODULE__

  # CLIENT
  def start_link(_) do
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
    {:ok, %{first_line: "", second_line: "", third_line: "", font: nil,
    prev_first_line: "", prev_second_line: "", prev_third_line: ""}}
  end

  @impl true
  def handle_info(:load_font, state) do
    {:ok, font} = Chisel.Font.load("/var/cu12.bdf")
    Logger.info("TextDisplay: font loaded")
    {:noreply, %{state | font: font}}
  end

  @impl true
  def handle_cast( {:writeFirstLine, text}, state) do
    new_state = %{ state | prev_first_line: state.first_line, first_line: text }
    write(new_state)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast( {:writeSecondLine, text}, state) do
    new_state = %{ state | prev_second_line: state.second_line, second_line: text }
    write(new_state)
    {:noreply, new_state}
  end

  @impl true
  def handle_cast( {:writeThirdLine, text}, state) do
    new_state = %{ state | prev_third_line: state.third_line, third_line: text }
    write(new_state)
    {:noreply, new_state}
  end

  defp write(%{font: font, first_line: first_line, second_line: second_line, third_line: third_line,
  prev_first_line: prev_first_line, prev_second_line: prev_second_line, prev_third_line: prev_third_line}) do
    font_config = [size_x: 1, size_y: 1]

    first_line_changed = first_line != prev_first_line
    second_line_changed = second_line != prev_second_line
    third_line_changed = third_line != prev_third_line
    text_changed = first_line_changed || second_line_changed || third_line_changed

    if (text_changed) do
      Display.clear()

      {_, _} = Chisel.Renderer.draw_text(first_line, 0, 0, font, &put_pixel/2, font_config)
      {_, _} = Chisel.Renderer.draw_text(second_line, 0, 16, font, &put_pixel/2, font_config)
      {_, _} = Chisel.Renderer.draw_text(third_line, 0, 32, font, &put_pixel/2, font_config)

      Display.display()
    end
  end

  defp put_pixel(x, y) do
    Display.put_pixel(x, y)
  end
end
