import Config

config :unique_ids_encyclopedia_ex,
  epoch_ms: 1_420_070_400_000

import_config "#{config_env()}.exs"
