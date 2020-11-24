defmodule TextDisplay do
  use GenServer

  require Logger

  @me __MODULE__

  # CLIENT
  def start_link(_) do
    Logger.info("start_link")

    GenServer.start_link(@me, :noargs, name: @me)
  end

  def write(text) do
    GenServer.cast(@me, {:write, text})
  end

  # SERVER
  @impl true
  def init(_) do
    self() |> send(:load_font)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:load_font, _) do
    {:ok, font} = Chisel.Font.load("/var/cu12.bdf")
    Logger.info("TextDisplay: font loaded")
    {:noreply, %{font: font}}
  end

  @impl true
  def handle_cast( {:write, text}, state) do
    Logger.info("Drawing text '#{text}'")

    Display.clear()
    {_, _} = Chisel.Renderer.draw_text(text, 0, 0, state.font, &put_pixel/2)
    Display.display()

    Logger.info("'#{text}' drawn")

    {:noreply, state}
  end

  defp put_pixel(x, y) do
    Display.put_pixel(x, y)
  end
end
