defmodule Button do
  require Logger

  use GenServer

  alias Circuits.GPIO

  @button_input_pin Application.get_env(:hello_nerves, :button_input_pin, 27)

  # CLIENT
  def start_link(_) do
    GenServer.start_link(__MODULE__, :noargs)
  end

  # SERVER
  @impl true
  def init(_) do
    Logger.info("init Button")

    {:ok, input_gpio} = GPIO.open(@button_input_pin, :input)

    self() |> send(:subscribe_to_changes)

    {:ok, %{pin: input_gpio}}
  end

  @impl true
  def handle_info(:subscribe_to_changes, %{pin: pin} = state) do
    Logger.info("Registering interrupts")
    GPIO.set_interrupts(pin, :both)
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, _timestamp, 0}, state), do: {:noreply, state}

  @impl true
  def handle_info({:circuits_gpio, _pin, _timestamp, 1}, state) do
    Logger.info("Received 1 from button")

    LedOnOff.toggle()

    {:noreply, state}
  end
end
