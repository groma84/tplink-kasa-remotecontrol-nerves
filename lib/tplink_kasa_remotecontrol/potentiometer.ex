defmodule Potentiometer do
  use GenServer

  require Logger

  @me __MODULE__
  @min_value 0
  @max_value 250
  @change_threshold 10

  # CLIENT
  def start_link(_) do
    GenServer.start_link(@me, :noargs, name: @me)
  end

  # SERVER
  @impl true
  def init(_) do
    schedule_read()
    {:ok, %{last_value: nil}}
  end

  @impl true
  def handle_info(:read, %{last_value: last_value} = state) do
    value = Spi.read(:channel0)

    new_value = if (last_value == nil || abs(last_value - value) > @change_threshold) do
      middle = (@max_value - @min_value) / 2

      if value < middle do
        LedOnOff.switch_off(:second)
      else
        LedOnOff.switch_on(:second)
      end

      TextDisplay.writeThirdLine("Poti val : #{value}")

      value
    else
      last_value
    end

    schedule_read()
    {:noreply, %{state | last_value: new_value}}
  end

  defp schedule_read() do
    Process.send_after(self(), :read, 1_000)
  end
end
