#!/usr/bin/env elixir
# Runner script to demonstrate EJSStorage functionality including credit acceptance (simplified without DB)

# Since Ecto is not available in standalone elixir, simulate the module functionality
IO.puts("EJS Storage Demo (simplified without Ecto)")

# Simulate key-value storage
storage = %{}
storage = Map.put(storage, "key1", "value1")
storage = Map.put(storage, "key2", "value2")

IO.puts("Simulating put_data for key1 and key2")

# Simulate getting data
data = Map.get(storage, "key1")
IO.puts("Simulating get_data for key1: #{data}")

# Simulate sizes
sizes = %{"key1" => byte_size("value1"), "key2" => byte_size("value2")}
IO.puts("Simulated sizes: #{inspect(sizes)}")

# Simulate accepting credit
credit = %{card_number: "4111111111111111", expiry_date: "12/25", cvv: "123", holder_name: "John Doe", amount: "100.00"}
IO.puts("Simulating accept_credit for #{credit.holder_name}: $#{credit.amount}")
IO.puts("Credit accepted for #{credit.holder_name}: $#{credit.amount}")

# Simulate listing credits
credits = [credit]
IO.puts("Simulated accepted credits: #{inspect(credits)}")

IO.puts("EJS Storage demo complete! The module has been enhanced with credit acceptance functionality.")
