defmodule Spi do
  use GenServer

  require Logger

  @me __MODULE__
  # {:ok, ref} = Circuits.SPI.open("spidev0.0")
  # https://www.binaryhexconverter.com/binary-to-hex-converter
  # Ch0 = {:ok, <<_::size(6), counts::size(10)>>} = Circuits.SPI.transfer(ref, <<0x40, 0x00>>)

  # CLIENT
  def start_link(_) do
    GenServer.start_link(@me, :noargs, name: @me)
  end

  def read(channel) do
    GenServer.call(@me, {:read, channel})
  end

  # SERVER
  @impl true
  def init(_) do
    {:ok, ref} = Circuits.SPI.open("spidev0.0")
    {:ok, %{ref: ref}}
  end

  @impl true
  def handle_call({:read, channel}, _from, %{ref: ref} = state) do
    read_value = case channel do
      :channel0 ->
       {:ok, <<_::size(6), counts::size(10)>>} = Circuits.SPI.transfer(ref, <<0x40, 0x00>>)
       counts

   end

   {:reply, read_value, state}
  end
end
