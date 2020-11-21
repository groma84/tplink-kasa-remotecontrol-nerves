defmodule LedOnOff do
  require Logger

  alias Circuits.GPIO

  def on(pin) do
    Logger.info("Writing 1 to pin #{pin}")

    {:ok, output_gpio} = GPIO.open(pin, :output)

    GPIO.write(output_gpio, 1)

    GPIO.close(output_gpio)
  end

  def off(pin) do
    Logger.info("Writing 0 to pin #{pin}")

    {:ok, output_gpio} = GPIO.open(pin, :output)

    GPIO.write(output_gpio, 0)

    GPIO.close(output_gpio)
  end
end
