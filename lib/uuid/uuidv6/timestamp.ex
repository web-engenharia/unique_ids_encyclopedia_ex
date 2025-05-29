defmodule Uuid.UuidV6.Timestamp do
  @moduledoc false

  # Segundos gregorianos na época do UUID: 1582-10-15 00:00:00Z
  @gregorian_epoch_seconds :calendar.datetime_to_gregorian_seconds({{1582, 10, 15}, {0, 0, 0}})

  # Gera um timestamp de 60 bits representando o número de intervalos
  # de 100 nanossegundos desde a época gregoriana.
  def generate_100ns_timestamp do
    {current_seconds, current_microseconds} = DateTime.to_gregorian_seconds(DateTime.utc_now())

    seconds_since_epoch = current_seconds - @gregorian_epoch_seconds
    seconds_since_epoch * 10_000_000 + current_microseconds * 10
  end

  # Divide o timestamp de 60 bits nas três partes necessárias para o UUIDv6.
  def split_timestamp(timestamp_100ns) do
    time_high = Bitwise.bsr(timestamp_100ns, 28)
    time_mid = Bitwise.band(Bitwise.bsr(timestamp_100ns, 12), 0xFFFF)
    time_low = Bitwise.band(timestamp_100ns, 0xFFF)

    {time_high, time_mid, time_low}
  end
end
