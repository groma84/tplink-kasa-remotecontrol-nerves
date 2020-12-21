defmodule UltrasonicSensor do
  use GenServer

  require Logger

  @me __MODULE__
  @trigger_pin Application.get_env(:tplink_kasa_remotecontrol, :ultrasonic_trigger_pin, 16)
  @echo_pin Application.get_env(:tplink_kasa_remotecontrol, :ultrasonic_echo_pin, 26)

  # CLIENT
  def start_link(_) do
    GenServer.start_link(@me, :noargs, name: @me)
  end

  # SERVER
  @impl true
  def init(_) do
    {:ok, pid} = UltrasonicSensorInternal.start_link({@echo_pin, @trigger_pin})

    #define SUCCESS 0
#define ERROR_INIT_GPIO -1
#define TIMEOUT_PING -2
#define TIMEOUT_PONG -3
#define ERROR_GPIO_PIN -4

    schedule_start_signal()

    {:ok, %{pid: pid}}
  end

  @impl true
  def handle_info(:start_signal, %{pid: pid} = state) do
    :ok = UltrasonicSensorInternal.update(pid)

    Process.send_after(self(), :stop_signal, 1000)

    {:noreply, state}
  end

  @impl true
  def handle_info(:stop_signal, %{pid: pid} = state) do
    {:ok, distance} = UltrasonicSensorInternal.info(pid)

    Logger.info("Received distance '#{distance}'")

    schedule_start_signal()
    {:noreply, state}
  end

  defp schedule_start_signal() do
    Process.send_after(self(), :start_signal, 1000)
  end
end
