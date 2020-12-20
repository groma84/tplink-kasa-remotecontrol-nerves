defmodule UltrasonicDistance do
  use GenServer

  require Logger

  alias Circuits.GPIO

  @me __MODULE__
  @trigger_pin Application.get_env(:hello_nerves, :ultrasonic_trigger_pin, 18)
  @echo_pin Application.get_env(:hello_nerves, :ultrasonic_echo_pin, 24)

  # CLIENT
  def start_link(_) do
    GenServer.start_link(@me, :noargs, name: @me)
  end

  # SERVER
  @impl true
  def init(_) do
    {:ok, trigger_gpio} = GPIO.open(@trigger_pin, :output)
    {:ok, echo_gpio} = GPIO.open(@echo_pin, :input)

    GPIO.set_interrupts(echo_gpio, :both)

    # schedule_start_signal()

    {:ok, %{trigger_gpio: trigger_gpio, echo_gpio: echo_gpio}}
  end

  @impl true
  def handle_info(:start_signal, %{trigger_gpio: trigger_gpio} = state) do
    start_signal(trigger_gpio)

    # Process.send_after(self(), :stop_signal, 1)

    {:noreply, state}
  end

  @impl true
  def handle_info(:stop_signal, %{trigger_gpio: trigger_gpio} = state) do
    stop_signal(trigger_gpio)
    sent_at = DateTime.utc_now()

    # schedule_start_signal()
    {:noreply, Map.put(state, :sent_at, sent_at)}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, _timestamp, 0}, state) do
    Logger.info("Received 0 from echo pin")

    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, _timestamp, 1}, %{sent_at: sent_at} = state) do
    received_at = DateTime.utc_now()
    time_diff = Time.diff(received_at, sent_at, :millisecond)

    Logger.info("Received echo with time_diff in ms #{time_diff}")

    {:noreply, state}
  end


  def ss() do
    Process.send_after(self(), :start_signal, 200)
  end

  def so() do
    Process.send_after(self(), :stop_signal, 200)
  end

  defp schedule_start_signal() do
    Process.send_after(self(), :start_signal, 200)
  end

  defp start_signal(trigger_gpio) do
    GPIO.write(trigger_gpio, 1)
  end

  defp stop_signal(trigger_gpio) do
    GPIO.write(trigger_gpio, 0)
  end
end
