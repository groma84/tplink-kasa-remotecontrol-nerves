defmodule LedOnOff do
  use GenServer

  require Logger

  alias Circuits.GPIO

  @me __MODULE__
  @led_control_output_pin Application.get_env(:hello_nerves, :led_control_output_pin, 17)
  @second_led_control_output_pin Application.get_env(:hello_nerves, :second_led_control_output_pin, 23)

  # CLIENT
  def start_link(_) do
    GenServer.start_link(@me, :noargs, name: @me)
  end

  def toggle(led) do
    GenServer.call(@me, {:toggle, led})
  end

  # SERVER
  @impl true
  def init(_) do
    {:ok, output_gpio} = GPIO.open(@led_control_output_pin, :output)
    {:ok, output_gpio_2} = GPIO.open(@second_led_control_output_pin, :output)

    self() |> send(:init_text_first)
    self() |> send(:init_text_second)

    {:ok, %{pin: output_gpio, pin2: output_gpio_2, ledOn: false, led2On: false}}
  end


  @impl true
  def handle_info(:init_text_first, state) do
    if state.ledOn do
      writeLedOn(:first)
    else
      writeLedOff(:first)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(:init_text_second, state) do
    if state.led2On do
      writeLedOn(:second)
    else
      writeLedOff(:second)
    end

    {:noreply, state}
  end

  @impl true
  def handle_call({:toggle, :first}, _from, state) do
    if state.ledOn do
      off(state.pin)
      writeLedOff(:first)
    else
      on(state.pin)
      writeLedOn(:first)
    end

    {:reply, %{}, %{state | ledOn: !state.ledOn}}
  end

  @impl true
  def handle_call({:toggle, :second}, _from, state) do
    if state.led2On do
      off(state.pin2)
      writeLedOff(:second)
    else
      on(state.pin2)
      writeLedOn(:second)
    end

    {:reply, %{}, %{state | led2On: !state.ledOn}}
  end

  defp on(gpio) do
    GPIO.write(gpio, 1)
  end

  defp off(gpio) do
    GPIO.write(gpio, 0)
  end

  defp writeLedOn(:first), do: TextDisplay.writeFirstLine("LED 1 on")
  defp writeLedOn(:second), do: TextDisplay.writeSecondLine("LED 2 on")
  defp writeLedOff(:first), do: TextDisplay.writeFirstLine("LED 1 off")
  defp writeLedOff(:second), do: TextDisplay.writeSecondLine("LED 2 off")
end
