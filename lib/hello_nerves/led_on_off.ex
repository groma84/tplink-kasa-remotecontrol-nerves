defmodule LedOnOff do
  use GenServer

  require Logger

  alias Circuits.GPIO

  @me __MODULE__
  @led_control_output_pin Application.get_env(:hello_nerves, :led_control_output_pin, 17)

  # CLIENT
  def start_link(_) do
    GenServer.start_link(@me, :noargs, name: @me)
  end

  def toggle() do
    GenServer.call(@me, :toggle)
  end

  # SERVER
  @impl true
  def init(_) do
    {:ok, output_gpio} = GPIO.open(@led_control_output_pin, :output)

    {:ok, %{pin: output_gpio, ledOn: false}}
  end

  @impl true
  def handle_call(:toggle, _from, state) do
    if state.ledOn do
      off(state.pin)
    else
      on(state.pin)
    end

    {:reply, %{}, %{pin: state.pin, ledOn: !state.ledOn}}
  end

  defp on(gpio) do
    Logger.info("Writing 1 to gpio pin #{@led_control_output_pin}")
    GPIO.write(gpio, 1)
  end

  defp off(gpio) do
    Logger.info("Writing 0 to pin #{@led_control_output_pin}")
    GPIO.write(gpio, 0)
  end
end
